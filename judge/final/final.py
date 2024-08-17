#=# oj.resources.kernel_bin = http://127.0.0.1:18003/nscscc/la/kernel/kernel.bin
#=# oj.resources.user_bin = artifacts:///asm/user-sample.bin
#=# oj.run_time.max = 30000

from TestcaseBase import *
import random
import traceback
import enum
import time
import struct
import binascii
import base64
import os
from timeit import default_timer as timer

datasize = 0x300000

class Testcase(TestcaseBase):
    class State(enum.Enum):
        WaitBoot = enum.auto()
        RunA = enum.auto()
        RunD = enum.auto()
        RunG = enum.auto()
        WaitG = enum.auto()
        Verify = enum.auto()
        Done = enum.auto()

    bootMessage = b'MONITOR for Loongarch32 - initialized.'
    recvBuf = b''
    
    @staticmethod
    def int2bytes(val):
        return struct.pack('<I', val)

    @staticmethod
    def bytes2int(val):
        return struct.unpack('<I', val)[0]

    def check(self):
        arr = struct.unpack('<'+'I'*int(datasize/4), ExtRAM[:datasize:False])
        ans = max(arr)
        r = struct.unpack('<I', ExtRAM[datasize:datasize+4:False])[0]
        if ans != r:
            self.log(f'ERROR! answer:0x{ans:08x}, your result:0x{r:08x}')
            return
        self.log("Data memory content verified")
        self.state = self.State.Done
            
    def endTest(self):
        if self.state == self.State.WaitBoot:
            score = 0
        elif self.state == self.State.RunD:
            score = 0.3
        elif self.state in [self.State.RunG, self.State.WaitG]:
            score = 0.5
        elif self.state == self.State.Verify:
            score = 0.7
        elif self.state == self.State.Done:
            score = 1

        self.finish(score)
        return True

    def stateChange(self, received: bytes):
        addr = 0x80100000
        if self.state == self.State.WaitBoot:
            bootMsgLen = len(self.bootMessage)
            self.log(f"Boot message: {str(self.recvBuf)[1:]}")
            if received != self.bootMessage:
                self.log('ERROR: incorrect message')
                return self.endTest()
            elif len(self.recvBuf) > bootMsgLen:
                self.log('WARNING: extra bytes received')
            self.recvBuf = b''

            self.state = self.State.RunA
            for i in range(0, len(self.testbin), 4):
                Serial << b'A'
                Serial << self.int2bytes(addr+i)
                Serial << self.int2bytes(4)
                Serial << self.testbin[i:i+4]
            self.log("User program written")

            self.state = self.State.RunD
            self.expectedLen = len(self.testbin)
            Serial << b'D'
            Serial << self.int2bytes(addr)
            Serial << self.int2bytes(len(self.testbin))

        elif self.state == self.State.RunD:
            self.log(f"  Program Readback:\n  {binascii.hexlify(self.recvBuf).decode('ascii')}")
            if received != self.testbin:
                self.log('ERROR: corrupted user program')
                return self.endTest()
            elif len(self.recvBuf) > len(self.testbin):
                self.log('WARNING: extra bytes received')
            self.recvBuf = b''
            self.log("Program memory content verified")

            self.state = self.State.RunG
            Serial << b'G'
            Serial << self.int2bytes(addr)
            self.expectedLen = 1

        elif self.state == self.State.RunG:
            if received == b'\x80':
                self.log('ERROR: exception occurred')
                return self.endTest()
            elif received != b'\x06':
                self.log('ERROR: start mark should be 0x06')
                return self.endTest()
            self.recvBuf = self.recvBuf[1:]
            self.time_start = timer()
            self.state = self.State.WaitG
            self.expectedLen = 1

        elif self.state == self.State.WaitG:
            self.recvBuf = self.recvBuf[1:]
            if received == b'\x80':
                self.log('ERROR: exception occurred')
                return self.endTest()
            elif received == b'\x07':
                elapsed = timer() - self.time_start
                self.log(f'Elapsed time: {elapsed:.3f}s')
                self.state = self.State.Verify
                self.check()
                return self.endTest()
            else:
                self.log(f"ERROR: Invalid byte 0x{received[0]:x} received")
                return self.endTest()

    @Serial # On receiving from serial port
    def recv(self, dataBytes):
        self.recvBuf += dataBytes
        while len(self.recvBuf) >= self.expectedLen:
            end = self.stateChange(self.recvBuf[:self.expectedLen])
            if end:
                break

    @Timer
    def timeout(self):
        self.log(f"ERROR: timeout during {self.state.name}")
        self.endTest()

    @started
    def initialize(self):
        self.state = self.State.WaitBoot
        self.expectedLen = len(self.bootMessage)
        self.testbin = base64.b64decode(RESOURCES['user_bin'])
        self.testdata = bytes(random.getrandbits(8) for _ in range(datasize))
        DIP << 0
        +Reset
        BaseRAM[:] = base64.b64decode(RESOURCES['kernel_bin'])
        ExtRAM[:] = self.testdata
        Serial.open(1, baud=9600) # NSCSCC
        # Serial.open(0, baud=9600) # THU
        -Reset
        Timer.oneshot(20000) # timeout in 10 seconds
# Supervisor kernel.elf at: http://grs.nscscc.com:18003/nscscc/la/kernel/kernel.elf
#=# oj.resources.kernel_bin = http://127.0.0.1:18003/nscscc/la/kernel/kernel.bin
#=# oj.run_time.max = 40000

from TestcaseBase import *
import random
import traceback
import enum
import time
import struct
import binascii
import base64
from timeit import default_timer as timer

class Testcase(TestcaseBase):
    class State(enum.Enum):
        WaitBoot = enum.auto()
        RunA = enum.auto()
        RunD = enum.auto()
        RunG = enum.auto()
        WaitG = enum.auto()
        RunR = enum.auto()
        RunD2 = enum.auto()
        Done = enum.auto()

    bootMessage = b'MONITOR for Loongarch32 - initialized.'
    recvBuf = b''

    @staticmethod
    def int2bytes(val):
        return struct.pack('<I', val)

    @staticmethod
    def bytes2int(val):
        return struct.unpack('<I', val)[0]

    def endTest(self):
        if self.state == self.State.WaitBoot:
            score = 0
        elif self.state == self.State.RunD:
            score = 0.3
        elif self.state in [self.State.RunG, self.State.WaitG]:
            score = 0.5
        elif self.state == self.State.RunR:
            score = 0.7
        elif self.state == self.State.RunD2:
            score = 0.8
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
            for i in range(0, len(USER_PROGRAM), 4):
                Serial << b'A'
                Serial << self.int2bytes(addr+i)
                Serial << self.int2bytes(4)
                Serial << USER_PROGRAM[i:i+4]
            self.log("User program written")

            self.state = self.State.RunD
            self.expectedLen = len(USER_PROGRAM)
            Serial << b'D'
            Serial << self.int2bytes(addr)
            Serial << self.int2bytes(len(USER_PROGRAM))

        elif self.state == self.State.RunD:
            self.log(f"  Program Readback:\n  {binascii.hexlify(self.recvBuf).decode('ascii')}")
            if received != USER_PROGRAM:
                self.log('ERROR: corrupted user program')
                return self.endTest()
            elif len(self.recvBuf) > len(USER_PROGRAM):
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
                self.log(f'Program elapsed time: {elapsed:.3f}s')

                self.state = self.State.RunR
                self.recvBuf = b''
                self.expectedLen = 31*4
                Serial << b'R'

        elif self.state == self.State.RunR:
            regList = [self.bytes2int(received[i:i+4])
                       for i in range(0, 31*4, 4)]
            self.log('\n'.join([f"  R{i+1} = {regList[i]:08x}"
                                for i in range(31)]))
            for pair in REG_VERIFICATION:
                if regList[pair[0]-1] != pair[1]:
                    self.log(f"ERROR: R{pair[0]} should equal {pair[1]:08x}")
                    return self.endTest()
            self.recvBuf = b''
            self.log("Register value verified")

            self.state = self.State.RunD2
            self.expectedLen = len(MEM_VERIFICATION)
            Serial << b'D'
            Serial << self.int2bytes(0x80400000)
            Serial << self.int2bytes(len(MEM_VERIFICATION))

        elif self.state == self.State.RunD2:
            self.log(f"  Data Readback:\n  {binascii.hexlify(self.recvBuf).decode('ascii')}")
            if received != MEM_VERIFICATION:
                self.log('ERROR: data memory content mismatch')
                return self.endTest()
            elif len(self.recvBuf) > len(MEM_VERIFICATION):
                self.log('WARNING: extra bytes received')
            self.recvBuf = b''
            self.log("Data memory content verified")

            self.state = self.State.Done
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
        DIP << 0
        +Reset
        BaseRAM[:] = base64.b64decode(RESOURCES['kernel_bin'])
        Serial.open(1, baud=9600) # NSCSCC
        # Serial.open(0, baud=9600) # THU
        -Reset
        Timer.oneshot(20000) # timeout in 20 seconds

USER_PROGRAM = binascii.unhexlify( # in Little-Endian
    # ###### User Program Assembly ######
    # __start:
    '0C048002' # addi.w      $t0,$zero,0x1   # t0 = 1
    '0D048002' # addi.w      $t1,$zero,0x1   # t1 = 1
    '04800015' # lu12i.w     $a0,-0x7fc00    # a0 = 0x80400000
    '85808002' # addi.w      $a1,$a0,0x20    # a1 = 0x80400020

    # loop:
    '8E351000' # add.w       $t2,$t0,$t1     # t2 = t0+t1
    'AC018002' # addi.w      $t0,$t1,0x0     # t0 = t1
    'CD018002' # addi.w      $t1,$t2,0x0     # t1 = t2
    '8E008029' # st.w        $t2,$a0,0x0
    '84108002' # addi.w      $a0,$a0,0x4     # a0 += 4
    '85ECFF5F' # bne         $a0,$a1,loop
    '2000004C' # jirl        $zero,$ra,0x0
)
REG_VERIFICATION = [(4, 0x80400020), (5, 0x80400020), (12, 0x22), (13, 0x37), (14, 0x37)]
MEM_VERIFICATION = binascii.unhexlify(
    '020000000300000005000000080000000d000000150000002200000037000000')

import struct
from TestcaseBase import *
import binascii
import os
import time

class Testcase(TestcaseBase):

    def onStart(self):
        +Reset  # Press reset button
        # init memory using random data
        BaseRAM[:] = MEM_RAND_INIT
        ExtRAM[:] = MEM_RAND_INIT
        # load test program at 0x00000000
        BaseRAM[::True] = TEST_PROGRAM
        -Reset
        # wait for test program running
        time.sleep(1)
        # read result
        result = ExtRAM[:0x100:False]
        # self.log(binascii.hexlify(result).decode('ascii'))
        # self.log(binascii.hexlify(MEM_ANSWER).decode('ascii'))

        fib_correct = struct.unpack('<'+'I'*64, MEM_ANSWER)
        fib_result = struct.unpack('<'+'I'*64, result)

        # compare result
        addr = errors = 0
        for ret, ans in zip(fib_result, fib_correct):
            if ret != ans:
                self.log(f'ExtRAM[0x{addr:03x}] should be 0x{ans:08x}, get 0x{ret:08x}')
                errors += 1
            addr += 4

        if errors == 0:
            self.log('Test pass')
            self.score = 1
        else:
            self.log('Test not pass')
            self.score = 0

        # end test
        self.finish(self.score)
        return True


# compiled test program
TEST_PROGRAM = binascii.unhexlify(
    '0C0480020D04800204800015850084028E351000AC018002CD0180028E008029'
    '8F008028CF0D005C8410800285E4FF5F8000005C'
)

# random data for ram init
MEM_RAND_INIT = os.urandom(4096)

# correct answer in ram
MEM_ANSWER = binascii.unhexlify(
    '020000000300000005000000080000000d000000150000002200000037000000'
    '5900000090000000e90000007901000062020000db0300003d060000180a0000'
    '551000006d1a0000c22a00002f450000f16f000020b500001125010031da0100'
    '42ff020073d90400b5d8070028b20c00dd8a1400053d2100e2c73500e7045700'
    'c9cc8c00b0d1e300799e700129705402a20ec503cb7e19066d8dde09380cf80f'
    'a599d619dda5ce29823fa5435fe5736de12419b1400a8d1e212fa6cf613933ee'
    '8268d9bde3a10cac650ae66948acf215adb6d87ff562cb95a219a415977c6fab'
    '399613c1d012836c09a9962dd9bb199ae264b0c7bb20ca619d857a2958a6448b'
)

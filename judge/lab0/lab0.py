from TestcaseBase import *

class Testcase(TestcaseBase):

    def onStart(self):
        score = 0

        for i in range(16):
            res = 1<<i
            DIP << res
            if int(LED) != res:
                self.log('Test not pass')
                self.finish(score)
                return True
                
        score = 1
        self.log('Test pass')
        self.finish(score)
        return True

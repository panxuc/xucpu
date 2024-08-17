    .global _start
    .section text
_start:
.text
    addi.w      $t0,$zero,0x1   # t0 = 1
    addi.w      $t1,$zero,0x1   # t1 = 1
    lu12i.w     $a0,-0x7fc00    # a0 = 0x80400000
    addi.w      $a1,$a0,0x20    # a1 = 0x80400020
loop:
    add.w       $t2,$t0,$t1     # t2 = t0+t1
    addi.w      $t0,$t1,0x0     # t0 = t1
    addi.w      $t1,$t2,0x0     # t1 = t2
    st.w        $t2,$a0,0x0
    addi.w      $a0,$a0,0x4     # a0 += 4
    bne         $a0,$a1,loop

    jirl        $zero,$ra,0x0

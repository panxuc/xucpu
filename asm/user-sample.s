    .global _start
    .section text
_start:
.text
    lu12i.w $a0,    -0x7fc00            # a0 = 0x80400000
    lu12i.w $a1,    0x300               # a1 = 0x300000
    add.w   $a1,    $a0,        $a1     # a1 = a0+a1 = 0x80700000
    addi.w  $a1,    $a1,        -0x4    # a1 = a1-4 = 0x806ffffc
loop:
    ld.w    $t0,    $a0,        0x0     # t0 = *a0
    ld.w    $t1,    $a0,        0x4     # t1 = *(a0+4)
    addi.w  $a0,    $a0,        0x4     # a0 += 4
    bltu    $t0,    $t1,        else
    st.w    $t0,    $a0,        0x0     # *a0 = t0
else:
    bne     $a0,    $a1,        loop

    ld.w    $t2,    $a1,        0x0     # t2 = *a1
    st.w    $t2,    $a1,        0x4     # *(a1+4) = t2
    jirl    $zero,  $ra,        0x0

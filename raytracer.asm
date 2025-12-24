; feliz natal pra todos ai
section .data
    w equ 1200
    h equ 900

    hdr db "p6", 10, "1200 900", 10, "255", 10
    hdr_len equ $ - hdr

    ; sfer natalina kkk
    s_x: dq 0.0
    s_y: dq 0.5
    s_z: dq -6.0
    s_r: dq 1.5

    ; chao
    p_y: dq -2.0

    ; luz
    l_x: dq -4.0
    l_y: dq 6.0
    l_z: dq -3.0

    ; consts
    c0: dq 0.0
    c1: dq 1.0
    c2: dq 2.0
    c4: dq 4.0
    cn1: dq -1.0
    ch: dq 0.5
    casp: dq 1.333333
    c255: dq 255.0
    ceps: dq 0.001
    camb: dq 0.2

section .bss
    alignb 64
    img_buf: resb w*h*3

section .text
    global _start

_start:
    call rndr_scn

    mov rax, 1
    mov rdi, 1
    mov rsi, hdr
    mov rdx, hdr_len
    syscall ; bota o hdr

    mov rax, 1
    mov rdi, 1
    mov rsi, img_buf
    mov rdx, w*h*3
    syscall ; joga os px kkk

    mov rax, 60
    xor rdi, rdi
    syscall ; vlw flw

rndr_scn:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    xor r12, r12
    lea r15, [rel img_buf]

.lp_y:
    cmp r12, h
    jge .fin
    xor r13, r13

.lp_x:
    cmp r13, w
    jge .nxt_y

    ; dir do raio kkk
    cvtsi2sd xmm0, r13
    movsd xmm1, [rel ch]
    mov rax, w
    cvtsi2sd xmm2, rax
    mulsd xmm2, xmm1
    subsd xmm0, xmm2
    cvtsi2sd xmm3, rax
    divsd xmm0, xmm3
    mulsd xmm0, [rel casp]

    cvtsi2sd xmm1, r12
    movsd xmm2, [rel ch]
    mov rax, h
    cvtsi2sd xmm3, rax
    mulsd xmm3, xmm2
    subsd xmm1, xmm3
    cvtsi2sd xmm3, rax
    divsd xmm1, xmm3
    xorpd xmm4, xmm4
    subsd xmm4, xmm1
    movsd xmm1, xmm4

    movsd xmm2, [rel cn1]

    ; norm kkk
    movsd xmm3, xmm0
    mulsd xmm3, xmm0
    movsd xmm4, xmm1
    mulsd xmm4, xmm1
    movsd xmm5, xmm2
    mulsd xmm5, xmm2
    addsd xmm3, xmm4
    addsd xmm3, xmm5
    sqrtsd xmm3, xmm3
    divsd xmm0, xmm3
    divsd xmm1, xmm3
    divsd xmm2, xmm3

    call trc_ry

    ; clmp
    xorpd xmm3, xmm3
    maxsd xmm0, xmm3
    maxsd xmm1, xmm3
    maxsd xmm2, xmm3

    movsd xmm3, [rel c255]
    minsd xmm0, xmm3
    minsd xmm1, xmm3
    minsd xmm2, xmm3

    cvttsd2si rax, xmm0
    mov byte [r15], al
    inc r15

    cvttsd2si rax, xmm1
    mov byte [r15], al
    inc r15

    cvttsd2si rax, xmm2
    mov byte [r15], al
    inc r15

    inc r13
    jmp .lp_x

.nxt_y:
    inc r12
    jmp .lp_y

.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

trc_ry:
    push rbp
    mov rbp, rsp
    sub rsp, 128

    movsd [rbp-8], xmm0
    movsd [rbp-16], xmm1
    movsd [rbp-24], xmm2

    ; hit sfer?
    movsd xmm3, [rel s_x]
    xorpd xmm4, xmm4
    subsd xmm4, xmm3

    movsd xmm3, [rel s_y]
    xorpd xmm5, xmm5
    subsd xmm5, xmm3

    movsd xmm3, [rel s_z]
    xorpd xmm6, xmm6
    subsd xmm6, xmm3

    ; b kkk
    movsd xmm7, xmm4
    mulsd xmm7, xmm0
    movsd xmm8, xmm5
    mulsd xmm8, xmm1
    addsd xmm7, xmm8
    movsd xmm8, xmm6
    mulsd xmm8, xmm2
    addsd xmm7, xmm8
    addsd xmm7, xmm7

    ; c
    movsd xmm8, xmm4
    mulsd xmm8, xmm4
    movsd xmm9, xmm5
    mulsd xmm9, xmm5
    addsd xmm8, xmm9
    movsd xmm9, xmm6
    mulsd xmm9, xmm6
    addsd xmm8, xmm9
    movsd xmm9, [rel s_r]
    mulsd xmm9, xmm9
    subsd xmm8, xmm9

    ; dsc kkk bhaskara sdd
    movsd xmm9, xmm7
    mulsd xmm9, xmm7
    movsd xmm10, xmm8
    addsd xmm10, xmm10
    addsd xmm10, xmm10
    subsd xmm9, xmm10

    xorpd xmm10, xmm10
    ucomisd xmm9, xmm10
    jb .chk_p

    sqrtsd xmm9, xmm9
    xorpd xmm10, xmm10
    subsd xmm10, xmm7
    subsd xmm10, xmm9
    movsd xmm11, [rel c2]
    divsd xmm10, xmm11

    movsd xmm11, [rel ceps]
    ucomisd xmm10, xmm11
    jbe .chk_p

    movsd [rbp-32], xmm10 ; t_s

    ; pln
    movsd xmm0, [rbp-16]
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .ht_s

    movsd xmm2, [rel p_y]
    divsd xmm2, xmm0
    xorpd xmm3, xmm3
    subsd xmm3, xmm2

    movsd xmm4, [rel ceps]
    ucomisd xmm3, xmm4
    jbe .ht_s

    ucomisd xmm3, xmm10
    jae .ht_s

    movsd [rbp-40], xmm3 ; t_p
    jmp .ht_p

.chk_p:
    movsd xmm0, [rbp-16]
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .bg

    movsd xmm2, [rel p_y]
    divsd xmm2, xmm0
    xorpd xmm3, xmm3
    subsd xmm3, xmm2

    movsd xmm4, [rel ceps]
    ucomisd xmm3, xmm4
    jbe .bg

    movsd [rbp-40], xmm3
    jmp .ht_p

.ht_s:
    movsd xmm10, [rbp-32]
    movsd xmm0, [rbp-8]
    movsd xmm1, [rbp-16]
    movsd xmm2, [rbp-24]
    mulsd xmm0, xmm10
    mulsd xmm1, xmm10
    mulsd xmm2, xmm10

    movsd [rbp-48], xmm0
    movsd [rbp-56], xmm1
    movsd [rbp-64], xmm2

    ; nrm kkk fsc hard
    subsd xmm0, [rel s_x]
    subsd xmm1, [rel s_y]
    subsd xmm2, [rel s_z]

    movsd xmm3, xmm0
    mulsd xmm3, xmm0
    movsd xmm4, xmm1
    mulsd xmm4, xmm1
    movsd xmm5, xmm2
    mulsd xmm5, xmm2
    addsd xmm3, xmm4
    addsd xmm3, xmm5
    sqrtsd xmm3, xmm3
    divsd xmm0, xmm3
    divsd xmm1, xmm3
    divsd xmm2, xmm3

    movsd [rbp-72], xmm0
    movsd [rbp-80], xmm1
    movsd [rbp-88], xmm2

    ; lgt
    movsd xmm3, [rel l_x]
    subsd xmm3, [rbp-48]
    movsd xmm4, [rel l_y]
    subsd xmm4, [rbp-56]
    movsd xmm5, [rel l_z]
    subsd xmm5, [rbp-64]

    movsd xmm6, xmm3
    mulsd xmm6, xmm3
    movsd xmm7, xmm4
    mulsd xmm7, xmm4
    movsd xmm8, xmm5
    mulsd xmm8, xmm5
    addsd xmm6, xmm7
    addsd xmm6, xmm8
    sqrtsd xmm6, xmm6
    divsd xmm3, xmm6
    divsd xmm4, xmm6
    divsd xmm5, xmm6

    mulsd xmm3, xmm0
    mulsd xmm4, xmm1
    mulsd xmm5, xmm2
    addsd xmm3, xmm4
    addsd xmm3, xmm5

    xorpd xmm4, xmm4
    maxsd xmm3, xmm4

    ; red natal kkk
    movsd xmm4, [rel camb]
    addsd xmm3, xmm4
    movsd xmm0, [rel c255]
    mulsd xmm0, xmm3
    movsd xmm1, xmm0
    movsd xmm4, [rel c4]
    divsd xmm1, xmm4
    movsd xmm2, xmm1
    jmp .end

.ht_p:
    movsd xmm10, [rbp-40]
    movsd xmm0, [rbp-8]
    movsd xmm1, [rbp-16]
    movsd xmm2, [rbp-24]
    mulsd xmm0, xmm10
    mulsd xmm1, xmm10
    mulsd xmm2, xmm10

    movsd [rbp-48], xmm0
    movsd [rbp-56], xmm1
    movsd [rbp-64], xmm2

    ; refl kkk
    movsd xmm0, [rbp-8]
    movsd xmm1, [rbp-16]
    xorpd xmm3, xmm3
    subsd xmm3, xmm1
    movsd xmm1, xmm3
    movsd xmm2, [rbp-24]

    movsd xmm3, [rbp-48]
    movsd xmm4, [rbp-56]
    movsd xmm5, [rbp-64]
    movsd xmm6, [rel ceps]
    addsd xmm4, xmm6

    movsd xmm7, [rel s_x]
    subsd xmm7, xmm3
    movsd xmm8, [rel s_y]
    subsd xmm8, xmm4
    movsd xmm9, [rel s_z]
    subsd xmm9, xmm5

    movsd xmm10, xmm7
    mulsd xmm10, xmm0
    movsd xmm11, xmm8
    mulsd xmm11, xmm1
    addsd xmm10, xmm11
    movsd xmm11, xmm9
    mulsd xmm11, xmm2
    addsd xmm10, xmm11
    addsd xmm10, xmm10

    movsd xmm11, xmm7
    mulsd xmm11, xmm7
    movsd xmm12, xmm8
    mulsd xmm12, xmm8
    addsd xmm11, xmm12
    movsd xmm12, xmm9
    mulsd xmm12, xmm9
    addsd xmm11, xmm12
    movsd xmm12, [rel s_r]
    mulsd xmm12, xmm12
    subsd xmm11, xmm12

    movsd xmm12, xmm10
    mulsd xmm12, xmm10
    movsd xmm13, xmm11
    addsd xmm13, xmm13
    addsd xmm13, xmm13
    subsd xmm12, xmm13

    xorpd xmm13, xmm13
    ucomisd xmm12, xmm13
    jb .p_no_refl

    movsd xmm0, [rel c255]
    movsd xmm3, [rel c2]
    divsd xmm0, xmm3
    movsd xmm1, xmm0
    divsd xmm1, xmm3
    divsd xmm1, xmm3
    movsd xmm2, xmm1
    jmp .end

.p_no_refl:
    movsd xmm0, [rel c255]
    movsd xmm3, [rel c4]
    divsd xmm0, xmm3
    movsd xmm1, xmm0
    movsd xmm4, [rel c2]
    addsd xmm1, xmm0
    divsd xmm1, xmm4
    movsd xmm2, xmm1
    jmp .end

.bg:
    ; sky kkk
    movsd xmm0, [rbp-16]
    addsd xmm0, [rel c1]
    mulsd xmm0, [rel ch]
    movsd xmm1, [rel c1]
    subsd xmm1, xmm0
    mulsd xmm1, [rel c255]
    movsd xmm3, [rel c4]
    divsd xmm1, xmm3
    movsd xmm0, xmm1
    addsd xmm1, xmm1
    divsd xmm1, [rel c2]
    movsd xmm2, xmm1
    addsd xmm2, xmm2

.end:
    add rsp, 128
    pop rbp
    ret

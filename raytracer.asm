section .data
    width equ 1200
    height equ 900

    ppm_header db "P6", 10, "1200 900", 10, "255", 10
    ppm_header_len equ $ - ppm_header


    sphere_x: dq 0.0
    sphere_y: dq 0.5
    sphere_z: dq -6.0
    sphere_r: dq 1.5


    plane_y: dq -2.0


    light_x: dq -4.0
    light_y: dq 6.0
    light_z: dq -3.0


    const_0: dq 0.0
    const_1: dq 1.0
    const_2: dq 2.0
    const_4: dq 4.0
    const_neg1: dq -1.0
    const_half: dq 0.5
    const_aspect: dq 1.333333
    const_255: dq 255.0
    const_epsilon: dq 0.001
    const_ambient: dq 0.2

section .bss
    alignb 64
    image_buffer: resb width*height*3

section .text
    global _start

_start:
    call render_scene

    mov rax, 1
    mov rdi, 1
    mov rsi, ppm_header
    mov rdx, ppm_header_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, image_buffer
    mov rdx, width*height*3
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

render_scene:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    xor r12, r12
    lea r15, [rel image_buffer]

.loop_y:
    cmp r12, height
    jge .done
    xor r13, r13

.loop_x:
    cmp r13, width
    jge .next_y


    cvtsi2sd xmm0, r13
    movsd xmm1, [rel const_half]
    mov rax, width
    cvtsi2sd xmm2, rax
    mulsd xmm2, xmm1
    subsd xmm0, xmm2
    cvtsi2sd xmm3, rax
    divsd xmm0, xmm3
    mulsd xmm0, [rel const_aspect]

    cvtsi2sd xmm1, r12
    movsd xmm2, [rel const_half]
    mov rax, height
    cvtsi2sd xmm3, rax
    mulsd xmm3, xmm2
    subsd xmm1, xmm3
    cvtsi2sd xmm3, rax
    divsd xmm1, xmm3
    xorpd xmm4, xmm4
    subsd xmm4, xmm1
    movsd xmm1, xmm4

    movsd xmm2, [rel const_neg1]

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


    call trace_ray


    xorpd xmm3, xmm3
    maxsd xmm0, xmm3
    maxsd xmm1, xmm3
    maxsd xmm2, xmm3

    movsd xmm3, [rel const_255]
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
    jmp .loop_x

.next_y:
    inc r12
    jmp .loop_y

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


trace_ray:
    push rbp
    mov rbp, rsp
    sub rsp, 128

    movsd [rbp-8], xmm0
    movsd [rbp-16], xmm1
    movsd [rbp-24], xmm2


    movsd xmm3, [rel sphere_x]
    xorpd xmm4, xmm4
    subsd xmm4, xmm3

    movsd xmm3, [rel sphere_y]
    xorpd xmm5, xmm5
    subsd xmm5, xmm3

    movsd xmm3, [rel sphere_z]
    xorpd xmm6, xmm6
    subsd xmm6, xmm3


    movsd xmm7, xmm4
    mulsd xmm7, xmm0
    movsd xmm8, xmm5
    mulsd xmm8, xmm1
    addsd xmm7, xmm8
    movsd xmm8, xmm6
    mulsd xmm8, xmm2
    addsd xmm7, xmm8
    addsd xmm7, xmm7


    movsd xmm8, xmm4
    mulsd xmm8, xmm4
    movsd xmm9, xmm5
    mulsd xmm9, xmm5
    addsd xmm8, xmm9
    movsd xmm9, xmm6
    mulsd xmm9, xmm6
    addsd xmm8, xmm9
    movsd xmm9, [rel sphere_r]
    mulsd xmm9, xmm9
    subsd xmm8, xmm9


    movsd xmm9, xmm7
    mulsd xmm9, xmm7
    movsd xmm10, xmm8
    addsd xmm10, xmm10
    addsd xmm10, xmm10
    subsd xmm9, xmm10

    xorpd xmm10, xmm10
    ucomisd xmm9, xmm10
    jb .check_plane


    sqrtsd xmm9, xmm9
    xorpd xmm10, xmm10
    subsd xmm10, xmm7
    subsd xmm10, xmm9
    movsd xmm11, [rel const_2]
    divsd xmm10, xmm11

    movsd xmm11, [rel const_epsilon]
    ucomisd xmm10, xmm11
    jbe .check_plane

    movsd [rbp-32], xmm10


    movsd xmm0, [rbp-16]
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .hit_sphere


    movsd xmm2, [rel plane_y]
    divsd xmm2, xmm0
    xorpd xmm3, xmm3
    subsd xmm3, xmm2

    movsd xmm4, [rel const_epsilon]
    ucomisd xmm3, xmm4
    jbe .hit_sphere


    ucomisd xmm3, xmm10
    jae .hit_sphere
    movsd [rbp-40], xmm3
    jmp .hit_plane

.check_plane:

    movsd xmm0, [rbp-16]
    xorpd xmm1, xmm1
    ucomisd xmm0, xmm1
    jae .background

    movsd xmm2, [rel plane_y]
    divsd xmm2, xmm0
    xorpd xmm3, xmm3
    subsd xmm3, xmm2

    movsd xmm4, [rel const_epsilon]
    ucomisd xmm3, xmm4
    jbe .background

    movsd [rbp-40], xmm3
    jmp .hit_plane

.hit_sphere:

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


    subsd xmm0, [rel sphere_x]
    subsd xmm1, [rel sphere_y]
    subsd xmm2, [rel sphere_z]

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


    movsd xmm3, [rel light_x]
    subsd xmm3, [rbp-48]
    movsd xmm4, [rel light_y]
    subsd xmm4, [rbp-56]
    movsd xmm5, [rel light_z]
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


    movsd xmm4, [rel const_ambient]
    addsd xmm3, xmm4

    movsd xmm0, [rel const_255]
    mulsd xmm0, xmm3

    movsd xmm1, xmm0
    movsd xmm4, [rel const_4]
    divsd xmm1, xmm4

    movsd xmm2, xmm1

    jmp .end

.hit_plane:

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

    ; pq q eu to escrevendo isso
    movsd xmm0, [rbp-8]
    movsd xmm1, [rbp-16]
    xorpd xmm3, xmm3
    subsd xmm3, xmm1
    movsd xmm1, xmm3
    movsd xmm2, [rbp-24]


    movsd xmm3, [rbp-48]
    movsd xmm4, [rbp-56]
    movsd xmm5, [rbp-64]
    movsd xmm6, [rel const_epsilon]
    addsd xmm4, xmm6

    ; teste
    movsd xmm7, [rel sphere_x]
    subsd xmm7, xmm3
    movsd xmm8, [rel sphere_y]
    subsd xmm8, xmm4
    movsd xmm9, [rel sphere_z]
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
    movsd xmm12, [rel sphere_r]
    mulsd xmm12, xmm12
    subsd xmm11, xmm12

    ; disc
    movsd xmm12, xmm10
    mulsd xmm12, xmm10
    movsd xmm13, xmm11
    addsd xmm13, xmm13
    addsd xmm13, xmm13
    subsd xmm12, xmm13

    xorpd xmm13, xmm13
    ucomisd xmm12, xmm13
    jb .plane_no_reflect

    ; reflexo
    movsd xmm0, [rel const_255]
    movsd xmm3, [rel const_2]
    divsd xmm0, xmm3

    movsd xmm1, xmm0
    divsd xmm1, xmm3
    divsd xmm1, xmm3

    movsd xmm2, xmm1

    jmp .end

.plane_no_reflect:
    ; chao
    movsd xmm0, [rel const_255]
    movsd xmm3, [rel const_4]
    divsd xmm0, xmm3
    movsd xmm1, xmm0
    movsd xmm4, [rel const_2]
    addsd xmm1, xmm0
    divsd xmm1, xmm4
    movsd xmm2, xmm1

    jmp .end

.background:
    ; ceu
    movsd xmm0, [rbp-16]
    addsd xmm0, [rel const_1]
    mulsd xmm0, [rel const_half]

    movsd xmm1, [rel const_1]
    subsd xmm1, xmm0
    mulsd xmm1, [rel const_255]
    movsd xmm3, [rel const_4]
    divsd xmm1, xmm3

    movsd xmm0, xmm1
    addsd xmm1, xmm1
    divsd xmm1, [rel const_2]

    movsd xmm2, xmm1
    addsd xmm2, xmm2

.end:
    add rsp, 128
    pop rbp
    ret

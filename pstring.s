.section .rodata

   format_print_error:.string "invalid input!\n"
.section .text

.global pstrlen
.type   pstrlen,@function

#return length of pstring
pstrlen:
    movzbq  (%rdi),     %rax #movzbl
    ret


.global replaceChar
.type   replaceChar,@function

#return pointer to pstring after changing char
replaceChar:

    #save old frame
    push    %rbp
    movq    %rsp,       %rbp

    push    %rbx             #callee save
    push    %r13
    push    %r12

    leaq    (%rdi),     %rbx #new pointer to pstring
    call    pstrlen    #get strlen
    movq    %rax,       %r13 #save strlen

    leaq    1(%rbx),    %rbx # start of str
    movq    $1,         %r12 #initialize i=0

.L5: #for loop
    cmpq    %r13,       %r12 #for condition r12<r13=len
    jg     .L8 #exit loop

.L6: #if
    cmpb    (%rbx),     %sil #problem here
    jne     .L7 #else+inc
    movb    %dl,        (%rbx) #change to new char

.L7: #increas i
    leaq    1(%rbx),    %rbx
    addq    $1,         %r12
    jmp     .L5

.L8: #END LOOP

    movq    %rdi,       %rax
    movq    -8(%rbp),   %rbx
    popq    %r12
    popq    %r13
    popq    %rbx
    movq    %rbp,       %rsp
    popq    %rbp
    ret

.global pstrijcpy
.type   pstrijcpy,@function

#return pointer to pstring after changing substring from other pstring
pstrijcpy:
    push    %r8
    push    %r9
    push    %rsi
    push    %rdi

    #save values

    leaq    (%rdi),     %r13    #new pointer to dest- iterator
    leaq    (%rsi),     %r14    #new pointer to src- iterator

    #check bounds for dest
    cmpb    %cl,        %dl     #i>j
    jg      .L9
    cmpb    $0,         %dl     #i<0
    jl      .L9
    call    pstrlen             #get dest.len
    cmpq    %rcx,       %rax    #dest.len<j
    jl      .L9                 #printError
    incq    %r13

    #check bounds for src
    push    %rcx
    movq    %rsi,       %rdi
    call    pstrlen             #src.len
    popq    %rcx
    cmpq    %rcx,       %rax    #src.len<j
    jle      .L9                #printError
    incq    %r14

    movq    $0,         %r12

.L11:#loop
    cmpq    %r12,       %rcx
    jl      .L12                #after loop
    cmpb    %r12b,      %dl
    jne     .L13
    movb    (%r14),     %r15b
    movb    %r15b,      (%r13)
    incq    %rdx

.L13: #add to r12
    incq    %r12
    incq    %r14
    incq    %r13
    jmp     .L11

.L12: #after loop
    pop     %rdi
    pop     %rsi
    movq    %rdi,       %rax
    jmp     .L10

.L9: #PRINT ERROR
    movq    $format_print_error,%rdi
    movq    $0,         %rax
    call    printf
    xorq    %rax,       %rax
    popq     %rdi
    popq     %rsi

.L10:
    popq     %r9
    popq     %r8
    ret


.global swapCase
.type   swapCase,@function
#swap lowercase<->uppercase
    swapCase:
    movq    %rdi,       %rbx
    call    pstrlen
    movq    %rax,       %r12    #r12=strln
    movq    $0,         %r15    #i=0
    incq    %rbx

.L16:   #loop
    cmpq    %r15,       %r12    #r13<r12
    je      .L17                #exit loop

    #check if bigger case
    cmpb    $90,        (%rbx)  #rbx<=90
    jg      .L14
    cmpb    $65,        (%rbx)  #rbx>=65
    jl     .L15

    addq    $32,        (%rbx)  #change to lower
    jmp     .L15

.L14: #check if lower case
    cmpb    $97,        (%rbx)  #rbx>=97
    jl      .L15
    cmpb    $122,       (%rbx)  #rbx<=122
    jge     .L15

    subq    $32,        (%rbx) #change to upper
    jmp     .L15

.L15: #add
    add     $1,         %r15
    incq    %rbx
    jmp     .L16

.L17: # exit loop
    movq    %rdi,       %rax
    ret


.global pstrijcmp
.type   pstrijcmp,@function

#return pointer to pstring after changing substring from other pstring
pstrijcmp:

    leaq    (%rdi),     %r13    #new pointer to dest- iterator
    leaq    (%rsi),     %r14    #new pointer to src- iterator

    #check bounds for first
    cmpb    %cl,        %dl     #i>j
    jg      .L20
    cmpb    $0,         %dl     #i<0
    jl      .L20
    call    pstrlen             #get first.len
    cmpq    %rcx,       %rax    #first.len<j
    jl      .L20                #fix
    incq    %r13

    #check bounds for second
    push    %rcx
    movq    %rsi,       %rdi
    call    pstrlen             #second.len
    popq    %rcx
    cmpq    %rcx,       %rax    #second.len<j
    jl      .L20                #printError

    incq    %r14
    movq    $0,         %r12
    movq    $0,         %rax
    movq    $0,         %r15

.L21:#loop
    cmpq    %rcx,       %r12
    jg      .L22                #after loop
    cmpq    %r12,       %rdx    #fix
    jne     .L26
    #incq    %rdx
    movb    (%r13),     %r15b
    cmpb    %r15b,      (%r14)
    jg      .L23                #r13>r14
    jl      .L24                #r13<r14
    je      .L25                #r13=r14
.L26: #add to r12
    incq    %r12
    incq    %r14
    incq    %r13
    jmp     .L21

.L23:#first greater
    movq    $-1,        %rax
    jmp     .L22

.L24: # second greater
    movq    $1,         %rax
    jmp     .L22

.L25: # equals
    incq    %r14
    incq    %r13
    incl    %r12d
    incq    %rdx
    jmp     .L21

.L20: #PRINT ERROR
    movq    $format_print_error,%rdi
    movq    $0,         %rax
    call    printf
    movq    $-2,        %rax

.L22:

    ret
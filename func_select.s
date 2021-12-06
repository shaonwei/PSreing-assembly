.section .rodata

    format_case1:   .string "first pstring length: %d, second pstring length: %d\n"
    format_case2:   .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    format_case34:  .string "length: %d, string: %s\n"
    format_case5:   .string "compare result: %d\n"
    format_default: .string "invalid option!\n"

    scanf_char:     .string " %c"
    scanf_int:      .string "%d"
    scanf_string:   .string "%s"

    .align 16

.L62: #jump table
    .quad   .case1 #x=50/601
    .quad   .cased #x=51
    .quad   .case2 #x=52
    .quad   .case3 #x=53
    .quad   .case4 #x=54
    .quad   .case5 #x=55
    .quad   .cased #x=default

    .section .text

    .global func_run
    .type   func_run,@function

    func_run:
        push    %rbp
        movq    %rsp,       %rbp
        subq    $32,        %rsp


        leaq    -50(%rdx),  %rdx
        cmpq    $10,        %rdx
        je      .case1
        cmpq    $5,         %rdx
        jg      .cased
        cmpq    $0,         %rdx
        jl      .cased
        jmp     *.L62(,%rdx,8)

    .case1: #pstrlen

        #str1
        call    pstrlen
        movq    %rax,       %r12 # srt1 len
        #str2
        movq    %rsi,       %rdi
        call    pstrlen
        movq    %rax,       %r13 # srt2 len

        #print:

        movq    $format_case1,%rdi
        movq    %r12,       %rsi
        movq    %r13,       %rdx
        movq    $0,         %rax
        call    printf

        jmp .L58 #out of switch

    .case2: #replaceChar

        #save pstrings
        leaq    (%rdi),     %r12
        leaq    (%rsi),     %r13

        #scanf old char
        movq    $scanf_char,%rdi
        leaq    -32(%rbp),  %rsi
        movq    $0,         %rax
        call    scanf

        xor     %r14,       %r14
        movq    -32(%rbp),  %r14
        movzbq  %r14b,      %r14

        #scanf new char
        movq    $scanf_char,%rdi
        leaq    -16(%rbp),  %rsi
        movq    $0,         %rax
        call    scanf
        movq    $0,         %r15
        movq    -16(%rbp),  %r15

        #call replaceChar for pstring 1
        leaq    (%r12),     %rdi
        leaq    (%r14),     %rsi #old
        movq    %r15,       %rdx #new
        movzbq  %sil,       %rsi
        movzbq  %dl,        %rdx

        call    replaceChar
        movq    %rax,       %r12

        #call replaceChar for pstring 2
        leaq    (%r13),     %rdi
        movq    %r14,       %rsi #old
        movq    %r15,       %rdx #new
        call    replaceChar
        movq    %rax,       %r13

        #print
        movq    $format_case2,%rdi
        movq    %r14,       %rsi #old
        movq    %r15,       %rdx #new
        leaq    (%r12),     %rcx
        leaq    1(%rcx),    %rcx
        leaq    (%r13),     %r8
        leaq    1(%r8),     %r8
        movq    $0,         %rax
        call    printf

        jmp     .L58 #out of switch

    .case3:

    /*
        push    %r12
        push    %r13
        push    %r14
        push    %r15
        push    %rbx
        */

       leaq    (%rdi),     %r12    #new pointer to dest
       leaq    (%rsi),     %r13    #new pointer to src

       #scanf i
       movq    $scanf_int, %rdi
       leaq   -32(%rbp),   %rsi
       movq    $0,         %rax
       call    scanf
       movl    -32(%rbp),  %r14d #i

       #scanf j
       movq    $scanf_int, %rdi
       leaq   -16(%rbp),   %rsi
       movq    $0,         %rax
       call    scanf
       movl    -16(%rbp),  %r15d

       ##call pstrijcpy
       leaq    (%r12),     %rdi     #dest
       leaq    (%r13),     %rsi     #src
       movq    %r14,       %rdx
       movq    %r15,       %rcx

       leaq    (%rdi),     %r8
       leaq    (%rsi),     %r9
       call    pstrijcpy

       leaq    (%r8),     %rdi    #dest
       leaq    (%r8),     %r12 #

       #prep for print
       call    pstrlen #get strlen
       movq    %rax,       %rbx #save strlen
       pushq   %r8
       pushq   %r9
       #print
       movq    $format_case34,%rdi
       movq    %rbx,       %rsi
       leaq    (%r12),     %rdx
       leaq    1(%rdx),    %rdx
       movq    $0,         %rax
       call    printf
       popq    %r9
       popq    %r8
       leaq    (%r9),      %rsi
       movq    %rsi,       %rdi
       call    pstrlen #get strlen
       movq    %rax,       %rbx #save strlen
       leaq    1(%rdi),     %rdx
       movq    $format_case34,%rdi
       movq    %rbx,       %rsi
       movq    $0,         %rax
       call    printf
        #restore values
        /*popq    %rbx
        popq    %r15
        popq    %r14
        popq    %r13
        popq    %r12*/
        ####
       jmp     .L58 #out of switch

    .case4:

      #save pointers
        leaq    (%rdi),     %r12
        leaq    (%rsi),     %r13
        #swap first pstr
        call    swapCase

        #print first pstr
        movq    %rax,        %rdx
        incq    %rdx
        call    pstrlen     #get strlen
        movq    %rax,        %rsi
        movq    $format_case34, %rdi
        movq    $0,          %rax
        call    printf

        movq    %r13,        %rdi

        call    swapCase

        #print second pstr
        movq    %rax,        %rdx
        incq    %rdx
        call    pstrlen      #get strlen
        movq    %rax,        %rsi
        movq    $format_case34,%rdi
        movq    $0,          %rax
        call    printf

        jmp     .L58 #out of switch

    .case5:

        leaq    (%rdi),     %r12    #new pointer to dest
        leaq    (%rsi),     %r13    #new pointer to src

        #scanf i
        movq    $scanf_int, %rdi
        leaq   -32(%rbp),   %rsi
        movq    $0,         %rax
        call    scanf
        movl    -32(%rbp),  %r14d #i

        #scanf j
        movq    $scanf_int, %rdi
        leaq   -16(%rbp),   %rsi
        movq    $0,         %rax
        call    scanf
        movl    -16(%rbp),  %r15d #j

        ##call pstrijcmp
        leaq    (%r12),     %rdi     #dest
        leaq    (%r13),     %rsi     #src
        movq    %r14,       %rdx
        movq    %r15,       %rcx

        call    pstrijcmp

        movq    $format_case5,%rdi
        movq    %rax,       %rsi
        movq    $0,         %rax
        call    printf
        jmp     .L58            #out of switch

    .cased:
        movq    $format_default,%rdi
        movq    $0,         %rax
        call    printf
        jmp     .L58 #out of switch

    .L58:
        movq    %rbp,       %rsp
        popq    %rbp
        xorq    %rax,       %rax
        ret
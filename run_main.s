.section .rodata
    format_int:     .string "%d"
    format_string:  .string "%s"
    format_outpot:  .string "%d"
    format_st:      .string "%s"

.section .text

.global run_main
.type   run_main,@function
run_main:
        movq    %rsp,       %rbp        #for correct debugging

        push    %rbp
        movq    %rsp,       %rbp
        subq    $528,       %rsp

        #scan 1 nun_1
        movq    $format_int,%rdi
        leaq    -528(%rbp), %rsi
        movq    $0,         %rax
        call    scanf

        #scan string_1
        movq    $format_string,%rdi
        leaq    -527(%rbp), %rsi
        movq    $0,         %rax
        call    scanf

        #scan 2 nun_2
        movq    $format_int,%rdi
        leaq    -272(%rbp), %rsi
        movq    $0,         %rax
        call scanf

        #scan string_2
        movq    $format_string,%rdi
        leaq    -271(%rbp), %rsi
        movq    $0,         %rax
        call    scanf

        #scan select
        movq    $format_int,%rdi
        leaq    -16(%rbp),  %rsi
        movq    $0,         %rax
        call    scanf

        movq    %rbp,       %rdi
        movq    $0,         %rdx
        movl    -16(%rbp),  %edx #option
        leaq    -272(%rbp), %rsi #pstr 2
        leaq    -528(%rbp), %rdi #pstr 1

        call    func_run
        movq    %rbp,       %rsp
        popq    %rbp

        xorq    %rax,       %rax
        ret
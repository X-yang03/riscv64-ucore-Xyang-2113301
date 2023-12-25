#include <mmu.h>
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop

    tail kern_init

.section .data         #;数据段
    # .align 2^12      
    .align PGSHIFT     #;内存页一页有4096bytes，因此要进行2的12次方的对齐
    .global bootstack
bootstack:
    .space KSTACKSIZE  #;留出两页，8KB大小的内存
    .global bootstacktop
bootstacktop:
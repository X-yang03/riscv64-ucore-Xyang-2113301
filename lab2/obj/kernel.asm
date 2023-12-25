
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	44a60613          	addi	a2,a2,1098 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	75e010ef          	jal	ra,ffffffffc02017ac <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	76a50513          	addi	a0,a0,1898 # ffffffffc02017c0 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	01a010ef          	jal	ra,ffffffffc0201084 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	1f4010ef          	jal	ra,ffffffffc020129e <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	1c0010ef          	jal	ra,ffffffffc020129e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	6d050513          	addi	a0,a0,1744 # ffffffffc0201810 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	6da50513          	addi	a0,a0,1754 # ffffffffc0201830 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	65c58593          	addi	a1,a1,1628 # ffffffffc02017be <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	6e650513          	addi	a0,a0,1766 # ffffffffc0201850 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	6f250513          	addi	a0,a0,1778 # ffffffffc0201870 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2fe58593          	addi	a1,a1,766 # ffffffffc0206488 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201890 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6e958593          	addi	a1,a1,1769 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	6f050513          	addi	a0,a0,1776 # ffffffffc02018b0 <etext+0xf2>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	61060613          	addi	a2,a2,1552 # ffffffffc02017e0 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	61c50513          	addi	a0,a0,1564 # ffffffffc02017f8 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	7d460613          	addi	a2,a2,2004 # ffffffffc02019c0 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	7ec58593          	addi	a1,a1,2028 # ffffffffc02019e0 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	7ec50513          	addi	a0,a0,2028 # ffffffffc02019e8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	7ee60613          	addi	a2,a2,2030 # ffffffffc02019f8 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	80e58593          	addi	a1,a1,-2034 # ffffffffc0201a20 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	7ce50513          	addi	a0,a0,1998 # ffffffffc02019e8 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0201a30 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	82258593          	addi	a1,a1,-2014 # ffffffffc0201a50 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	7b250513          	addi	a0,a0,1970 # ffffffffc02019e8 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	6b850513          	addi	a0,a0,1720 # ffffffffc0201928 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	6be50513          	addi	a0,a0,1726 # ffffffffc0201950 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	638c8c93          	addi	s9,s9,1592 # ffffffffc02018e0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	6c898993          	addi	s3,s3,1736 # ffffffffc0201978 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	6c890913          	addi	s2,s2,1736 # ffffffffc0201980 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	6c6b0b13          	addi	s6,s6,1734 # ffffffffc0201988 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	716a8a93          	addi	s5,s5,1814 # ffffffffc02019e0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	354010ef          	jal	ra,ffffffffc020162a <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	4a6010ef          	jal	ra,ffffffffc020178e <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	5e2d0d13          	addi	s10,s10,1506 # ffffffffc02018e0 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	458010ef          	jal	ra,ffffffffc0201764 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	444010ef          	jal	ra,ffffffffc0201764 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	408010ef          	jal	ra,ffffffffc020178e <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	60a50513          	addi	a0,a0,1546 # ffffffffc02019a8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	68250513          	addi	a0,a0,1666 # ffffffffc0201a60 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	4e450513          	addi	a0,a0,1252 # ffffffffc02018d8 <etext+0x11a>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	2e0010ef          	jal	ra,ffffffffc0201704 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	64e50513          	addi	a0,a0,1614 # ffffffffc0201a80 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	2b80106f          	j	ffffffffc0201704 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	2920106f          	j	ffffffffc02016e8 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	2c60106f          	j	ffffffffc0201720 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	71450513          	addi	a0,a0,1812 # ffffffffc0201b98 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	71c50513          	addi	a0,a0,1820 # ffffffffc0201bb0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	72650513          	addi	a0,a0,1830 # ffffffffc0201bc8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	73050513          	addi	a0,a0,1840 # ffffffffc0201be0 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	73a50513          	addi	a0,a0,1850 # ffffffffc0201bf8 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	74450513          	addi	a0,a0,1860 # ffffffffc0201c10 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	74e50513          	addi	a0,a0,1870 # ffffffffc0201c28 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	75850513          	addi	a0,a0,1880 # ffffffffc0201c40 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	76250513          	addi	a0,a0,1890 # ffffffffc0201c58 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	76c50513          	addi	a0,a0,1900 # ffffffffc0201c70 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	77650513          	addi	a0,a0,1910 # ffffffffc0201c88 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	78050513          	addi	a0,a0,1920 # ffffffffc0201ca0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	78a50513          	addi	a0,a0,1930 # ffffffffc0201cb8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	79450513          	addi	a0,a0,1940 # ffffffffc0201cd0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	79e50513          	addi	a0,a0,1950 # ffffffffc0201ce8 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	7a850513          	addi	a0,a0,1960 # ffffffffc0201d00 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	7b250513          	addi	a0,a0,1970 # ffffffffc0201d18 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201d30 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	7c650513          	addi	a0,a0,1990 # ffffffffc0201d48 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	7d050513          	addi	a0,a0,2000 # ffffffffc0201d60 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	7da50513          	addi	a0,a0,2010 # ffffffffc0201d78 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	7e450513          	addi	a0,a0,2020 # ffffffffc0201d90 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	7ee50513          	addi	a0,a0,2030 # ffffffffc0201da8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	7f850513          	addi	a0,a0,2040 # ffffffffc0201dc0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	80250513          	addi	a0,a0,-2046 # ffffffffc0201dd8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	80c50513          	addi	a0,a0,-2036 # ffffffffc0201df0 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	81650513          	addi	a0,a0,-2026 # ffffffffc0201e08 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	82050513          	addi	a0,a0,-2016 # ffffffffc0201e20 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	82a50513          	addi	a0,a0,-2006 # ffffffffc0201e38 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	83450513          	addi	a0,a0,-1996 # ffffffffc0201e50 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0201e68 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	84450513          	addi	a0,a0,-1980 # ffffffffc0201e80 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	84650513          	addi	a0,a0,-1978 # ffffffffc0201e98 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	84650513          	addi	a0,a0,-1978 # ffffffffc0201eb0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0201ec8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	85650513          	addi	a0,a0,-1962 # ffffffffc0201ee0 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201ef8 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	3e070713          	addi	a4,a4,992 # ffffffffc0201a9c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	46250513          	addi	a0,a0,1122 # ffffffffc0201b30 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	43650513          	addi	a0,a0,1078 # ffffffffc0201b10 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201ad0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	45e50513          	addi	a0,a0,1118 # ffffffffc0201b50 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	44e50513          	addi	a0,a0,1102 # ffffffffc0201b78 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	3ba50513          	addi	a0,a0,954 # ffffffffc0201af0 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	41c50513          	addi	a0,a0,1052 # ffffffffc0201b68 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <buddy_free_pages>:
    assert(n > 0);
ffffffffc0200846:	10058463          	beqz	a1,ffffffffc020094e <buddy_free_pages+0x108>
    if (!IS_POWER_OF_2(n))
ffffffffc020084a:	fff58793          	addi	a5,a1,-1
ffffffffc020084e:	8fed                	and	a5,a5,a1
ffffffffc0200850:	882e                	mv	a6,a1
ffffffffc0200852:	c395                	beqz	a5,ffffffffc0200876 <buddy_free_pages+0x30>
    while (tmp >>= 1)
ffffffffc0200854:	4015d81b          	sraiw	a6,a1,0x1
ffffffffc0200858:	0e080963          	beqz	a6,ffffffffc020094a <buddy_free_pages+0x104>
    int n = 0, tmp = size;
ffffffffc020085c:	4781                	li	a5,0
ffffffffc020085e:	a011                	j	ffffffffc0200862 <buddy_free_pages+0x1c>
        n++;
ffffffffc0200860:	87ba                	mv	a5,a4
    while (tmp >>= 1)
ffffffffc0200862:	40185813          	srai	a6,a6,0x1
        n++;
ffffffffc0200866:	0017871b          	addiw	a4,a5,1
    while (tmp >>= 1)
ffffffffc020086a:	fe081be3          	bnez	a6,ffffffffc0200860 <buddy_free_pages+0x1a>
ffffffffc020086e:	2789                	addiw	a5,a5,2
ffffffffc0200870:	4805                	li	a6,1
ffffffffc0200872:	00f8183b          	sllw	a6,a6,a5
    int offset = (base - buddy_manager.mem_tree);
ffffffffc0200876:	00006897          	auipc	a7,0x6
ffffffffc020087a:	bda88893          	addi	a7,a7,-1062 # ffffffffc0206450 <buddy_manager>
ffffffffc020087e:	0088b583          	ld	a1,8(a7)
ffffffffc0200882:	00002797          	auipc	a5,0x2
ffffffffc0200886:	87678793          	addi	a5,a5,-1930 # ffffffffc02020f8 <commands+0x818>
ffffffffc020088a:	639c                	ld	a5,0(a5)
ffffffffc020088c:	40b505b3          	sub	a1,a0,a1
ffffffffc0200890:	858d                	srai	a1,a1,0x3
ffffffffc0200892:	02f585b3          	mul	a1,a1,a5
    index = buddy_manager.total_size + offset - 1;
ffffffffc0200896:	0108a783          	lw	a5,16(a7)
    node_size = 1;
ffffffffc020089a:	4685                	li	a3,1
        if (index == 0)
ffffffffc020089c:	4605                	li	a2,1
    index = buddy_manager.total_size + offset - 1;
ffffffffc020089e:	37fd                	addiw	a5,a5,-1
ffffffffc02008a0:	9fad                	addw	a5,a5,a1
    while (node_size != n)
ffffffffc02008a2:	a811                	j	ffffffffc02008b6 <buddy_free_pages+0x70>
        index = PARENT(index);
ffffffffc02008a4:	37fd                	addiw	a5,a5,-1
ffffffffc02008a6:	0007871b          	sext.w	a4,a5
        node_size *= 2;
ffffffffc02008aa:	0016969b          	slliw	a3,a3,0x1
        index = PARENT(index);
ffffffffc02008ae:	0017d79b          	srliw	a5,a5,0x1
        if (index == 0)
ffffffffc02008b2:	08e67b63          	bleu	a4,a2,ffffffffc0200948 <buddy_free_pages+0x102>
    while (node_size != n)
ffffffffc02008b6:	02069713          	slli	a4,a3,0x20
ffffffffc02008ba:	9301                	srli	a4,a4,0x20
ffffffffc02008bc:	ff0714e3          	bne	a4,a6,ffffffffc02008a4 <buddy_free_pages+0x5e>
    buddy_manager.size[index] = node_size;
ffffffffc02008c0:	0008b303          	ld	t1,0(a7)
ffffffffc02008c4:	02079713          	slli	a4,a5,0x20
ffffffffc02008c8:	8379                	srli	a4,a4,0x1e
ffffffffc02008ca:	971a                	add	a4,a4,t1
ffffffffc02008cc:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc02008ce:	cba1                	beqz	a5,ffffffffc020091e <buddy_free_pages+0xd8>
        index = PARENT(index);
ffffffffc02008d0:	37fd                	addiw	a5,a5,-1
ffffffffc02008d2:	0017d51b          	srliw	a0,a5,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008d6:	ffe7f713          	andi	a4,a5,-2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008da:	0015061b          	addiw	a2,a0,1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008de:	2705                	addiw	a4,a4,1
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e0:	0016161b          	slliw	a2,a2,0x1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e4:	1702                	slli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008e6:	1602                	slli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008e8:	9301                	srli	a4,a4,0x20
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008ea:	9201                	srli	a2,a2,0x20
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008ec:	070a                	slli	a4,a4,0x2
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008ee:	060a                	slli	a2,a2,0x2
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008f0:	971a                	add	a4,a4,t1
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f2:	961a                	add	a2,a2,t1
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
ffffffffc02008f4:	00072883          	lw	a7,0(a4)
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
ffffffffc02008f8:	4210                	lw	a2,0(a2)
ffffffffc02008fa:	02051713          	slli	a4,a0,0x20
ffffffffc02008fe:	8379                	srli	a4,a4,0x1e
        node_size *= 2;
ffffffffc0200900:	0016969b          	slliw	a3,a3,0x1
        if (left_longest + right_longest == node_size){  //合并
ffffffffc0200904:	00c88ebb          	addw	t4,a7,a2
        index = PARENT(index);
ffffffffc0200908:	0005079b          	sext.w	a5,a0
        if (left_longest + right_longest == node_size){  //合并
ffffffffc020090c:	971a                	add	a4,a4,t1
ffffffffc020090e:	02de8b63          	beq	t4,a3,ffffffffc0200944 <buddy_free_pages+0xfe>
            buddy_manager.size[index] = MAX(left_longest, right_longest);
ffffffffc0200912:	8546                	mv	a0,a7
ffffffffc0200914:	00c8f363          	bleu	a2,a7,ffffffffc020091a <buddy_free_pages+0xd4>
ffffffffc0200918:	8532                	mv	a0,a2
ffffffffc020091a:	c308                	sw	a0,0(a4)
    while (index)
ffffffffc020091c:	fbd5                	bnez	a5,ffffffffc02008d0 <buddy_free_pages+0x8a>
    nr_free+=n;
ffffffffc020091e:	00006797          	auipc	a5,0x6
ffffffffc0200922:	b1a78793          	addi	a5,a5,-1254 # ffffffffc0206438 <free_area>
ffffffffc0200926:	4b9c                	lw	a5,16(a5)
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200928:	8642                	mv	a2,a6
ffffffffc020092a:	2581                	sext.w	a1,a1
    nr_free+=n;
ffffffffc020092c:	0107883b          	addw	a6,a5,a6
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200930:	00002517          	auipc	a0,0x2
ffffffffc0200934:	80850513          	addi	a0,a0,-2040 # ffffffffc0202138 <commands+0x858>
    nr_free+=n;
ffffffffc0200938:	00006797          	auipc	a5,0x6
ffffffffc020093c:	b107a823          	sw	a6,-1264(a5) # ffffffffc0206448 <free_area+0x10>
    cprintf("free done at %u with %u pages!\n",offset,n);
ffffffffc0200940:	f76ff06f          	j	ffffffffc02000b6 <cprintf>
            buddy_manager.size[index] = node_size;
ffffffffc0200944:	c314                	sw	a3,0(a4)
ffffffffc0200946:	b761                	j	ffffffffc02008ce <buddy_free_pages+0x88>
ffffffffc0200948:	8082                	ret
    while (tmp >>= 1)
ffffffffc020094a:	4809                	li	a6,2
    return (1 << n);
ffffffffc020094c:	b72d                	j	ffffffffc0200876 <buddy_free_pages+0x30>
{
ffffffffc020094e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200950:	00001697          	auipc	a3,0x1
ffffffffc0200954:	7b068693          	addi	a3,a3,1968 # ffffffffc0202100 <commands+0x820>
ffffffffc0200958:	00001617          	auipc	a2,0x1
ffffffffc020095c:	7b060613          	addi	a2,a2,1968 # ffffffffc0202108 <commands+0x828>
ffffffffc0200960:	09600593          	li	a1,150
ffffffffc0200964:	00001517          	auipc	a0,0x1
ffffffffc0200968:	7bc50513          	addi	a0,a0,1980 # ffffffffc0202120 <commands+0x840>
{
ffffffffc020096c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020096e:	a3fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200972 <buddy_alloc_pages>:
{
ffffffffc0200972:	1141                	addi	sp,sp,-16
ffffffffc0200974:	e406                	sd	ra,8(sp)
ffffffffc0200976:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200978:	16050c63          	beqz	a0,ffffffffc0200af0 <buddy_alloc_pages+0x17e>
    if (!IS_POWER_OF_2(n))
ffffffffc020097c:	fff50793          	addi	a5,a0,-1
ffffffffc0200980:	8fe9                	and	a5,a5,a0
ffffffffc0200982:	12079563          	bnez	a5,ffffffffc0200aac <buddy_alloc_pages+0x13a>
    if (n > nr_free)
ffffffffc0200986:	00006797          	auipc	a5,0x6
ffffffffc020098a:	ac27e783          	lwu	a5,-1342(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc020098e:	14a7e363          	bltu	a5,a0,ffffffffc0200ad4 <buddy_alloc_pages+0x162>
    if (buddy_manager.size[index] < n)
ffffffffc0200992:	00006317          	auipc	t1,0x6
ffffffffc0200996:	abe30313          	addi	t1,t1,-1346 # ffffffffc0206450 <buddy_manager>
ffffffffc020099a:	00033603          	ld	a2,0(t1)
ffffffffc020099e:	00066783          	lwu	a5,0(a2)
ffffffffc02009a2:	12a7e963          	bltu	a5,a0,ffffffffc0200ad4 <buddy_alloc_pages+0x162>
    for (node_size = buddy_manager.total_size; node_size != n; node_size /= 2)
ffffffffc02009a6:	01032583          	lw	a1,16(t1)
ffffffffc02009aa:	02059793          	slli	a5,a1,0x20
ffffffffc02009ae:	9381                	srli	a5,a5,0x20
ffffffffc02009b0:	12f50863          	beq	a0,a5,ffffffffc0200ae0 <buddy_alloc_pages+0x16e>
    unsigned index = 0;
ffffffffc02009b4:	4781                	li	a5,0
        if (buddy_manager.size[LEFT_LEAF(index)] >= n)
ffffffffc02009b6:	0017969b          	slliw	a3,a5,0x1
ffffffffc02009ba:	0016879b          	addiw	a5,a3,1
ffffffffc02009be:	02079713          	slli	a4,a5,0x20
ffffffffc02009c2:	8379                	srli	a4,a4,0x1e
ffffffffc02009c4:	9732                	add	a4,a4,a2
ffffffffc02009c6:	00076703          	lwu	a4,0(a4)
ffffffffc02009ca:	00a77463          	bleu	a0,a4,ffffffffc02009d2 <buddy_alloc_pages+0x60>
            index = RIGHT_LEAF(index);
ffffffffc02009ce:	0026879b          	addiw	a5,a3,2
    for (node_size = buddy_manager.total_size; node_size != n; node_size /= 2)
ffffffffc02009d2:	0015d59b          	srliw	a1,a1,0x1
ffffffffc02009d6:	02059713          	slli	a4,a1,0x20
ffffffffc02009da:	9301                	srli	a4,a4,0x20
ffffffffc02009dc:	fca71de3          	bne	a4,a0,ffffffffc02009b6 <buddy_alloc_pages+0x44>
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc02009e0:	0017871b          	addiw	a4,a5,1
ffffffffc02009e4:	02b705bb          	mulw	a1,a4,a1
    buddy_manager.size[index] = 0;
ffffffffc02009e8:	02079713          	slli	a4,a5,0x20
ffffffffc02009ec:	8379                	srli	a4,a4,0x1e
ffffffffc02009ee:	9732                	add	a4,a4,a2
ffffffffc02009f0:	00072023          	sw	zero,0(a4)
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc02009f4:	01032703          	lw	a4,16(t1)
ffffffffc02009f8:	9d99                	subw	a1,a1,a4
    while (index)
ffffffffc02009fa:	c7a9                	beqz	a5,ffffffffc0200a44 <buddy_alloc_pages+0xd2>
        index = PARENT(index);
ffffffffc02009fc:	37fd                	addiw	a5,a5,-1
ffffffffc02009fe:	0017d81b          	srliw	a6,a5,0x1
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a02:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200a06:	0018069b          	addiw	a3,a6,1
ffffffffc0200a0a:	0016969b          	slliw	a3,a3,0x1
ffffffffc0200a0e:	2705                	addiw	a4,a4,1
ffffffffc0200a10:	1682                	slli	a3,a3,0x20
ffffffffc0200a12:	1702                	slli	a4,a4,0x20
ffffffffc0200a14:	9281                	srli	a3,a3,0x20
ffffffffc0200a16:	9301                	srli	a4,a4,0x20
ffffffffc0200a18:	068a                	slli	a3,a3,0x2
ffffffffc0200a1a:	070a                	slli	a4,a4,0x2
ffffffffc0200a1c:	9732                	add	a4,a4,a2
ffffffffc0200a1e:	96b2                	add	a3,a3,a2
ffffffffc0200a20:	00072883          	lw	a7,0(a4)
ffffffffc0200a24:	4294                	lw	a3,0(a3)
ffffffffc0200a26:	02081713          	slli	a4,a6,0x20
ffffffffc0200a2a:	8379                	srli	a4,a4,0x1e
ffffffffc0200a2c:	00068e9b          	sext.w	t4,a3
ffffffffc0200a30:	00088e1b          	sext.w	t3,a7
        index = PARENT(index);
ffffffffc0200a34:	0008079b          	sext.w	a5,a6
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
ffffffffc0200a38:	9732                	add	a4,a4,a2
ffffffffc0200a3a:	01cef363          	bleu	t3,t4,ffffffffc0200a40 <buddy_alloc_pages+0xce>
ffffffffc0200a3e:	86c6                	mv	a3,a7
ffffffffc0200a40:	c314                	sw	a3,0(a4)
    while (index)
ffffffffc0200a42:	ffcd                	bnez	a5,ffffffffc02009fc <buddy_alloc_pages+0x8a>
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a44:	02059713          	slli	a4,a1,0x20
ffffffffc0200a48:	9301                	srli	a4,a4,0x20
ffffffffc0200a4a:	00271793          	slli	a5,a4,0x2
ffffffffc0200a4e:	00833403          	ld	s0,8(t1)
ffffffffc0200a52:	97ba                	add	a5,a5,a4
    for (page = base; page != base + n; page++)
ffffffffc0200a54:	00251713          	slli	a4,a0,0x2
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a58:	078e                	slli	a5,a5,0x3
    for (page = base; page != base + n; page++)
ffffffffc0200a5a:	972a                	add	a4,a4,a0
    struct Page *base = buddy_manager.mem_tree + offset;
ffffffffc0200a5c:	943e                	add	s0,s0,a5
    for (page = base; page != base + n; page++)
ffffffffc0200a5e:	070e                	slli	a4,a4,0x3
ffffffffc0200a60:	9722                	add	a4,a4,s0
ffffffffc0200a62:	87a2                	mv	a5,s0
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a64:	56f5                	li	a3,-3
ffffffffc0200a66:	00e40a63          	beq	s0,a4,ffffffffc0200a7a <buddy_alloc_pages+0x108>
ffffffffc0200a6a:	00878613          	addi	a2,a5,8
ffffffffc0200a6e:	60d6302f          	amoand.d	zero,a3,(a2)
ffffffffc0200a72:	02878793          	addi	a5,a5,40
ffffffffc0200a76:	fee79ae3          	bne	a5,a4,ffffffffc0200a6a <buddy_alloc_pages+0xf8>
    nr_free -= n;
ffffffffc0200a7a:	00006797          	auipc	a5,0x6
ffffffffc0200a7e:	9be78793          	addi	a5,a5,-1602 # ffffffffc0206438 <free_area>
ffffffffc0200a82:	4b9c                	lw	a5,16(a5)
ffffffffc0200a84:	0005071b          	sext.w	a4,a0
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200a88:	862a                	mv	a2,a0
    nr_free -= n;
ffffffffc0200a8a:	9f99                	subw	a5,a5,a4
ffffffffc0200a8c:	00006697          	auipc	a3,0x6
ffffffffc0200a90:	9af6ae23          	sw	a5,-1604(a3) # ffffffffc0206448 <free_area+0x10>
    base->property = n;  //用n来保存分配的页数，n为2的幂
ffffffffc0200a94:	c818                	sw	a4,16(s0)
    cprintf("alloc done at %u with %u pages\n",offset,n);
ffffffffc0200a96:	00001517          	auipc	a0,0x1
ffffffffc0200a9a:	47a50513          	addi	a0,a0,1146 # ffffffffc0201f10 <commands+0x630>
ffffffffc0200a9e:	e18ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200aa2:	8522                	mv	a0,s0
ffffffffc0200aa4:	60a2                	ld	ra,8(sp)
ffffffffc0200aa6:	6402                	ld	s0,0(sp)
ffffffffc0200aa8:	0141                	addi	sp,sp,16
ffffffffc0200aaa:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200aac:	4015551b          	sraiw	a0,a0,0x1
ffffffffc0200ab0:	cd15                	beqz	a0,ffffffffc0200aec <buddy_alloc_pages+0x17a>
    int n = 0, tmp = size;
ffffffffc0200ab2:	4781                	li	a5,0
ffffffffc0200ab4:	a011                	j	ffffffffc0200ab8 <buddy_alloc_pages+0x146>
        n++;
ffffffffc0200ab6:	87ba                	mv	a5,a4
    while (tmp >>= 1)
ffffffffc0200ab8:	8505                	srai	a0,a0,0x1
        n++;
ffffffffc0200aba:	0017871b          	addiw	a4,a5,1
    while (tmp >>= 1)
ffffffffc0200abe:	fd65                	bnez	a0,ffffffffc0200ab6 <buddy_alloc_pages+0x144>
ffffffffc0200ac0:	2789                	addiw	a5,a5,2
ffffffffc0200ac2:	4505                	li	a0,1
ffffffffc0200ac4:	00f5153b          	sllw	a0,a0,a5
    if (n > nr_free)
ffffffffc0200ac8:	00006797          	auipc	a5,0x6
ffffffffc0200acc:	9807e783          	lwu	a5,-1664(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200ad0:	eca7f1e3          	bleu	a0,a5,ffffffffc0200992 <buddy_alloc_pages+0x20>
        return NULL;
ffffffffc0200ad4:	4401                	li	s0,0
}
ffffffffc0200ad6:	8522                	mv	a0,s0
ffffffffc0200ad8:	60a2                	ld	ra,8(sp)
ffffffffc0200ada:	6402                	ld	s0,0(sp)
ffffffffc0200adc:	0141                	addi	sp,sp,16
ffffffffc0200ade:	8082                	ret
    buddy_manager.size[index] = 0;
ffffffffc0200ae0:	00062023          	sw	zero,0(a2)
    offset = (index + 1) * node_size - buddy_manager.total_size;
ffffffffc0200ae4:	01032783          	lw	a5,16(t1)
ffffffffc0200ae8:	9d9d                	subw	a1,a1,a5
    while (index)
ffffffffc0200aea:	bfa9                	j	ffffffffc0200a44 <buddy_alloc_pages+0xd2>
    while (tmp >>= 1)
ffffffffc0200aec:	4509                	li	a0,2
    return (1 << n);
ffffffffc0200aee:	bd61                	j	ffffffffc0200986 <buddy_alloc_pages+0x14>
    assert(n > 0);
ffffffffc0200af0:	00001697          	auipc	a3,0x1
ffffffffc0200af4:	61068693          	addi	a3,a3,1552 # ffffffffc0202100 <commands+0x820>
ffffffffc0200af8:	00001617          	auipc	a2,0x1
ffffffffc0200afc:	61060613          	addi	a2,a2,1552 # ffffffffc0202108 <commands+0x828>
ffffffffc0200b00:	05d00593          	li	a1,93
ffffffffc0200b04:	00001517          	auipc	a0,0x1
ffffffffc0200b08:	61c50513          	addi	a0,a0,1564 # ffffffffc0202120 <commands+0x840>
ffffffffc0200b0c:	8a1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b10 <buddy_init_memmap>:
{
ffffffffc0200b10:	1141                	addi	sp,sp,-16
ffffffffc0200b12:	e406                	sd	ra,8(sp)
ffffffffc0200b14:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200b16:	c5e5                	beqz	a1,ffffffffc0200bfe <buddy_init_memmap+0xee>
    int n = 0, tmp = size;
ffffffffc0200b18:	0005841b          	sext.w	s0,a1
    while (tmp >>= 1)
ffffffffc0200b1c:	40145793          	srai	a5,s0,0x1
ffffffffc0200b20:	cfcd                	beqz	a5,ffffffffc0200bda <buddy_init_memmap+0xca>
    int n = 0, tmp = size;
ffffffffc0200b22:	4701                	li	a4,0
ffffffffc0200b24:	a011                	j	ffffffffc0200b28 <buddy_init_memmap+0x18>
        n++;
ffffffffc0200b26:	8736                	mv	a4,a3
    while (tmp >>= 1)
ffffffffc0200b28:	8785                	srai	a5,a5,0x1
        n++;
ffffffffc0200b2a:	0017069b          	addiw	a3,a4,1
    while (tmp >>= 1)
ffffffffc0200b2e:	ffe5                	bnez	a5,ffffffffc0200b26 <buddy_init_memmap+0x16>
ffffffffc0200b30:	2709                	addiw	a4,a4,2
ffffffffc0200b32:	4605                	li	a2,1
ffffffffc0200b34:	00e6163b          	sllw	a2,a2,a4
    for (; p != base + n; p++)
ffffffffc0200b38:	00259793          	slli	a5,a1,0x2
ffffffffc0200b3c:	97ae                	add	a5,a5,a1
ffffffffc0200b3e:	078e                	slli	a5,a5,0x3
ffffffffc0200b40:	00f506b3          	add	a3,a0,a5
ffffffffc0200b44:	02d50463          	beq	a0,a3,ffffffffc0200b6c <buddy_init_memmap+0x5c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b48:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200b4a:	87aa                	mv	a5,a0
ffffffffc0200b4c:	8b05                	andi	a4,a4,1
ffffffffc0200b4e:	e709                	bnez	a4,ffffffffc0200b58 <buddy_init_memmap+0x48>
ffffffffc0200b50:	a079                	j	ffffffffc0200bde <buddy_init_memmap+0xce>
ffffffffc0200b52:	6798                	ld	a4,8(a5)
ffffffffc0200b54:	8b05                	andi	a4,a4,1
ffffffffc0200b56:	c741                	beqz	a4,ffffffffc0200bde <buddy_init_memmap+0xce>
        p->flags = p->property = 0;
ffffffffc0200b58:	0007a823          	sw	zero,16(a5)
ffffffffc0200b5c:	0007b423          	sd	zero,8(a5)
//ppn<<12,indicating the physical address of page----Xyang


static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b60:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200b64:	02878793          	addi	a5,a5,40
ffffffffc0200b68:	fed795e3          	bne	a5,a3,ffffffffc0200b52 <buddy_init_memmap+0x42>
    buddy_manager.total_size = round_up_n;
ffffffffc0200b6c:	0006071b          	sext.w	a4,a2
    base->property = n; // 从base开始有n个可用页
ffffffffc0200b70:	c900                	sw	s0,16(a0)
    unsigned node_size = 2 * round_up_n;
ffffffffc0200b72:	0017179b          	slliw	a5,a4,0x1
    buddy_manager.mem_tree = base;
ffffffffc0200b76:	00006897          	auipc	a7,0x6
ffffffffc0200b7a:	8ea8b123          	sd	a0,-1822(a7) # ffffffffc0206458 <buddy_manager+0x8>
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200b7e:	00161813          	slli	a6,a2,0x1
    buddy_manager.total_size = round_up_n;
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	8ce52f23          	sw	a4,-1826(a0) # ffffffffc0206460 <buddy_manager+0x10>
    buddy_manager.size = (unsigned *)p;
ffffffffc0200b8a:	00006517          	auipc	a0,0x6
ffffffffc0200b8e:	8cd53323          	sd	a3,-1850(a0) # ffffffffc0206450 <buddy_manager>
    unsigned node_size = 2 * round_up_n;
ffffffffc0200b92:	0007851b          	sext.w	a0,a5
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200b96:	387d                	addiw	a6,a6,-1
ffffffffc0200b98:	87b6                	mv	a5,a3
ffffffffc0200b9a:	4701                	li	a4,0
        if (IS_POWER_OF_2(i + 1))
ffffffffc0200b9c:	0017069b          	addiw	a3,a4,1
ffffffffc0200ba0:	8f75                	and	a4,a4,a3
ffffffffc0200ba2:	e319                	bnez	a4,ffffffffc0200ba8 <buddy_init_memmap+0x98>
            node_size /= 2;
ffffffffc0200ba4:	0015551b          	srliw	a0,a0,0x1
        buddy_manager.size[i] = node_size;
ffffffffc0200ba8:	c388                	sw	a0,0(a5)
ffffffffc0200baa:	8736                	mv	a4,a3
ffffffffc0200bac:	0791                	addi	a5,a5,4
    for (int i = 0; i <2 * round_up_n - 1; ++i)
ffffffffc0200bae:	ff0697e3          	bne	a3,a6,ffffffffc0200b9c <buddy_init_memmap+0x8c>
    cprintf("initialized %u pages with a %u size tree\n",n,round_up_n);
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	5b650513          	addi	a0,a0,1462 # ffffffffc0202168 <commands+0x888>
ffffffffc0200bba:	cfcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    nr_free += n;
ffffffffc0200bbe:	00006797          	auipc	a5,0x6
ffffffffc0200bc2:	87a78793          	addi	a5,a5,-1926 # ffffffffc0206438 <free_area>
ffffffffc0200bc6:	4b9c                	lw	a5,16(a5)
}
ffffffffc0200bc8:	60a2                	ld	ra,8(sp)
    nr_free += n;
ffffffffc0200bca:	9c3d                	addw	s0,s0,a5
ffffffffc0200bcc:	00006797          	auipc	a5,0x6
ffffffffc0200bd0:	8687ae23          	sw	s0,-1924(a5) # ffffffffc0206448 <free_area+0x10>
}
ffffffffc0200bd4:	6402                	ld	s0,0(sp)
ffffffffc0200bd6:	0141                	addi	sp,sp,16
ffffffffc0200bd8:	8082                	ret
    while (tmp >>= 1)
ffffffffc0200bda:	4609                	li	a2,2
ffffffffc0200bdc:	bfb1                	j	ffffffffc0200b38 <buddy_init_memmap+0x28>
        assert(PageReserved(p));
ffffffffc0200bde:	00001697          	auipc	a3,0x1
ffffffffc0200be2:	57a68693          	addi	a3,a3,1402 # ffffffffc0202158 <commands+0x878>
ffffffffc0200be6:	00001617          	auipc	a2,0x1
ffffffffc0200bea:	52260613          	addi	a2,a2,1314 # ffffffffc0202108 <commands+0x828>
ffffffffc0200bee:	03600593          	li	a1,54
ffffffffc0200bf2:	00001517          	auipc	a0,0x1
ffffffffc0200bf6:	52e50513          	addi	a0,a0,1326 # ffffffffc0202120 <commands+0x840>
ffffffffc0200bfa:	fb2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bfe:	00001697          	auipc	a3,0x1
ffffffffc0200c02:	50268693          	addi	a3,a3,1282 # ffffffffc0202100 <commands+0x820>
ffffffffc0200c06:	00001617          	auipc	a2,0x1
ffffffffc0200c0a:	50260613          	addi	a2,a2,1282 # ffffffffc0202108 <commands+0x828>
ffffffffc0200c0e:	03000593          	li	a1,48
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	50e50513          	addi	a0,a0,1294 # ffffffffc0202120 <commands+0x840>
ffffffffc0200c1a:	f92ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c1e <buddy_check>:
basic_check(void) {

}

static void
buddy_check(void) {
ffffffffc0200c1e:	7139                	addi	sp,sp,-64
    cprintf("buddy check!\n");
ffffffffc0200c20:	00001517          	auipc	a0,0x1
ffffffffc0200c24:	31050513          	addi	a0,a0,784 # ffffffffc0201f30 <commands+0x650>
buddy_check(void) {
ffffffffc0200c28:	fc06                	sd	ra,56(sp)
ffffffffc0200c2a:	f822                	sd	s0,48(sp)
ffffffffc0200c2c:	f426                	sd	s1,40(sp)
ffffffffc0200c2e:	f04a                	sd	s2,32(sp)
ffffffffc0200c30:	ec4e                	sd	s3,24(sp)
ffffffffc0200c32:	e852                	sd	s4,16(sp)
ffffffffc0200c34:	e456                	sd	s5,8(sp)
ffffffffc0200c36:	e05a                	sd	s6,0(sp)
    cprintf("buddy check!\n");
ffffffffc0200c38:	c7eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    struct Page *p0, *p1, *p2, *p3, *p4;
    p0 = p1 = p2 = p3 = p4 = NULL;

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	3bc000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c42:	24050c63          	beqz	a0,ffffffffc0200e9a <buddy_check+0x27c>
ffffffffc0200c46:	84aa                	mv	s1,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c48:	4505                	li	a0,1
ffffffffc0200c4a:	3b0000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c4e:	842a                	mv	s0,a0
ffffffffc0200c50:	2c050563          	beqz	a0,ffffffffc0200f1a <buddy_check+0x2fc>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c54:	4505                	li	a0,1
ffffffffc0200c56:	3a4000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c5a:	892a                	mv	s2,a0
ffffffffc0200c5c:	28050f63          	beqz	a0,ffffffffc0200efa <buddy_check+0x2dc>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c60:	1a848d63          	beq	s1,s0,ffffffffc0200e1a <buddy_check+0x1fc>
ffffffffc0200c64:	1aa48b63          	beq	s1,a0,ffffffffc0200e1a <buddy_check+0x1fc>
ffffffffc0200c68:	1aa40963          	beq	s0,a0,ffffffffc0200e1a <buddy_check+0x1fc>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c6c:	409c                	lw	a5,0(s1)
ffffffffc0200c6e:	1c079663          	bnez	a5,ffffffffc0200e3a <buddy_check+0x21c>
ffffffffc0200c72:	401c                	lw	a5,0(s0)
ffffffffc0200c74:	1c079363          	bnez	a5,ffffffffc0200e3a <buddy_check+0x21c>
ffffffffc0200c78:	411c                	lw	a5,0(a0)
ffffffffc0200c7a:	1c079063          	bnez	a5,ffffffffc0200e3a <buddy_check+0x21c>
    assert(p1==p0+1 && p2 == p1+1);  //页面地址关系
ffffffffc0200c7e:	02848793          	addi	a5,s1,40
ffffffffc0200c82:	1cf41c63          	bne	s0,a5,ffffffffc0200e5a <buddy_check+0x23c>
ffffffffc0200c86:	02840793          	addi	a5,s0,40
ffffffffc0200c8a:	1cf51863          	bne	a0,a5,ffffffffc0200e5a <buddy_check+0x23c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c8e:	00005797          	auipc	a5,0x5
ffffffffc0200c92:	7f278793          	addi	a5,a5,2034 # ffffffffc0206480 <pages>
ffffffffc0200c96:	639c                	ld	a5,0(a5)
ffffffffc0200c98:	00001717          	auipc	a4,0x1
ffffffffc0200c9c:	46070713          	addi	a4,a4,1120 # ffffffffc02020f8 <commands+0x818>
ffffffffc0200ca0:	630c                	ld	a1,0(a4)
ffffffffc0200ca2:	40f48733          	sub	a4,s1,a5
ffffffffc0200ca6:	870d                	srai	a4,a4,0x3
ffffffffc0200ca8:	02b70733          	mul	a4,a4,a1
ffffffffc0200cac:	00002697          	auipc	a3,0x2
ffffffffc0200cb0:	8ac68693          	addi	a3,a3,-1876 # ffffffffc0202558 <nbase>
ffffffffc0200cb4:	6290                	ld	a2,0(a3)

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200cb6:	00005697          	auipc	a3,0x5
ffffffffc0200cba:	76268693          	addi	a3,a3,1890 # ffffffffc0206418 <npage>
ffffffffc0200cbe:	6294                	ld	a3,0(a3)
ffffffffc0200cc0:	06b2                	slli	a3,a3,0xc
ffffffffc0200cc2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cc4:	0732                	slli	a4,a4,0xc
ffffffffc0200cc6:	28d77a63          	bleu	a3,a4,ffffffffc0200f5a <buddy_check+0x33c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cca:	40f40733          	sub	a4,s0,a5
ffffffffc0200cce:	870d                	srai	a4,a4,0x3
ffffffffc0200cd0:	02b70733          	mul	a4,a4,a1
ffffffffc0200cd4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cd6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cd8:	26d77163          	bleu	a3,a4,ffffffffc0200f3a <buddy_check+0x31c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cdc:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ce0:	878d                	srai	a5,a5,0x3
ffffffffc0200ce2:	02b787b3          	mul	a5,a5,a1
ffffffffc0200ce6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ce8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cea:	2ed7f863          	bleu	a3,a5,ffffffffc0200fda <buddy_check+0x3bc>

    free_page(p0);    
ffffffffc0200cee:	8526                	mv	a0,s1
ffffffffc0200cf0:	4585                	li	a1,1
ffffffffc0200cf2:	34c000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_page(p1);
ffffffffc0200cf6:	8522                	mv	a0,s0
ffffffffc0200cf8:	4585                	li	a1,1
ffffffffc0200cfa:	344000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_page(p2);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	854a                	mv	a0,s2
ffffffffc0200d02:	33c000ef          	jal	ra,ffffffffc020103e <free_pages>
    
    p1 = alloc_pages(512); //p1应该指向最开始的512个页
ffffffffc0200d06:	20000513          	li	a0,512
ffffffffc0200d0a:	2f0000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200d0e:	84aa                	mv	s1,a0
    p2 = alloc_pages(512);
ffffffffc0200d10:	20000513          	li	a0,512
ffffffffc0200d14:	2e6000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200d18:	842a                	mv	s0,a0
    p3 = alloc_pages(1024);
ffffffffc0200d1a:	40000513          	li	a0,1024
ffffffffc0200d1e:	2dc000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>

    assert(p3 - p2 == p2 - p1);//检查相邻关系
ffffffffc0200d22:	40850733          	sub	a4,a0,s0
ffffffffc0200d26:	409407b3          	sub	a5,s0,s1
    p3 = alloc_pages(1024);
ffffffffc0200d2a:	892a                	mv	s2,a0
    assert(p3 - p2 == p2 - p1);//检查相邻关系
ffffffffc0200d2c:	28f71763          	bne	a4,a5,ffffffffc0200fba <buddy_check+0x39c>

    free_pages(p1, 256);
ffffffffc0200d30:	10000593          	li	a1,256
ffffffffc0200d34:	8526                	mv	a0,s1
ffffffffc0200d36:	308000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_pages(p2, 512);
ffffffffc0200d3a:	8522                	mv	a0,s0
ffffffffc0200d3c:	20000593          	li	a1,512
    free_pages(p1 + 256, 256);
ffffffffc0200d40:	640d                	lui	s0,0x3
    free_pages(p2, 512);
ffffffffc0200d42:	2fc000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_pages(p1 + 256, 256);
ffffffffc0200d46:	80040413          	addi	s0,s0,-2048 # 2800 <BASE_ADDRESS-0xffffffffc01fd800>
ffffffffc0200d4a:	10000593          	li	a1,256
ffffffffc0200d4e:	00848533          	add	a0,s1,s0
ffffffffc0200d52:	2ec000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_pages(p3,1024);
ffffffffc0200d56:	40000593          	li	a1,1024
ffffffffc0200d5a:	854a                	mv	a0,s2
ffffffffc0200d5c:	2e2000ef          	jal	ra,ffffffffc020103e <free_pages>
    //检验释放页时，相邻内存的合并

    p0 = alloc_pages(8192);
ffffffffc0200d60:	6509                	lui	a0,0x2
ffffffffc0200d62:	298000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200d66:	89aa                	mv	s3,a0

    assert(p0 == p1); //重新分配，p0也指向最开始的页
ffffffffc0200d68:	22a49963          	bne	s1,a0,ffffffffc0200f9a <buddy_check+0x37c>

    p1 = alloc_pages(128);
ffffffffc0200d6c:	08000513          	li	a0,128
ffffffffc0200d70:	28a000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200d74:	8aaa                	mv	s5,a0
    p2 = alloc_pages(64);
    

    assert(p1 + 128 == p2);// 检查是否相邻
ffffffffc0200d76:	6485                	lui	s1,0x1
    p2 = alloc_pages(64);
ffffffffc0200d78:	04000513          	li	a0,64
ffffffffc0200d7c:	27e000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
    assert(p1 + 128 == p2);// 检查是否相邻
ffffffffc0200d80:	40048913          	addi	s2,s1,1024 # 1400 <BASE_ADDRESS-0xffffffffc01fec00>
ffffffffc0200d84:	012a87b3          	add	a5,s5,s2
    p2 = alloc_pages(64);
ffffffffc0200d88:	8a2a                	mv	s4,a0
    assert(p1 + 128 == p2);// 检查是否相邻
ffffffffc0200d8a:	1ef51863          	bne	a0,a5,ffffffffc0200f7a <buddy_check+0x35c>

    p3 = alloc_pages(128);
ffffffffc0200d8e:	08000513          	li	a0,128
ffffffffc0200d92:	268000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>


    //检查p3和p1是否重叠
    assert(p1 + 256 == p3);
ffffffffc0200d96:	9456                	add	s0,s0,s5
    p3 = alloc_pages(128);
ffffffffc0200d98:	8b2a                	mv	s6,a0
    assert(p1 + 256 == p3);
ffffffffc0200d9a:	14851063          	bne	a0,s0,ffffffffc0200eda <buddy_check+0x2bc>
    
    //释放p1
    free_pages(p1, 128);
ffffffffc0200d9e:	8556                	mv	a0,s5
ffffffffc0200da0:	08000593          	li	a1,128
ffffffffc0200da4:	29a000ef          	jal	ra,ffffffffc020103e <free_pages>

    p4 = alloc_pages(64);
ffffffffc0200da8:	04000513          	li	a0,64
ffffffffc0200dac:	24e000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
    assert(p4 + 128 == p2);
ffffffffc0200db0:	992a                	add	s2,s2,a0
    p4 = alloc_pages(64);
ffffffffc0200db2:	8aaa                	mv	s5,a0
    assert(p4 + 128 == p2);
ffffffffc0200db4:	112a1363          	bne	s4,s2,ffffffffc0200eba <buddy_check+0x29c>
    // 检查p4是否能够使用p1刚刚释放的内存

    free_pages(p3, 128);
ffffffffc0200db8:	08000593          	li	a1,128
ffffffffc0200dbc:	855a                	mv	a0,s6
ffffffffc0200dbe:	280000ef          	jal	ra,ffffffffc020103e <free_pages>
    p3 = alloc_pages(64);
ffffffffc0200dc2:	04000513          	li	a0,64

    // 检查p3是否在p2、p4之间
    assert(p3 == p4 + 64 && p3 == p2 - 64);
ffffffffc0200dc6:	a0048493          	addi	s1,s1,-1536
    p3 = alloc_pages(64);
ffffffffc0200dca:	230000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
    assert(p3 == p4 + 64 && p3 == p2 - 64);
ffffffffc0200dce:	94d6                	add	s1,s1,s5
    p3 = alloc_pages(64);
ffffffffc0200dd0:	842a                	mv	s0,a0
    assert(p3 == p4 + 64 && p3 == p2 - 64);
ffffffffc0200dd2:	0a951463          	bne	a0,s1,ffffffffc0200e7a <buddy_check+0x25c>
ffffffffc0200dd6:	77fd                	lui	a5,0xfffff
ffffffffc0200dd8:	60078793          	addi	a5,a5,1536 # fffffffffffff600 <end+0x3fdf9178>
ffffffffc0200ddc:	97d2                	add	a5,a5,s4
ffffffffc0200dde:	08f51e63          	bne	a0,a5,ffffffffc0200e7a <buddy_check+0x25c>
    free_pages(p2, 64);
ffffffffc0200de2:	8552                	mv	a0,s4
ffffffffc0200de4:	04000593          	li	a1,64
ffffffffc0200de8:	256000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_pages(p4, 64);
ffffffffc0200dec:	8556                	mv	a0,s5
ffffffffc0200dee:	04000593          	li	a1,64
ffffffffc0200df2:	24c000ef          	jal	ra,ffffffffc020103e <free_pages>
    free_pages(p3, 64);
ffffffffc0200df6:	8522                	mv	a0,s0
ffffffffc0200df8:	04000593          	li	a1,64
ffffffffc0200dfc:	242000ef          	jal	ra,ffffffffc020103e <free_pages>
    // 全部释放
    free_pages(p0, 8192);
    
}
ffffffffc0200e00:	7442                	ld	s0,48(sp)
ffffffffc0200e02:	70e2                	ld	ra,56(sp)
ffffffffc0200e04:	74a2                	ld	s1,40(sp)
ffffffffc0200e06:	7902                	ld	s2,32(sp)
ffffffffc0200e08:	6a42                	ld	s4,16(sp)
ffffffffc0200e0a:	6aa2                	ld	s5,8(sp)
ffffffffc0200e0c:	6b02                	ld	s6,0(sp)
    free_pages(p0, 8192);
ffffffffc0200e0e:	854e                	mv	a0,s3
}
ffffffffc0200e10:	69e2                	ld	s3,24(sp)
    free_pages(p0, 8192);
ffffffffc0200e12:	6589                	lui	a1,0x2
}
ffffffffc0200e14:	6121                	addi	sp,sp,64
    free_pages(p0, 8192);
ffffffffc0200e16:	2280006f          	j	ffffffffc020103e <free_pages>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e1a:	00001697          	auipc	a3,0x1
ffffffffc0200e1e:	18668693          	addi	a3,a3,390 # ffffffffc0201fa0 <commands+0x6c0>
ffffffffc0200e22:	00001617          	auipc	a2,0x1
ffffffffc0200e26:	2e660613          	addi	a2,a2,742 # ffffffffc0202108 <commands+0x828>
ffffffffc0200e2a:	0dc00593          	li	a1,220
ffffffffc0200e2e:	00001517          	auipc	a0,0x1
ffffffffc0200e32:	2f250513          	addi	a0,a0,754 # ffffffffc0202120 <commands+0x840>
ffffffffc0200e36:	d76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e3a:	00001697          	auipc	a3,0x1
ffffffffc0200e3e:	18e68693          	addi	a3,a3,398 # ffffffffc0201fc8 <commands+0x6e8>
ffffffffc0200e42:	00001617          	auipc	a2,0x1
ffffffffc0200e46:	2c660613          	addi	a2,a2,710 # ffffffffc0202108 <commands+0x828>
ffffffffc0200e4a:	0dd00593          	li	a1,221
ffffffffc0200e4e:	00001517          	auipc	a0,0x1
ffffffffc0200e52:	2d250513          	addi	a0,a0,722 # ffffffffc0202120 <commands+0x840>
ffffffffc0200e56:	d56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1==p0+1 && p2 == p1+1);  //页面地址关系
ffffffffc0200e5a:	00001697          	auipc	a3,0x1
ffffffffc0200e5e:	1ae68693          	addi	a3,a3,430 # ffffffffc0202008 <commands+0x728>
ffffffffc0200e62:	00001617          	auipc	a2,0x1
ffffffffc0200e66:	2a660613          	addi	a2,a2,678 # ffffffffc0202108 <commands+0x828>
ffffffffc0200e6a:	0de00593          	li	a1,222
ffffffffc0200e6e:	00001517          	auipc	a0,0x1
ffffffffc0200e72:	2b250513          	addi	a0,a0,690 # ffffffffc0202120 <commands+0x840>
ffffffffc0200e76:	d36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 == p4 + 64 && p3 == p2 - 64);
ffffffffc0200e7a:	00001697          	auipc	a3,0x1
ffffffffc0200e7e:	25e68693          	addi	a3,a3,606 # ffffffffc02020d8 <commands+0x7f8>
ffffffffc0200e82:	00001617          	auipc	a2,0x1
ffffffffc0200e86:	28660613          	addi	a2,a2,646 # ffffffffc0202108 <commands+0x828>
ffffffffc0200e8a:	10f00593          	li	a1,271
ffffffffc0200e8e:	00001517          	auipc	a0,0x1
ffffffffc0200e92:	29250513          	addi	a0,a0,658 # ffffffffc0202120 <commands+0x840>
ffffffffc0200e96:	d16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e9a:	00001697          	auipc	a3,0x1
ffffffffc0200e9e:	0a668693          	addi	a3,a3,166 # ffffffffc0201f40 <commands+0x660>
ffffffffc0200ea2:	00001617          	auipc	a2,0x1
ffffffffc0200ea6:	26660613          	addi	a2,a2,614 # ffffffffc0202108 <commands+0x828>
ffffffffc0200eaa:	0d800593          	li	a1,216
ffffffffc0200eae:	00001517          	auipc	a0,0x1
ffffffffc0200eb2:	27250513          	addi	a0,a0,626 # ffffffffc0202120 <commands+0x840>
ffffffffc0200eb6:	cf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p4 + 128 == p2);
ffffffffc0200eba:	00001697          	auipc	a3,0x1
ffffffffc0200ebe:	20e68693          	addi	a3,a3,526 # ffffffffc02020c8 <commands+0x7e8>
ffffffffc0200ec2:	00001617          	auipc	a2,0x1
ffffffffc0200ec6:	24660613          	addi	a2,a2,582 # ffffffffc0202108 <commands+0x828>
ffffffffc0200eca:	10800593          	li	a1,264
ffffffffc0200ece:	00001517          	auipc	a0,0x1
ffffffffc0200ed2:	25250513          	addi	a0,a0,594 # ffffffffc0202120 <commands+0x840>
ffffffffc0200ed6:	cd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 + 256 == p3);
ffffffffc0200eda:	00001697          	auipc	a3,0x1
ffffffffc0200ede:	1de68693          	addi	a3,a3,478 # ffffffffc02020b8 <commands+0x7d8>
ffffffffc0200ee2:	00001617          	auipc	a2,0x1
ffffffffc0200ee6:	22660613          	addi	a2,a2,550 # ffffffffc0202108 <commands+0x828>
ffffffffc0200eea:	10200593          	li	a1,258
ffffffffc0200eee:	00001517          	auipc	a0,0x1
ffffffffc0200ef2:	23250513          	addi	a0,a0,562 # ffffffffc0202120 <commands+0x840>
ffffffffc0200ef6:	cb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200efa:	00001697          	auipc	a3,0x1
ffffffffc0200efe:	08668693          	addi	a3,a3,134 # ffffffffc0201f80 <commands+0x6a0>
ffffffffc0200f02:	00001617          	auipc	a2,0x1
ffffffffc0200f06:	20660613          	addi	a2,a2,518 # ffffffffc0202108 <commands+0x828>
ffffffffc0200f0a:	0da00593          	li	a1,218
ffffffffc0200f0e:	00001517          	auipc	a0,0x1
ffffffffc0200f12:	21250513          	addi	a0,a0,530 # ffffffffc0202120 <commands+0x840>
ffffffffc0200f16:	c96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f1a:	00001697          	auipc	a3,0x1
ffffffffc0200f1e:	04668693          	addi	a3,a3,70 # ffffffffc0201f60 <commands+0x680>
ffffffffc0200f22:	00001617          	auipc	a2,0x1
ffffffffc0200f26:	1e660613          	addi	a2,a2,486 # ffffffffc0202108 <commands+0x828>
ffffffffc0200f2a:	0d900593          	li	a1,217
ffffffffc0200f2e:	00001517          	auipc	a0,0x1
ffffffffc0200f32:	1f250513          	addi	a0,a0,498 # ffffffffc0202120 <commands+0x840>
ffffffffc0200f36:	c76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f3a:	00001697          	auipc	a3,0x1
ffffffffc0200f3e:	10668693          	addi	a3,a3,262 # ffffffffc0202040 <commands+0x760>
ffffffffc0200f42:	00001617          	auipc	a2,0x1
ffffffffc0200f46:	1c660613          	addi	a2,a2,454 # ffffffffc0202108 <commands+0x828>
ffffffffc0200f4a:	0e100593          	li	a1,225
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	1d250513          	addi	a0,a0,466 # ffffffffc0202120 <commands+0x840>
ffffffffc0200f56:	c56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f5a:	00001697          	auipc	a3,0x1
ffffffffc0200f5e:	0c668693          	addi	a3,a3,198 # ffffffffc0202020 <commands+0x740>
ffffffffc0200f62:	00001617          	auipc	a2,0x1
ffffffffc0200f66:	1a660613          	addi	a2,a2,422 # ffffffffc0202108 <commands+0x828>
ffffffffc0200f6a:	0e000593          	li	a1,224
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	1b250513          	addi	a0,a0,434 # ffffffffc0202120 <commands+0x840>
ffffffffc0200f76:	c36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 + 128 == p2);// 检查是否相邻
ffffffffc0200f7a:	00001697          	auipc	a3,0x1
ffffffffc0200f7e:	12e68693          	addi	a3,a3,302 # ffffffffc02020a8 <commands+0x7c8>
ffffffffc0200f82:	00001617          	auipc	a2,0x1
ffffffffc0200f86:	18660613          	addi	a2,a2,390 # ffffffffc0202108 <commands+0x828>
ffffffffc0200f8a:	0fc00593          	li	a1,252
ffffffffc0200f8e:	00001517          	auipc	a0,0x1
ffffffffc0200f92:	19250513          	addi	a0,a0,402 # ffffffffc0202120 <commands+0x840>
ffffffffc0200f96:	c16ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == p1); //重新分配，p0也指向最开始的页
ffffffffc0200f9a:	00001697          	auipc	a3,0x1
ffffffffc0200f9e:	0fe68693          	addi	a3,a3,254 # ffffffffc0202098 <commands+0x7b8>
ffffffffc0200fa2:	00001617          	auipc	a2,0x1
ffffffffc0200fa6:	16660613          	addi	a2,a2,358 # ffffffffc0202108 <commands+0x828>
ffffffffc0200faa:	0f600593          	li	a1,246
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	17250513          	addi	a0,a0,370 # ffffffffc0202120 <commands+0x840>
ffffffffc0200fb6:	bf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 - p2 == p2 - p1);//检查相邻关系
ffffffffc0200fba:	00001697          	auipc	a3,0x1
ffffffffc0200fbe:	0c668693          	addi	a3,a3,198 # ffffffffc0202080 <commands+0x7a0>
ffffffffc0200fc2:	00001617          	auipc	a2,0x1
ffffffffc0200fc6:	14660613          	addi	a2,a2,326 # ffffffffc0202108 <commands+0x828>
ffffffffc0200fca:	0ec00593          	li	a1,236
ffffffffc0200fce:	00001517          	auipc	a0,0x1
ffffffffc0200fd2:	15250513          	addi	a0,a0,338 # ffffffffc0202120 <commands+0x840>
ffffffffc0200fd6:	bd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fda:	00001697          	auipc	a3,0x1
ffffffffc0200fde:	08668693          	addi	a3,a3,134 # ffffffffc0202060 <commands+0x780>
ffffffffc0200fe2:	00001617          	auipc	a2,0x1
ffffffffc0200fe6:	12660613          	addi	a2,a2,294 # ffffffffc0202108 <commands+0x828>
ffffffffc0200fea:	0e200593          	li	a1,226
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	13250513          	addi	a0,a0,306 # ffffffffc0202120 <commands+0x840>
ffffffffc0200ff6:	bb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ffa <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0200ffe:	8b89                	andi	a5,a5,2
ffffffffc0201000:	eb89                	bnez	a5,ffffffffc0201012 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201002:	00005797          	auipc	a5,0x5
ffffffffc0201006:	46e78793          	addi	a5,a5,1134 # ffffffffc0206470 <pmm_manager>
ffffffffc020100a:	639c                	ld	a5,0(a5)
ffffffffc020100c:	0187b303          	ld	t1,24(a5)
ffffffffc0201010:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201012:	1141                	addi	sp,sp,-16
ffffffffc0201014:	e406                	sd	ra,8(sp)
ffffffffc0201016:	e022                	sd	s0,0(sp)
ffffffffc0201018:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020101a:	c4aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020101e:	00005797          	auipc	a5,0x5
ffffffffc0201022:	45278793          	addi	a5,a5,1106 # ffffffffc0206470 <pmm_manager>
ffffffffc0201026:	639c                	ld	a5,0(a5)
ffffffffc0201028:	8522                	mv	a0,s0
ffffffffc020102a:	6f9c                	ld	a5,24(a5)
ffffffffc020102c:	9782                	jalr	a5
ffffffffc020102e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201030:	c2eff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201034:	8522                	mv	a0,s0
ffffffffc0201036:	60a2                	ld	ra,8(sp)
ffffffffc0201038:	6402                	ld	s0,0(sp)
ffffffffc020103a:	0141                	addi	sp,sp,16
ffffffffc020103c:	8082                	ret

ffffffffc020103e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020103e:	100027f3          	csrr	a5,sstatus
ffffffffc0201042:	8b89                	andi	a5,a5,2
ffffffffc0201044:	eb89                	bnez	a5,ffffffffc0201056 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201046:	00005797          	auipc	a5,0x5
ffffffffc020104a:	42a78793          	addi	a5,a5,1066 # ffffffffc0206470 <pmm_manager>
ffffffffc020104e:	639c                	ld	a5,0(a5)
ffffffffc0201050:	0207b303          	ld	t1,32(a5)
ffffffffc0201054:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201056:	1101                	addi	sp,sp,-32
ffffffffc0201058:	ec06                	sd	ra,24(sp)
ffffffffc020105a:	e822                	sd	s0,16(sp)
ffffffffc020105c:	e426                	sd	s1,8(sp)
ffffffffc020105e:	842a                	mv	s0,a0
ffffffffc0201060:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201062:	c02ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201066:	00005797          	auipc	a5,0x5
ffffffffc020106a:	40a78793          	addi	a5,a5,1034 # ffffffffc0206470 <pmm_manager>
ffffffffc020106e:	639c                	ld	a5,0(a5)
ffffffffc0201070:	85a6                	mv	a1,s1
ffffffffc0201072:	8522                	mv	a0,s0
ffffffffc0201074:	739c                	ld	a5,32(a5)
ffffffffc0201076:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201078:	6442                	ld	s0,16(sp)
ffffffffc020107a:	60e2                	ld	ra,24(sp)
ffffffffc020107c:	64a2                	ld	s1,8(sp)
ffffffffc020107e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201080:	bdeff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201084 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201084:	00001797          	auipc	a5,0x1
ffffffffc0201088:	11478793          	addi	a5,a5,276 # ffffffffc0202198 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020108c:	638c                	ld	a1,0(a5)
    }
    
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020108e:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201090:	00001517          	auipc	a0,0x1
ffffffffc0201094:	15850513          	addi	a0,a0,344 # ffffffffc02021e8 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201098:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020109a:	00005717          	auipc	a4,0x5
ffffffffc020109e:	3cf73b23          	sd	a5,982(a4) # ffffffffc0206470 <pmm_manager>
void pmm_init(void) {
ffffffffc02010a2:	e822                	sd	s0,16(sp)
ffffffffc02010a4:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02010a6:	00005417          	auipc	s0,0x5
ffffffffc02010aa:	3ca40413          	addi	s0,s0,970 # ffffffffc0206470 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02010ae:	808ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02010b2:	601c                	ld	a5,0(s0)
ffffffffc02010b4:	679c                	ld	a5,8(a5)
ffffffffc02010b6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010b8:	57f5                	li	a5,-3
ffffffffc02010ba:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02010bc:	00001517          	auipc	a0,0x1
ffffffffc02010c0:	14450513          	addi	a0,a0,324 # ffffffffc0202200 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010c4:	00005717          	auipc	a4,0x5
ffffffffc02010c8:	3af73a23          	sd	a5,948(a4) # ffffffffc0206478 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02010cc:	febfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02010d0:	46c5                	li	a3,17
ffffffffc02010d2:	06ee                	slli	a3,a3,0x1b
ffffffffc02010d4:	40100613          	li	a2,1025
ffffffffc02010d8:	16fd                	addi	a3,a3,-1
ffffffffc02010da:	0656                	slli	a2,a2,0x15
ffffffffc02010dc:	07e005b7          	lui	a1,0x7e00
ffffffffc02010e0:	00001517          	auipc	a0,0x1
ffffffffc02010e4:	13850513          	addi	a0,a0,312 # ffffffffc0202218 <buddy_pmm_manager+0x80>
ffffffffc02010e8:	fcffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010ec:	777d                	lui	a4,0xfffff
ffffffffc02010ee:	00006797          	auipc	a5,0x6
ffffffffc02010f2:	39978793          	addi	a5,a5,921 # ffffffffc0207487 <end+0xfff>
ffffffffc02010f6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010f8:	00088737          	lui	a4,0x88
ffffffffc02010fc:	00005697          	auipc	a3,0x5
ffffffffc0201100:	30e6be23          	sd	a4,796(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201104:	4601                	li	a2,0
ffffffffc0201106:	00005717          	auipc	a4,0x5
ffffffffc020110a:	36f73d23          	sd	a5,890(a4) # ffffffffc0206480 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020110e:	4681                	li	a3,0
ffffffffc0201110:	00005897          	auipc	a7,0x5
ffffffffc0201114:	30888893          	addi	a7,a7,776 # ffffffffc0206418 <npage>
ffffffffc0201118:	00005597          	auipc	a1,0x5
ffffffffc020111c:	36858593          	addi	a1,a1,872 # ffffffffc0206480 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201120:	4805                	li	a6,1
ffffffffc0201122:	fff80537          	lui	a0,0xfff80
ffffffffc0201126:	a011                	j	ffffffffc020112a <pmm_init+0xa6>
ffffffffc0201128:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020112a:	97b2                	add	a5,a5,a2
ffffffffc020112c:	07a1                	addi	a5,a5,8
ffffffffc020112e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201132:	0008b703          	ld	a4,0(a7)
ffffffffc0201136:	0685                	addi	a3,a3,1
ffffffffc0201138:	02860613          	addi	a2,a2,40
ffffffffc020113c:	00a707b3          	add	a5,a4,a0
ffffffffc0201140:	fef6e4e3          	bltu	a3,a5,ffffffffc0201128 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201144:	6190                	ld	a2,0(a1)
ffffffffc0201146:	00271793          	slli	a5,a4,0x2
ffffffffc020114a:	97ba                	add	a5,a5,a4
ffffffffc020114c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201150:	078e                	slli	a5,a5,0x3
ffffffffc0201152:	96b2                	add	a3,a3,a2
ffffffffc0201154:	96be                	add	a3,a3,a5
ffffffffc0201156:	c02007b7          	lui	a5,0xc0200
ffffffffc020115a:	08f6e863          	bltu	a3,a5,ffffffffc02011ea <pmm_init+0x166>
ffffffffc020115e:	00005497          	auipc	s1,0x5
ffffffffc0201162:	31a48493          	addi	s1,s1,794 # ffffffffc0206478 <va_pa_offset>
ffffffffc0201166:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201168:	45c5                	li	a1,17
ffffffffc020116a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020116c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020116e:	04b6e963          	bltu	a3,a1,ffffffffc02011c0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201172:	601c                	ld	a5,0(s0)
ffffffffc0201174:	7b9c                	ld	a5,48(a5)
ffffffffc0201176:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	13850513          	addi	a0,a0,312 # ffffffffc02022b0 <buddy_pmm_manager+0x118>
ffffffffc0201180:	f37fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020118c:	00005797          	auipc	a5,0x5
ffffffffc0201190:	28d7ba23          	sd	a3,660(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201194:	c02007b7          	lui	a5,0xc0200
ffffffffc0201198:	06f6e563          	bltu	a3,a5,ffffffffc0201202 <pmm_init+0x17e>
ffffffffc020119c:	609c                	ld	a5,0(s1)
}
ffffffffc020119e:	6442                	ld	s0,16(sp)
ffffffffc02011a0:	60e2                	ld	ra,24(sp)
ffffffffc02011a2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011a4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02011a6:	8e9d                	sub	a3,a3,a5
ffffffffc02011a8:	00005797          	auipc	a5,0x5
ffffffffc02011ac:	2cd7b023          	sd	a3,704(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011b0:	00001517          	auipc	a0,0x1
ffffffffc02011b4:	12050513          	addi	a0,a0,288 # ffffffffc02022d0 <buddy_pmm_manager+0x138>
ffffffffc02011b8:	8636                	mv	a2,a3
}
ffffffffc02011ba:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02011bc:	efbfe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02011c0:	6785                	lui	a5,0x1
ffffffffc02011c2:	17fd                	addi	a5,a5,-1
ffffffffc02011c4:	96be                	add	a3,a3,a5
ffffffffc02011c6:	77fd                	lui	a5,0xfffff
ffffffffc02011c8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011ca:	00c6d793          	srli	a5,a3,0xc
ffffffffc02011ce:	04e7f663          	bleu	a4,a5,ffffffffc020121a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02011d2:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011d4:	97aa                	add	a5,a5,a0
ffffffffc02011d6:	00279513          	slli	a0,a5,0x2
ffffffffc02011da:	953e                	add	a0,a0,a5
ffffffffc02011dc:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011de:	8d95                	sub	a1,a1,a3
ffffffffc02011e0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02011e2:	81b1                	srli	a1,a1,0xc
ffffffffc02011e4:	9532                	add	a0,a0,a2
ffffffffc02011e6:	9782                	jalr	a5
ffffffffc02011e8:	b769                	j	ffffffffc0201172 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011ea:	00001617          	auipc	a2,0x1
ffffffffc02011ee:	05e60613          	addi	a2,a2,94 # ffffffffc0202248 <buddy_pmm_manager+0xb0>
ffffffffc02011f2:	06f00593          	li	a1,111
ffffffffc02011f6:	00001517          	auipc	a0,0x1
ffffffffc02011fa:	07a50513          	addi	a0,a0,122 # ffffffffc0202270 <buddy_pmm_manager+0xd8>
ffffffffc02011fe:	9aeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201202:	00001617          	auipc	a2,0x1
ffffffffc0201206:	04660613          	addi	a2,a2,70 # ffffffffc0202248 <buddy_pmm_manager+0xb0>
ffffffffc020120a:	08b00593          	li	a1,139
ffffffffc020120e:	00001517          	auipc	a0,0x1
ffffffffc0201212:	06250513          	addi	a0,a0,98 # ffffffffc0202270 <buddy_pmm_manager+0xd8>
ffffffffc0201216:	996ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020121a:	00001617          	auipc	a2,0x1
ffffffffc020121e:	06660613          	addi	a2,a2,102 # ffffffffc0202280 <buddy_pmm_manager+0xe8>
ffffffffc0201222:	06c00593          	li	a1,108
ffffffffc0201226:	00001517          	auipc	a0,0x1
ffffffffc020122a:	07a50513          	addi	a0,a0,122 # ffffffffc02022a0 <buddy_pmm_manager+0x108>
ffffffffc020122e:	97eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201232 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201232:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201236:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201238:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020123c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020123e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201242:	f022                	sd	s0,32(sp)
ffffffffc0201244:	ec26                	sd	s1,24(sp)
ffffffffc0201246:	e84a                	sd	s2,16(sp)
ffffffffc0201248:	f406                	sd	ra,40(sp)
ffffffffc020124a:	e44e                	sd	s3,8(sp)
ffffffffc020124c:	84aa                	mv	s1,a0
ffffffffc020124e:	892e                	mv	s2,a1
ffffffffc0201250:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201254:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201256:	03067e63          	bleu	a6,a2,ffffffffc0201292 <printnum+0x60>
ffffffffc020125a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020125c:	00805763          	blez	s0,ffffffffc020126a <printnum+0x38>
ffffffffc0201260:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201262:	85ca                	mv	a1,s2
ffffffffc0201264:	854e                	mv	a0,s3
ffffffffc0201266:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201268:	fc65                	bnez	s0,ffffffffc0201260 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020126a:	1a02                	slli	s4,s4,0x20
ffffffffc020126c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201270:	00001797          	auipc	a5,0x1
ffffffffc0201274:	23078793          	addi	a5,a5,560 # ffffffffc02024a0 <error_string+0x38>
ffffffffc0201278:	9a3e                	add	s4,s4,a5
}
ffffffffc020127a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020127c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201280:	70a2                	ld	ra,40(sp)
ffffffffc0201282:	69a2                	ld	s3,8(sp)
ffffffffc0201284:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201286:	85ca                	mv	a1,s2
ffffffffc0201288:	8326                	mv	t1,s1
}
ffffffffc020128a:	6942                	ld	s2,16(sp)
ffffffffc020128c:	64e2                	ld	s1,24(sp)
ffffffffc020128e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201290:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201292:	03065633          	divu	a2,a2,a6
ffffffffc0201296:	8722                	mv	a4,s0
ffffffffc0201298:	f9bff0ef          	jal	ra,ffffffffc0201232 <printnum>
ffffffffc020129c:	b7f9                	j	ffffffffc020126a <printnum+0x38>

ffffffffc020129e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020129e:	7119                	addi	sp,sp,-128
ffffffffc02012a0:	f4a6                	sd	s1,104(sp)
ffffffffc02012a2:	f0ca                	sd	s2,96(sp)
ffffffffc02012a4:	e8d2                	sd	s4,80(sp)
ffffffffc02012a6:	e4d6                	sd	s5,72(sp)
ffffffffc02012a8:	e0da                	sd	s6,64(sp)
ffffffffc02012aa:	fc5e                	sd	s7,56(sp)
ffffffffc02012ac:	f862                	sd	s8,48(sp)
ffffffffc02012ae:	f06a                	sd	s10,32(sp)
ffffffffc02012b0:	fc86                	sd	ra,120(sp)
ffffffffc02012b2:	f8a2                	sd	s0,112(sp)
ffffffffc02012b4:	ecce                	sd	s3,88(sp)
ffffffffc02012b6:	f466                	sd	s9,40(sp)
ffffffffc02012b8:	ec6e                	sd	s11,24(sp)
ffffffffc02012ba:	892a                	mv	s2,a0
ffffffffc02012bc:	84ae                	mv	s1,a1
ffffffffc02012be:	8d32                	mv	s10,a2
ffffffffc02012c0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02012c2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c4:	00001a17          	auipc	s4,0x1
ffffffffc02012c8:	04ca0a13          	addi	s4,s4,76 # ffffffffc0202310 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012cc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02012d0:	00001c17          	auipc	s8,0x1
ffffffffc02012d4:	198c0c13          	addi	s8,s8,408 # ffffffffc0202468 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012d8:	000d4503          	lbu	a0,0(s10)
ffffffffc02012dc:	02500793          	li	a5,37
ffffffffc02012e0:	001d0413          	addi	s0,s10,1
ffffffffc02012e4:	00f50e63          	beq	a0,a5,ffffffffc0201300 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02012e8:	c521                	beqz	a0,ffffffffc0201330 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ea:	02500993          	li	s3,37
ffffffffc02012ee:	a011                	j	ffffffffc02012f2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02012f0:	c121                	beqz	a0,ffffffffc0201330 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02012f2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012f4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02012f6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012f8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012fc:	ff351ae3          	bne	a0,s3,ffffffffc02012f0 <vprintfmt+0x52>
ffffffffc0201300:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201304:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201308:	4981                	li	s3,0
ffffffffc020130a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020130c:	5cfd                	li	s9,-1
ffffffffc020130e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201310:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201314:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201316:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020131a:	0ff6f693          	andi	a3,a3,255
ffffffffc020131e:	00140d13          	addi	s10,s0,1
ffffffffc0201322:	20d5e563          	bltu	a1,a3,ffffffffc020152c <vprintfmt+0x28e>
ffffffffc0201326:	068a                	slli	a3,a3,0x2
ffffffffc0201328:	96d2                	add	a3,a3,s4
ffffffffc020132a:	4294                	lw	a3,0(a3)
ffffffffc020132c:	96d2                	add	a3,a3,s4
ffffffffc020132e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201330:	70e6                	ld	ra,120(sp)
ffffffffc0201332:	7446                	ld	s0,112(sp)
ffffffffc0201334:	74a6                	ld	s1,104(sp)
ffffffffc0201336:	7906                	ld	s2,96(sp)
ffffffffc0201338:	69e6                	ld	s3,88(sp)
ffffffffc020133a:	6a46                	ld	s4,80(sp)
ffffffffc020133c:	6aa6                	ld	s5,72(sp)
ffffffffc020133e:	6b06                	ld	s6,64(sp)
ffffffffc0201340:	7be2                	ld	s7,56(sp)
ffffffffc0201342:	7c42                	ld	s8,48(sp)
ffffffffc0201344:	7ca2                	ld	s9,40(sp)
ffffffffc0201346:	7d02                	ld	s10,32(sp)
ffffffffc0201348:	6de2                	ld	s11,24(sp)
ffffffffc020134a:	6109                	addi	sp,sp,128
ffffffffc020134c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020134e:	4705                	li	a4,1
ffffffffc0201350:	008a8593          	addi	a1,s5,8
ffffffffc0201354:	01074463          	blt	a4,a6,ffffffffc020135c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201358:	26080363          	beqz	a6,ffffffffc02015be <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020135c:	000ab603          	ld	a2,0(s5)
ffffffffc0201360:	46c1                	li	a3,16
ffffffffc0201362:	8aae                	mv	s5,a1
ffffffffc0201364:	a06d                	j	ffffffffc020140e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201366:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020136a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020136c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020136e:	b765                	j	ffffffffc0201316 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201370:	000aa503          	lw	a0,0(s5)
ffffffffc0201374:	85a6                	mv	a1,s1
ffffffffc0201376:	0aa1                	addi	s5,s5,8
ffffffffc0201378:	9902                	jalr	s2
            break;
ffffffffc020137a:	bfb9                	j	ffffffffc02012d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020137c:	4705                	li	a4,1
ffffffffc020137e:	008a8993          	addi	s3,s5,8
ffffffffc0201382:	01074463          	blt	a4,a6,ffffffffc020138a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201386:	22080463          	beqz	a6,ffffffffc02015ae <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020138a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020138e:	24044463          	bltz	s0,ffffffffc02015d6 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201392:	8622                	mv	a2,s0
ffffffffc0201394:	8ace                	mv	s5,s3
ffffffffc0201396:	46a9                	li	a3,10
ffffffffc0201398:	a89d                	j	ffffffffc020140e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020139a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020139e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02013a0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02013a2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02013a6:	8fb5                	xor	a5,a5,a3
ffffffffc02013a8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013ac:	1ad74363          	blt	a4,a3,ffffffffc0201552 <vprintfmt+0x2b4>
ffffffffc02013b0:	00369793          	slli	a5,a3,0x3
ffffffffc02013b4:	97e2                	add	a5,a5,s8
ffffffffc02013b6:	639c                	ld	a5,0(a5)
ffffffffc02013b8:	18078d63          	beqz	a5,ffffffffc0201552 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02013bc:	86be                	mv	a3,a5
ffffffffc02013be:	00001617          	auipc	a2,0x1
ffffffffc02013c2:	19260613          	addi	a2,a2,402 # ffffffffc0202550 <error_string+0xe8>
ffffffffc02013c6:	85a6                	mv	a1,s1
ffffffffc02013c8:	854a                	mv	a0,s2
ffffffffc02013ca:	240000ef          	jal	ra,ffffffffc020160a <printfmt>
ffffffffc02013ce:	b729                	j	ffffffffc02012d8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02013d0:	00144603          	lbu	a2,1(s0)
ffffffffc02013d4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013d8:	bf3d                	j	ffffffffc0201316 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02013da:	4705                	li	a4,1
ffffffffc02013dc:	008a8593          	addi	a1,s5,8
ffffffffc02013e0:	01074463          	blt	a4,a6,ffffffffc02013e8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02013e4:	1e080263          	beqz	a6,ffffffffc02015c8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02013e8:	000ab603          	ld	a2,0(s5)
ffffffffc02013ec:	46a1                	li	a3,8
ffffffffc02013ee:	8aae                	mv	s5,a1
ffffffffc02013f0:	a839                	j	ffffffffc020140e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02013f2:	03000513          	li	a0,48
ffffffffc02013f6:	85a6                	mv	a1,s1
ffffffffc02013f8:	e03e                	sd	a5,0(sp)
ffffffffc02013fa:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02013fc:	85a6                	mv	a1,s1
ffffffffc02013fe:	07800513          	li	a0,120
ffffffffc0201402:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201404:	0aa1                	addi	s5,s5,8
ffffffffc0201406:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020140a:	6782                	ld	a5,0(sp)
ffffffffc020140c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020140e:	876e                	mv	a4,s11
ffffffffc0201410:	85a6                	mv	a1,s1
ffffffffc0201412:	854a                	mv	a0,s2
ffffffffc0201414:	e1fff0ef          	jal	ra,ffffffffc0201232 <printnum>
            break;
ffffffffc0201418:	b5c1                	j	ffffffffc02012d8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020141a:	000ab603          	ld	a2,0(s5)
ffffffffc020141e:	0aa1                	addi	s5,s5,8
ffffffffc0201420:	1c060663          	beqz	a2,ffffffffc02015ec <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201424:	00160413          	addi	s0,a2,1
ffffffffc0201428:	17b05c63          	blez	s11,ffffffffc02015a0 <vprintfmt+0x302>
ffffffffc020142c:	02d00593          	li	a1,45
ffffffffc0201430:	14b79263          	bne	a5,a1,ffffffffc0201574 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201434:	00064783          	lbu	a5,0(a2)
ffffffffc0201438:	0007851b          	sext.w	a0,a5
ffffffffc020143c:	c905                	beqz	a0,ffffffffc020146c <vprintfmt+0x1ce>
ffffffffc020143e:	000cc563          	bltz	s9,ffffffffc0201448 <vprintfmt+0x1aa>
ffffffffc0201442:	3cfd                	addiw	s9,s9,-1
ffffffffc0201444:	036c8263          	beq	s9,s6,ffffffffc0201468 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201448:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020144a:	18098463          	beqz	s3,ffffffffc02015d2 <vprintfmt+0x334>
ffffffffc020144e:	3781                	addiw	a5,a5,-32
ffffffffc0201450:	18fbf163          	bleu	a5,s7,ffffffffc02015d2 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201454:	03f00513          	li	a0,63
ffffffffc0201458:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020145a:	0405                	addi	s0,s0,1
ffffffffc020145c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201460:	3dfd                	addiw	s11,s11,-1
ffffffffc0201462:	0007851b          	sext.w	a0,a5
ffffffffc0201466:	fd61                	bnez	a0,ffffffffc020143e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201468:	e7b058e3          	blez	s11,ffffffffc02012d8 <vprintfmt+0x3a>
ffffffffc020146c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020146e:	85a6                	mv	a1,s1
ffffffffc0201470:	02000513          	li	a0,32
ffffffffc0201474:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201476:	e60d81e3          	beqz	s11,ffffffffc02012d8 <vprintfmt+0x3a>
ffffffffc020147a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020147c:	85a6                	mv	a1,s1
ffffffffc020147e:	02000513          	li	a0,32
ffffffffc0201482:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201484:	fe0d94e3          	bnez	s11,ffffffffc020146c <vprintfmt+0x1ce>
ffffffffc0201488:	bd81                	j	ffffffffc02012d8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020148a:	4705                	li	a4,1
ffffffffc020148c:	008a8593          	addi	a1,s5,8
ffffffffc0201490:	01074463          	blt	a4,a6,ffffffffc0201498 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201494:	12080063          	beqz	a6,ffffffffc02015b4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201498:	000ab603          	ld	a2,0(s5)
ffffffffc020149c:	46a9                	li	a3,10
ffffffffc020149e:	8aae                	mv	s5,a1
ffffffffc02014a0:	b7bd                	j	ffffffffc020140e <vprintfmt+0x170>
ffffffffc02014a2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02014a6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014aa:	846a                	mv	s0,s10
ffffffffc02014ac:	b5ad                	j	ffffffffc0201316 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02014ae:	85a6                	mv	a1,s1
ffffffffc02014b0:	02500513          	li	a0,37
ffffffffc02014b4:	9902                	jalr	s2
            break;
ffffffffc02014b6:	b50d                	j	ffffffffc02012d8 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02014b8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02014bc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02014c0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014c2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02014c4:	e40dd9e3          	bgez	s11,ffffffffc0201316 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02014c8:	8de6                	mv	s11,s9
ffffffffc02014ca:	5cfd                	li	s9,-1
ffffffffc02014cc:	b5a9                	j	ffffffffc0201316 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02014ce:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02014d2:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014d8:	bd3d                	j	ffffffffc0201316 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02014da:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02014de:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02014e4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02014e8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014ec:	fcd56ce3          	bltu	a0,a3,ffffffffc02014c4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02014f0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02014f2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02014f6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02014fa:	0196873b          	addw	a4,a3,s9
ffffffffc02014fe:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201502:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201506:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020150a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020150e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201512:	fcd57fe3          	bleu	a3,a0,ffffffffc02014f0 <vprintfmt+0x252>
ffffffffc0201516:	b77d                	j	ffffffffc02014c4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201518:	fffdc693          	not	a3,s11
ffffffffc020151c:	96fd                	srai	a3,a3,0x3f
ffffffffc020151e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201522:	00144603          	lbu	a2,1(s0)
ffffffffc0201526:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201528:	846a                	mv	s0,s10
ffffffffc020152a:	b3f5                	j	ffffffffc0201316 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020152c:	85a6                	mv	a1,s1
ffffffffc020152e:	02500513          	li	a0,37
ffffffffc0201532:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201534:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201538:	02500793          	li	a5,37
ffffffffc020153c:	8d22                	mv	s10,s0
ffffffffc020153e:	d8f70de3          	beq	a4,a5,ffffffffc02012d8 <vprintfmt+0x3a>
ffffffffc0201542:	02500713          	li	a4,37
ffffffffc0201546:	1d7d                	addi	s10,s10,-1
ffffffffc0201548:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020154c:	fee79de3          	bne	a5,a4,ffffffffc0201546 <vprintfmt+0x2a8>
ffffffffc0201550:	b361                	j	ffffffffc02012d8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201552:	00001617          	auipc	a2,0x1
ffffffffc0201556:	fee60613          	addi	a2,a2,-18 # ffffffffc0202540 <error_string+0xd8>
ffffffffc020155a:	85a6                	mv	a1,s1
ffffffffc020155c:	854a                	mv	a0,s2
ffffffffc020155e:	0ac000ef          	jal	ra,ffffffffc020160a <printfmt>
ffffffffc0201562:	bb9d                	j	ffffffffc02012d8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201564:	00001617          	auipc	a2,0x1
ffffffffc0201568:	fd460613          	addi	a2,a2,-44 # ffffffffc0202538 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020156c:	00001417          	auipc	s0,0x1
ffffffffc0201570:	fcd40413          	addi	s0,s0,-51 # ffffffffc0202539 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201574:	8532                	mv	a0,a2
ffffffffc0201576:	85e6                	mv	a1,s9
ffffffffc0201578:	e032                	sd	a2,0(sp)
ffffffffc020157a:	e43e                	sd	a5,8(sp)
ffffffffc020157c:	1c2000ef          	jal	ra,ffffffffc020173e <strnlen>
ffffffffc0201580:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201584:	6602                	ld	a2,0(sp)
ffffffffc0201586:	01b05d63          	blez	s11,ffffffffc02015a0 <vprintfmt+0x302>
ffffffffc020158a:	67a2                	ld	a5,8(sp)
ffffffffc020158c:	2781                	sext.w	a5,a5
ffffffffc020158e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201590:	6522                	ld	a0,8(sp)
ffffffffc0201592:	85a6                	mv	a1,s1
ffffffffc0201594:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201596:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201598:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020159a:	6602                	ld	a2,0(sp)
ffffffffc020159c:	fe0d9ae3          	bnez	s11,ffffffffc0201590 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015a0:	00064783          	lbu	a5,0(a2)
ffffffffc02015a4:	0007851b          	sext.w	a0,a5
ffffffffc02015a8:	e8051be3          	bnez	a0,ffffffffc020143e <vprintfmt+0x1a0>
ffffffffc02015ac:	b335                	j	ffffffffc02012d8 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02015ae:	000aa403          	lw	s0,0(s5)
ffffffffc02015b2:	bbf1                	j	ffffffffc020138e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02015b4:	000ae603          	lwu	a2,0(s5)
ffffffffc02015b8:	46a9                	li	a3,10
ffffffffc02015ba:	8aae                	mv	s5,a1
ffffffffc02015bc:	bd89                	j	ffffffffc020140e <vprintfmt+0x170>
ffffffffc02015be:	000ae603          	lwu	a2,0(s5)
ffffffffc02015c2:	46c1                	li	a3,16
ffffffffc02015c4:	8aae                	mv	s5,a1
ffffffffc02015c6:	b5a1                	j	ffffffffc020140e <vprintfmt+0x170>
ffffffffc02015c8:	000ae603          	lwu	a2,0(s5)
ffffffffc02015cc:	46a1                	li	a3,8
ffffffffc02015ce:	8aae                	mv	s5,a1
ffffffffc02015d0:	bd3d                	j	ffffffffc020140e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02015d2:	9902                	jalr	s2
ffffffffc02015d4:	b559                	j	ffffffffc020145a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02015d6:	85a6                	mv	a1,s1
ffffffffc02015d8:	02d00513          	li	a0,45
ffffffffc02015dc:	e03e                	sd	a5,0(sp)
ffffffffc02015de:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02015e0:	8ace                	mv	s5,s3
ffffffffc02015e2:	40800633          	neg	a2,s0
ffffffffc02015e6:	46a9                	li	a3,10
ffffffffc02015e8:	6782                	ld	a5,0(sp)
ffffffffc02015ea:	b515                	j	ffffffffc020140e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02015ec:	01b05663          	blez	s11,ffffffffc02015f8 <vprintfmt+0x35a>
ffffffffc02015f0:	02d00693          	li	a3,45
ffffffffc02015f4:	f6d798e3          	bne	a5,a3,ffffffffc0201564 <vprintfmt+0x2c6>
ffffffffc02015f8:	00001417          	auipc	s0,0x1
ffffffffc02015fc:	f4140413          	addi	s0,s0,-191 # ffffffffc0202539 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201600:	02800513          	li	a0,40
ffffffffc0201604:	02800793          	li	a5,40
ffffffffc0201608:	bd1d                	j	ffffffffc020143e <vprintfmt+0x1a0>

ffffffffc020160a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020160a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020160c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201610:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201612:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201614:	ec06                	sd	ra,24(sp)
ffffffffc0201616:	f83a                	sd	a4,48(sp)
ffffffffc0201618:	fc3e                	sd	a5,56(sp)
ffffffffc020161a:	e0c2                	sd	a6,64(sp)
ffffffffc020161c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020161e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201620:	c7fff0ef          	jal	ra,ffffffffc020129e <vprintfmt>
}
ffffffffc0201624:	60e2                	ld	ra,24(sp)
ffffffffc0201626:	6161                	addi	sp,sp,80
ffffffffc0201628:	8082                	ret

ffffffffc020162a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020162a:	715d                	addi	sp,sp,-80
ffffffffc020162c:	e486                	sd	ra,72(sp)
ffffffffc020162e:	e0a2                	sd	s0,64(sp)
ffffffffc0201630:	fc26                	sd	s1,56(sp)
ffffffffc0201632:	f84a                	sd	s2,48(sp)
ffffffffc0201634:	f44e                	sd	s3,40(sp)
ffffffffc0201636:	f052                	sd	s4,32(sp)
ffffffffc0201638:	ec56                	sd	s5,24(sp)
ffffffffc020163a:	e85a                	sd	s6,16(sp)
ffffffffc020163c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020163e:	c901                	beqz	a0,ffffffffc020164e <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201640:	85aa                	mv	a1,a0
ffffffffc0201642:	00001517          	auipc	a0,0x1
ffffffffc0201646:	f0e50513          	addi	a0,a0,-242 # ffffffffc0202550 <error_string+0xe8>
ffffffffc020164a:	a6dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc020164e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201650:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201652:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201654:	4aa9                	li	s5,10
ffffffffc0201656:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201658:	00005b97          	auipc	s7,0x5
ffffffffc020165c:	9b8b8b93          	addi	s7,s7,-1608 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201660:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201664:	acbfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201668:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020166a:	00054b63          	bltz	a0,ffffffffc0201680 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020166e:	00a95b63          	ble	a0,s2,ffffffffc0201684 <readline+0x5a>
ffffffffc0201672:	029a5463          	ble	s1,s4,ffffffffc020169a <readline+0x70>
        c = getchar();
ffffffffc0201676:	ab9fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020167a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020167c:	fe0559e3          	bgez	a0,ffffffffc020166e <readline+0x44>
            return NULL;
ffffffffc0201680:	4501                	li	a0,0
ffffffffc0201682:	a099                	j	ffffffffc02016c8 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201684:	03341463          	bne	s0,s3,ffffffffc02016ac <readline+0x82>
ffffffffc0201688:	e8b9                	bnez	s1,ffffffffc02016de <readline+0xb4>
        c = getchar();
ffffffffc020168a:	aa5fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020168e:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201690:	fe0548e3          	bltz	a0,ffffffffc0201680 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201694:	fea958e3          	ble	a0,s2,ffffffffc0201684 <readline+0x5a>
ffffffffc0201698:	4481                	li	s1,0
            cputchar(c);
ffffffffc020169a:	8522                	mv	a0,s0
ffffffffc020169c:	a4ffe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02016a0:	009b87b3          	add	a5,s7,s1
ffffffffc02016a4:	00878023          	sb	s0,0(a5)
ffffffffc02016a8:	2485                	addiw	s1,s1,1
ffffffffc02016aa:	bf6d                	j	ffffffffc0201664 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02016ac:	01540463          	beq	s0,s5,ffffffffc02016b4 <readline+0x8a>
ffffffffc02016b0:	fb641ae3          	bne	s0,s6,ffffffffc0201664 <readline+0x3a>
            cputchar(c);
ffffffffc02016b4:	8522                	mv	a0,s0
ffffffffc02016b6:	a35fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02016ba:	00005517          	auipc	a0,0x5
ffffffffc02016be:	95650513          	addi	a0,a0,-1706 # ffffffffc0206010 <edata>
ffffffffc02016c2:	94aa                	add	s1,s1,a0
ffffffffc02016c4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02016c8:	60a6                	ld	ra,72(sp)
ffffffffc02016ca:	6406                	ld	s0,64(sp)
ffffffffc02016cc:	74e2                	ld	s1,56(sp)
ffffffffc02016ce:	7942                	ld	s2,48(sp)
ffffffffc02016d0:	79a2                	ld	s3,40(sp)
ffffffffc02016d2:	7a02                	ld	s4,32(sp)
ffffffffc02016d4:	6ae2                	ld	s5,24(sp)
ffffffffc02016d6:	6b42                	ld	s6,16(sp)
ffffffffc02016d8:	6ba2                	ld	s7,8(sp)
ffffffffc02016da:	6161                	addi	sp,sp,80
ffffffffc02016dc:	8082                	ret
            cputchar(c);
ffffffffc02016de:	4521                	li	a0,8
ffffffffc02016e0:	a0bfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02016e4:	34fd                	addiw	s1,s1,-1
ffffffffc02016e6:	bfbd                	j	ffffffffc0201664 <readline+0x3a>

ffffffffc02016e8 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02016e8:	00005797          	auipc	a5,0x5
ffffffffc02016ec:	92078793          	addi	a5,a5,-1760 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02016f0:	6398                	ld	a4,0(a5)
ffffffffc02016f2:	4781                	li	a5,0
ffffffffc02016f4:	88ba                	mv	a7,a4
ffffffffc02016f6:	852a                	mv	a0,a0
ffffffffc02016f8:	85be                	mv	a1,a5
ffffffffc02016fa:	863e                	mv	a2,a5
ffffffffc02016fc:	00000073          	ecall
ffffffffc0201700:	87aa                	mv	a5,a0
}
ffffffffc0201702:	8082                	ret

ffffffffc0201704 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201704:	00005797          	auipc	a5,0x5
ffffffffc0201708:	d2478793          	addi	a5,a5,-732 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc020170c:	6398                	ld	a4,0(a5)
ffffffffc020170e:	4781                	li	a5,0
ffffffffc0201710:	88ba                	mv	a7,a4
ffffffffc0201712:	852a                	mv	a0,a0
ffffffffc0201714:	85be                	mv	a1,a5
ffffffffc0201716:	863e                	mv	a2,a5
ffffffffc0201718:	00000073          	ecall
ffffffffc020171c:	87aa                	mv	a5,a0
}
ffffffffc020171e:	8082                	ret

ffffffffc0201720 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201720:	00005797          	auipc	a5,0x5
ffffffffc0201724:	8e078793          	addi	a5,a5,-1824 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201728:	639c                	ld	a5,0(a5)
ffffffffc020172a:	4501                	li	a0,0
ffffffffc020172c:	88be                	mv	a7,a5
ffffffffc020172e:	852a                	mv	a0,a0
ffffffffc0201730:	85aa                	mv	a1,a0
ffffffffc0201732:	862a                	mv	a2,a0
ffffffffc0201734:	00000073          	ecall
ffffffffc0201738:	852a                	mv	a0,a0
ffffffffc020173a:	2501                	sext.w	a0,a0
ffffffffc020173c:	8082                	ret

ffffffffc020173e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020173e:	c185                	beqz	a1,ffffffffc020175e <strnlen+0x20>
ffffffffc0201740:	00054783          	lbu	a5,0(a0)
ffffffffc0201744:	cf89                	beqz	a5,ffffffffc020175e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201746:	4781                	li	a5,0
ffffffffc0201748:	a021                	j	ffffffffc0201750 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020174a:	00074703          	lbu	a4,0(a4)
ffffffffc020174e:	c711                	beqz	a4,ffffffffc020175a <strnlen+0x1c>
        cnt ++;
ffffffffc0201750:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201752:	00f50733          	add	a4,a0,a5
ffffffffc0201756:	fef59ae3          	bne	a1,a5,ffffffffc020174a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020175a:	853e                	mv	a0,a5
ffffffffc020175c:	8082                	ret
    size_t cnt = 0;
ffffffffc020175e:	4781                	li	a5,0
}
ffffffffc0201760:	853e                	mv	a0,a5
ffffffffc0201762:	8082                	ret

ffffffffc0201764 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201764:	00054783          	lbu	a5,0(a0)
ffffffffc0201768:	0005c703          	lbu	a4,0(a1)
ffffffffc020176c:	cb91                	beqz	a5,ffffffffc0201780 <strcmp+0x1c>
ffffffffc020176e:	00e79c63          	bne	a5,a4,ffffffffc0201786 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201772:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201774:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201778:	0585                	addi	a1,a1,1
ffffffffc020177a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020177e:	fbe5                	bnez	a5,ffffffffc020176e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201780:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201782:	9d19                	subw	a0,a0,a4
ffffffffc0201784:	8082                	ret
ffffffffc0201786:	0007851b          	sext.w	a0,a5
ffffffffc020178a:	9d19                	subw	a0,a0,a4
ffffffffc020178c:	8082                	ret

ffffffffc020178e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020178e:	00054783          	lbu	a5,0(a0)
ffffffffc0201792:	cb91                	beqz	a5,ffffffffc02017a6 <strchr+0x18>
        if (*s == c) {
ffffffffc0201794:	00b79563          	bne	a5,a1,ffffffffc020179e <strchr+0x10>
ffffffffc0201798:	a809                	j	ffffffffc02017aa <strchr+0x1c>
ffffffffc020179a:	00b78763          	beq	a5,a1,ffffffffc02017a8 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020179e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02017a0:	00054783          	lbu	a5,0(a0)
ffffffffc02017a4:	fbfd                	bnez	a5,ffffffffc020179a <strchr+0xc>
    }
    return NULL;
ffffffffc02017a6:	4501                	li	a0,0
}
ffffffffc02017a8:	8082                	ret
ffffffffc02017aa:	8082                	ret

ffffffffc02017ac <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02017ac:	ca01                	beqz	a2,ffffffffc02017bc <memset+0x10>
ffffffffc02017ae:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017b0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017b2:	0785                	addi	a5,a5,1
ffffffffc02017b4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02017b8:	fec79de3          	bne	a5,a2,ffffffffc02017b2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017bc:	8082                	ret

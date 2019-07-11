int main() {
    unsigned short s = 0;
    while (1) {
        for (volatile int i = 0; i < 100; i++) {}
        asm volatile("sb %[some], 0(%[some2])" : : [some]"r" (s >> 8), [some2]"r" (0x8000000000000005));
        asm volatile("sb %[some], 0(%[some2])" : : [some]"r" (s), [some2]"r" (0x8000000000000004));
    }
    return 0;
}

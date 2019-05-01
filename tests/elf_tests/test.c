// Jump to main of the program
asm("j main");
// Function prototype for foo
long foo(long a, long b);

int main() {
    long a, b = 1;
    a = foo(a, b);
    return 0;
}

long foo(long a, long b) {
    long res = 0;
    for (volatile int i = 0; i < 100; i++) {
        res += a + b;
    }
    return res;
}
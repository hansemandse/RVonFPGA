// Minimal start up code taken from the 02155 Computer Architecture Engineering lab 7
asm("li sp, 0x800"); // SP set to 2048
asm("j main"); // Jump to the main function of the program

long add(long a, long b) {
    return a + b;
}

int main() {
    long a = 7613273, b = 82162738;
    long c = add(a, b);
    return 0;
}
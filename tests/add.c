// Minimal start up code taken from the 02155 Computer Architecture Engineering lab 7
asm("li sp, 0x800"); // SP set to 2048
asm("j main"); // Jump to the main function of the program

int main() {
    long a = 115, b = 7142;
    long c = a + b;
    return 0;
}
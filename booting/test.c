/*#include "boot_funcs.h"

int main(void) {
    int val = 0;
    for (;;) {
        for (volatile int i = 0; i < 100000000; i++) {}
        val++;
        write_led_lo((char) val);
        write_led_hi((char) (val >> 8));
    }
    return 0;
}
*/

char sum1(char *a, int n) {
    char s = 0;
    for (int i = 0; i < n; i++)
        s += a[i];
    return s;
}

short sum2(short *a, int n) {
    short s = 0;
    for (int i = 0; i < n; i++)
        s += a[i];
    return s;
}

int sum3(int *a, int n) {
    int s = 0;
    for (int i = 0; i < n; i++)
        s += a[i];
    return s;
}

long main(void) {
    static char a[5] = "Hans";
    static char b[5] = "Hens";
    static short c[2] = {124, 12214};
    static short d[2] = {12451, 14312};
    static int e[3] = {418326, 3127321, 321411};
    static int f[3] = {1237231, 4310892, 321821};
    int s = sum1(a, 5) + sum1(b, 5) + sum2(c, 2) + sum2(d, 2) + sum3(e, 3) + sum3(f, 3);
    for (int i = 0; i < 5; i++)
        a[i] += s;
    return 0;
}
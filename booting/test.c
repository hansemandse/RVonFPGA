#include "boot_funcs.h"

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

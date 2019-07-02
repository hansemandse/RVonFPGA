// ***********************************************************************
//              |
// Title        : Implementation and Optimization of a RISC-V Processor on
//              : a FPGA
//              |
// Developers   : Hans Jakob Damsgaard, Technical University of Denmark
//              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
//              |
// Purpose      : This file is a part of a full system implemented as part
//              : of a bachelor's thesis at DTU. The thesis is written in
//              : cooperation with the Institute of Mathematics and
//              : Computer Science.
//              : This code is a set of function wrappers for the
//              : low-level assembly implemented functions of the
//              : bootloader such that these may be used by other C
//              : programs.
//              |
// Revision     : 1.0   (last updated July 2, 2019)
//              |
// Available at : https://github.com/hansemandse/RVonFPGA
//              |
// ***********************************************************************

// Constants for addressing the memory mapped I/O modules
#define UART_DATA_ADDR      0x8000000000000001
#define UART_STB_OUT_ADDR   0x8000000000000002
#define UART_STB_IN_ADDR    0x8000000000000003
#define LED_LO_ADDR         0x8000000000000004
#define LED_HI_ADDR         0x8000000000000005
#define SW_LO_ADDR          0x8000000000000004
#define SW_HI_ADDR          0x8000000000000005
#define MEM_START           0x1000000000000000

char uart_stb_in(void) {
    char ret;
    asm("lb %[some], 0(%[some2])" : [some]"=r" (ret) : [some2]"r" (UART_STB_IN_ADDR));
    return ret;
}

char uart_stb_out(void) {
    char ret;
    asm("lb %[some], 0(%[some2])" : [some]"=r" (ret) : [some2]"r" (UART_STB_OUT_ADDR));
    return ret;
}

char read_uart(void) {
    char ret;
    // If data is not ready, spin on the ready register
    while (!uart_stb_in()) {}
    // New data was available; read it into the variable ret
    asm("lb %[some], 0(%[some2])" : [some]"=r" (ret) : [some2]"r" (UART_DATA_ADDR));
    return ret;
}

void write_uart(char val) {
    // Write the argument to the UART data register address
    asm("sb %[some], 0(%[some2])" : : [some]"r" (val), [some2]"r" (UART_DATA_ADDR));
    return;
}

void write_led_lo(char val) {
    asm("sb %[some], 0(%[some2])" : : [some]"r" (val), [some2]"r" (LED_LO_ADDR));
    return;
}
void write_led_hi(char val) {
    asm("sb %[some], 0(%[some2])" : : [some]"r" (val), [some2]"r" (LED_HI_ADDR));
    return;
}

char read_sw_lo(void) {
    char ret;
    asm("lb %[some], 0(%[some2])" : [some]"=r" (ret) : [some2]"r" (SW_LO_ADDR));
    return ret;
}
char read_sw_hi(void) {
    char ret;
    asm("lb %[some], 0(%[some2])" : [some]"=r" (ret) : [some2]"r" (SW_HI_ADDR));
    return ret;
}

int read_srec(void) {
    char count, checksum, type = '\0';
    int address, reccount = 0;
    char array[ 8 + 64 + 2 ];
    while (!(type >= '7' && type <= '9')) {
        // Poll the uart until an 'S' is received
        while (read_uart() != 'S') {}
        type = read_uart();
        if (type < '0' || type > '9') {
            // Illegal type received - should be between '0'-'9'
            return -1;
        }
        // Read in the number of bytes expected
        array[0] = read_uart();
        array[0] = array[0] <= '9' ? array[0] - '0' : array[0] - 'A' + 0xA;
        array[1] = read_uart();
        array[1] = array[1] <= '9' ? array[1] - '0' : array[1] - 'A' + 0xA;
        count = ((array[0] << 4) | (array[1])) << 1;
        // Reading in the data
        for (int i = 0; i < count; i++) {
            array[i] = read_uart();
            array[i] = array[i] <= '9' ? array[i] - '0' : array[i] - 'A' + 0xA;
        }
        // Formatting the data (combining two characters to a single byte)
        for (int i = 0; i < count; i += 2) {
            array[i] = (array[i] << 4) | (0x0F & array[i+1]);
        }
        // Update the count value for analyzing the checksum
        count = count >> 1;
        // Sum the count, address and data fields
        checksum = count;
        for (int i = 0; i < count-1; i++) {
            checksum += array[i];
        }
        // The checksum should be the one's complement of the sum of the count,
        // address and data fields
        if (checksum != (0xFF ^ array[count])) {return 2;}
        // Depending on the type, perform a certain action
        switch (type) {
            // Data records contain a number of data bytes to be stored in memory
            // starting at the given address
            case '1':   // Data record (16-bit address)
                address = (array[0] << 8) | array[1];
                for (int i = 2; i < count-1; i++) {
                    asm("sb %[some], 0(%[some2])" : : [some]"r" (array[i]), [some2]"r" (MEM_START | address));
                    address++;
                }
                break;
            case '2':   // Data record (24-bit address)
                address = (array[0] << 16) | (array[1] << 8) | array[2];
                for (int i = 3; i < count-1; i++) {
                    asm("sb %[some], 0(%[some2])" : : [some]"r" (array[i]), [some2]"r" (MEM_START | address));
                    address++;
                }
                break;
            case '3':   // Data record (32-bit address)
                address = (array[0] << 24) | (array[1] << 16) | (array[2] << 8) | array[3];
                for (int i = 4; i < count-1; i++) {
                    asm("sb %[some], 0(%[some2])" : : [some]"r" (array[i]), [some2]"r" (MEM_START | address));
                    address++;
                }
                break;
            case '5':   // (Optional) count record
                // The record count should match the number of (S1, S2 or S3) records handled so far
                if (reccount - 1 != (array[0] + array[1])) {return 3;}
                break;
            // Termination records contain only the start address for executing the program
            // contained in the SREC file - this is why it is set globally allowing jumps
            case '7':   // Termination record (16-bit address)
                return (array[0] << 8) | array[1];
            case '8':   // Termination record (24-bit address)
                return (array[0] << 16) | (array[1] << 8) | array[2];
            case '9':   // Termination record (32-bit address)
                return (array[0] << 24) | (array[1] << 16) | (array[2] << 8) | array[3];
            default:    // Header record (16-bit address)
                // Data field only contains file identifiers, version and revision information
                // - nothing is to be stored.
                break;
        }
        reccount++;
        // Skip the carriage return and line feed characters of current record
        // - this is performed by the while loop at the top of this function
    }
    return 0;
}

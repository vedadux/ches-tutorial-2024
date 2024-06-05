#include <verilated.h>
#include "Vascon_sbox.h"
#include "ascon.h"

#include <iostream>
#include <cstdio>
#include <cassert>

int main(int argc, char** argv) 
{
    for (uint8_t sbox_in = 0; sbox_in < 32; sbox_in += 1)
    {
        uint8_t x0, x1, x2, x3, x4;
        x0 = (sbox_in >> 4) & 1;
        x1 = (sbox_in >> 3) & 1;
        x2 = (sbox_in >> 2) & 1;
        x3 = (sbox_in >> 1) & 1;
        x4 = (sbox_in >> 0) & 1;
        
        ascon_sbox(x0, x1, x2, x3, x4);

        uint8_t sbox_out = 0;
        sbox_out = (sbox_out << 1) | (x0 & 1);
        sbox_out = (sbox_out << 1) | (x1 & 1);
        sbox_out = (sbox_out << 1) | (x2 & 1);
        sbox_out = (sbox_out << 1) | (x3 & 1);
        sbox_out = (sbox_out << 1) | (x4 & 1);
        
        assert(sbox_out == ASCON_SBOX_TABLE[sbox_in]);
    }

    // Initialize Verilator
    Verilated::commandArgs(argc, argv);

    // Create an instance of the DUT module
    Vascon_sbox* dut = new Vascon_sbox;

    for (uint32_t input = 0; input < 32; input++) 
    {
        // Set input value
        dut->in_x = input;

        // Evaluate the DUT
        dut->eval();

        uint32_t expected = ASCON_SBOX_TABLE[input];
        uint32_t output = dut->out_y;
        
        // Check if the output matches the expected value
        if (output != expected)
        {
            // Test failed
            printf("Test failed %02x: %02x != %02x\n", input, output, expected);
            // Exit with failure
            exit(1);
        }
    }
    // All tests passed
    printf("All tests passed!\n");
    // Delete the DUT instance
    delete dut;

    // Exit with success
    exit(0);
}
#include <verilated.h>
#include "Vpresent_sbox.h"
#include "present.h"

#include <iostream>
#include <cstdio>
#include <cassert>

int main(int argc, char** argv) 
{
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);

    // Create an instance of the DUT module
    Vpresent_sbox* dut = new Vpresent_sbox;

    for (uint32_t input = 0; input < 16; input++) 
    {
        // Set input value
        dut->in_x = input;

        // Evaluate the DUT
        dut->eval();

        uint32_t expected = PRESENT_SBOX_TABLE[input];
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
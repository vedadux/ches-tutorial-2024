#include <verilated.h>
#include "Vmasked_xor.h"

#include <iostream>
#include <cstdio>
#include <cassert>
#include <random>

void init_shares(uint8_t val, std::mt19937_64& gen, uint8_t* ptr, uint64_t n)
{
    uint8_t share_xor = 0;
    for (int i = 0; i < n - 1; i++)
    {
        ptr[i] = gen() & 0x01;
        share_xor ^= ptr[i];
    }
    ptr[n - 1] = share_xor ^ val;
}

int main(int argc, char** argv) 
{
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);

    // Create an instance of the DUT module
    Vmasked_xor* dut = new Vmasked_xor;

    // Create a randomness source
    std::random_device rd;
    
    // Create a pseudo-random generator
    std::mt19937_64 gen(rd());

    for (uint32_t run_id = 0; run_id < 100; run_id += 1)
    for (uint32_t input = 0; input < 4; input++) 
    {
        uint32_t input_a = (input >> 0) & 1;
        uint32_t input_b = (input >> 1) & 1;

        uint32_t expected = input_a ^ input_b;
        
        uint8_t in_a_shares[NUM_SHARES];
        uint8_t in_b_shares[NUM_SHARES];
        init_shares(input_a, gen, in_a_shares, NUM_SHARES);
        init_shares(input_b, gen, in_b_shares, NUM_SHARES);

        dut->in_a = 0;
        dut->in_b = 0;
        for (int i = 0; i < NUM_SHARES; i++)
        {
            dut->in_a |= (uint64_t)(in_a_shares[i]) << ((uint64_t)i*1);
            dut->in_b |= (uint64_t)(in_b_shares[i]) << ((uint64_t)i*1);
        }
        dut->eval();

        uint32_t out_c_shares[NUM_SHARES];
        uint32_t output_c = 0;
        for (int i = 0; i < NUM_SHARES; i++)
        {
            out_c_shares[i] = ((dut->out_c) >> (i*1)) & 0x1;
            output_c ^= out_c_shares[i];
        }
        
        // Check if the output matches the expected value
        if (output_c != expected)
        {
            // Test failed
            printf("Test failed %01d %01d: %01d != %01d\n", input_a, input_b, output_c, expected);
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
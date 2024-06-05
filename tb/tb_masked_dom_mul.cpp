#include <verilated.h>
#include "Vmasked_dom_mul.h"

#include <iostream>
#include <cstdio>
#include <cassert>
#include <random>

template<typename T>
void tick(T* dut)
{
    dut->eval();
    dut->in_clock = 1;
    dut->eval();
    dut->in_clock = 0;
    dut->eval();
}

template<typename T>
void reset(T* dut)
{
    dut->in_reset = 1;
    dut->eval();
    tick(dut);
    dut->in_reset = 0;
    dut->eval();
    tick(dut);
}

void set_randoms(std::mt19937_64& gen, uint8_t* ptr, uint64_t size)
{
    for (int i = 0; i < size / sizeof(uint8_t); i += 1)
    {
        ptr[i] = gen();
    }
}

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

#define LATENCY 1

int main(int argc, char** argv) 
{
    printf("NUM_SHARES: %d\n", NUM_SHARES);
    printf("LATENCY:    %d\n", LATENCY);
    
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);

    // Create an instance of the DUT module
    Vmasked_dom_mul* dut = new Vmasked_dom_mul;
    printf("Size of in_p: %ld\n", sizeof(dut->in_p));

    // Create a randomness source
    std::random_device rd;
    
    // Create a pseudo-random generator
    std::mt19937_64 gen(rd());

    // Perform random testing for all inputs to in_a and in_b
    for (uint32_t run_id = 0; run_id < 100; run_id += 1)
    for (uint32_t input = 0; input < 4; input++) 
    {
        uint32_t input_a = (input >> 0) & 1;
        uint32_t input_b = (input >> 1) & 1;

        uint32_t expected = input_a & input_b;
        
        // Set input value
        reset(dut);

        uint8_t in_a_shares[NUM_SHARES];
        uint8_t in_b_shares[NUM_SHARES];
        init_shares(input_a, gen, in_a_shares, NUM_SHARES);
        init_shares(input_b, gen, in_b_shares, NUM_SHARES);

        set_randoms(gen, (uint8_t*)(&(dut->in_p)), sizeof(dut->in_p));

        dut->in_a = 0;
        dut->in_b = 0;
        for (int i = 0; i < NUM_SHARES; i++)
        {
            dut->in_a |= (uint64_t)(in_a_shares[i]) << ((uint64_t)i*1);
            dut->in_b |= (uint64_t)(in_b_shares[i]) << ((uint64_t)i*1);
        }
        dut->eval();

        for (int time = 0; time < LATENCY; time++)
        {
            set_randoms(gen, (uint8_t*)(&(dut->in_p)), sizeof(dut->in_p));
            dut->eval();
            tick(dut);
        }
        
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
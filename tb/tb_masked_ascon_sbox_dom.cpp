#include <verilated.h>
#include "Vmasked_ascon_sbox_dom.h"
#include "ascon.h"

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
    Vmasked_ascon_sbox_dom* dut = new Vmasked_ascon_sbox_dom;
    printf("Size of in_random: %ld\n", sizeof(dut->in_random));

    // Create a randomness source
    std::random_device rd;
    
    // Create a pseudo-random generator
    std::mt19937_64 gen(rd());

    // Perform random testing for all inputs to in_x
    for (uint32_t run_id = 0; run_id < 100; run_id += 1)
    for (uint32_t input = 0; input < 32; input++) 
    {
        uint32_t expected = ASCON_SBOX_TABLE[input];
        
        // Set input value
        reset(dut);

        set_randoms(gen, (uint8_t*)(&(dut->in_random)), sizeof(dut->in_random));

        uint8_t in_x_shares[5][NUM_SHARES];
        for (int bit_id = 0; bit_id < 5; bit_id += 1)
        {
            init_shares((input >> bit_id) & 1, gen, in_x_shares[bit_id], NUM_SHARES);
        }
        
        dut->in_x = 0;
        for (int bit_id = 0; bit_id < 5; bit_id += 1)
        for (int share_id = 0; share_id < NUM_SHARES; share_id++)
        {
            dut->in_x |= (uint64_t)(in_x_shares[bit_id][share_id]) << (uint64_t)(share_id*1 + bit_id*NUM_SHARES);
        }
        dut->eval();

        for (int time = 0; time < LATENCY; time++)
        {
            set_randoms(gen, (uint8_t*)(&(dut->in_random)), sizeof(dut->in_random));
            dut->eval();
            tick(dut);
        }
        
        uint32_t out_y_shares[NUM_SHARES];
        uint32_t output = 0;
        for (int bit_id = 0; bit_id < 5; bit_id += 1)
        for (int share_id = 0; share_id < NUM_SHARES; share_id++)
        {
            out_y_shares[share_id] = ((dut->out_y) >> (share_id*1 + bit_id*NUM_SHARES)) & 0x1;
            output ^= out_y_shares[share_id] << bit_id;
        }
        
        // Check if the output matches the expected value
        if (output != expected)
        {
            // Test failed
            printf("Test failed %02x : %02x != %02x\n", input, output, expected);
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
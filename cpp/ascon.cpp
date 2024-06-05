#include "ascon.h"
#include <cstdio>

uint8_t ASCON_SBOX_TABLE[32] = {
    0x04, 0x0b, 0x1f, 0x14, 0x1a, 0x15, 0x09, 0x02, 
    0x1b, 0x05, 0x08, 0x12, 0x1d, 0x03, 0x06, 0x1c, 
    0x1e, 0x13, 0x07, 0x0e, 0x00, 0x0d, 0x11, 0x18,
    0x10, 0x0c, 0x01, 0x19, 0x16, 0x0a, 0x0f, 0x17, 
};

void ascon_linear(ascon_state_t* s)
{
    s->x[0] = s->x[0] ^ ROR(s->x[0], 19) ^ ROR(s->x[0], 28);
    s->x[1] = s->x[1] ^ ROR(s->x[1], 61) ^ ROR(s->x[1], 39);
    s->x[2] = s->x[2] ^ ROR(s->x[2],  1) ^ ROR(s->x[2],  6);
    s->x[3] = s->x[3] ^ ROR(s->x[3], 10) ^ ROR(s->x[3], 17);
    s->x[4] = s->x[4] ^ ROR(s->x[4],  7) ^ ROR(s->x[4], 41);
}

void ascon_round(ascon_state_t* s, uint8_t C) 
{
    ascon_add_const(s, C);
    ascon_sbox(s->x[0], s->x[1], s->x[2], s->x[3], s->x[4]);
    ascon_linear(s);

    print_ascon_state(" round output", s);
}

void ascon_p_rounds(ascon_state_t* s, int num) 
{
    int rc = ascon_rc_start(num);
    do {
        ascon_round(s, rc);
        rc += ascon_rc_inc;
    } while (rc != ascon_rc_end);
}

void print_ascon_state(const char* text, ascon_state_t* s)
{
    std::printf("%s: ", text);
    for (uint8_t i = 0; i < 5; i++)
        std::printf("%08lx", s->x[i]);
    std::printf("\n");
    std::fflush(stdout);
}
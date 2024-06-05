#ifndef ASCON_H
#define ASCON_H

#include <cstdint>

struct ascon_state_t {
  uint64_t x[5];
};

inline uint64_t ROR(uint64_t x, int n);

inline void ascon_add_const(ascon_state_t* s, uint8_t C);

template<typename T>
void ascon_sbox(T& x0, T& x1, T& x2, T& x3, T& x4);

void ascon_linear(ascon_state_t* s);

void ascon_round(ascon_state_t* s, uint8_t C);

inline int ascon_rc_start(int num_rounds);
constexpr int ascon_rc_inc = -0x0f;
constexpr int ascon_rc_end = 0x3c;

void ascon_p_rounds(ascon_state_t* s, int num);

void print_ascon_state(const char* text, ascon_state_t* s);

extern uint8_t ASCON_SBOX_TABLE[32];

#include "ascon.hpp"
#endif /* ASCON_H */
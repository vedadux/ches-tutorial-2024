#ifndef ASCON_HPP
#define ASCON_HPP

#include "ascon.h"

inline uint64_t ROR(uint64_t x, int n) 
{ 
    return x >> n | x << (-n & 63); 
}

inline void ascon_add_const(ascon_state_t* s, uint8_t C)
{
    s->x[2] ^= C;
}

template<typename T>
void ascon_sbox(T& x0, T& x1, T& x2, T& x3, T& x4)
{
    x0 ^= x4;
    x4 ^= x3;
    x2 ^= x1;
    
    T y0 = x0 ^ (~x1 & x2);
    T y1 = x1 ^ (~x2 & x3);
    T y2 = x2 ^ (~x3 & x4);
    T y3 = x3 ^ (~x4 & x0);
    T y4 = x4 ^ (~x0 & x1);
    
    x0 = y0 ^ y4;
    x1 = y0 ^ y1;
    x2 = ~y2;
    x3 = y2 ^ y3;
    x4 = y4;
}

inline int ascon_rc_start(int num_rounds) 
{ 
    return ((3  + num_rounds) << 4) | 
           ((12 - num_rounds) << 0);
}

#endif // ASCON_HPP

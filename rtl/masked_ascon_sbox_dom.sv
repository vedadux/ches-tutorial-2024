`ifndef MASKED_ASCON_SBOX_DOM_SV
`define MASKED_ASCON_SBOX_DOM_SV

`define USE_V1
// `define USE_V2

`ifdef USE_V1
`include "masked_ascon_sbox_dom_v1.sv"
`elsif USE_V2
`include "masked_ascon_sbox_dom_v2.sv"
`endif

`endif // MASKED_ASCON_SBOX_DOM_SV

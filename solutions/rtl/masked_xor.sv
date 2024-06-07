`ifndef MASKED_XOR_SV
`define MASKED_XOR_SV

`include "dev_package.sv"

module masked_xor #(
    parameter NUM_SHARES = 2
)(
    in_a, in_b, out_c
);
    import dev_package::*;
    
    input  bit[NUM_SHARES-1:0] in_a;
    input  bit[NUM_SHARES-1:0] in_b;
    output bit[NUM_SHARES-1:0] out_c;
    
    assign out_c = in_a ^ in_b;
endmodule : masked_xor
`endif // MASKED_XOR_SV

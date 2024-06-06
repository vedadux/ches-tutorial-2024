`ifndef MASKED_ASCON_SBOX_DOM_V2_SV
`define MASKED_ASCON_SBOX_DOM_V2_SV

`include "dev_package.sv"
`include "masked_dom_mul.sv"
`include "masked_xor.sv"
`include "masked_not.sv"
`include "d_register.sv"

module masked_ascon_sbox_dom #(
    parameter NUM_SHARES = 2
)(
    in_x, out_y, in_random, in_clock, in_reset
);
    import dev_package::*;
    typedef bit[NUM_SHARES-1:0] shared_bit;
    localparam NUM_QUADRATIC = num_quad(NUM_SHARES);
    localparam NUM_DOM_MUL_GADGETS = 5; // @todo Adapt this here!

    input  bit[4:0][NUM_SHARES-1:0] in_x;
    output bit[4:0][NUM_SHARES-1:0] out_y;
    input  bit[NUM_DOM_MUL_GADGETS-1:0][NUM_QUADRATIC-1:0] in_random;
    input in_clock;
    input in_reset;

    shared_bit x0_t0, x1_t0, x2_t0, x3_t0, x4_t0;
    assign {x0_t0, x1_t0, x2_t0, x3_t0, x4_t0} = in_x;
    
    // @todo Implement a masked version of the Ascon SBox.
    // @details Go through your prior unmasked implementation and
    // replace the bit-level operations using masked gadget versions. 

    shared_bit a0_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a0_t0 (.in_a(x0_t0), .in_b(x4_t0), .out_c(a0_t0));
    shared_bit a1_t0; assign a1_t0 = x1_t0;
    shared_bit a2_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a2_t0 (.in_a(x2_t0), .in_b(x1_t0), .out_c(a2_t0));
    shared_bit a3_t0; assign a3_t0 = x3_t0;
    shared_bit a4_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a4_t0 (.in_a(x4_t0), .in_b(x3_t0), .out_c(a4_t0));
    
    shared_bit a0_t1; d_register #(.T(shared_bit)) reg_a0_t1 (.in_value(a0_t0), .out_value(a0_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a1_t1; d_register #(.T(shared_bit)) reg_a1_t1 (.in_value(a1_t0), .out_value(a1_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a2_t1; d_register #(.T(shared_bit)) reg_a2_t1 (.in_value(a2_t0), .out_value(a2_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a3_t1; d_register #(.T(shared_bit)) reg_a3_t1 (.in_value(a3_t0), .out_value(a3_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a4_t1; d_register #(.T(shared_bit)) reg_a4_t1 (.in_value(a4_t0), .out_value(a4_t1), .in_clock(in_clock), .in_reset(in_reset));

    shared_bit na0_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_na0_t1 (.in_a(a0_t1), .out_b(na0_t1));
    shared_bit na1_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_na1_t1 (.in_a(a1_t1), .out_b(na1_t1));
    shared_bit na2_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_na2_t1 (.in_a(a2_t1), .out_b(na2_t1));
    shared_bit na3_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_na3_t1 (.in_a(a3_t1), .out_b(na3_t1));
    shared_bit na4_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_na4_t1 (.in_a(a4_t1), .out_b(na4_t1));
    
    shared_bit b0_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b0_t2 
        (.in_a(na1_t1), .in_b(a2_t1), .out_c(b0_t2), .in_p(in_random[0]), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit b1_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b1_t2 
        (.in_a(na2_t1), .in_b(a3_t1), .out_c(b1_t2), .in_p(in_random[1]), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit b2_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b2_t2 
        (.in_a(na3_t1), .in_b(a4_t1), .out_c(b2_t2), .in_p(in_random[2]), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit b3_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b3_t2 
        (.in_a(na4_t1), .in_b(a0_t1), .out_c(b3_t2), .in_p(in_random[3]), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit b4_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b4_t2 
        (.in_a(na0_t1), .in_b(a1_t1), .out_c(b4_t2), .in_p(in_random[4]), 
         .in_clock(in_clock), .in_reset(in_reset));
    
    shared_bit a0_t2; d_register #(.T(shared_bit)) reg_a0_t2 (.in_value(a0_t1), .out_value(a0_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a1_t2; d_register #(.T(shared_bit)) reg_a1_t2 (.in_value(a1_t1), .out_value(a1_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a2_t2; d_register #(.T(shared_bit)) reg_a2_t2 (.in_value(a2_t1), .out_value(a2_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a3_t2; d_register #(.T(shared_bit)) reg_a3_t2 (.in_value(a3_t1), .out_value(a3_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit a4_t2; d_register #(.T(shared_bit)) reg_a4_t2 (.in_value(a4_t1), .out_value(a4_t2), .in_clock(in_clock), .in_reset(in_reset));

    shared_bit c0_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c0_t2 (.in_a(a0_t2), .in_b(b0_t2), .out_c(c0_t2));
    shared_bit c1_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c1_t2 (.in_a(a1_t2), .in_b(b1_t2), .out_c(c1_t2));
    shared_bit c2_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c2_t2 (.in_a(a2_t2), .in_b(b2_t2), .out_c(c2_t2));
    shared_bit c3_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c3_t2 (.in_a(a3_t2), .in_b(b3_t2), .out_c(c3_t2));
    shared_bit c4_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c4_t2 (.in_a(a4_t2), .in_b(b4_t2), .out_c(c4_t2));
    
    shared_bit y0_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y0_t2 (.in_a(c0_t2), .in_b(c4_t2), .out_c(y0_t2));
    shared_bit y1_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y1_t2 (.in_a(c1_t2), .in_b(c0_t2), .out_c(y1_t2));
    shared_bit y2_t2; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_y2_t2 (.in_a(c2_t2), .out_b(y2_t2));
    shared_bit y3_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y3_t2 (.in_a(c3_t2), .in_b(c2_t2), .out_c(y3_t2));
    shared_bit y4_t2; assign y4_t2 = c4_t2;

    assign out_y = {y0_t2, y1_t2, y2_t2, y3_t2, y4_t2};
endmodule : masked_ascon_sbox_dom
`endif // MASKED_ASCON_SBOX_DOM_V2_SV

`ifndef MASKED_ASCON_SBOX_DOM_V2_SV
`define MASKED_ASCON_SBOX_DOM_V2_SV

`include "dev_package.sv"
`include "masked_dom_mul.sv"
`include "masked_xor.sv"
`include "masked_not.sv"
`include "masked_zero.sv"

module masked_ascon_sbox_dom #(
    parameter NUM_SHARES = 2
)(
    in_x, out_y, in_random, in_clock, in_reset
);
    import dev_package::*;
    
    localparam NUM_QUADRATIC = num_quad(NUM_SHARES);
    localparam NUM_RAW_ZERO  = num_zero_random(NUM_SHARES);
    localparam NUM_DOM_MUL_GADGETS = 5; // @todo Adapt this here!
    localparam NUM_ZERO_GADGETS = 5;    // @todo Adapt this here!
    localparam NUM_RANDOM = NUM_DOM_MUL_GADGETS * NUM_QUADRATIC +
                            NUM_ZERO_GADGETS * NUM_RAW_ZERO;

    typedef bit[NUM_SHARES-1:0] shared_bit_t;
    typedef bit[NUM_QUADRATIC-1:0] quad_random_t;
    typedef bit[NUM_RAW_ZERO-1:0]  zero_random_t;
    

    input  bit[4:0][NUM_SHARES-1:0] in_x;
    output bit[4:0][NUM_SHARES-1:0] out_y;
    input  bit[NUM_RANDOM-1:0] in_random;
    input in_clock;
    input in_reset;

    shared_bit_t x0_t0, x1_t0, x2_t0, x3_t0, x4_t0;
    assign {x0_t0, x1_t0, x2_t0, x3_t0, x4_t0} = in_x;
    
    quad_random_t p0_t0, p1_t0, p2_t0, p3_t0, p4_t0;
    zero_random_t raw_r0_t0, raw_r1_t0, raw_r2_t0, raw_r3_t0, raw_r4_t0;
    
    assign {    p0_t0,     p1_t0,     p2_t0,     p3_t0,     p4_t0,
            raw_r0_t0, raw_r1_t0, raw_r2_t0, raw_r3_t0, raw_r4_t0 } = in_random;

    // @todo Implement a masked version of the Ascon SBox.
    // @details Go through your prior unmasked implementation and
    // replace the bit-level operations using masked gadget versions. 

    // @note To prevent yourself from making pipelining errors, you should use
    // suffixes in your module that show the latency of a given signal respective
    // to the inputs. For example, if you instantiate a masked_xor gadget, you
    // know that its output will have the same latency as the inputs as there
    // are no register stages. Same goes for a masked_not. However, if you have
    // a d_register module or the masked_dom_mul module, and ints inputs have
    // a "_t0" suffix, you should use a "_t1" suffix for the module outputs.
    // Whenever you have to instantiate a gadget, make sure that their inputs
    // have the same lateny! This means that you might have to delay some of the
    // inputs using a d_register.

    // @note After finishing, make sure that you test your implementation using
    // ```
    // rm -r obj && make obj/Vsyn_masked_ascon_sbox_dom && ./obj/Vsyn_masked_ascon_sbox_dom
    // ```
    // to make sure your implementation is a correct pipelined masked Ascon Sbox 
    // implementation. Also test this with different amounts of shares using
    // the prefix, e.g., `NUM_SHARES=3` in front of the command above. Overall
    // testing at this stage will prevent you from debugging the whole crypto 
    // algorithm later on, and instead detect any bugs, e.g., pipelining issues, 
    // early!

    shared_bit_t r0_t0, r1_t0, r2_t0, r3_t0, r4_t0;
    masked_zero #(.NUM_SHARES(NUM_SHARES)) masked_r0_t0 (
        .in_random(raw_r0_t0), .out_random(r0_t0), .in_clock(in_clock), .in_reset(in_reset)
    );
    masked_zero #(.NUM_SHARES(NUM_SHARES)) masked_r1_t0 (
        .in_random(raw_r1_t0), .out_random(r1_t0), .in_clock(in_clock), .in_reset(in_reset)
    );
    masked_zero #(.NUM_SHARES(NUM_SHARES)) masked_r2_t0 (
        .in_random(raw_r2_t0), .out_random(r2_t0), .in_clock(in_clock), .in_reset(in_reset)
    );
    masked_zero #(.NUM_SHARES(NUM_SHARES)) masked_r3_t0 (
        .in_random(raw_r3_t0), .out_random(r3_t0), .in_clock(in_clock), .in_reset(in_reset)
    );
    masked_zero #(.NUM_SHARES(NUM_SHARES)) masked_r4_t0 (
        .in_random(raw_r4_t0), .out_random(r4_t0), .in_clock(in_clock), .in_reset(in_reset)
    );

    shared_bit_t a0_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a0_t0 (.in_a(x0_t0), .in_b(x4_t0), .out_c(a0_t0));
    shared_bit_t a1_t0; assign a1_t0 = x1_t0;
    shared_bit_t a2_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a2_t0 (.in_a(x2_t0), .in_b(x1_t0), .out_c(a2_t0));
    shared_bit_t a3_t0; assign a3_t0 = x3_t0;
    shared_bit_t a4_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_a4_t0 (.in_a(x4_t0), .in_b(x3_t0), .out_c(a4_t0));
    
    shared_bit_t ar0_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_ar0_t0 (.in_a(a0_t0), .in_b(r0_t0), .out_c(ar0_t0));
    shared_bit_t ar1_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_ar1_t0 (.in_a(a1_t0), .in_b(r1_t0), .out_c(ar1_t0));
    shared_bit_t ar2_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_ar2_t0 (.in_a(a2_t0), .in_b(r2_t0), .out_c(ar2_t0));
    shared_bit_t ar3_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_ar3_t0 (.in_a(a3_t0), .in_b(r3_t0), .out_c(ar3_t0));
    shared_bit_t ar4_t0; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_ar4_t0 (.in_a(a4_t0), .in_b(r4_t0), .out_c(ar4_t0));
    
    shared_bit_t ar0_t1; d_register #(.T(shared_bit_t)) reg_ar0_t1 (.in_value(ar0_t0), .out_value(ar0_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar1_t1; d_register #(.T(shared_bit_t)) reg_ar1_t1 (.in_value(ar1_t0), .out_value(ar1_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar2_t1; d_register #(.T(shared_bit_t)) reg_ar2_t1 (.in_value(ar2_t0), .out_value(ar2_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar3_t1; d_register #(.T(shared_bit_t)) reg_ar3_t1 (.in_value(ar3_t0), .out_value(ar3_t1), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar4_t1; d_register #(.T(shared_bit_t)) reg_ar4_t1 (.in_value(ar4_t0), .out_value(ar4_t1), .in_clock(in_clock), .in_reset(in_reset));

    shared_bit_t nar0_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_nar0_t1 (.in_a(ar0_t1), .out_b(nar0_t1));
    shared_bit_t nar1_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_nar1_t1 (.in_a(ar1_t1), .out_b(nar1_t1));
    shared_bit_t nar2_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_nar2_t1 (.in_a(ar2_t1), .out_b(nar2_t1));
    shared_bit_t nar3_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_nar3_t1 (.in_a(ar3_t1), .out_b(nar3_t1));
    shared_bit_t nar4_t1; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_nar4_t1 (.in_a(ar4_t1), .out_b(nar4_t1));
    
    shared_bit_t b0_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b0_t2 
        (.in_a(nar1_t1), .in_b(ar2_t1), .out_c(b0_t2), .in_p(p0_t0), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t b1_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b1_t2 
        (.in_a(nar2_t1), .in_b(ar3_t1), .out_c(b1_t2), .in_p(p1_t0), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t b2_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b2_t2 
        (.in_a(nar3_t1), .in_b(ar4_t1), .out_c(b2_t2), .in_p(p2_t0), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t b3_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b3_t2 
        (.in_a(nar4_t1), .in_b(ar0_t1), .out_c(b3_t2), .in_p(p3_t0), 
         .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t b4_t2; masked_dom_mul #(.NUM_SHARES(NUM_SHARES)) masked_b4_t2 
        (.in_a(nar0_t1), .in_b(ar1_t1), .out_c(b4_t2), .in_p(p4_t0), 
         .in_clock(in_clock), .in_reset(in_reset));
    
    shared_bit_t ar0_t2; d_register #(.T(shared_bit_t)) reg_ar0_t2 (.in_value(ar0_t1), .out_value(ar0_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar1_t2; d_register #(.T(shared_bit_t)) reg_ar1_t2 (.in_value(ar1_t1), .out_value(ar1_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar2_t2; d_register #(.T(shared_bit_t)) reg_ar2_t2 (.in_value(ar2_t1), .out_value(ar2_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar3_t2; d_register #(.T(shared_bit_t)) reg_ar3_t2 (.in_value(ar3_t1), .out_value(ar3_t2), .in_clock(in_clock), .in_reset(in_reset));
    shared_bit_t ar4_t2; d_register #(.T(shared_bit_t)) reg_ar4_t2 (.in_value(ar4_t1), .out_value(ar4_t2), .in_clock(in_clock), .in_reset(in_reset));

    shared_bit_t c0_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c0_t2 (.in_a(ar0_t2), .in_b(b0_t2), .out_c(c0_t2));
    shared_bit_t c1_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c1_t2 (.in_a(ar1_t2), .in_b(b1_t2), .out_c(c1_t2));
    shared_bit_t c2_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c2_t2 (.in_a(ar2_t2), .in_b(b2_t2), .out_c(c2_t2));
    shared_bit_t c3_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c3_t2 (.in_a(ar3_t2), .in_b(b3_t2), .out_c(c3_t2));
    shared_bit_t c4_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_c4_t2 (.in_a(ar4_t2), .in_b(b4_t2), .out_c(c4_t2));
    
    shared_bit_t y0_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y0_t2 (.in_a(c0_t2), .in_b(c4_t2), .out_c(y0_t2));
    shared_bit_t y1_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y1_t2 (.in_a(c1_t2), .in_b(c0_t2), .out_c(y1_t2));
    shared_bit_t y2_t2; masked_not #(.NUM_SHARES(NUM_SHARES)) masked_y2_t2 (.in_a(c2_t2), .out_b(y2_t2));
    shared_bit_t y3_t2; masked_xor #(.NUM_SHARES(NUM_SHARES)) masked_y3_t2 (.in_a(c3_t2), .in_b(c2_t2), .out_c(y3_t2));
    shared_bit_t y4_t2; assign y4_t2 = c4_t2;

    assign out_y = {y0_t2, y1_t2, y2_t2, y3_t2, y4_t2};
endmodule : masked_ascon_sbox_dom
`endif // MASKED_ASCON_SBOX_DOM_V2_SV

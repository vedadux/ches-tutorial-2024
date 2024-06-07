`ifndef MASKED_ASCON_SBOX_DOM_SV
`define MASKED_ASCON_SBOX_DOM_SV

`include "dev_package.sv"
`include "masked_dom_mul.sv"
`include "masked_xor.sv"
`include "masked_not.sv"

module masked_ascon_sbox_dom #(
    parameter NUM_SHARES = 2
)(
    in_x, out_y, in_random, in_clock, in_reset
);
    import dev_package::*;
    typedef bit[NUM_SHARES-1:0] shared_bit_t;
    typedef bit[NUM_QUADRATIC-1:0] quad_random_t;
    
    localparam NUM_QUADRATIC = num_quad(NUM_SHARES);
    // @note if you need more randomness, declare it here
    localparam NUM_DOM_MUL_GADGETS = 5;
    localparam NUM_RANDOM = NUM_DOM_MUL_GADGETS * NUM_QUADRATIC;

    input  bit[4:0][NUM_SHARES-1:0] in_x;
    output bit[4:0][NUM_SHARES-1:0] out_y;
    input  bit[NUM_RANDOM-1:0] in_random;
    input in_clock;
    input in_reset;

    shared_bit_t x0_t0, x1_t0, x2_t0, x3_t0, x4_t0;
    assign {x0_t0, x1_t0, x2_t0, x3_t0, x4_t0} = in_x;
    
    // @note Boilerplate randomness splitting
    quad_random_t p0_t0, p1_t0, p2_t0, p3_t0, p4_t0;
    assign {p0_t0, p1_t0, p2_t0, p3_t0, p4_t0} = in_random;

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

endmodule : masked_ascon_sbox_dom
`endif // MASKED_ASCON_SBOX_DOM_SV

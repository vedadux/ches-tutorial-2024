`ifndef MASKED_DOM_MUL_SV
`define MASKED_DOM_MUL_SV

`include "dev_package.sv"
`include "register.sv"
`include "reduce_xor.sv"

module masked_dom_mul #(
    parameter NUM_SHARES = 2
)(
    in_a, in_b, in_p, out_c, in_clock, in_reset
);
    import dev_package::*;
    localparam NUM_QUARDATIC = num_quad(NUM_SHARES);
    
    input  bit[NUM_SHARES-1:0]    in_a;
    input  bit[NUM_SHARES-1:0]    in_b;
    input  bit[NUM_QUARDATIC-1:0] in_p;
    output bit[NUM_SHARES-1:0]    out_c;
    input in_clock;
    input in_reset;

    /// @brief Two dimensional array for A_i & B_j
    bit[NUM_SHARES-1:0][NUM_SHARES-1:0] cross_mul_t0;
    /// @brief Two dimensional array for A_i & B_j ^ P_{i,j}
    bit[NUM_SHARES-1:0][NUM_SHARES-1:0] cross_blind_t0;
    /// @brief Two dimensional array for Reg[A_i & B_j ^ P_{i,j}]
    bit[NUM_SHARES-1:0][NUM_SHARES-1:0] cross_blind_t1;
    
    /// @todo Implement the DOM Masked multiplier.
    
    /// @details Use `genvar` variables and two nested `generate` blocks
    /// to perform the computations needed for the DOM multiplier. Make sure
    /// to handle the special case for i == j in the algorithm. Do not forget
    /// to instantiate registers for the blinded cross-domain terms and
    /// pay attention to the way the blinded cross-domain terms are compressed
    /// back to be only n domains at the end.
    
    /// @note In SystemVerilog, you can use `generate` ... `endgenerate`
    /// blocks to generate wire assignments and instantiate modules. Here, you
    /// can use `for` loops looping over `genvar` variables a fixed number of times
    /// and even `if` ... `else` constructs conditioned on `genvar` type variables
    /// to instantiate/assign in bulk or conditionally. 

    /// @note For the random values P_{i,j} you will notice that the input
    /// in_p is flat, and cannot be doubly indexed. Here, to compute the real
    /// index from i and j, use the quad_index function where you additionally
    /// provide the correct number of shares.

    /// @note When instantiating other modules ALWAYS use the verbose syntax
    /// for parameter and argument passing to avoid errors. For example, when
    /// instantiating a register, do something like:
    /* ```
        register #(.T(your_input_type)) the_name_of_the_register_instance (
                    .in_value(the_register_input), 
                    .out_value(the_register_output),
                    .in_clock(in_clock), // <- always use the same clock
                    .in_reset(in_reset)  // <- always use the same reset
                );
        ```
    */

    /// @note You can use the reduce_xor module for the compression part of
    /// the DOM multiplier. It is generic, so make sure to provide it with
    /// parameters, i.e., your element width and the number of elements that
    /// you are xoring together.

    genvar i, j;
    generate
        for (i = 0; i < NUM_SHARES; i++)
        begin : gen_loop_i
            for (j = 0; j < NUM_SHARES; j++)
            begin : gen_loop_j
                ///
                assign cross_mul_t0[i][j] = in_a[i] & in_b[j];
                if (i == j) begin : gen_if_ij_eq
                    assign cross_blind_t0[i][j] = cross_mul_t0[i][j];
                end else begin : gen_if_ij_neq
                    assign cross_blind_t0[i][j] = cross_mul_t0[i][j] ^ in_p[quad_index(i, j, NUM_SHARES)];
                end
                register #(.T(bit)) gen_reg_ij(
                    .in_value(cross_blind_t0[i][j]), 
                    .out_value(cross_blind_t1[i][j]),
                    .in_clock(in_clock),
                    .in_reset(in_reset)
                );
            end
            reduce_xor #(
                .ELEMENT_WIDTH(1), 
                .NUM_ELEMENTS(NUM_SHARES)) 
                gen_xor_tree_i (
                .in_elements(cross_blind_t1[i]), 
                .out_xor(out_c[i])
            );
        end
    endgenerate
endmodule : masked_dom_mul
`endif // MASKED_DOM_MUL_SV

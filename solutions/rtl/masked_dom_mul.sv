`ifndef MASKED_DOM_MUL_SV
`define MASKED_DOM_MUL_SV

`include "dev_package.sv"
`include "d_register.sv"
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
                d_register #(.T(bit)) gen_reg_ij(
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

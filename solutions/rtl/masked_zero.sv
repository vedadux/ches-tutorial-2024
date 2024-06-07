`ifndef MASKED_ZERO_SV
`define MASKED_ZERO_SV

`include "dev_package.sv"
`include "d_register.sv"

module masked_zero #(
    parameter NUM_SHARES = 2
)(
    in_random, out_random, in_clock, in_reset
);
    import dev_package::*;
    localparam NUM_NEEDED = num_zero_random(NUM_SHARES);
    typedef bit[NUM_SHARES-1:0] shared_bit;
    
    input  bit[NUM_NEEDED-1:0] in_random;
    output shared_bit out_random;
    input  in_clock;
    input  in_reset;
    
    shared_bit shared_zero;
    generate
        if (NUM_SHARES == 2) begin : gen_2_shares
            assign shared_zero[0] = in_random[0];
            assign shared_zero[1] = in_random[0];
        end
        else if (NUM_SHARES == 3) begin : gen_3_shares
            assign shared_zero[0] = in_random[0];
            assign shared_zero[1] = in_random[1];
            assign shared_zero[2] = in_random[0] ^ in_random[1];
        end
        else if (NUM_SHARES == 4 || NUM_SHARES == 5) begin : gen_gt3_shares
            shared_bit shuffled_random = {in_random[0], in_random[NUM_SHARES-1:1]};
            assign shared_zero = in_random ^ shuffled_random;
        end
        else begin : gen_error
            $error("Unsuported number of shares");
        end
    endgenerate

    d_register #(.T(shared_bit)) reg_stage (
        .in_value(shared_zero),
        .out_value(out_random),
        .in_clock(in_clock),
        .in_reset(in_reset)
    );
endmodule : masked_zero
`endif // MASKED_ZERO_SV

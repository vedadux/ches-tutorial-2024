`ifndef MASKED_NOT_SV
`define MASKED_NOT_SV

`include "dev_package.sv"

module masked_not #(
    parameter NUM_SHARES = 2
)(
    in_a, out_b
);
    import dev_package::*;
    
    input  bit[NUM_SHARES-1:0] in_a;
    output bit[NUM_SHARES-1:0] out_b;
    
    assign out_b = {in_a[NUM_SHARES-1:1], ~in_a[0]};
endmodule : masked_not
`endif // MASKED_NOT_SV

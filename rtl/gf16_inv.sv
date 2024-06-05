`ifndef GF16_INV_SV
`define GF16_INV_SV

`include "dev_package.sv"

module gf16_inv (
    in_x, out_y
);
    import dev_package::*;
    input  bv4_t in_x;
    output bv4_t out_y;

    bit x0, x1, x2, x3;
    assign {x3, x2, x1, x0} = in_x;
    
    bit a0; assign a0 = x1 ^ x0;
    bit a1; assign a1 = x3 ^ x2;
    bit b0; assign b0 = x2 & x0;
    bit b1; assign b1 = x3 & x1;
    bit c0; assign c0 = a0 ^ b0;
    bit c1; assign c1 = a1 ^ b0;
    bit d0; assign d0 = x0 ^ b1;
    bit d1; assign d1 = x2 ^ b1;
    bit e0; assign e0 = x3 & c0;
    bit e1; assign e1 = x1 & c1;
    bit f0; assign f0 = a1 & d0;
    bit f1; assign f1 = a0 & d1;
    bit y3; assign y3 = a0 ^ e1;
    bit y2; assign y2 = x0 ^ f1;
    bit y1; assign y1 = a1 ^ e0;
    bit y0; assign y0 = x2 ^ f0;

    assign out_y = {y3, y2, y1, y0};
endmodule : gf16_inv
`endif // GF16_INV_SV

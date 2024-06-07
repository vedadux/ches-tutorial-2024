`ifndef PRESENT_SBOX_SV
`define PRESENT_SBOX_SV

`include "dev_package.sv"

module present_sbox (
    in_x, out_y
);
    import dev_package::*;
    input  bv4_t in_x;
    output bv4_t out_y;

    bit x0, x1, x2, x3;
    assign {x3, x2, x1, x0} = in_x;
    
    bit  x4; assign  x4 =  x1 &   x3; // depth (1)
    bit  x5; assign  x5 =  x1 &   x2; // depth (1)
    bit  x9; assign  x9 =  x2 &   x3; // depth (1)
    bit  x6; assign  x6 =  x2 ^   x4; // depth (1)
    bit  x7; assign  x7 =  x2 ^   x5; // depth (1)
    bit  x8; assign  x8 =  x6 ^   x7; // depth (1)
    bit x10; assign x10 =  x8 ^   x9; // depth (1)
    bit x11; assign x11 =  x1 ^   x5; // depth (1)
    bit x13; assign x13 =  x3 ^  x10; // depth (1)
    bit x15; assign x15 =  x0 ^  x10; // depth (1)
    bit x16; assign x16 =  x3 ~^  x7; // depth (1)
    bit x17; assign x17 = x11 ^  x13; // depth (1)
    bit x19; assign x19 =  x0 ~^ x16; // depth (1)
    bit x12; assign x12 =  x0 &  x10; // depth (2)
    bit x18; assign x18 = x15 &  x17; // depth (2)
    bit x14; assign x14 = x11 ^  x12; // depth (2)
    bit x20; assign x20 = x13 ^  x14; // depth (2)
    bit x21; assign x21 = x16 ^  x18; // depth (2)
    bit x22; assign x22 = x15 ~^ x20; // depth (2)

    bit y0; assign y0 = x19;
    bit y1; assign y1 = x20;
    bit y2; assign y2 = x21;
    bit y3; assign y3 = x22;

    assign out_y = {y3, y2, y1, y0};
endmodule : present_sbox
`endif // PRESENT_SBOX_SV

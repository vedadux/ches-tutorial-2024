`ifndef ASCON_SBOX_SV
`define ASCON_SBOX_SV

`include "dev_package.sv"

module ascon_sbox (
    in_x, out_y
);
    import dev_package::*;
    input  bv5_t in_x;
    output bv5_t out_y;

    // for some reason they define x0 as the MSB and x4 as LSB
    bit x0, x1, x2, x3, x4;
    assign {x0, x1, x2, x3, x4} = in_x;
    
    /// @todo Implement the Ascon sbox using bit-level operations.
    
    /// @details (System)Verilog is not exactly like C/C++, but it is
    /// similar. Use the Ascon C++ implementation as a starting point.
    /// Here, try to go for a single-static assignment approach, where
    /// whenever a variable is overwritten in C++, you replace it with
    /// a new variable in SystemVerilog that is used instead from that
    /// point onwards. This should prevent you from accidentally creating
    /// latches and will make the masking process much easier later on.
    
    /// @note Also make sure to declare variables before assigning them 
    /// as Verilator (the simulator we will use) sometimes bugs out for 
    /// such constructs. And pay attention to MSB/LSB order!

    bit a0; assign a0 = x0 ^ x4;
    bit a1; assign a1 = x1;
    bit a2; assign a2 = x2 ^ x1;
    bit a3; assign a3 = x3;
    bit a4; assign a4 = x4 ^ x3;
    
    bit b0; assign b0 = (~a1 & a2);
    bit b1; assign b1 = (~a2 & a3);
    bit b2; assign b2 = (~a3 & a4);
    bit b3; assign b3 = (~a4 & a0);
    bit b4; assign b4 = (~a0 & a1);
    
    bit c0; assign c0 = a0 ^ b0;
    bit c1; assign c1 = a1 ^ b1;
    bit c2; assign c2 = a2 ^ b2;
    bit c3; assign c3 = a3 ^ b3;
    bit c4; assign c4 = a4 ^ b4;
    
    bit y0; assign y0 = c0 ^ c4;
    bit y1; assign y1 = c1 ^ c0;
    bit y2; assign y2 = ~c2;
    bit y3; assign y3 = c3 ^ c2;
    bit y4; assign y4 = c4;

    assign out_y = {y0, y1, y2, y3, y4};
endmodule : ascon_sbox
`endif // ASCON_SBOX_SV

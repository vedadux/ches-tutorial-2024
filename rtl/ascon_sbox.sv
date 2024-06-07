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

    bit y0, y1, y2, y3, y4;
    assign out_y = {y0, y1, y2, y3, y4};
endmodule : ascon_sbox
`endif // ASCON_SBOX_SV

`ifndef REDUCE_XOR_SV
`define REDUCE_XOR_SV

// `define REDUCE_XOR_RECURSIVE

module reduce_xor #(
    parameter NUM_ELEMENTS = 5,
    parameter ELEMENT_WIDTH = 4
)(
    in_elements, out_xor
);
    typedef bit[ELEMENT_WIDTH-1:0] T;
    
    input  T[NUM_ELEMENTS-1:0] in_elements;
    output T                   out_xor;
    
    bit[ELEMENT_WIDTH-1:0][NUM_ELEMENTS-1:0] transposed;
    genvar i, j;
    generate
        for (i = 0; i < ELEMENT_WIDTH; i += 1) begin
            for (j = 0; j < NUM_ELEMENTS; j += 1) begin
                assign transposed[i][j] = in_elements[j][i];
            end
            assign out_xor[i] = ^transposed[i];
        end
    endgenerate
endmodule : reduce_xor
`endif // REDUCE_XOR_SV

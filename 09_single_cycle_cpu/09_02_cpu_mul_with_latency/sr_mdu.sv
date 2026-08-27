//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

`include "sr_cpu.svh"

module sr_mdu
# (
    parameter n_delay = 2
)
(
    input               clk,
    input               rst,

    input               i_vld,
    input        [31:0] srcA,
    input        [31:0] srcB,
    output              o_vld,
    output logic [31:0] result,
    output              busy
);

    logic busy_r;

    always_ff @(posedge clk or posedge rst) begin   
        if (rst)
            busy_r <= 1'b0;
        else if (i_vld)
            busy_r <= 1'b1;
        else if (o_vld)
            busy_r <= 1'b0;
    end

    assign busy = busy_r;


    logic [31:0] buf_r;   
    assign buf_r = srcA * srcB; 


    shift_register #(
    .width(1),
    .depth(2)
    ) valid (
    .clk(clk),
    .rst(rst),
    .in_data(i_vld),
    .out_data(o_vld)
    );

    shift_register #(
        .width(32),
        .depth(2)
    ) result_b (
        .clk(clk),
        .rst(rst),
        .in_data(buf_r),
        .out_data(result)
    );




endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 1, depth = 2
)(
    input                clk,
    input                rst,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        if(rst) begin
            for(int i = 0; i < depth; i++)
                data[i] = '0;
        end else begin
            data [0] <= in_data;
            for (int i = 1; i < depth; i ++)
                data [i] <= data [i - 1];
        end
    end

    assign out_data = data [depth - 1];

endmodule


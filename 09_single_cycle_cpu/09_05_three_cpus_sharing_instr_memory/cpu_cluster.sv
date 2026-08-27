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

module cpu_cluster
#(
    parameter nCPUs = 3
)
(
    input                        clk,      // clock
    input                        rst,      // reset

    input   [nCPUs - 1:0][31:0]  rstPC,    // program counter set on reset
    input   [nCPUs - 1:0][ 4:0]  regAddr,  // debug access reg address
    output  [nCPUs - 1:0][31:0]  regData   // debug access reg data
);
    localparam ROM_SIZE = 1024;
    localparam ADDR_W  = $clog2(ROM_SIZE);

    wire [nCPUs - 1:0][31:0] imAddr;
    logic [31:0] romAddr;
    wire [31:0] imData;

    wire [7:0] gnt;

    round_robin_arbiter_8 arbiter
    (
        .clk ( clk ),
        .rst ( rst ),
        .req ( 8'b00000111 ),
        .gnt ( gnt )
    );

    assign romAddr = gnt[0] ? imAddr[0] : (gnt[1] ? imAddr[1] : imAddr[2]);

    instruction_rom # (.SIZE (ROM_SIZE)) i_rom
    (
        .a       (ADDR_W'(romAddr)),
        .rd      (imData)
    );

    sr_cpu cpu_1
            (
                .clk(clk),
                .rst(rst),
                .rstPC (rstPC[0]),
                .imAddr(imAddr[0]),
                .imData(imData),
                .imDataVld(gnt[0]),
                .regAddr(regAddr[0]),
                .regData(regData[0])
            );
    
    sr_cpu cpu_2
            (
                .clk(clk),
                .rst(rst),
                .rstPC (rstPC[1]),
                .imAddr(imAddr[1]),
                .imData(imData),
                .imDataVld(gnt[1]),
                .regAddr(regAddr[1]),
                .regData(regData[1])
            );

    sr_cpu cpu_3
            (
                .clk(clk),
                .rst(rst),
                .rstPC (rstPC[2]),
                .imAddr(imAddr[2]),
                .imData(imData),
                .imDataVld(gnt[2]),
                .regAddr(regAddr[2]),
                .regData(regData[2])
            );


endmodule

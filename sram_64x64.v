`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:57 10/06/2018 
// Design Name: 
// Module Name:    sram_64x64 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sram_64x64(
    input                   clk_i,
    input                   rst_i,
    input                   wr_en_i,
    input                   rd_en_i,
    input [5:0]             addr_i,
    input [63:0]            wdata_i,
	 output [63:0]           rdata_o
);

    reg [63:0]          bram[63:0];    
    integer          i;   
    reg [63:0]       data;
//add implementation code here 
    always @(posedge clk_i or posedge rst_i)
    begin
       if (rst_i)   
         begin
           for(i=0;i<=63;i=i+1) //reset, 按字操作
           bram[i] <= 32'b0;
         end
       else if (wr_en_i) begin
            bram[addr_i] <= wdata_i;
       end
       else if (rd_en_i) begin
            data <= bram[addr_i];
       end
       else begin
        data <= 32'bz;      //读写均无效时，为高阻态。若不加此句，时序会出现问题
       end
    end

    assign rdata_o = data ;
endmodule

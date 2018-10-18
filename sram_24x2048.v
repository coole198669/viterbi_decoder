`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:21:57 10/06/2018 
// Design Name: 
// Module Name:    sram_24x2048 
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
module sram_24x2048(
    input                   clk_i,
    input                   rst_i,
    input                   wr_en_i,
    input                   rd_en_i,
    input [10:0]             addr_i,
    input [23:0]            wdata_i,
	 output [23:0]           rdata_o
);

    reg [23:0]          bram[2047:0];    
    integer          i;   
    reg [23:0]       data;
//add implementation code here 
    always @(posedge clk_i or posedge rst_i)
    begin
       if (rst_i)   
         begin
           for(i=0;i<=2047;i=i+1) //reset, 按字操作
           bram[i] <= 23'b0;
         end
       else if (wr_en_i) begin
            bram[addr_i] <= wdata_i;
       end
       else if (rd_en_i) begin
            data <= bram[addr_i];
       end
       else begin
        data <= 23'bz;      //读写均无效时，为高阻态。若不加此句，时序会出现问题
       end
    end

    assign rdata_o = data ;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2021 08:49:08 AM
// Design Name: 
// Module Name: drawing_line_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
localparam ADC_bit = 4;
typedef struct {
    logic [ADC_bit-1:0] red;
    logic [ADC_bit-1:0] green;
    logic [ADC_bit-1:0] blue; 
}pixel_color;
module drawing_line_top(
    input logic clk,
    input logic rst,
    //input logic pin,
    output logic Hsync,
    output logic Vsync,
    output logic [ADC_bit-1:0] vgaRed,
    output logic [ADC_bit-1:0] vgaGreen,
    output logic [ADC_bit-1:0] vgaBlue,
    input logic [11:0] x0,y0,x1,y1,
    output logic disp_en,
    output logic vga_clk,
    output logic [11:0] v_cntr, h_cntr
    );
    
    logic  vga_clk_buff;
    clock_div#(4) vga_clk_mod(.clock(clk), .reset(rst), .div_clock(vga_clk_buff) ); 
    
    logic [11:0] v_cntr_buff, h_cntr_buff;
    logic Hsync_buff, Vsync_buff, disp_en_buff;   
    vga_controller#(
         .h_actv_pixel(50), 
         .h_sync_pulse(2),
         .h_back_porch(1),
         .h_front_porch(3),
         .h_sync_pol(0),
        
         .v_actv_pixel(60),
         .v_sync_pulse(1),
         .v_back_porch(1),
         .v_front_porch(1),
         .v_sync_pol(0)
    ) vgatxt(.clk(vga_clk_buff), .reset(rst), .h_sync(Hsync_buff), .v_sync(Vsync_buff), .h_counter_out(h_cntr_buff), .v_counter_out(v_cntr_buff), .disp_enable(disp_en_buff));
    
    
    // coordinate of the beginning and end of the line
    logic [11:0] x0_1 = 320;
    logic [11:0] y0_1 = 20;
    logic [11:0] x1_1 = 250;
    logic [11:0] y1_1 = 170;
    
    logic [11:0] x0_2 = 200;
    logic [11:0] y0_2 = 80;
    logic [11:0] x1_2 = 440;
    logic [11:0] y1_2 = 80;
    
    logic [11:0] pix_y_1, pix_x_1;
    logic [11:0] pix_y,pix_x; // pixel coordinate that is left black, return value of the line drawer module
    /*pixel_color my_color_t = '{4'b0 ,4'b0 , 4'b0} ; // color palette for one pixel RGB
    assign {vgaRed, vgaGreen, vgaBlue} = {my_color_t.red, my_color_t.green, my_color_t.blue};*/
    //line draawer module
    logic [11:0] zx0, zx1; 
    //assign zx0 = x0 -1;
    //assign zx1 = x1 -1;
    logic [11:0] z_cntr;
    
    line_drawer drw1(.nx0(x0), .nx1(x1),.disp_en(disp_en_buff), .rst(rst), .Vsync(Vsync_buff), .ny0(y0), .ny1(y1), .v_cntr(v_cntr_buff), .h_cntr(h_cntr_buff), .vga_clk(vga_clk_buff), .y(pix_y), .x(pix_x)); 
    //line_drawer drw2(.nx0(x0_1), .nx1(x1_1),.disp_en(disp_en_buff), .rst(rst), .Vsync(Vsync), .ny0(y0_1), .ny1(y1_1), .v_cntr(v_cntr), .h_cntr(h_cntr), .vga_clk(vga_clk), .y(pix_y_1), .x(pix_x_1));  //,.x(pix_x), .y(pix_y));
    logic [11:0] pix_y_2, pix_x_2;
    //line_drawer drw3(.nx0(x0_2), .nx1(x1_2),.disp_en(disp_en_buff), .rst(rst), .Vsync(Vsync), .ny0(y0_2), .ny1(y1_2), .v_cntr(v_cntr), .h_cntr(h_cntr), .vga_clk(vga_clk), .y(pix_y_2), .x(pix_x_2)); 
    
    // to display pixel, sequential 
    pixel_color my_color = '{4'b0 ,4'b0 , 4'b0} ; // color palette for one pixel RGB
    assign {vgaRed, vgaGreen, vgaBlue} = {my_color.red, my_color.green, my_color.blue};/// assign it to output port
    
    always_ff @(posedge vga_clk_buff)begin
        if (( (h_cntr_buff == pix_x && v_cntr_buff == pix_y ))&& disp_en_buff == 1'b1 )begin // || (h_cntr == pix_x_1 && v_cntr == pix_y_1 )  || (h_cntr == pix_x_2 && v_cntr == pix_y_2 )
            my_color <= '{4'hf,4'b0,4'b0};
            //{vgaRed, vgaGreen, vgaBlue} <= {4'hf,4'b0,4'b0};
        end  
        else if (disp_en_buff == 1'b1) begin
            my_color <= '{4'b1111,4'b1111,4'b1111};
        end
        else begin
            my_color <= '{4'b0 ,4'b0 , 4'b0}; 
        end
    end
    
    assign vga_clk = vga_clk_buff;
    always_ff @(posedge vga_clk_buff)begin
        v_cntr <= v_cntr_buff;
        h_cntr <= h_cntr_buff;
        Vsync <= Vsync_buff;
        Hsync <= Hsync_buff;
        
        disp_en <= disp_en_buff;
    end
    
    
endmodule

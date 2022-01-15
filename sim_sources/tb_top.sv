`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2021 07:47:00 AM
// Design Name: 
// Module Name: tb_top
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
// top level testbench contains the interface, DUT and test
// connects all these together
//`include "vga_interface.sv"
//`include "testbench_pkg.svh"
`include "const_pkg.svh"
`include "testbench_pkg.svh"

import testbench_pkg::*;


module tb_top();
    vga_interface line_if();

    bit clk=1;
    
    always #5 clk = ~clk;
     
    property vga_clk_check_ast;
       @(posedge clk) $rose(line_if.vga_clk) |->##[3:6] !line_if.vga_clk;
    endproperty
    VGA_CLK_PER_CHECK: assert property(vga_clk_check_ast)
    else $error("Assertion Error: vga_clk_check_ast");
    
    property vsync_check_ast;
       @(posedge clk) line_if.Vsync |->##[0:$] $fell(line_if.Vsync);
    endproperty
    VSYNC_CHECK: assert property(vsync_check_ast)
    else $error("Assertion Error: vsync_check_ast");
   
    // instantiade the top module
    drawing_line_top DUT(
                        .clk(clk),
                        .rst(line_if.rst), 
                        .Vsync(line_if.Vsync), 
                        .vgaRed(line_if.vga_r), 
                        .vgaGreen(line_if.vga_g),
                        .vgaBlue(line_if.vga_b), 
                        .x0(line_if.x0),
                        .y0(line_if.y0), 
                        .x1(line_if.x1),
                        .y1(line_if.y1), 
                        .disp_en(line_if.disp_en),
                        .vga_clk(line_if.vga_clk),  
                        .v_cntr(line_if.v_cntr),
                        .h_cntr(line_if.h_cntr) 
                        );
    test m_test;
    
    assert property
        (@(posedge clk) clk |->##[0:3] !line_if.rst);
        
    initial begin
        $display("TEST_STARTING");
        line_if.rst = 1;
        //apply reset
        #200ns;
        line_if.rst = 0;
        m_test = new(); // new test object
        m_test.m_env.line_vif = line_if ; // assign and connect the interface
        fork
           begin
              m_test.run();// run the test
           end
           begin
              #2ms;
           end
        join_any
        $display("TEST_FINISHED");
        $finish;
    end 
endmodule
interface  vga_interface();
    logic rst;
    logic [11:0] x0, y0, x1, y1;
    logic disp_en;
    logic [11:0] v_cntr, h_cntr;
    logic Hsync, Vsync;
    logic [3:0] vga_r, vga_g, vga_b;
    logic vga_clk;
endinterface
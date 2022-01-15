// transaction object

typedef struct {
    logic [`ADC_bit-1:0] red;
    logic [`ADC_bit-1:0] green;
    logic [`ADC_bit-1:0] blue; 
}pixel_color;



class sequence_item;
    /*typedef struct {
        logic [`CRDNT-1:0] h_crdnt; // x
        logic [`CRDNT-1:0] v_crdnt; // y
    }crdnt;*/
    rand bit [11:0] x0,y0,x1,y1;
    bit disp_en;
    bit [11:0] v_cntr, h_cntr;
    bit Hsync, Vsync;
    bit [3:0] vga_r, vga_g, vga_b;
    bit vga_clk;
    crdnt crdnt_t; /// use this to send data from monitor to scoreboard
    pixel_color color;
    function void print (input string tag="");
        $display("T=%0t %s crdnt x0:0x%0h y0:0x%0h x1:0x%0h y1:0x%0h v_cntr:0x%0h, h_cntr:0x%0h ", $time, tag, x0,y0,x1,y1, v_cntr, h_cntr);
    endfunction
endclass
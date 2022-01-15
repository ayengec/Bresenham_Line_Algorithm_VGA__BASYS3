`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2021 08:52:12 AM
// Design Name: 
// Module Name: line_drawer
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




module line_drawer(
    //input logic [11:0] x0,y0,x1,y1,
    input logic [11:0] nx0,ny0,nx1,ny1,
    input logic  disp_en,
    input logic [11:0] v_cntr,
    input logic [11:0] h_cntr,
    input logic vga_clk,
    input logic rst, 
    input logic Vsync,
    output logic [11:0] y, x
    );
    
    logic [11:0] x0 = 2;
    logic [11:0] y0 = 7;
    logic [11:0] x1 = 9;
    logic [11:0] y1 = 2;
    
    logic [11:0] n,w;
    //x, wide side should be increasing order
    
    
    logic [11:0] w0,n0,w1,n1;
   
    
    /*
        x axis is the horizontal axis
        y axis is the vertical axis
    */
    
    // first calculate the dx and dy and D 
    // dx = x1 - x0, dy = y1 - y0, D = 2dy - dx 
    // equate the current y with the y0 
    
    // reset steg is done, then loop through x pixel, 
    // when the crdnt on the x axis changes, decide the coordinate of the pixel will be drawn send as decision
    
    
    // state of the drawer, set state to set the difference values, does the precalculation
    // loop state to loop through the pixel
    
    typedef enum logic [1:0] {set_drawer,loop_drawer, low_high, reset_state} drawer_state;
    
    drawer_state drw_s = low_high; ///state of the drawer
    
    //logic [11:0] dx,dy; // difference btw end of the line and beginning of the line 
    logic [11:0] dw,dn;
    //////////////////////////////////////////////////////////////////////////////////////
    int  D;
    int offset_D = 32'hffff;
    ///////////////////////////////////////////////////////////////////////////////////////
    //logic [11:0] x_cntr = 12'd0;
    logic [11:0] w_cntr = 12'd0;
    
    
     
    logic low_or_high = 1'b0;  // if x is greater 1, y is greater 0
    
    // change y-vertical axis as narrow side
    // vhange x-horizontal axis as wider side
    
    // this logic is used to indicate if the narow side coordinate will be incremented or decremented
    // if narrow axis increase along with the wide axis, n_dir is 1 and n is gonna be incremented
    // if narrow axis deecrease alogn with the wide axis, n_dir is 0 and n is gonna be  decremented 
    logic n_dir ; 
    always_ff @(posedge vga_clk)begin
            if(rst)begin
                w_cntr <= 'd0;
                drw_s <= low_high;
            end 
            else begin
                
                case(drw_s) 
                    low_high:begin
                                if(x0 >  x1 && y0 > y1 )begin
                                    if((x0 - x1) > (y0 - y1))begin
                                        low_or_high <= 1'b1 ;
                                    end
                                    else begin
                                        low_or_high <= 1'b0 ;
                                    end
                                end
                                else if(x0 >  x1 && y0 < y1 )begin
                                    if((x0 - x1) > (y1 - y0))begin
                                        low_or_high <= 1'b1 ;
                                    end
                                    else begin
                                        low_or_high <= 1'b0 ;
                                    end
                                end
                                else if(x0 <  x1 && y0 > y1 )begin
                                    if((x1 - x0) > (y0 - y1))begin
                                        low_or_high <= 1'b1 ;
                                    end
                                    else begin
                                        low_or_high <= 1'b0 ;
                                    end
                                end
                                else if(x0 <  x1 && y0 < y1 )begin
                                    if((x1 - x0) > (y1 - y0))begin
                                        low_or_high <= 1'b1 ;
                                    end
                                    else begin
                                        low_or_high <= 1'b0 ;
                                    end
                                end 
                                drw_s <= set_drawer;                                                                                            
                            end
                    set_drawer:begin
                                /// calculate dx and dy and D , equate current y to y0
                                /// pre calculation
                                    if(low_or_high == 1'b1)begin // x is wider
                                        if(x0 > x1)begin 
                                            {w0, n0, w1, n1} <= {x1,y1,x0,y0}; 
                                            dw <= x0 - x1;
                                            if(y0 > y1) begin
                                                dn <= y0 - y1;
                                                D <= 2*(y0 - y1) - (x0 - x1) + offset_D; 
                                                n_dir <= 1'b0; // n is decremented
                                            end
                                            else begin
                                                dn <= y1 - y0;
                                                D <= 2*(y1 - y0) - (x0 - x1) + offset_D; 
                                                n_dir <= 1'b0; // n is incremented
                                            end
                                            n <= y1;
                                            w <= x1;// + x_cntr; wide one is always incremented
                                            w_cntr <= 'd0;
                                            drw_s <= loop_drawer;
                                        end
                                        else begin
                                            {w0, n0, w1, n1} <= {x0,y0,x1,y1}; 
                                            dw <= x1 - x0;
                                            if(y1 > y0) begin
                                                dn <= y1 - y0;
                                                D <= 2*(y1 - y0) - (x1 - x0) + offset_D;
                                                n_dir <= 1'b1; // n is increment
                                            end
                                            else begin
                                                dn <= y0 - y1;
                                                D <= 2*(y0 - y1) - (x1 - x0) + offset_D;
                                                n_dir <= 1'b0; // n is decremented
                                            end
                                            // also decide whether the y will be incremented or decremented, when the D>0_offset is satisfied
                                            //dn <= n1 - n0;
                                            n <= y0;
                                            w <= x0;// + x_cntr;
                                            w_cntr <= 'd0;
                                              
                                            drw_s <= loop_drawer;
                                        
                                        end
                                    end
                                    else begin    /// high y is wider
                                        if(y0 > y1)begin 
                                           {w0, n0, w1, n1} <= {y1,x1,y0,x0}; 
                                           dw <= y0 - y1; 
                                           if(x0 > x1) begin
                                               dn <= x0 - x1;
                                               n_dir <= 1'b0; // n is decremented
                                               D <= 2*(x0 - x1) - (y0 - y1) + offset_D;
                                           end
                                           else begin
                                               dn <= x1 - x0;
                                               n_dir <= 1'b1; // n is incremented
                                               D <= 2*(x1 - x0) - (y0 - y1) + offset_D;
                                           end
                                           n <= x0;
                                           w <= y1;// + x_cntr;
                                           w_cntr <= 'd0;
                                           //D <= 2*(y0 - y1) - (x0 - x1) + offset_D;  
                                           drw_s <= loop_drawer;
                                        end
                                        else begin /// y1 > y0
                                            {w0, n0, w1, n1} <= {y0,x0,y1,x1}; 
                                            dw <= y1 - y0;
                                            if(x0 > x1) begin
                                              dn <= x0 - x1;
                                              n_dir <= 1'b0; // n is decremented
                                              D <= 2*(x0 - x1) - (y1 - y0) + offset_D;
                                            end
                                            else begin
                                              dn <= x1 - x0;
                                              n_dir <= 1'b1; // n is incremented
                                              D <= 2*(x1 - x0) - (y1 - y0) + offset_D;
                                            end
                                            n <= x0;
                                            w <= y0;// + x_cntr;
                                            w_cntr <= 'd0;
                                            //D <= 2*(y0 - y1) - (x0 - x1) + offset_D;  
                                            drw_s <= loop_drawer;
                                        end
                                    end
                                    /*
                                    dw <= w1 - w0;
                                    if(n1 > n0) begin
                                        dn <= n1 - n0;
                                        n_dir <= 1'b1; // n is incremented
                                    end
                                    else begin
                                        dn <= n0 - n1;
                                        n_dir <= 1'b0; // n is decremented
                                    end
                                    // also decide whether the y will be incremented or decremented, when the D>0_offset is satisfied
                                    //dn <= n1 - n0;
                                    n <= n0;
                                    w <= w0;// + x_cntr;
                                    w_cntr <= 'd0;
                                    D <= 2*(n1 - n0) - (w1 - w0) + offset_D;  
                                    drw_s <= loop_drawer;*/
                                end
                    loop_drawer:begin
                                    // waits for the pixel
                                    // wait untill the vertical crdnt matches the w0
                                    // if y is wider w-y, n-x, otherwise x is wider w-x,n-y
                                    //if x is wider low_or_high is 1, in case of wide y low_or_high is 0
                                    if(low_or_high == 1'b1)
                                        {x,y} <= {w,n};
                                    else
                                        {x,y} <= {n,w};
                                        
                                    //w <= w0 + w_cntr;
                                    
                                    // change this to vertical or horizontal
                                    // if high(x is wider) and ()  or   (if low y is wider) and ()
                                    if(  (low_or_high == 1'b1) && (h_cntr +1 == w0 + w_cntr) ||    ((low_or_high == 1'b0) && (v_cntr == w0 + w_cntr && h_cntr > n ) ))begin //  ||    ((low_or_high == 1'b0) && (v_cntr == w0 + w_cntr && h_cntr > n ) ) (low_or_high == 1'b1) && 
                                        w_cntr <= w_cntr + 1; // increment x counter
                                        w <= w + 1;
                                        if( D > (12'd0 + offset_D) )begin  // if D is positive, pixel should be in the negative half plane
                                            if(n_dir == 1'b0)begin// decrement n
                                                n <= n - 1;
                                            end
                                            if(n_dir == 1'b1)begin// increment n
                                                n <= n + 1; 
                                            end
                                            D <= D - 2*dw  + 2*dn;
                                        end
                                        else begin
                                        D <= D + 2*dn;
                                        end
                                    end 
                                    //(low_or_high == 1'b1) && (w_cntr + w0 == w1+1) ||    ((low_or_high == 1'b0) && (w_cntr + w0 == w1)
                                    if(((low_or_high == 1'b1) && (w_cntr + w0 == w1)) ||    ((low_or_high == 1'b0) && (w_cntr + w0 == w1+1))) begin // end of the line, reset the x_cntr and enter the loop_drawer state
                                        w_cntr <= 'd0; 
                                        n <= n0;
                                        w <= w0;
                                        drw_s <= set_drawer;   
                                    end
                                end
                    
                endcase        
            end
            if(x0 != nx0 || y0 != ny0 || x1 != nx1 || y1 != ny1)begin
                {x0, y0, x1, y1} <= {nx0, ny0, nx1, ny1};
                drw_s <= low_high;
            end
        end
    
endmodule
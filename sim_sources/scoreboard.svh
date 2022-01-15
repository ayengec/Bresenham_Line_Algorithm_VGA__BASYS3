`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.01.2022 21:51:43
// Design Name: 
// Module Name: scoreboard
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
typedef struct {    
    logic [`CRDNT-1:0] x0;
    logic [`CRDNT-1:0] y0;
    logic [`CRDNT-1:0] x1;
    logic [`CRDNT-1:0] y1;
}a_line;



class scoreboard;
   /* typedef struct {
        logic [`CRDNT-1:0] h_crdnt; // x
        logic [`CRDNT-1:0] v_crdnt; // y
    }crdnt;*/
    mailbox scb_mbx;
    mailbox drv2scb_mbx;
    event all_pix_send;

    crdnt  crdnt_d [$]; //unbounded queues , generated
    crdnt  crdnt_dut [$]; // coordinates from dut
    
    a_line line_z; // this will hold the line 
    
    int v_error [$];
    int  h_error [$];
    int err_occrd ;
    int d_size, dut_size;
    
    // returns the absolute value of the input 
    function logic [`CRDNT-1:0] abs_t(input logic [`CRDNT-1:0] a);
         return  (a[`CRDNT-1]) ? -a : a; 
    endfunction
    task run();
            sequence_item drv_item = new;  
            #138us;  // first frame might contain garbage datas, checking after 2nd frame started
     
            fork
                forever begin// compares the resulting
                    @ (all_pix_send); // wait untill the all pixels are sent from monitor
                    for(int c = 0; c < crdnt_dut.size(); c++)begin
                        $display("T=%0t [Scoreboard] ----v_cntr: 0x%0h, h_cntr: 0x%0h size of 0x%0h 0x%0h ", 
                        $time, crdnt_dut[c].v_crdnt, crdnt_dut[c].h_crdnt, crdnt_dut.size(), crdnt_d.size());
                    end
                    crdnt_dut.sort();
                    crdnt_d.sort();
                    /// examine the otput of the DUT(crdnt_dut) and the algorithm results(crdnt_d) 
                    //that generates line coordinates in scoreboard
                    err_occrd = 0; // put the error code in err_cord, print the error accrding to this
                    d_size = crdnt_d.size();// check the size of the arrays that stores the pixel coordinates
                    dut_size = crdnt_dut.size();
                    if (  d_size == dut_size )begin // if same size
                        // start looping through pixels and compare them
                        for (int c = 0; c < crdnt_dut.size(); c++)begin
                            // if a coordinate does not match, store the error margin between them
                            // before storing the error check if the same error occured before, if not store it
                            if(crdnt_dut[c].v_crdnt != crdnt_d[c].v_crdnt)begin
                                err_occrd = 1; // if there is shifting, set err_occrd to 1
                                if ( !((crdnt_d[c].v_crdnt - crdnt_dut[c].v_crdnt) inside {v_error}))begin
                                    v_error.push_back(crdnt_d[c].v_crdnt - crdnt_dut[c].v_crdnt);
                                end
                            end
                            // for horizontal crdnt the same as the vertical coordinate
                            else if(crdnt_dut[c].h_crdnt != crdnt_d[c].h_crdnt) begin
                                err_occrd = 1;// if there is shifting, set err_occrd to 1
                                if ( !((crdnt_d[c].h_crdnt - crdnt_dut[c].h_crdnt) inside {h_error}))begin
                                    h_error.push_back(crdnt_d[c].h_crdnt - crdnt_dut[c].h_crdnt);
                                end;
                            end
                        end
                    end
                    else begin// if sizes of result of reference model and DUT do not match
                        err_occrd = 2;// completely mismatch error code
                    end
                    // check the error code(err_occrd), display the error accordingly
                    if(err_occrd == 0)begin
                        $display("T = %0t [SCOREBOARD] PASS!  ,line of x0: 0x%0h, y0: 0x%0h, x1: 0x%0h, y1: 0x%0h", $time, drv_item.x0,
                             drv_item.y0, drv_item.x1,drv_item.y1);
                    end
                    else if(err_occrd == 1)begin
                        if(v_error.size() < 2 && h_error.size() < 2)begin
                            $display("T = %0t [SCOREBOARD] ERROR!,vertical error: 0x%0h, horizontal error: 0x%0h ,line of x0: 0x%0h, y0: 0x%0h, x1: 0x%0h, y1: 0x%0h", $time,
                             abs_t(v_error[0]),abs_t(h_error[0]), drv_item.x0,drv_item.y0,drv_item.x1,drv_item.y1);
                        end
                        else begin
                           $display("T = %0t [SCOREBOARD] ERROR!,completeley mismatched  ,line of x0: 0x%0h, y0: 0x%0h, x1: 0x%0h, y1: 0x%0h",
                            $time, drv_item.x0,  drv_item.y0,drv_item.x1,drv_item.y1);
                        end
                    end
                   else if (err_occrd == 2)begin
                           $display("T = %0t [SCOREBOARD] ERROR!,completeley mismatched  ,line of x0: 0x%0h, y0: 0x%0h, x1: 0x%0h, y1: 0x%0h",
                            $time, drv_item.x0,drv_item.y0, drv_item.x1, drv_item.y1);
                   end 
                    
                    // delete the m_item of the crdnt dut
                    crdnt_dut.delete();
                    v_error.delete();
                    h_error.delete();
                    $display("   ");
                end
                // stores the data coming from monitor
                forever begin
                    sequence_item m_item = new;// new transaction object
                    
                    // it contains queue  
                    scb_mbx.get(m_item); // when the m_item arrived
                    // check if it is in the color of a line,
                    if(m_item.color.red == 4'hf && m_item.color.green == 4'h0 
                                            && m_item.color.blue == 4'h0)begin
                        // if it is push back to queue
                        crdnt_dut.push_back(m_item.crdnt_t); 
                    end  
                    // when the m_item arrived, check if it is in the color of a line, 
                    //if it is push back to queue
                    // and wait untill the event that indicates all pixel
                    // of the one page is send from monitor
                end
                // this loop runs the reference model when the data arrived from driver
                forever begin
                     // sequence_item drv_item = new; keep line m_item beg of the forever
                    drv2scb_mbx.get(drv_item);
                    
                    {line_z.x0, line_z.y0, line_z.x1,line_z.y1} = {drv_item.x0, 
                                                                    drv_item.y0, 
                                                                    drv_item.x1, drv_item.y1};
                    
                    $display(
                    "T=%0t [Scoreboard] crdnt from driver via transaction x0:0x%0h y0:0x%0h x1:0x%0h y1:0x%0h "
                                                    , $time, drv_item.x0,
                                                     drv_item.y0,
                                                     drv_item.x1,
                                                     drv_item.y1);
                     
                     // before calling the function, delete all element
                     // delete both array that is generated by function and send by dut-monitor
                     crdnt_d.delete();
                     bresenham(line_z,crdnt_d);
                    for(int i = 0; i < crdnt_d.size(); i++)begin
                        $display(" alg v_cntr: 0x%0h, h_cntr:0x%0h ",crdnt_d[i].v_crdnt,crdnt_d[i].h_crdnt);
                     end
                 end
                 
            join_any
    endtask
    function bresenham(input a_line line_1, ref crdnt crdnt_d [$]);
            logic [`CRDNT-1:0] x0 = line_1.x0;
            logic [`CRDNT-1:0] x1 = line_1.x1;
            logic [`CRDNT-1:0] y0 = line_1.y0;
            logic [`CRDNT-1:0] y1 = line_1.y1;   
            
            a_line line_z;
            
            if( abs_t(y1-y0) < abs_t(x1-x0))begin
                if(x0 > x1)begin
                    {line_z.x0, line_z.y0, line_z.x1, line_z.y1} = {x1,y1,x0,y0};   
                end 
                else begin 
                    {line_z.x0, line_z.y0, line_z.x1, line_z.y1} = {x0,y0,x1,y1};
                end
                plotlineLow(line_z, crdnt_d);    
            end
            else begin
                if(y0>y1) begin
                    {line_z.x0, line_z.y0, line_z.x1, line_z.y1} = {x1,y1,x0,y0};
                end
                else begin
                    {line_z.x0, line_z.y0, line_z.x1, line_z.y1} = {x0,y0,x1,y1};
                end
                plotlineHigh(line_z, crdnt_d);
            end
    endfunction
    //if y projection is wider, use plotlineHigh    
    function plotlineHigh(input a_line line_1,ref  crdnt crdnt_d [$]);
        int dx, dy, D,xi;//differences and error D
        logic [`CRDNT-1:0] x;
        logic [`CRDNT-1:0] x0 = line_1.x0;//two end corrdinate of the line
        logic [`CRDNT-1:0] x1 = line_1.x1;
        logic [`CRDNT-1:0] y0 = line_1.y0;
        logic [`CRDNT-1:0] y1 = line_1.y1;
        
        // it will return the coordinate of the pixel to be drawn
        // an dynamic array is input as reference
        // fill this dynamic array 
        crdnt crdnt_plt;
        dx = x1 - x0;
        dy = y1 - y0;
        xi = 1;// this will be add on to x
        // if x1 < x0, decrement x
        // if x0 < x1 increment x
        if(dx<0)begin
            xi = -1; // so if x0 is larger than x1, set xi to -1 
            dx = -dx;
        end
        D = (2 *dx) -dy; // set error
        x = x0; 
        
        //start counting of the wide side and 
        //decide wheter narrow side should change or keep it same
        for(int y = y0; y < y1+1; y++)begin
            crdnt_plt.h_crdnt = x;
            crdnt_plt.v_crdnt = y;
            crdnt_d.push_back(crdnt_plt);// push the resulting coordinate
            // type of the array is crdnt_plt
            if(D>0)begin// if error positive
                x = x + xi;// increment or decrement
                D = D + (2 * (dx - dy));//set error for next check
            end
            else begin// if error negative
                // no change in the crdnt of x
                D = D + 2*dx;//set error for next check
            end
        end
    endfunction
    //if x projection is wider, use plotlineLow
    function plotlineLow(input a_line line_1,ref  crdnt crdnt_d [$]);
        int dx, dy, D,yi;//differences and error D
        logic [`CRDNT-1:0] y;
        logic [`CRDNT-1:0] x0 = line_1.x0;//two end corrdinate of the line
        logic [`CRDNT-1:0] x1 = line_1.x1;
        logic [`CRDNT-1:0] y0 = line_1.y0;
        logic [`CRDNT-1:0] y1 = line_1.y1;
        // it will return the coordinate of the pixel to be drawn
        // an dynamic array is input as reference
        // fill this dynamic array        
        crdnt crdnt_plt;
        dx = x1 - x0;
        dy = y1 - y0;
        yi = 1;// this will be add on to y
                // if y1 < y0, decrement y
                // if y0 < y1 increment y
        if(dy<0)begin
            yi = -1;// so if y0 is larger than y1, set yi to -1 
            dy = -dy;
        end
        D = 2*dy - dx;
        y = y0;      
        //start counting of the wide side and 
        //decide wheter narrow side should change or keep it same
        for(int x=x0; x < x1+1; x++)begin
            crdnt_plt.h_crdnt = x;
            crdnt_plt.v_crdnt = y;
            if(yi == 1)begin
                crdnt_d.push_back(crdnt_plt);// push the resulting coordinate
            end
            else if (yi == -1)begin
                crdnt_d.push_front(crdnt_plt);// push the resulting coordinate
            end
            // type of the array is crdnt_plt
            if(D > 0) begin// if error positive
                y = y + yi;// increment or decrement
                D = D + 2*(dy - dx) ;//set error for next check
            end
            else begin// if error negative
            // no change in the crdnt of y
                D = D + 2*dy;//set error for next check
            end 
        end
    
    endfunction
endclass

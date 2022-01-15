`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2021 07:41:16 AM
// Design Name: 
// Module Name: vga_controller
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


/*
vga_scrn_spec is the data structure to hold the screen timing info
number of active video area, porches and sync pixel data is stored

horizontal data indicates the num of  pixel, vertical data indicates the num of line
h_sync_pol, and v_sync_pol, indicates the polarization of the sync signal, which is low (0) for VGA
*/
typedef struct {
    int h_actv_pixel = 640;
    int h_sync_pulse = 96;
    int h_back_porch = 48;
    int h_front_porch = 16;
    int h_sync_pol = 0;
    
    int v_actv_pixel = 480;
    int v_sync_pulse = 2;
    int v_back_porch = 33;
    int v_front_porch = 10;
    int v_sync_pol = 0;
} vga_scrn_spec;


module vga_controller #( 
    parameter h_actv_pixel = 640,
    parameter h_sync_pulse = 96,
    parameter h_back_porch = 48,
    parameter h_front_porch = 16,
    parameter h_sync_pol = 0,
    
    parameter v_actv_pixel = 480,
    parameter v_sync_pulse = 2,
    parameter v_back_porch = 33,
    parameter v_front_porch = 10,
    parameter v_sync_pol = 0    
)(
    input logic clk,   // pixel clock, not the system clock, it should be connected to divided proper clock for VGA format
    input logic reset, // reset is active high
    output logic h_sync, // horizontal syncronization pin
    output logic v_sync, // vertical syncronizatiion pin 
    output logic [11:0] h_counter_out, // returns the horizontal pixel coordinate 
    output logic [11:0] v_counter_out, // returns the vertical pixel coordinate that is displayed
    output logic disp_enable  // display enable is active low
    );
    
   /*
   HORIZONTAL TIMING
   this line is horizontal sync signal           -------------------------------------------__________________------------ 
   this represent  a line of pixels on the screen.....active region........||frontPorch|||||__syncPulseregion__|||backPorch 
                                                 send here display pixel...||||||||all RGB value should be 0|||||||||||||||
   for 640*480 pixel screen
   line operation: sends 640 display pixel(active area)
                    sends 16 black pixel for front porch,
                    sets horizontal sync to low for 96 pixel
                     then sends 48 black pixel for back porch 
                     
   VERTICAL TIMING
   */
    /*
    v_tot_pixel , h_tot_pixel are the sum of all sync pulse, porches and active pixel areas for horizontal and vertical
    total pixels on the screen, contains all displayed area and blank area
    
    
    beg_of_v_sync and end_f_v_sync
    to send the sync signal correctly according to timing, beggining and end of the sync signal are indicated, 
    when the pixel counters are in the range of these parameters, sync signal is set 
    
    v_counter and h_counter
    according to these two counter, program knows 
    if the current pixel is in the active region then sends display data
    if the counter pixel is in the are of sync pulse then it will set the sync signal     
    */
    localparam v_tot_pixel = v_sync_pulse + v_back_porch + v_actv_pixel + v_front_porch;
    localparam h_tot_pixel = h_sync_pulse + h_back_porch + h_actv_pixel + h_front_porch;
    
    localparam beg_of_v_sync = v_actv_pixel + v_front_porch ;
    localparam end_of_v_sync = v_sync_pulse + v_actv_pixel + v_front_porch -1 ;
    
    
    localparam beg_of_h_sync = h_actv_pixel + h_front_porch ;
    localparam end_of_h_sync = h_sync_pulse + h_actv_pixel + h_front_porch -1 ;
    
    logic [11:0]  v_counter;
    logic [11:0]  h_counter;
    
   
    
 
    
    always_ff @(posedge clk or  posedge reset )begin
    /* asynchronous reset, resets all pixel counters, beginning pixel is top left one
       set sync signals to high,
       reset the disp_enable signal so the top module will not send display pixel 
     */ 
        h_counter_out <= h_counter;
        v_counter_out <= v_counter;
        if (reset)begin     
            v_counter <= 0; // reset the counters
            h_counter <= 0;
            h_sync <= ~h_sync_pol;
            v_sync <= ~v_sync_pol;
            h_counter_out <= 0;
            v_counter_out <= 0;
            //disp_enable <= 0;// display enable is active low
        end
        else begin
        
            // count the pixel, v_counter, h_counter
            // will indicate where we are and 
            //by comparing them with the porches and sync pixels coordinates, disp_enable, h_sync and v_sync signals are generated
            if (h_counter < (h_tot_pixel-1))begin
                h_counter <= h_counter + 1 ;
            end
            else begin
                h_counter <= 0;
                if (v_counter < (v_tot_pixel -1))
                    v_counter <= v_counter + 1 ;
                else 
                    v_counter <= 0;
            end
            
            
            /* create the h_sync signal
            When the pixel counters are in the range of synchronization region, set sync signal to zero(low)
            out of the region sync signals remain high
            h_sync_pol is low(0)
            */
            if(h_counter inside {[beg_of_h_sync : end_of_h_sync]})begin
                h_sync <= h_sync_pol; 
            end           
            else begin
                h_sync <= ~h_sync_pol;
            end
            // create the v_sync signal
            if ((v_counter inside {[beg_of_v_sync : end_of_v_sync]}))
                v_sync <= v_sync_pol;
            else
                v_sync <= ~v_sync_pol;
     


        end
    end 
      
    always_ff @(posedge clk or  posedge reset)begin
        if(reset)begin
            disp_enable <= 0;
        end
        else begin
          /* create the disp_enable signa
            When the counters are in the range of displayable pixel area, disp_enable pin is set to high(one)
            so the top module can sends the pixel values to display meaningfull thigns
            l*/
            if ((v_counter inside {[0:v_actv_pixel-1]}) & (h_counter inside {[0:h_actv_pixel-1]}) )
                disp_enable <= 1;
            else 
                disp_enable <= 0; 
            end
    end
    
endmodule


/*

 always_ff @(negedge clk or negedge reset)begin
        if(reset)begin
            disp_enable <= 0;
        end
        else begin
          ///create the disp_enable signa
            //When the counters are in the range of displayable pixel area, disp_enable pin is set to high(one)
            //so the top module can sends the pixel values to display meaningfull thigns
           // l
            if ((v_counter inside {[0:v_actv_pixel-1]}) & (h_counter inside {[0:h_actv_pixel-1]}) )
                disp_enable <= 1;
            else 
                disp_enable <= 0; 
            end
    end

*/


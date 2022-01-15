

class monitor;

    virtual vga_interface line_vif;
    mailbox scb_mbx;
    event all_pix_send; // indicates and triggered when the all pixels of the one page is send
    
    task run();
        $display("T=%0t [Monitor] starting", $time);
        forever begin
            sequence_item m_item = new;
            
            /////////////////////////////////////////////////////////////
            @ (posedge line_vif.Vsync);
            $display("T=%0t [Monitor] starting to send pixel data ", $time);
            while( line_vif.Vsync ) begin // while vertical sync is high
                @ (posedge line_vif.vga_clk); // at the positive edge of the vga clock
                if(line_vif.disp_en == 1)begin // if the display enable is high, means it is in the active region
                    /*if(line_vif.vga_r == 4'hf & line_vif.vga_g == 4'h0  & line_vif.vga_b == 4'h0)begin
                        crdnt_temp.v_crdnt = line_vif.v_cntr;
                        crdnt_temp.h_crdnt = line_vif.h_cntr;
                        m_item.crdnt_q.push_back(crdnt_temp);
                        //$display("T=%0t [MONITOR] starting v:0x%0h , h:0x%0h", $time,line_vif.v_cntr,line_vif.h_cntr );
                    end*/
                    m_item.crdnt_t.v_crdnt = line_vif.v_cntr; // place vertical crdnt into trns objetc
                    m_item.crdnt_t.h_crdnt = line_vif.h_cntr; // place horizontal crdnt into trns object
                    m_item.color.red = line_vif.vga_r;   // place the color of the pixel 
                    m_item.color.green = line_vif.vga_g;
                    m_item.color.blue = line_vif.vga_b;
                    scb_mbx.put(m_item);
                end
            end 
            //////////////////////////////////////////////////////////////
            $display("T=%0t [Monitor] all pixel data send ", $time);
            #0 -> all_pix_send;
        end   
    endtask
endclass
class driver;
    virtual vga_interface line_vif;
    event driver_wait;
    mailbox driver_mbx;
    mailbox drv2scb_mbx;
    
    task run();
        sequence_item m_item = new;
        sequence_item scb_item = new;
        
        $display ("T=%0t [Driver] starting.. ", $time);
        forever begin 
            #5 -> driver_wait;
            @ (posedge line_vif.Vsync); // wait untill the positive edge of the vsync pulse, then send new coordinate
            $display("T= %0t [Driver] waiting for m_item  ", $time);
            driver_mbx.get(m_item);
            $display("T= %0t [Driver] m_item arrived, x0:0x%0h  y0:0x%0h x1:0x%0h y1:0x%0h ", $time, m_item.x0, m_item.y0, m_item.x1,m_item.y1);
            /// to dut via interface
            line_vif.x0 <= m_item.x0;
            line_vif.y0 <= m_item.y0;
            line_vif.x1 <= m_item.x1;
            line_vif.y1 <= m_item.y1;
            
            
            // to scoreboard via transaction object
            scb_item.x0 = m_item.x0;
            scb_item.y0 = m_item.y0;
            scb_item.x1 = m_item.x1;
            scb_item.y1 = m_item.y1;
            
            drv2scb_mbx.put(scb_item);
        end
    endtask
endclass
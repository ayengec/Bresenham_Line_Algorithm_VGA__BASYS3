
class environment;
    driver d0;
    generator g0;
    monitor m0;
    scoreboard s0;
    mailbox driver_mbx;// mailbox btwn driver and generator
    mailbox scb_mbx; // btwn monitor and scoreboard
    mailbox drv2scb_mbx;// driver to scoreboard
    event driver_wait;// when triggered,
    //driver indicates it is ready to receive data from generator
    event all_pix_send;//when triggered
    //monitor indicates all pixel is sent of a frame
    //so scoreboard can start scoring 
    
    //interface to DUT
    //instantiate all components and
    // 
    virtual vga_interface line_vif;
    
    function new();
        d0 = new();//new objects
        g0 = new();
        m0 = new();
        s0 = new();
        driver_mbx = new();
        scb_mbx = new();
        drv2scb_mbx = new();
        
        //assign all handels
        d0.driver_mbx = driver_mbx;
        g0.driver_mbx = driver_mbx;
        m0.scb_mbx = scb_mbx;
        s0.scb_mbx = scb_mbx;
        d0.drv2scb_mbx = drv2scb_mbx;
        s0.drv2scb_mbx = drv2scb_mbx;
        
        d0.driver_wait = driver_wait;
        g0.driver_wait = driver_wait;
        
        m0.all_pix_send = all_pix_send;
        s0.all_pix_send = all_pix_send;
        
    endfunction
    
    virtual task run();
            d0.line_vif = line_vif;
            m0.line_vif = line_vif;
            fork //run all component
                d0.run();
                m0.run();
                g0.run();
                s0.run();
            join_any
    endtask
    
endclass
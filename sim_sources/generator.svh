class generator;
    mailbox driver_mbx;// initilize mailbox, between generator and driver
    event driver_wait;
    int test_crdnt [5][4]  = { {0,0,9,9},
                                {10,2,2,20},
                                {20,2,1,10}, 
                                {3,3,8,15},
                                {2,2,2,20}
                                };
    task run();
        forever begin
            sequence_item m_item = new; // create new transaction object
            for(int g = 0; g < 5; g++ )begin
                $display("T=%0t [Generator]waits the driver event ", $time);
                @ (driver_wait)
                m_item.x0 = test_crdnt[g][0];
                m_item.y0 = test_crdnt[g][1];
                m_item.x1 = test_crdnt[g][2];
                m_item.y1 = test_crdnt[g][3];
        
                driver_mbx.put(m_item); // put transaction object into mailbox
                $display("T=%0t [Generator] send the line coordinate ", $time);
            end
        end
    endtask
endclass
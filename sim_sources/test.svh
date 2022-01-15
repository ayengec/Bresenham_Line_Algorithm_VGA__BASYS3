class test;
    environment m_env; 
    function new();
        m_env = new();
    endfunction
    
    task run();
        $display ("T=%0t new test", $time);
        m_env.run();
    endtask
    
endclass
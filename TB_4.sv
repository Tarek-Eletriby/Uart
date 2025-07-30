module uart_tx_tb_n(uart_if.tb_mp intf);
`include "uart_packet4.sv"

  typedef struct packed {
     logic         tx; 
     logic         tx_busy; 
  } output_t;
 

  uart_packet        stim_array[];
  output_t        sim_output[$];
  output_t    expected_op[$];



 // uart_tx dut (.*);
  
  function void configure_stim_storage(int size);
    stim_array = new[size];
    expected_op.delete();
    sim_output.delete();
  endfunction
  
  task automatic generate_stimulus(ref uart_packet stim_array[]);
    foreach (stim_array[i]) begin
      stim_array[i] = new();
      assert(stim_array[i].randomize()) else $finish;
      stim_array[i].sample_coverage();
    end
  endtask

task automatic drive_stim();
    foreach(stim_array[j])
    begin
      @(negedge intf.clk);
      intf.rst_n=1;
      intf.data_in = stim_array[j].data_in;
      intf.parity_en = stim_array[j].parity_en;
      intf.even_parity = stim_array[j].even_parity;
      collect_output_data(intf.tx, intf.tx_busy);
      intf.tx_start=1;

      @(negedge intf.clk);
      intf.tx_start=0;
      @(negedge intf.clk);
       collect_output_data(intf.tx, intf.tx_busy); //collect tx_busy and tx idle 0;
      @(negedge intf.clk);
      //collect tx_busy and tx 0 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 1 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 2 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 3 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 4 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 5 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 6 bit
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy and tx 7 bit
      collect_output_data(intf.tx, intf.tx_busy);    
      if(intf.parity_en!=0) begin
        @(negedge intf.clk);
        //collect tx_busy and tx parity
        collect_output_data(intf.tx, intf.tx_busy);
      end
      @(negedge intf.clk);
      //collect tx_busy=1 and tx =1
      collect_output_data(intf.tx, intf.tx_busy);
      @(negedge intf.clk);
      //collect tx_busy=0 and tx =1
      collect_output_data(intf.tx, intf.tx_busy);
    end
endtask

// Task to test reset during transmission for FSM coverage
task automatic test_reset_scenarios();
    // Test reset during START state
    @(negedge intf.clk);
    intf.rst_n = 1;
    intf.data_in = 8'hAA;
    intf.parity_en = 1;
    intf.even_parity = 1;
    intf.tx_start = 1;
    @(negedge intf.clk);
    intf.tx_start = 0;
    // Reset during START state
    @(negedge intf.clk);
    intf.rst_n = 0;
    @(negedge intf.clk);
    intf.rst_n = 1;
    
    // Test reset during DATA state
    @(negedge intf.clk);
    intf.data_in = 8'h55;
    intf.parity_en = 1;
    intf.tx_start = 1;
    @(negedge intf.clk);
    intf.tx_start = 0;
    @(negedge intf.clk); // START state
    @(negedge intf.clk); // DATA state
    @(negedge intf.clk); // Still in DATA state
    // Reset during DATA state
    intf.rst_n = 0;
    @(negedge intf.clk);
    intf.rst_n = 1;
    
    // Test reset during PARITY state
    @(negedge intf.clk);
    intf.data_in = 8'hFF;
    intf.parity_en = 1;
    intf.tx_start = 1;
    @(negedge intf.clk);
    intf.tx_start = 0;
    // Wait until parity state
    repeat(9) @(negedge intf.clk); // START + 8 DATA bits
    // Reset during PARITY state
    intf.rst_n = 0;
    @(negedge intf.clk);
    intf.rst_n = 1;
endtask

task collect_output_data(logic tx, logic tx_busy);
    output_t out_0;
    out_0.tx=tx;
    out_0.tx_busy=tx_busy;
    sim_output.push_back(out_0);
endtask

task automatic golden_model();
    output_t out_1;
    output_t out_2;
    logic [7:0] data_temp;
    foreach (stim_array[i]) begin
      if(intf.rst_n==0)
      begin
      out_1.tx=1;
      out_1.tx_busy=0;
      expected_op.push_back(out_1);
      end

      else begin
      out_2.tx=1;
      out_2.tx_busy=0;
      expected_op.push_back(out_2);
      #10ns;
      out_2.tx=0;
      out_2.tx_busy=1;
      expected_op.push_back(out_2);
      data_temp = stim_array[i].data_in;
      for (int j = 0; j < 8; j++) begin
         out_2.tx = data_temp[j];
         out_2.tx_busy = 1;
         expected_op.push_back(out_2);
      end
      if(stim_array[i].parity_en!=0)
            begin
                if(stim_array[i].even_parity!=0)
                    out_2.tx = ^data_temp;
                else
                    out_2.tx = ~^data_temp;
                out_2.tx_busy=1;
                expected_op.push_back(out_2);
            end
      out_2.tx=1;
      out_2.tx_busy=1;
      expected_op.push_back(out_2);
      #20ns;
      out_2.tx=1;
      out_2.tx_busy=0;
      expected_op.push_back(out_2);
    end
    end
endtask

task check_results ();
    output_t temp;
    for (int i = 0; i < sim_output.size() && i < expected_op.size(); i++) begin
        temp = expected_op[i]; // Use by index
        if (temp.tx == sim_output[i].tx && temp.tx_busy == sim_output[i].tx_busy)
    $display("[PASSED] tx = %0b, tx_busy = %0b | expected tx = %0b, expected_tx_busy = %0b",
             sim_output[i].tx, sim_output[i].tx_busy,
             temp.tx, temp.tx_busy);
else
    $error("[ERROR] tx = %0b, tx_busy = %0b | expected tx = %0b, expected_tx_busy = %0b",
           sim_output[i].tx, sim_output[i].tx_busy,
           temp.tx, temp.tx_busy);

    end
endtask


  initial begin
    intf.rst_n=0;
    #20ns;
    configure_stim_storage(100);
    generate_stimulus(stim_array);
    drive_stim();
    
    // Test reset scenarios for better FSM coverage
    test_reset_scenarios();
    
    golden_model();
    check_results();

  end
endmodule
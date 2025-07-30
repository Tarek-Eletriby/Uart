//`include "uart_if.sv"
//`include "design.v"
//`include "tb.sv"
//import uart_packet_pkg::*;

module top;
  logic clk = 0;
  always #5ns clk = ~clk;

  uart_if intf(clk);
  uart_tx dut(.intf(intf));
  uart_tx_tb tb(.intf(intf));
endmodule

  class uart_packet;
    rand    logic [7:0] data_in;
    rand    bit   parity_en;
    rand    bit   even_parity;

    constraint even_parity_c {
        even_parity dist {1 :/ 50 , 0 :/ 50};
    }

    covergroup uart_cov;

    cp_data_in_all: coverpoint data_in {
      option.auto_bin_max = 256;
    }

    cp_data_in_corner: coverpoint data_in {
      bins all_zeros    = {8'b00000000};
      bins all_ones     = {8'b11111111};
      bins ascending[]  = {[8'b00000001:8'b01111111]}; // from 1 to 127
      bins descending[] = {[8'b10000000:8'b11111110]}; // from 128 to 254
    }

    cp_parity_type: coverpoint {parity_en, even_parity} {
      bins no_parity    = {2'b00};
      bins even_parity  = {2'b11};
      bins odd_parity   = {2'b10};
    }
    endgroup

      function new();
         uart_cov = new();
      endfunction

      function void sample_coverage();
         uart_cov.sample();
      endfunction
  endclass
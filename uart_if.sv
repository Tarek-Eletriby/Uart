interface uart_if(input bit clk);
    logic rst_n;
    logic tx_start;
    logic [7:0] data_in;
    logic parity_en;
    logic even_parity;
    logic tx;
    logic tx_busy;

    modport dut_mp (
        input clk, rst_n, tx_start, data_in, parity_en, even_parity,
        output tx, tx_busy
    );

    modport tb_mp (
        input clk, tx, tx_busy,
        output rst_n, tx_start, data_in, parity_en, even_parity
    );
endinterface

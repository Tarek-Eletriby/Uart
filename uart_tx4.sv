module uart_tx(uart_if.dut_mp intf);

    reg tx_reg, tx_busy_reg;
    assign intf.tx = tx_reg;
    assign intf.tx_busy = tx_busy_reg;

    // State machine states
    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARITY = 3'd3,
               STOP   = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg       parity_bit;

    always @(posedge intf.clk or negedge intf.rst_n) begin
        if (!intf.rst_n) begin
            state     <= IDLE;
            tx_reg        <= 1'b1;  // idle is high
            tx_busy_reg   <= 1'b0;
            shift_reg <= 8'd0;
            bit_cnt   <= 4'd0;
            parity_bit <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_reg <= 1'b1;
                    tx_busy_reg <= 1'b0;
                    if (intf.tx_start) begin
                        shift_reg <= intf.data_in;
                        bit_cnt <= 4'd0;
                        parity_bit <= (intf.even_parity) ? (^intf.data_in) : ~(^intf.data_in);
                        tx_busy_reg <= 1'b1;
                        state <= START;
                    end
                end

                START: begin
                    tx_reg <= 1'b0; // start bit
                    state <= DATA;
                end

                DATA: begin
                    tx_reg <= shift_reg[0];             
                    shift_reg <= shift_reg >> 1;     
                    bit_cnt <= bit_cnt + 1;  
                    if (bit_cnt == 4'd7) begin
                        if (intf.parity_en)
                            state <= PARITY;
                        else
                            state <= STOP;
                    end
                end

                PARITY: begin
                    tx_reg <= parity_bit;
                    state <= STOP;
                end

                STOP: begin
                    tx_reg <= 1'b1; // stop bit (always 1)
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
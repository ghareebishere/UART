module uart_tx_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,         // Baud tick from generator
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_busy
  );
  // FSM States
  parameter IDLE       = 3'b000;
  parameter START_BIT  = 3'b001;
  parameter DATA_BITS  = 3'b010;
  parameter PARITY_BIT = 3'b011;
  parameter STOP_BIT   = 3'b100;
  parameter CLEANUP    = 3'b101;

  reg [2:0] state = IDLE;
  reg [7:0] data_reg;
  reg       parity_bit;
  reg [3:0] bit_index;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      state     <= IDLE;
      tx        <= 1'b1;
      tx_busy   <= 0;
      bit_index <= 0;
    end
    else if (tick)
    begin
      case (state)
        IDLE:
        begin
          tx <= 1;
          tx_busy <= 0;
          if (tx_start)
          begin
            data_reg <= tx_data;
            parity_bit <= ^tx_data; // Even parity
            bit_index <= 0;
            tx_busy <= 1;
            state <= START_BIT;
          end
        end
        START_BIT:
        begin
          tx <= 0; // Start bit
          state <= DATA_BITS;
        end
        DATA_BITS:
        begin
          tx <= data_reg[bit_index];
          bit_index <= bit_index + 1;
          if (bit_index == 7)
            state <= PARITY_BIT;
        end
        PARITY_BIT:
        begin
          tx <= parity_bit;
          state <= STOP_BIT;
        end
        STOP_BIT:
        begin
          tx <= 1;
          state <= CLEANUP;
        end
        CLEANUP:
        begin
          tx_busy <= 0;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule

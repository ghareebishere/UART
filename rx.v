module uart_rx_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,          // 16× baud tick
    input  wire       rx,
    output reg [7:0]  rx_data,
    output reg        rx_valid,
    output reg        parity_error,
    output reg        stop_error
  );

  // FSM States
  parameter IDLE   = 3'b000;
  parameter START  = 3'b001;
  parameter DATA   = 3'b010;
  parameter PARITY = 3'b011;
  parameter STOP   = 3'b100;
  parameter DONE   = 3'b101;

  reg [2:0] state = IDLE;
  reg [3:0] sample_count = 0;
  reg [3:0] bit_index = 0;
  reg [7:0] data_buffer = 0;
  reg       received_parity;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      state <= IDLE;
      rx_valid <= 0;
      parity_error <= 0;
      stop_error <= 0;
    end
    else if (tick)
    begin
      case (state)
        IDLE:
        begin
          rx_valid <= 0;
          if (rx == 0)
          begin
            sample_count <= 0;
            state <= START;
          end
        end
        START:
        begin
          sample_count <= sample_count + 1;
          if (sample_count == 7)
          begin
            if (rx == 0)
            begin
              sample_count <= 0;
              bit_index <= 0;
              state <= DATA;
            end
            else
            begin
              state <= IDLE;
            end
          end
        end
        DATA:
        begin
          sample_count <= sample_count + 1;
          if (sample_count == 15)
          begin
            data_buffer[bit_index] <= rx;
            bit_index <= bit_index + 1;
            sample_count <= 0;
            if (bit_index == 7)
              state <= PARITY;
          end
        end
        PARITY:
        begin
          sample_count <= sample_count + 1;
          if (sample_count == 15)
          begin
            received_parity <= rx;
            sample_count <= 0;
            state <= STOP;
          end
        end
        STOP:
        begin
          sample_count <= sample_count + 1;
          if (sample_count == 15)
          begin
            stop_error <= (rx != 1);
            parity_error <= (received_parity != (^data_buffer));
            rx_data <= data_buffer;
            rx_valid <= 1;
            state <= DONE;
          end
        end
        DONE:
        begin
          rx_valid <= 0;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule

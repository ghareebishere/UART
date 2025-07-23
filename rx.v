module uart_rx_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       tick,          //! tick from baude generator
    input  wire       rx, //! serialized data in
    output reg [7:0]  rx_data, //! parallel data
    output reg        rx_valid, //! vaild byte flag
    output reg        parity_error, //! error check  parity
    output reg        stop_error //! stop bit error
  );

  // FSM States
  parameter IDLE   = 3'b000; 
  parameter START  = 3'b001; //! start bit state 
  parameter DATA   = 3'b010; //! data bits state
  parameter PARITY = 3'b011; //! parity in
  parameter STOP   = 3'b100;
  parameter DONE   = 3'b101; //! rise vaild flag, go back to IDLE

  reg [2:0] state = IDLE;
  reg [3:0] sample_count = 0; //!  for the oversampling proccess
  reg [3:0] bit_index = 0;
  reg [7:0] data_buffer = 0; //! where the recived bits be stored?
  reg       received_parity; //! wbu recived parity for checking?

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

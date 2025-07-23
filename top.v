module uart_top #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    input  wire       rx,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       parity_error,
    output wire       stop_error
);

wire tick_tx, tick_rx;

  // Shared Baud Generator: tick for TX and RX
  baud_gen #(.BAUD_RATE(BAUD_RATE), .CLK_FREQ(50000000), .OVERSAMPLE(1)) baud_tx (
             .clk(clk), .rst(rst), .tick(tick_tx)
           );

  baud_gen #(.BAUD_RATE(BAUD_RATE), .CLK_FREQ(50000000), .OVERSAMPLE(16)) baud_rx (
             .clk(clk), .rst(rst), .tick(tick_rx)
           );

  uart_tx_fsm tx_unit (
                .clk(clk), .rst(rst),
                .tick(tick_tx),
                .tx_start(tx_start),
                .tx_data(tx_data),
                .tx(tx),
                .tx_busy()
              );

  uart_rx_fsm rx_unit (
                .clk(clk), .rst(rst),
                .tick(tick_rx),
                .rx(rx),
                .rx_data(rx_data),
                .rx_valid(rx_valid),
                .parity_error(parity_error),
                .stop_error(stop_error)
              );
endmodule

`timescale 1ns/1ps

module uart_top_tb;

  // Parameters
  parameter CLK_PERIOD = 20;  // 50 MHz clock
  parameter BAUD_RATE = 115_200;

  // Signals
  reg clk;
  reg rst;
  reg tx_start;
  reg [7:0] tx_data;
  wire tx;
  wire [7:0] rx_data;
  wire rx_valid;
  wire parity_error;
  wire stop_error;

  // Instantiate UUT with loopback
  uart_top #(
             .CLK_FREQ(50_000_000),
             .BAUD_RATE(BAUD_RATE))
           uut (
             .clk(clk),
             .rst(rst),
             .tx_start(tx_start),
             .tx_data(tx_data),
             .tx(tx),
             .rx(tx),  // Loopback: connect TX to RX
             .rx_data(rx_data),
             .rx_valid(rx_valid),
             .parity_error(parity_error),
             .stop_error(stop_error)
           );

  // Clock generation
  initial
  begin
    clk = 0;
    forever
      #(CLK_PERIOD/2) clk = ~clk;
  end

  // Main test sequence
  initial
  begin
    // Initialize
    rst = 1;
    tx_start = 0;
    tx_data = 0;
    #100;

    // Release reset
    rst = 0;
    #100;

    $display("Starting UART top module testbench...");

    // Test 1: Single byte transmission with loopback
    $display("\nTest 1: Transmit and receive 8'h55");
    tx_data = 8'h55;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(rx_valid);
    check_result(8'h55, 0, 0);

    // Test 2: Different byte with loopback
    $display("\nTest 2: Transmit and receive 8'hAA");
    tx_data = 8'hAA;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(rx_valid);
    check_result(8'hAA, 0, 0);

    // Test 3: Continuous transmission
    $display("\nTest 3: Continuous transmission");
    tx_data = 8'h12;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(rx_valid);

    tx_data = 8'h34;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(rx_valid);

    tx_data = 8'h56;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(rx_valid);

    $display("\nAll tests completed!");
    $finish;
  end

  // Result checking task
  task check_result;
    input [7:0] exp_data;
    input exp_parity_error;
    input exp_stop_error;
    begin
      if (rx_data !== exp_data)
        $display("ERROR: Data 0x%h != expected 0x%h", rx_data, exp_data);
      else
        $display("Data OK: 0x%h", rx_data);

      if (parity_error !== exp_parity_error)
        $display("ERROR: Parity error %b != expected %b",
                 parity_error, exp_parity_error);
      else
        $display("Parity error: %b (expected)", parity_error);

      if (stop_error !== exp_stop_error)
        $display("ERROR: Stop error %b != expected %b",
                 stop_error, exp_stop_error);
      else
        $display("Stop error: %b (expected)", stop_error);
    end
  endtask

  // Basic monitoring
  initial
  begin
    $monitor("Time: %0t ns | TX Start: %b | TX: %b | RX Data: 0x%h | Valid: %b | Errors: P:%b S:%b",
             $time, tx_start, tx, rx_data, rx_valid, parity_error, stop_error);
  end

  // VCD dump for waveform viewing
  initial
  begin
    $dumpfile("uart_top_tb.vcd");
    $dumpvars(0, uart_top_tb);
  end
endmodule

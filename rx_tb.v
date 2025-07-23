`timescale 1ns/1ps

module uart_rx_fsm_tb;

  // Parameters (using faster baud rate for quicker simulation)
  parameter CLK_PERIOD = 20;       // 50 MHz clock
  parameter BAUD_RATE = 1_000_000; // 1 Mbps (faster simulation)
  parameter BIT_TIME = 1_000_000_000 / BAUD_RATE; // 1000ns
  parameter TICK_PERIOD = BIT_TIME / 16;          // 62.5ns

  // Signals
  reg clk;
  reg rst;
  reg tick;
  reg rx;
  wire [7:0] rx_data;
  wire rx_valid;
  wire parity_error;
  wire stop_error;

  // Instantiate UART RX FSM
  uart_rx_fsm uut (
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .parity_error(parity_error),
    .stop_error(stop_error)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Tick generation (simplified)
  initial begin
    tick = 0;
    forever #(TICK_PERIOD) tick = ~tick;
  end

  // Main test sequence
  initial begin
    // Initialize
    rst = 1;
    rx = 1;
    #100;
    rst = 0;
    #100;
    
    $display("Starting simplified UART RX FSM testbench...");
    
    // Test 1: Normal transmission
    $display("\nTest 1: Normal transmission");
    send_byte(8'hA5, 0, 0);
    check_result(8'hA5, 0, 0);
    
    // Test 2: Parity error
    $display("\nTest 2: Parity error");
    send_byte(8'h5A, 1, 0); // Inject parity error
    check_result(8'h5A, 1, 0);
    
    // Test 3: Stop bit error
    $display("\nTest 3: Stop bit error");
    send_byte(8'h99, 0, 1); // Inject stop bit error
    check_result(8'h99, 0, 1);
    
    $display("\nAll tests completed!");
    $finish;
  end

  // Simplified byte transmission task
  task send_byte;
    input [7:0] data;
    input parity_err;
    input stop_err;
    integer i;
    reg parity;
    begin
      parity = ^data; // Calculate parity
      
      // Start bit
      rx = 0;
      #BIT_TIME;
      
      // Data bits (LSB first)
      for (i = 0; i < 8; i = i + 1) begin
        rx = data[i];
        #BIT_TIME;
      end
      
      // Parity bit (with optional error)
      rx = parity_err ? ~parity : parity;
      #BIT_TIME;
      
      // Stop bit (with optional error)
      rx = stop_err ? 0 : 1;
      #BIT_TIME;
      
      // Return to idle
      rx = 1;
      #(BIT_TIME);
    end
  endtask

  // Simplified result checking
  task check_result;
    input [7:0] exp_data;
    input exp_parity_err;
    input exp_stop_err;
    begin
      wait(rx_valid);
      #10;
      
      if (rx_data !== exp_data)
        $display("ERROR: Data 0x%h != expected 0x%h", rx_data, exp_data);
      else
        $display("Data OK: 0x%h", rx_data);
        
      if (parity_error !== exp_parity_err)
        $display("ERROR: Parity error %b != expected %b", 
                 parity_error, exp_parity_err);
      else
        $display("Parity error: %b (expected)", parity_error);
        
      if (stop_error !== exp_stop_err)
        $display("ERROR: Stop error %b != expected %b", 
                 stop_error, exp_stop_err);
      else
        $display("Stop error: %b (expected)", stop_error);
    end
  endtask

  // Basic monitoring
  initial begin
    $monitor("Time: %0t ns | RX: %b | Data: 0x%h | Valid: %b | Errors: P:%b S:%b",
             $time, rx, rx_data, rx_valid, parity_error, stop_error);
  end

  // VCD dump
  initial begin
    $dumpfile("uart_rx_fsm_tb.vcd");
    $dumpvars(0, uart_rx_fsm_tb);
  end
endmodule
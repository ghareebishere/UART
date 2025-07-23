`timescale 1ns/1ps

module uart_tx_fsm_tb;

  // Parameters
  parameter CLK_PERIOD = 10;  // 100 MHz clock
  parameter BAUD_RATE = 1_000_000;  // 1 Mbps for faster simulation
  parameter TICK_PERIOD = 1_000_000_000 / BAUD_RATE;  // 1000ns (1µs)
  
  // Signals
  reg clk;
  reg rst;
  reg tick;
  reg tx_start;
  reg [7:0] tx_data;
  wire tx;
  wire tx_busy;
  
  // Instantiate UUT
  uart_tx_fsm uut (
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end
  
  // Baud tick generation
  initial begin
    tick = 0;
    forever #(TICK_PERIOD/2) tick = ~tick;
  end
  
  // Main test sequence
  initial begin
    // Initialize
    rst = 1;
    tx_start = 0;
    tx_data = 0;
    #100;
    
    // Release reset
    rst = 0;
    #100;
    
    $display("Starting UART TX FSM testbench...");
    
    // Test 1: Single byte transmission
    $display("\nTest 1: Transmit 8'h55");
    tx_data = 8'h55;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    
    // Wait for transmission to complete
    wait(!tx_busy);
    #100;
    
    // Test 2: Another byte with different value
    $display("\nTest 2: Transmit 8'hAA");
    tx_data = 8'hAA;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    
    // Wait for transmission to complete
    wait(!tx_busy);
    #100;
    
    // Test 3: Continuous transmission
    $display("\nTest 3: Continuous transmission");
    tx_data = 8'h12;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(!tx_busy);
    
    tx_data = 8'h34;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(!tx_busy);
    
    tx_data = 8'h56;
    tx_start = 1;
    @(posedge clk);
    tx_start = 0;
    wait(!tx_busy);
    
    $display("\nAll tests completed!");
    $finish;
  end
  
  // Basic monitoring
  initial begin
    $monitor("Time: %0t ns | State: %b | TX: %b | Busy: %b",
             $time, uut.state, tx, tx_busy);
  end
  
  // VCD dump for waveform viewing
  initial begin
    $dumpfile("uart_tx_fsm_tb.vcd");
    $dumpvars(0, uart_tx_fsm_tb);
  end
endmodule
`timescale 1ns / 1ps

module baud_gen_tb;

  reg clk = 0;
  reg rst = 1;
  wire tick;

  // Parameters for 1 MHz tick at 50 MHz clk
  localparam CLK_FREQ = 50000000;
  localparam BAUD = 1000000;
  localparam OVERSAMPLE = 1;

  baud_gen #(
             .CLK_FREQ(CLK_FREQ),
             .BAUD_RATE(BAUD),
             .OVERSAMPLE(OVERSAMPLE)
           ) dut (
             .clk(clk),
             .rst(rst),
             .tick(tick)
           );

  always #10 clk = ~clk; // 50 MHz

  integer tick_count = 0;

  initial
  begin
    $display("==== Baud Generator Test ====");
    #50;
    rst = 0;

    repeat (200)
    begin
      @(posedge clk);
      if (tick)
      begin
        tick_count = tick_count + 1;
        $display("Tick @ %0t ns", $time);
      end
    end

    $display("Total Ticks: %0d", tick_count);
    $finish;
  end
endmodule

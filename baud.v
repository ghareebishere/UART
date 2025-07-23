module baud_gen #(
    parameter CLK_FREQ = 50000000, //! clk of system
    parameter BAUD_RATE = 9600, //! parameterized baude rate
    parameter OVERSAMPLE = 1         //! 1 for TX, 16 for RX as oversampling in TX would be useless
  )(
    input wire clk,
    input wire rst,
    output reg tick
  );

  localparam integer DIVISOR = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
  reg [$clog2(DIVISOR)-1:0] counter = 0;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      counter <= 0;
      tick <= 0;
    end
    else if (counter == DIVISOR - 1)
    begin
      counter <= 0;
      tick <= 1;
    end
    else
    begin
      counter <= counter + 1;
      tick <= 0;
    end
  end
endmodule

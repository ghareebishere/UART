# intro
parameterized UART protocol implemented as
- TX: transmitter module
- RX: reciver module
- baud generator 
- top module to implement all the above as total unit

## TX
![](exports\uart_tx_fsm.svg "TX")
### ports

| name | Direction | Type       | Description               |
| --------- | --------- | ---------- | ------------------------- |
| clk       | input     | wire       | obv                       |
| rst       | input     | wire       | async rst                 |
| tick      | input     | wire       | Baud tick from generator  |
| tx_start  | input     | wire       | start flag                |
| tx_data   | input     | wire [7:0] | data in                   |
| tx        | output    |            | seralized data out        |
| tx_busy   | output    |            | busy working on data flag |
### Signals

| Name         | Type      | Description                                 |
| ------------ | --------- | ------------------------------------------- |
| data_reg     | reg [7:0] | reg for storing data and shifting operation |
| bit_index    | reg [3:0] | bit index track                             |

## RX
![](exports\uart_rx_fsm.svg "RX")
### Ports

| Port name    | Direction | Type  | Description               |
| ------------ | --------- | ----- | ------------------------- |
| tick         | input     | wire  | tick from baude generator |
| rx           | input     | wire  | serialized data in        |
| rx_data      | output    | [7:0] | parallel data             |
| rx_valid     | output    |       | vaild byte flag           |
| parity_error | output    |       | error check  parity       |
| stop_error   | output    |       | stop bit error            |

### Signals

| Name             | Type      | Description                       |
| ---------------- | --------- | --------------------------------- |
| sample_count = 0 | reg [3:0] | for the oversampling proccess     |
| bit_index = 0    | reg [3:0] |       tracking the index of processed bit|
| data_buffer = 0  | reg [7:0] | where the recived bits be stored? |
| received_parity  | reg       | wbu recived parity for checking?  |


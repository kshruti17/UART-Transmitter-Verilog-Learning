## Simulation Results

### UART Transmitter Waveform

The waveform illustrates the UART transmitter's TX signal, FSM state transitions, and data-bit progression during transmission.

![UART Transmitter Waveform](UART.jpeg)

### Testbench Simulation Output

The simulation output shows the testbench checks for the start bit, all eight data bits, stop bit, and transmission completion.

![UART Testbench Simulation Output](UART_simulation.jpeg)

## Key Learnings

- Understood UART serial communication and the 8-N-1 frame format.
- Calculated baud rate, bit period, and clock cycles per bit.
- Designed a four-state FSM: IDLE, START, DATA, and STOP.
- Implemented the UART transmitter using Verilog HDL.
- Created a testbench and verified the transmitted data using Icarus Verilog and EPWave.
- Learned to inspect waveforms and debug simulation issues.

## Future Improvements

- Test multiple data patterns.
- Verify bit timing independently.
- Implement a UART receiver and test transmitter-to-receiver communication.

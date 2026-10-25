`timescale 1ns/1ps

module tb_uart_tx;
    parameter integer CLKS_PER_BIT = 5208;
    parameter integer BIT_TIME = CLKS_PER_BIT * 20; // ns

    reg clk, rst, tx_start;
    reg [7:0] tx_data;
    wire tx, tx_busy, tx_done;
    integer i;

    uart_tx #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) dut (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy), .tx_done(tx_done)
    );

    // 50 MHz clock: 20 ns period.
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // VCD dump for EPWave.
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx);
    end

    initial begin
        rst = 1'b1;
        tx_start = 1'b0;
        tx_data = 8'h41; // ASCII 'A'

        repeat (5) @(negedge clk);
        rst = 1'b0;

        @(negedge clk);
        tx_start = 1'b1;
        @(negedge clk);
        tx_start = 1'b0;

        wait (tx_busy == 1'b1);

        // Check start bit at the midpoint of its bit period.
        #(BIT_TIME / 2);
        if (tx !== 1'b0) $display("ERROR: Start bit should be 0");
        else $display("PASS: Start bit = 0");

        // Check eight data bits, LSB first.
        for (i = 0; i < 8; i = i + 1) begin
            #(BIT_TIME);
            if (tx !== tx_data[i])
                $display("ERROR: Data bit %0d incorrect", i);
            else
                $display("PASS: Data bit %0d = %b", i, tx);
        end

        #(BIT_TIME);
        if (tx !== 1'b1) $display("ERROR: Stop bit should be 1");
        else $display("PASS: Stop bit = 1");

        wait (tx_done == 1'b1);
        $display("PASS: Transmission completed");

        @(posedge clk);
        #1;
        if (tx_done !== 1'b0) $display("ERROR: tx_done should return to 0");
        else $display("PASS: tx_done pulse cleared");

        $display("UART testbench finished.");
        $finish;
    end

    initial begin
        #(BIT_TIME * 12);
        $display("ERROR: Simulation timed out");
        $finish;
    end
endmodule

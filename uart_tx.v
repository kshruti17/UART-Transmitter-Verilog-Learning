`timescale 1ns/1ps

module uart_tx #(
    parameter integer CLK_FREQ = 50000000,
    parameter integer BAUD_RATE = 9600,
    parameter integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output wire       tx_busy,
    output reg        tx_done
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [12:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  data_reg;

    assign tx_busy = (state != IDLE);

    // Combinational output: TX level depends on the current FSM state.
    always @(*) begin
        case (state)
            IDLE:  tx = 1'b1;
            START: tx = 1'b0;
            DATA:  tx = data_reg[bit_index];
            STOP:  tx = 1'b1;
            default: tx = 1'b1;
        endcase
    end

    // Sequential FSM, baud counter, data register, and completion pulse.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            data_reg  <= 0;
            tx_done   <= 0;
        end
        else begin
            tx_done <= 0;

            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;

                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START;
                    end
                end

                START: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;

                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 0;
                        state <= IDLE;
                        tx_done <= 1'b1;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                    clk_count <= 0;
                    bit_index <= 0;
                end
            endcase
        end
    end

endmodule

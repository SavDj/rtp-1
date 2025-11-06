interface alu_if (
    input logic clk,
    input logic rst_n
);
    logic        i_valid;
    logic        o_ready;
    logic [7:0]  A;
    logic [7:0]  B;
    logic [2:0]  opcode;
    logic        single_cycle_mode;
    logic        o_valid;
    logic        o_busy;
    logic        o_error;
    logic [7:0]  result;
    logic        carry_out;
    logic        zero_flag;
    logic        overflow_flag;

    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output i_valid, A, B, opcode, single_cycle_mode;
        input  o_ready, o_valid, o_busy, o_error, result, carry_out, zero_flag, overflow_flag;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input i_valid, o_ready, A, B, opcode, single_cycle_mode;
        input o_valid, o_busy, o_error, result, carry_out, zero_flag, overflow_flag;
    endclocking

    modport DRIVER(clocking driver_cb, input clk, rst_n);
    modport MONITOR(clocking monitor_cb, input clk, rst_n);

endinterface
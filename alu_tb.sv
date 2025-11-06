module alu_tb;
  import uvm_pkg::*;
  import alu_pkg::*;

  bit clk;
  bit rst_n;

  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
  end

  alu_if intf (
      .clk(clk),
      .rst_n(rst_n)
  );

  alu dut (
      .clk(intf.clk),
      .rst_n(intf.rst_n),
      .i_valid(intf.i_valid),
      .o_ready(intf.o_ready),
      .A(intf.A),
      .B(intf.B),
      .opcode(intf.opcode),
      .single_cycle_mode(intf.single_cycle_mode),
      .o_valid(intf.o_valid),
      .o_busy(intf.o_busy),
      .o_error(intf.o_error),
      .result(intf.result),
      .carry_out(intf.carry_out),
      .zero_flag(intf.zero_flag),
      .overflow_flag(intf.overflow_flag)
  );

  initial begin
    uvm_config_db#(virtual alu_if.DRIVER)::set(uvm_root::get(), "*", "vif", intf.DRIVER);
    uvm_config_db#(virtual alu_if.MONITOR)::set(uvm_root::get(), "*", "vif", intf.MONITOR);
  end

  initial begin
    run_test("alu_test");
  end

  initial begin
    #50000;
    $display("*** TIMEOUT ***");
    $finish;
  end

endmodule
class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)

  alu_env env;
  alu_sequence  seq;

  function new(string name = "alu_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
    seq = alu_sequence::type_id::create("seq");
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Starting ALU test", UVM_LOW)
    seq.start(env.agnt.sequencer);
    #1000;
    `uvm_info("TEST", "ALU test completed", UVM_LOW)
    phase.drop_objection(this);
  endtask : run_phase

endclass : alu_test
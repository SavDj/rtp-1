class alu_env extends uvm_env;
  alu_agent      agnt;
  alu_scoreboard scb;

  `uvm_component_utils(alu_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agnt = alu_agent::type_id::create("agnt", this);
    scb = alu_scoreboard::type_id::create("scb", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    agnt.monitor.item_collected_port.connect(scb.item_collected_actual.analysis_export);
    
    agnt.driver.expected_item_port.connect(scb.item_collected_expected.analysis_export);
  endfunction : connect_phase

endclass : alu_env
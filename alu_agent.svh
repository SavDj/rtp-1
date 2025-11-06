class alu_agent extends uvm_agent;
  alu_driver    driver;
  alu_sequencer sequencer;
  alu_monitor   monitor;

  `uvm_component_utils(alu_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver = alu_driver::type_id::create("driver", this);
      sequencer = alu_sequencer::type_id::create("sequencer", this);
    end
    monitor = alu_monitor::type_id::create("monitor", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : alu_agent
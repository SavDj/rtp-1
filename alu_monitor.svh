class alu_monitor extends uvm_monitor;
    virtual alu_if.MONITOR vif;
    uvm_analysis_port #(alu_item) item_collected_port;
    alu_item trans_collected;

    `uvm_component_utils(alu_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        trans_collected = null;
        item_collected_port = new("item_collected_port", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_if.MONITOR)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            
            if (vif.monitor_cb.o_valid && vif.rst_n) begin
                trans_collected = alu_item::type_id::create("trans_collected");
                
                trans_collected.result = vif.monitor_cb.result;
                trans_collected.carry_out = vif.monitor_cb.carry_out;
                trans_collected.zero_flag = vif.monitor_cb.zero_flag;
                trans_collected.overflow_flag = vif.monitor_cb.overflow_flag;
                trans_collected.o_error = vif.monitor_cb.o_error;
                
                `uvm_info("MONITOR", $sformatf("Captured result: %0d (0x%0h)", 
                          trans_collected.result, trans_collected.result), UVM_MEDIUM)
                item_collected_port.write(trans_collected);
                trans_collected = null;
            end
        end
    endtask : run_phase

endclass : alu_monitor
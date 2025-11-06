class alu_driver extends uvm_driver #(alu_item);
    virtual alu_if.DRIVER vif;
    uvm_analysis_port #(alu_item) expected_item_port;

    `uvm_component_utils(alu_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        expected_item_port = new("expected_item_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual alu_if.DRIVER)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.driver_cb.i_valid <= 0;
        @(posedge vif.rst_n);

        forever begin
            seq_item_port.get_next_item(req);
            drive();
            seq_item_port.item_done();
        end
    endtask

    virtual task drive();
        req.compute_expected();

        `uvm_info("DRIVER", $sformatf("Driving: A=%0d, B=%0d, op=%0b, mode=%0b", 
                  req.A, req.B, req.opcode, req.single_cycle_mode), UVM_MEDIUM)

        vif.driver_cb.single_cycle_mode <= req.single_cycle_mode;
        @(vif.driver_cb);

        vif.driver_cb.i_valid <= 1;
        vif.driver_cb.A <= req.A;
        vif.driver_cb.B <= req.B;
        vif.driver_cb.opcode <= req.opcode;

        do begin
            @(vif.driver_cb);
        end while (vif.driver_cb.o_ready !== 1);

        vif.driver_cb.i_valid <= 0;

        expected_item_port.write(req);

        `uvm_info("DRIVER", "Transaction accepted", UVM_MEDIUM)
    endtask

endclass
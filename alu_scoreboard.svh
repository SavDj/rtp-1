class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_tlm_analysis_fifo #(alu_item) item_collected_expected, item_collected_actual;
    int tests_passed = 0;
    int tests_failed = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_expected = new("item_collected_expected", this);
        item_collected_actual   = new("item_collected_actual", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        alu_item expected, actual;
        
        forever begin
            item_collected_expected.get(expected);
            item_collected_actual.get(actual);
            
            if (expected.expected_result === actual.result) begin
                `uvm_info("SCOREBOARD", $sformatf("PASS: A=%0d, B=%0d, op=%0b -> result=%0d (expected=%0d)", 
                          expected.A, expected.B, expected.opcode, actual.result, expected.expected_result), UVM_MEDIUM)
                tests_passed++;
            end else begin
                `uvm_error("SCOREBOARD", $sformatf("FAIL: A=%0d, B=%0d, op=%0b -> result=%0d (expected=%0d)", 
                          expected.A, expected.B, expected.opcode, actual.result, expected.expected_result))
                tests_failed++;
            end
            
            if (expected.expected_carry !== actual.carry_out) begin
                `uvm_warning("SCOREBOARD", $sformatf("Carry flag mismatch: expected=%0b, actual=%0b", 
                            expected.expected_carry, actual.carry_out))
            end
            if (expected.expected_zero !== actual.zero_flag) begin
                `uvm_warning("SCOREBOARD", $sformatf("Zero flag mismatch: expected=%0b, actual=%0b", 
                            expected.expected_zero, actual.zero_flag))
            end
        end
    endtask : run_phase

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf("Test Summary: PASSED=%0d, FAILED=%0d", 
                  tests_passed, tests_failed), UVM_NONE)
    endfunction : report_phase

endclass : alu_scoreboard
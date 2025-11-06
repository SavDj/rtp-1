class alu_coverage extends uvm_subscriber #(alu_item);
    covergroup cg_alu @(posedge vif.MONITOR.clk);
        option.per_instance = 1;
        
        cp_opcode: coverpoint item.opcode {
            bins add      = {3'b000};
            bins sub      = {3'b001};
            bins and_op   = {3'b010};
            bins or_op    = {3'b011};
            bins xor_op   = {3'b100};
            bins shl      = {3'b101};
            bins ashr     = {3'b110};
            bins not_op   = {3'b111};
        }
        
        cp_mode: coverpoint item.single_cycle_mode {
            bins single_cycle = {1'b1};
            bins pipeline     = {1'b0};
        }
        
        cp_a: coverpoint item.A {
            bins zero     = {8'h00};
            bins small    = {[8'h01:8'h3F]};
            bins medium   = {[8'h40:8'h7F]};
            bins large    = {[8'h80:8'hBF]};
            bins max      = {[8'hC0:8'hFF]};
        }
        
        cp_b: coverpoint item.B {
            bins zero     = {8'h00};
            bins small    = {[8'h01:8'h3F]};
            bins medium   = {[8'h40:8'h7F]};
            bins large    = {[8'h80:8'hBF]};
            bins max      = {[8'hC0:8'hFF]};
        }
        
        cp_zero: coverpoint item.expected_zero {
            bins zero_result = {1};
            bins nonzero     = {0};
        }
        
        cp_carry: coverpoint item.expected_carry {
            bins carry_set = {1};
            bins no_carry  = {0};
        }
        
        cross_opcode_mode: cross cp_opcode, cp_mode;
        cross_data:        cross cp_a, cp_b, cp_opcode;
        cross_flags:       cross cp_opcode, cp_zero, cp_carry;
        
    endgroup
    
    virtual alu_if vif;
    
    alu_item item;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item = new();
    endfunction
    
    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Coverage virtual interface not set")
        cg_alu = new();
    endfunction
    
    virtual function void write(alu_item t);
        item = t;
        cg_alu.sample();
    endfunction
    
    function real get_coverage();
        return cg_alu.get_inst_coverage();
    endfunction

endclass
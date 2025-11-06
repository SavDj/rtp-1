class alu_sequence extends uvm_sequence #(alu_item);
  `uvm_object_utils(alu_sequence)

  function new(string name = "alu_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("SEQ", "Testing ADD (000)", UVM_MEDIUM)
    test_opcode(3'b000, 5, 1);
    
    `uvm_info("SEQ", "Testing SUB (001)", UVM_MEDIUM)
    test_opcode(3'b001, 5, 1);
    
    `uvm_info("SEQ", "Testing AND (010)", UVM_MEDIUM)
    test_opcode(3'b010, 3, 1);
    
    `uvm_info("SEQ", "Testing OR (011)", UVM_MEDIUM)
    test_opcode(3'b011, 3, 1);
    
    `uvm_info("SEQ", "Testing XOR (100)", UVM_MEDIUM)
    test_opcode(3'b100, 3, 1);
    
    `uvm_info("SEQ", "Testing SHL (101)", UVM_MEDIUM)
    test_opcode(3'b101, 3, 1);
    
    `uvm_info("SEQ", "Testing ASHR (110)", UVM_MEDIUM)
    test_opcode(3'b110, 3, 1);
    
    `uvm_info("SEQ", "Testing NOT (111)", UVM_MEDIUM)
    test_opcode(3'b111, 3, 1);
    
    `uvm_info("SEQ", "Testing pipeline mode (ADD/SUB)", UVM_MEDIUM)
    for (int i = 0; i < 3; i++) begin
        req = alu_item::type_id::create("req");
        wait_for_grant();
        assert(req.randomize() with {
            opcode inside {3'b000, 3'b001};
            single_cycle_mode == 0;
            A inside {[10:30]};
            B inside {[1:15]};
        });
        req.compute_expected();
        send_request(req);
        wait_for_item_done();
    end
    
    `uvm_info("SEQ", "Testing corner cases", UVM_MEDIUM)
    test_corner_cases();
  endtask

  virtual task test_opcode(bit [2:0] op, int count, bit mode);
    for (int i = 0; i < count; i++) begin
        req = alu_item::type_id::create("req");
        wait_for_grant();
        assert(req.randomize() with {
            opcode == op;
            single_cycle_mode == mode;
            A inside {[0:255]};
            B inside {[0:255]};
        });
        req.compute_expected();
        send_request(req);
        wait_for_item_done();
        #10;
    end
  endtask

  virtual task test_corner_cases();
    send_corner_transaction(8'hFF, 8'hFF, 3'b000, 1);
    send_corner_transaction(8'h00, 8'h00, 3'b010, 1);
    send_corner_transaction(8'hFF, 8'hFF, 3'b011, 1);
    send_corner_transaction(8'hFF, 8'h00, 3'b100, 1);
    
    send_corner_transaction(8'h80, 8'h00, 3'b101, 1);
    send_corner_transaction(8'hFF, 8'h00, 3'b110, 1);
    
    send_corner_transaction(8'h00, 8'h00, 3'b111, 1);
    send_corner_transaction(8'hFF, 8'h00, 3'b111, 1);
  endtask

  virtual task send_corner_transaction(bit [7:0] a_val, bit [7:0] b_val, bit [2:0] op, bit mode);
    req = alu_item::type_id::create("req");
    wait_for_grant();
    req.A = a_val;
    req.B = b_val;
    req.opcode = op;
    req.single_cycle_mode = mode;
    req.compute_expected();
    send_request(req);
    wait_for_item_done();
    #10;
  endtask

endclass
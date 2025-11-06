class alu_item extends uvm_sequence_item;
    rand logic [7:0]  A;
    rand logic [7:0]  B;
    rand logic [2:0]  opcode;
    rand logic        single_cycle_mode;
    
    logic [7:0]  result;
    logic        carry_out;
    logic        zero_flag;
    logic        overflow_flag;
    logic        o_error;

    logic [7:0]  expected_result;
    logic        expected_carry;
    logic        expected_zero;
    logic        expected_overflow;

    constraint valid_opcode_c {
        opcode inside {[0:7]};
    }

    constraint data_range_c {
        A inside {[0:255]};
        B inside {[0:255]};
    }

    `uvm_object_utils_begin(alu_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_int(opcode, UVM_ALL_ON)
        `uvm_field_int(single_cycle_mode, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
        `uvm_field_int(carry_out, UVM_ALL_ON)
        `uvm_field_int(zero_flag, UVM_ALL_ON)
        `uvm_field_int(overflow_flag, UVM_ALL_ON)
        `uvm_field_int(o_error, UVM_ALL_ON)
        `uvm_field_int(expected_result, UVM_ALL_ON)
        `uvm_field_int(expected_carry, UVM_ALL_ON)
        `uvm_field_int(expected_zero, UVM_ALL_ON)
        `uvm_field_int(expected_overflow, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_item");
        super.new(name);
    endfunction

    function void compute_expected();
        case (opcode)
            3'b000: begin
                expected_result = A + B;
                expected_carry = (A + B) > 255;
                expected_overflow = ((!A[7] && !B[7] && expected_result[7]) || 
                                    (A[7] && B[7] && !expected_result[7]));
            end
            3'b001: begin
                expected_result = A - B;
                expected_carry = A < B;
                expected_overflow = ((!A[7] && B[7] && expected_result[7]) || 
                                    (A[7] && !B[7] && !expected_result[7]));
            end
            3'b010: begin
                expected_result = A & B;
                expected_carry = 0;
                expected_overflow = 0;
            end
            3'b011: begin
                expected_result = A | B;
                expected_carry = 0;
                expected_overflow = 0;
            end
            3'b100: begin
                expected_result = A ^ B;
                expected_carry = 0;
                expected_overflow = 0;
            end
            3'b101: begin
                expected_result = A << 1;
                expected_carry = A[7];
                expected_overflow = 0;
            end
            3'b110: begin
                expected_result = {A[7], A[7:1]};
                expected_carry = A[0];
                expected_overflow = 0;
            end
            3'b111: begin
                expected_result = ~A;
                expected_carry = 0;
                expected_overflow = 0;
            end
            default: begin
                expected_result = 8'h00;
                expected_carry = 0;
                expected_overflow = 0;
            end
        endcase
        expected_zero = (expected_result == 8'h00);
    endfunction

endclass
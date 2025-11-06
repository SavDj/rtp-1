module alu (
    input         clk,
    input         rst_n,
    input         i_valid,
    output reg    o_ready,
    input  [7:0]  A,
    input  [7:0]  B,
    input  [2:0]  opcode,
    input         single_cycle_mode,
    output reg    o_valid,
    output reg    o_busy,
    output reg    o_error,
    output reg [7:0] result,
    output reg    carry_out,
    output reg    zero_flag,
    output reg    overflow_flag
);

    reg [7:0]  result_comb;
    reg        carry_out_comb;
    reg        zero_flag_comb;
    reg        overflow_flag_comb;
    
    reg [8:0]  add_result;
    reg        pipeline_full;
    reg        computing;
    
    reg        valid_pipeline;
    reg [2:0]  opcode_pipeline;
    reg [7:0]  A_pipeline, B_pipeline;

    typedef enum {IDLE, BUSY} fsm_state_t;
    fsm_state_t single_cycle_state;

    reg [8:0]  add_result_sc;
    reg [7:0]  result_sc;
    reg        carry_out_sc;
    reg        zero_flag_sc;
    reg        overflow_flag_sc;

    always @* begin
        result_comb = 8'h00;
        carry_out_comb = 1'b0;
        overflow_flag_comb = 1'b0;
        add_result = 9'b0;

        case (opcode_pipeline)
            3'b000: begin
                add_result = A_pipeline + B_pipeline;
                result_comb = add_result[7:0];
                carry_out_comb = add_result[8];
                overflow_flag_comb = ((!A_pipeline[7] && !B_pipeline[7] && result_comb[7]) || 
                                     (A_pipeline[7] && B_pipeline[7] && !result_comb[7]));
            end
            
            3'b001: begin
                result_comb = A_pipeline - B_pipeline;
                carry_out_comb = (A_pipeline < B_pipeline);
                overflow_flag_comb = ((!A_pipeline[7] && B_pipeline[7] && result_comb[7]) || 
                                     (A_pipeline[7] && !B_pipeline[7] && !result_comb[7]));
            end
            
            3'b010: result_comb = A_pipeline & B_pipeline;
            3'b011: result_comb = A_pipeline | B_pipeline;
            3'b100: result_comb = A_pipeline ^ B_pipeline;
            
            3'b101: begin
                result_comb = A_pipeline << 1;
                carry_out_comb = A_pipeline[7];
            end
            
            3'b110: begin
                result_comb = {A_pipeline[7], A_pipeline[7:1]};
                carry_out_comb = A_pipeline[0];
            end
            
            3'b111: result_comb = ~A_pipeline;
            
            default: begin
                result_comb = 8'h00;
            end
        endcase

        zero_flag_comb = (result_comb == 8'h00);
    end

    always @* begin
        result_sc = 8'h00;
        carry_out_sc = 1'b0;
        overflow_flag_sc = 1'b0;
        add_result_sc = 9'b0;

        case (opcode)
            3'b000: begin
                add_result_sc = A + B;
                result_sc = add_result_sc[7:0];
                carry_out_sc = add_result_sc[8];
                overflow_flag_sc = ((!A[7] && !B[7] && result_sc[7]) || 
                                   (A[7] && B[7] && !result_sc[7]));
            end
            
            3'b001: begin
                result_sc = A - B;
                carry_out_sc = (A < B);
                overflow_flag_sc = ((!A[7] && B[7] && result_sc[7]) || 
                                   (A[7] && !B[7] && !result_sc[7]));
            end
            
            3'b010: result_sc = A & B;
            3'b011: result_sc = A | B;
            3'b100: result_sc = A ^ B;
            
            3'b101: begin
                result_sc = A << 1;
                carry_out_sc = A[7];
            end
            
            3'b110: begin
                result_sc = {A[7], A[7:1]};
                carry_out_sc = A[0];
            end
            
            3'b111: result_sc = ~A;
            
            default: begin
                result_sc = 8'h00;
            end
        endcase

        zero_flag_sc = (result_sc == 8'h00);
    end

    always @* begin
        o_ready = (!valid_pipeline && !single_cycle_mode) || 
                  (single_cycle_mode && (single_cycle_state == IDLE));
        
        pipeline_full = valid_pipeline && !single_cycle_mode;
        
        computing = valid_pipeline || (single_cycle_mode && (single_cycle_state != IDLE));
        o_busy = computing;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_pipeline <= 1'b0;
            opcode_pipeline <= 3'b0;
            A_pipeline <= 8'b0;
            B_pipeline <= 8'b0;
            single_cycle_state <= IDLE;
        end else begin
            if (single_cycle_mode) begin
                case (single_cycle_state)
                    IDLE: begin
                        if (i_valid && o_ready) begin
                            single_cycle_state <= BUSY;
                        end
                    end
                    BUSY: begin
                        single_cycle_state <= IDLE;
                    end
                endcase
            end 
            else begin
                if (o_ready && i_valid) begin
                    valid_pipeline <= 1'b1;
                    opcode_pipeline <= opcode;
                    A_pipeline <= A;
                    B_pipeline <= B;
                end 
                else if (valid_pipeline) begin
                    valid_pipeline <= 1'b0;
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_valid <= 1'b0;
            result <= 8'h00;
            carry_out <= 1'b0;
            zero_flag <= 1'b0;
            overflow_flag <= 1'b0;
            o_error <= 1'b0;
        end else begin
            o_error <= 1'b0;
            
            if (single_cycle_mode) begin
                if (single_cycle_state == BUSY) begin
                    o_valid <= 1'b1;
                    result <= result_sc;
                    carry_out <= carry_out_sc;
                    zero_flag <= zero_flag_sc;
                    overflow_flag <= overflow_flag_sc;
                end else begin
                    o_valid <= 1'b0;
                end
            end else begin
                o_valid <= valid_pipeline;
                if (valid_pipeline) begin
                    result <= result_comb;
                    carry_out <= carry_out_comb;
                    zero_flag <= zero_flag_comb;
                    overflow_flag <= overflow_flag_comb;
                end
            end
        end
    end

endmodule
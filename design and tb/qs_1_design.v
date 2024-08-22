module ALSU #(
parameter input_priority = "A" ,
parameter FULL_ADDER = "ON" 
)
(
input clk , rst ,
input [2:0] A , B ,opcode , 
input cin , serial_in , red_op_A , red_op_B , bypass_A , bypass_B , direction ,

output reg [5:0] out ,
output reg [15:0] leds
);

reg [2:0] A_reg , B_reg ,opcode_reg ;
reg cin_reg , serial_in_reg , red_op_A_reg , red_op_B_reg ,
    bypass_A_reg , bypass_B_reg , direction_reg ;

reg invalid ;     

always @(posedge clk or posedge rst) begin
    if(rst) begin 
        A_reg         <= 0 ;
        B_reg         <= 0 ;
        opcode_reg    <= 0 ;
        cin_reg       <= 0 ;
        serial_in_reg <= 0 ;
        red_op_A_reg  <= 0 ;
        red_op_B_reg  <= 0 ;
        bypass_A_reg  <= 0 ;
        bypass_B_reg  <= 0 ;
        direction_reg <= 0 ;  
    end
    else begin
        A_reg         <= A        ;
        B_reg         <= B        ;
        opcode_reg    <= opcode   ;
        cin_reg       <= cin      ;
        serial_in_reg <= serial_in;
        red_op_A_reg  <= red_op_A ;
        red_op_B_reg  <= red_op_B ;
        bypass_A_reg  <= bypass_A ;
        bypass_B_reg  <= bypass_B ;
        direction_reg <= direction; 
    end 

end

always@(posedge clk or posedge rst ) begin 
    if(rst) begin
        out <= 0 ; 
        invalid <= 0 ; 
    end
    else begin 
        if(bypass_A_reg) begin 
            out <= A_reg ; 
            invalid <= 0 ; 
        end
        else if (bypass_B_reg) begin 
            out <= B_reg ; 
            invalid <= 0 ; 
        end 
        else if (bypass_A_reg && bypass_B_reg) begin 
            case(input_priority) 
                "A" : out <= A_reg ; 
                "B" : out <= B_reg ; 
            endcase 
            invalid <= 0 ; 
        end 
        else begin                   // start of code  
            case(opcode_reg) 
                3'b000 : begin 
                        invalid <= 0 ; 
                        if(red_op_A_reg) 
                            out <= &A_reg ; 
                        else if (red_op_B_reg)
                            out <= &B_reg ; 
                        else if (red_op_A_reg && red_op_B_reg) begin 
                            case(input_priority) 
                            "A" : out <= &A_reg ; 
                            "B" : out <= &B_reg ; 
                            endcase 
                            end
                        else 
                            out <= A_reg & B_reg ;     
                end 
                3'b001 : begin 
                        invalid <= 0 ; 
                        if(red_op_A_reg) 
                            out <= ^A_reg ; 
                        else if (red_op_B_reg)
                            out <= ^B_reg ; 
                        else if (red_op_A_reg && red_op_B_reg) begin 
                            case(input_priority) 
                            "A" : out <= ^A_reg ; 
                            "B" : out <= ^B_reg ; 
                            endcase 
                            end
                        else 
                            out <= A_reg ^ B_reg ;     
                end 
                3'b010 : begin 
                        if (red_op_A_reg || red_op_B_reg ) begin 
                            out <= 0; 
                            invalid <= 1 ; 
                        end 
                        else begin 
                            case(FULL_ADDER) 
                                "ON" : out <= A_reg + B_reg + cin_reg ; 
                                "OFF": out <= A_reg + B_reg ; 
                            endcase
                        end
                end 
                3'b011 : begin 
                        if (red_op_A_reg || red_op_B_reg ) begin 
                            out <= 0; 
                            invalid <= 1 ; 
                        end 
                        else 
                            out <= A_reg * B_reg ; 
                end 
                3'b100 : begin
                        if (red_op_A_reg || red_op_B_reg ) begin 
                            out <= 0; 
                            invalid <= 1 ; 
                        end 
                        else    begin 
                            if (direction_reg) 
                                out <= {out[4:0] , serial_in_reg}  ; 
                            else 
                                out <= {serial_in_reg,out[5:1]} ;     
                        end
                end
                3'b101 : begin 
                        if (red_op_A_reg || red_op_B_reg ) begin 
                            out <= 0; 
                            invalid <= 1 ; 
                        end 
                        else    begin 
                            if (direction_reg) 
                                out <= {out[4:0] , out[5]}; 
                            else 
                                out <= {out[0] , out[5:1]};     
                        end
                end
                3'b110 : begin
                    invalid <= 1 ; 
                end
                3'b111 : begin 
                    invalid <= 1 ; 
                end 
            endcase
        end
    end
end 

always@(posedge clk ) begin 
    if (invalid)
        leds = 16'b1111_1111_1111_1111 ;
    else if (~invalid) 
        leds = 16'b0 ;
end


endmodule 

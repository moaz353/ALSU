module ALSU_tb ;

reg clk , rst ;
reg [2:0] A_tb , B_tb ,opcode_tb ;
reg cin_tb , serial_in_tb , red_op_A_tb , red_op_B_tb , bypass_A_tb , bypass_B_tb , direction_tb ;

wire [5:0] out ;
wire [15:0] leds ; 

ALSU DUT (.clk(clk),.rst(rst),.A(A_tb),.B(B_tb),.opcode(opcode_tb),
            .cin(cin_tb),.serial_in(serial_in_tb),.red_op_A(red_op_A_tb),.red_op_B(red_op_B_tb),
            .bypass_A(bypass_A_tb),.bypass_B(bypass_B_tb) , .direction(direction_tb) , 
            .out(out) , .leds(leds) ) ; 

initial begin
    clk=0 ; 
    forever #1 clk =~clk ; 
end

integer i ;
initial begin 
    rst = 1 ; 
    @(negedge clk) ; 
    rst = 0 ; 
    bypass_A_tb=0 ; 
    bypass_B_tb = 0 ; 
  
for (i=0 ; i < 30000 ; i =i+1 ) begin  
    A_tb=$urandom_range(5,15) ; 
    B_tb=$urandom_range(5,15) ; 
    direction_tb=$random ;    
    serial_in_tb=$random ;
    cin_tb=$random ; 
    opcode_tb=$urandom_range ( 0,7 ) ;
    if(i<5000) begin 
        red_op_A_tb=$random; 
        red_op_B_tb=$random; 
        @(negedge clk) ;
    end 
    else if (i>5000 & i<15000)begin 
        red_op_A_tb=1; 
        red_op_B_tb=$random;  
        @(negedge clk) ;

    end   
    else if (i>15000 & i<20000) begin 
        red_op_A_tb=$random; 
        red_op_B_tb=$random;
        bypass_A_tb= 1 ;
        bypass_B_tb= 0 ;  
        @(negedge clk) ;

    end
    else if (i>20000 & i<25000) begin 
        red_op_A_tb=$random; 
        red_op_B_tb=$random;
        bypass_A_tb= 1 ;
        bypass_B_tb= $random ;  
        @(negedge clk) ;

    end 
    else begin 
        red_op_A_tb=1 ; 
        red_op_B_tb=1 ;
        bypass_A_tb=0 ;
        bypass_B_tb=0 ; 
        @(negedge clk) ;

    end 
end
$stop ;
end 
endmodule



module Timer_8254(D,A,WR,RD,CS,CLK,OUT,GATE);
  
	inout [7:0] D;
	input [1:0] A;
	input WR,RD,CS;
	input [2:0] CLK,GATE;
	output [2:0] OUT;
	
	wire [7:0] data_bus;
	wire [7:0] counter_out [2:0];
	reg [7:0] control_word;
	
	assign data_bus = (WR==0 & RD==1 & CS==0)? D :
	                  (WR==1 & RD==0 & A==2'b00 & CS==0)? counter_out[0] :
	                  (WR==1 & RD==0 & A==2'b01 & CS==0)? counter_out[1] :
	                  (WR==1 & RD==0 & A==2'b10 & CS==0)? counter_out[2] : data_bus;
	assign D = (WR==1 & RD==0 & CS==0)? data_bus : D;
	
	always @(posedge CLK[0])
	 if(A==2'b11 & WR==0 & CS==0)
	   control_word <= data_bus;
	 else
	   control_word <= control_word;
	
	Counter counter0(control_word,{data_bus,data_bus},counter_out[0],CLK[0],GATE[0],OUT[0],A,WR,RD,CS,2'b00,CLK[0]);
	Counter counter1(control_word,{data_bus,data_bus},counter_out[1],CLK[1],GATE[1],OUT[1],A,WR,RD,CS,2'b01,CLK[0]);
	Counter counter2(control_word,{data_bus,data_bus},counter_out[2],CLK[2],GATE[2],OUT[2],A,WR,RD,CS,2'b10,CLK[0]);
	
endmodule

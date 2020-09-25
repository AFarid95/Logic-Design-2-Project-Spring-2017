module Counter(control_word,in_count,output_to_data_bus,CLK,GATE,OUT,A,WR,RD,CS,address,global_CLK);
  
  input [7:0] control_word;
  output [7:0] output_to_data_bus;
  input [15:0] in_count;
  input CLK,GATE,global_CLK;
  output OUT;
  input WR,RD,CS;
  input [1:0] A,address;
  
  reg [15:0] CR;
  wire [15:0] current_count;
  wire [15:0] latched_count;
  reg [7:0] status_register;
  wire [7:0] latched_status;
  wire [1:0] CR_enable,OL_enable;
  wire status_register_enable,status_latch_enable,count_enable;
  wire [1:0] out_count_enable;
  wire out_status_enable;
  wire load_new_count;
  wire count_loaded,counter_programmed;
  wire null_count;
  wire CR_reset;
    
  assign output_to_data_bus = (out_status_enable==1)? latched_status:
                              (out_count_enable==2'b01)? latched_count[7:0]:
                              (out_count_enable==2'b10)? latched_count[15:8]: output_to_data_bus;
  
  assign latched_count[15:8] = (OL_enable[1]==1)? current_count[15:8] : latched_count[15:8];
  assign latched_count[7:0] = (OL_enable[0]==1)? current_count[7:0] : latched_count[7:0];
  assign latched_status = (status_latch_enable==1)? status_register : latched_status;
  
  assign count_enable = 1; //le7ad ma megz w khamis wel ghaly ye5alaso el modes
  //mohem fash5: zabat el load_new_count
  
  always @(posedge CR_reset)
    CR <= 16'h0000;
  
  always @(posedge global_CLK)
  begin
    
    if(CR_enable[1])
      CR[15:8] <= in_count[15:8];
    else
      CR[15:8] <= CR[15:8];
    
    if(CR_enable[0])
      CR[7:0] <= in_count[7:0];
    else
      CR[7:0] <= CR[7:0];
    
    status_register[7:6] <= {OUT,null_count};
    if(status_register_enable)
      status_register[5:0] <= control_word[5:0];
    
  end
  
  always @(OL_enable)
  begin
    
  end
  
  CountingElement CE(CR,current_count,CLK,count_enable,load_new_count,count_loaded,counter_programmed,status_register[0],status_register[5:4]);
  ControlLogic control_logic(control_word,status_register,CLK,GATE,OUT,null_count,load_new_count,count_loaded,counter_programmed,
  CR_enable,OL_enable,status_register_enable,status_latch_enable,count_enable,CR_reset,
  A,WR,RD,CS,address,out_count_enable,out_status_enable);
  
endmodule

 module CountingElement(initial_count,current_count,CLK,count_enable,load_new_count,count_loaded,counter_programmed,BCD,RW);
  
  input [15:0] initial_count;
  output [15:0] current_count;
  input CLK,count_enable,load_new_count,BCD;
  output count_loaded;
  input counter_programmed;
  input [1:0] RW;
  
  reg [15:0] current_count;
  reg count_loaded;
  
  always @(counter_programmed)
    if(counter_programmed)
      count_loaded <= 0;
  
  always @(posedge CLK)
  begin
    if(load_new_count)
    begin
      current_count <= initial_count;
      count_loaded <= 1;
    end
    else if(count_enable)
    begin
      if(RW==2'b01)
      begin
        if(BCD & current_count[7:0]==8'h00)
          current_count[7:0] <= 8'h99;
        else
          current_count[7:0] <= current_count[7:0] - 1;
      end
      else if(RW==2'b10)
      begin
        if(BCD & current_count[15:8]==8'h00)
          current_count[15:8] <= 8'h99;
        else
          current_count[15:8] <= current_count[15:8] - 1;
      end
      else
      begin
        if(BCD & current_count==16'h0000)
          current_count <= 16'h9999;
        else
          current_count <= current_count - 1;
      end
    end
  end
endmodule

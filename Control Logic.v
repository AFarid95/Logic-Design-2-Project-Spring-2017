module ControlLogic(control_word,status_byte,CLK,GATE,OUT,null_count,load_new_count,count_loaded,counter_programmed,
  CR_enable,OL_enable,status_register_enable,status_latch_enable,count_enable,CR_reset,
  A,WR,RD,CS,my_address,read_count_enable,read_status_enable);
  
  input [7:0] control_word,status_byte;
  input CLK,GATE;
  output OUT,null_count,load_new_count,counter_programmed;
  input count_loaded;
  output [1:0] CR_enable,OL_enable;
  output status_register_enable,status_latch_enable,count_enable,CR_reset;
  input [1:0] A,my_address;
  input WR,RD,CS;
  output [1:0] read_count_enable;
  output read_status_enable;
  
  reg [1:0] CR_enable,OL_enable;
  reg MSB_write,MSB_read;
  reg counter_latched,status_latched;
  reg [1:0] read_count_enable;
  reg read_status_enable;
  reg CR_reset,status_latch_enable;
  reg counter_programmed;
  
  assign status_register_enable = (control_word[7:6]==my_address & ~(control_word[5:4]==2'b00))? 1 : 0;
  assign null_count = (count_loaded==0)? 1 : 0;
  
  always @(count_loaded)
  if(count_loaded==0)
    counter_programmed <= 0;
  
  always @(control_word)
  begin
    if(control_word[7:6]==my_address & ~(control_word[5:4]==2'b00)) //counter programmed
    begin
      CR_reset <= 1;
      MSB_write <= 0;
      OL_enable <= 2'b11;
      status_latch_enable <= 1;
      counter_latched <= 0;
      status_latched <= 0;
      read_count_enable <= 2'b00;
      read_status_enable <= 0;
      counter_programmed <= 1;
    end
    else if(control_word[7:6]==my_address & control_word[5:4]==2'b00) //counter latch command
    begin
      OL_enable <= 2'b00;
      counter_latched <= 1;
      MSB_read <= 0;
    end
    else if(control_word[7:6]==2'b11 & control_word[my_address+1]==1) //read-back command
    begin
      if(control_word[5]==0)  //latch count
      begin
        OL_enable <= 2'b00;
        counter_latched <= 1;
        MSB_read <= 0;
      end
      if(control_word[4]==0)  //latch status
      begin
        status_latch_enable <= 0;
        status_latched <= 1;
      end
    end
  end
  
  always @(A,WR,RD,CS)
  begin
    if(A==my_address & RD==0 & WR==1 & CS==0) //read operation
    begin
      if(status_latched)  //read latched status
      begin
        read_count_enable <= 2'b00;
        read_status_enable <= 1;
        status_latch_enable <= 1;
        status_latched <= 0;
      end
      else if(counter_latched)  //read latched counter
      begin
        if(status_byte[5:4]==2'b01)
        begin
          read_count_enable <= 2'b01;
          read_status_enable <= 0;
          OL_enable <= 2'b11;
          counter_latched <= 0;
        end
        else if(status_byte[5:4]==2'b10)
        begin
          read_count_enable <= 2'b10;
          read_status_enable <= 0;
          OL_enable <= 2'b11;
          counter_latched <= 0;
        end
        else if(status_byte[5:4]==2'b11)
        begin
          if(MSB_read)
          begin
            read_count_enable <= 2'b10;
            read_status_enable <= 0;
            OL_enable[1] <= 1;
            counter_latched <= 0;
          end
          else
          begin
            read_count_enable <= 2'b01;
            read_status_enable <= 0;
            OL_enable[0] <= 1;
          end
          MSB_read <= ~MSB_read;
        end
      end
      else  //simple read
      begin
        if(status_byte[5:4]==2'b01)
        begin
          read_count_enable <= 2'b01;
          read_status_enable <= 0;
        end
        else if(status_byte[5:4]==2'b10)
        begin
          read_count_enable <= 2'b10;
          read_status_enable <= 0;
        end
        else if(status_byte[5:4]==2'b11)
        begin
          if(MSB_read)
          begin
            read_count_enable <= 2'b10;
            read_status_enable <= 0;
          end
          else
          begin
            read_count_enable <= 2'b01;
            read_status_enable <= 0;
          end
          MSB_read <= ~MSB_read;
        end
      end
    end
    else if(A==my_address & RD==1 & WR==0 & CS==0) //write operation
    begin
      CR_reset <= 0;
      if(status_byte[5:4]==2'b01)
        CR_enable <= 2'b01;
      else if(status_byte[5:4]==2'b10)
        CR_enable <= 2'b10;
      else if(status_byte[5:4]==2'b11)
      begin
        if(MSB_write)
          CR_enable <= 2'b10;
        else
          CR_enable <= 2'b01;
        MSB_write <= ~MSB_write;
      end
    end
  end
  
endmodule

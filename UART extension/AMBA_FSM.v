module AMBA_FSM
(input clock, resetn, pkt_valid, 
 input [1:0]data_in,
 input ram_full, ram_empty_0, ram_empty_1, ram_empty_2, soft_reset_0, soft_reset_1, soft_reset_2, parity_done, low_packet_valid, 
 output write_enb_cam, detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_cam, busy);

parameter  
  DECODE_ADDRESS= 3'b000,
  LOAD_FIRST_DATA=3'b001,
  LOAD_DATA=3'b010,
  LOAD_PARITY=3'b011,
  ram_FULL_STATE=3'b100,
  LOAD_AFTER_FULL=3'b101,
  WAIT_TILL_EMPTY=3'b110,
  CHECK_PARITY_ERROR=3'b111;

reg [2:0]state, next_state;

    always@(posedge clock)
    begin
     if(~resetn)
     state<= DECODE_ADDRESS;
     
/* else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
 next_state= DECODE_ADDRESS;*/
     
     else
     state<= next_state;
    end

 always@*
 begin
  next_state= DECODE_ADDRESS;
  case(state)
 
DECODE_ADDRESS : if((pkt_valid && (data_in[1:0]==2'b00)) && ram_empty_0 || (pkt_valid && (data_in[1:0]==2'b01) && ram_empty_1)||(pkt_valid && (data_in[1:0]==2'b10) && ram_empty_2))
          
  next_state= LOAD_FIRST_DATA;
  else if((pkt_valid &&(data_in[1:0]==2'b00)) && ~ram_empty_0 ||
  (pkt_valid &&(data_in[1:0]==2'b01)&& ~ram_empty_1) ||
  (pkt_valid&&(data_in[1:0]==2'b10)&& ~ram_empty_2))
  
  next_state= WAIT_TILL_EMPTY;
   else 
  next_state=DECODE_ADDRESS;

  LOAD_FIRST_DATA: next_state= LOAD_DATA;

  LOAD_DATA: if(ram_full==1)
      next_state=ram_FULL_STATE;
      else if(ram_full==0 && pkt_valid==0)
      next_state=LOAD_PARITY;
      else
      next_state= LOAD_DATA;
    
  LOAD_PARITY: next_state= CHECK_PARITY_ERROR;

  ram_FULL_STATE: if(ram_full==0) 
      next_state= LOAD_AFTER_FULL;
      else
      next_state=ram_FULL_STATE;

  LOAD_AFTER_FULL :if(parity_done==0 && low_packet_valid==0)
      next_state= LOAD_DATA;

      else if(parity_done==0 && low_packet_valid==1)
      next_state= LOAD_PARITY;
      else if(parity_done==1)
      next_state= DECODE_ADDRESS;
    
  WAIT_TILL_EMPTY :

/* if(~ram_empty_0 || ~ram_empty_1 || ~ram_empty_2)
 next_state=WAIT_TILL_EMPTY;
 else
 next_state= LOAD_FIRST_DATA;*/

     begin
     next_state = DECODE_ADDRESS;

     case(data_in)
     2'b00 :begin
       if(soft_reset_0)
        next_state = DECODE_ADDRESS;
       else if(~ram_empty_0)
        next_state = WAIT_TILL_EMPTY;
       else if(ram_empty_0)
        next_state = LOAD_FIRST_DATA;
      end
     2'b01 :begin
       if(soft_reset_1)
        next_state = DECODE_ADDRESS;
       else if(~ram_empty_1)
        next_state = WAIT_TILL_EMPTY;
       else if(ram_empty_1)
        next_state = LOAD_FIRST_DATA;
      end
     2'b10 :begin
       if(soft_reset_2)
        next_state = DECODE_ADDRESS;
       else if(~ram_empty_2)
        next_state = WAIT_TILL_EMPTY;
       else if(ram_empty_2)
        next_state = LOAD_FIRST_DATA;
      end
     endcase
     end 
 

  CHECK_PARITY_ERROR:if (ram_full)
      next_state= ram_FULL_STATE;
      else
      next_state=DECODE_ADDRESS;

     endcase
     end
    
assign detect_add =(state==DECODE_ADDRESS)?1:0;
assign rst_int_cam=(state==CHECK_PARITY_ERROR)?1:0;
assign lfd_state=(state==LOAD_FIRST_DATA)?1:0;

assign busy=(state==LOAD_PARITY || state== LOAD_AFTER_FULL || state==CHECK_PARITY_ERROR || state==LOAD_FIRST_DATA || state==ram_FULL_STATE || state== WAIT_TILL_EMPTY)?1:0;

/*assign busy=(state==LOAD_DATA)?0:1;
assign write_enb_cam=(state==ram_FULL_STATE || state==WAIT_TILL_EMPTY)?0:1;*/

assign write_enb_cam=(state==LOAD_PARITY || state==LOAD_AFTER_FULL || state==LOAD_DATA)?1:0;
assign laf_state=(state==LOAD_AFTER_FULL)?1:0;
assign full_state=(state==ram_FULL_STATE)?1:0;
assign ld_state=(state==LOAD_DATA);
endmodule

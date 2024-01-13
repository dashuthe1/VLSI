module tb();
reg clock, resetn, read_enb_2, pkt_valid;

reg [7:0]data_in;
wire [7:0] data_out_2;
wire   vld_out_2, busy;
event simrdwr;
event check_vld_2;
parameter DELAY=10;
  
integer i;

top DUT(clock, resetn, pkt_valid,  read_enb_2, data_in,
                ,,vld_out_2, busy,  data_out_2);

always
begin
clock=0;
#(DELAY/2);
clock=1'b1;
#(DELAY/2);
end

task rst;
begin
resetn=0;
@(negedge clock);
resetn=1'b1;
end
endtask

task initialize;
begin
{read_enb_2, pkt_valid, data_in}=0;

end
endtask



task pkt_gen_14(input [13:0]payloadlen); // packet generation payload 14
   reg [7:0]header,payload_data,parity;
//   reg[13:0]payloadlen;
   reg[7:0]cparity;
   begin
   parity=0;
   wait(!busy)
   begin
   @(negedge clock);
//   payloadlen=14;
   pkt_valid=1'b1;
   header={payloadlen,2'b10};
   data_in=header;
   parity=parity^data_in;
   end
   @(negedge clock);
     
   for(i=0;i<payloadlen;i=i+1)
   begin
   wait(!busy)    
   @(negedge clock);
   payload_data={$random}%256;
   data_in=payload_data;
   parity=parity^data_in;    
   end     
    
   wait(!busy)    
   @(negedge clock);
   pkt_valid=0;    
   data_in=parity;
   repeat(10)
   @(negedge clock);
   read_enb_2=1'b1;
   -> check_vld_2;
   end
endtask




initial
begin
@(simrdwr);
wait(vld_out_2)
 begin
 read_enb_2 = 1'b1;
 end
end

initial   
begin    
@(check_vld_2);  
wait(~vld_out_2)
 read_enb_2=0;
end


initial
begin
initialize; 
rst;
pkt_gen_14(14);

#1000 $finish;
end
endmodule

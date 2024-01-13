

module top(input clock, resetn, pkt_valid, read_enb_2, 
input [7:0]data_in, output  vld_out_0,vld_out_1,vld_out_2, busy, 
output [7:0] data_out_2);

wire [2:0]w_enb;
wire [2:0]soft_reset;
wire [2:0]read_enb;
wire [2:0]empt;
wire [2:0]full;
wire lfd_state_w,vld_out_0,vld_out_1,read_enb_0,read_enb_1,err;
wire [7:0]data_out_temp[2:0];
wire [7:0]d_out;

wire [7:0]data_out_0,data_out_1;

genvar i;

generate 
for(i=0;i<3;i=i+1)

begin:ram
 UART f(.clock(clock), .resetn(resetn), .soft_reset(soft_reset[i]),
 .lfd_state(lfd_state_w), .write_enb(w_enb[i]), .data_in(d_out), .read_enb(read_enb[i]), 
 .full(full[i]), .empty(empt[i]), .data_out(data_out_temp[i]));
end
endgenerate


AMBA_bridge_control r1(.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .data_in(data_in), .dout(d_out), .ram_full(ram_full), .detect_add(detect_add), .ld_state(ld_state),  .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state_w), .rst_int_cam(rst_int_cam),  .err(err), .parity_done(parity_done), .low_packet_valid(low_packet_valid));

AMBA_FSM fs1(.clock(clock), .resetn(resetn), .pkt_valid(pkt_valid), .data_in(data_in[1:0]), .soft_reset_0(soft_reset[0]), .soft_reset_1(soft_reset[1]), .soft_reset_2(soft_reset[2]), .ram_full(ram_full), .ram_empty_0(empt[0]), .ram_empty_1(empt[1]), .ram_empty_2(empt[2]), .parity_done(parity_done), .low_packet_valid(low_packet_valid), .busy(busy), .rst_int_cam(rst_int_cam), .full_state(full_state), .lfd_state(lfd_state_w), .laf_state(laf_state), .ld_state(ld_state), .detect_add(detect_add), .write_enb_cam(write_enb_cam));

interfacing s1(.clock(clock), .resetn(resetn), .data_in(data_in[1:0]), .detect_add(detect_add), .full_0(full[0]), .full_1(full[1]), .full_2(full[2]), .read_enb_0(read_enb[0]), .read_enb_1(read_enb[1]), .read_enb_2(read_enb[2]), .write_enb_cam(write_enb_cam), .empty_0(empt[0]), .empty_1(empt[1]), .empty_2(empt[2]), .vld_out_0(vld_out_0), .vld_out_1(vld_out_1), .vld_out_2(vld_out_2), .soft_reset_0(soft_reset[0]), .soft_reset_1(soft_reset[1]), .soft_reset_2(soft_reset[2]), .write_enb(w_enb), .ram_full(ram_full));


assign read_enb[0]= read_enb_0;
assign read_enb[1]= read_enb_1;
assign read_enb[2]= read_enb_2;
assign  data_out_0=data_out_temp[0];
assign data_out_1=data_out_temp[1];
assign data_out_2=data_out_temp[2];
endmodule

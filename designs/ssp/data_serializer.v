// -----------------------------------------------------------------------------
// FILE NAME          : data_serializer.v
// AUTHOR             : Sharukh S. Shaikh
// AUTHOR'S EMAIL     : sharukhsshaikh@utexas.edu
// VERSION DATE       : 11/6/2016
// DESCRIPTION        : Parallel to serial data converter
// -----------------------------------------------------------------------------
// PARAM NAME RANGE   : DESCRIPTION : DEFAULT : UNITS
// -----------------------------------------------------------------------------


`define DATA_WIDTH 8

module data_serializer (i_PCLK, i_CLEAR_B, i_TXDATA, i_TX_VALID, o_REQ, o_SSPOE_B, o_SSPTXD, o_SSPCLKOUT, o_SSPFSSOUT);


//=============IO ports======================

input                     i_PCLK, i_CLEAR_B, i_TX_VALID;
input [`DATA_WIDTH-1 : 0] i_TXDATA;

output reg                o_REQ, o_SSPOE_B, o_SSPTXD, o_SSPCLKOUT, o_SSPFSSOUT;


//=============Internal Variables==============

parameter SIZE = 3, IDLE  = 3'b001, START_TX = 3'b010, TX_LOOP = 3'b011, TX_NEXT = 3'b100;

reg [SIZE-1:0]          state        ;// State of the FSM
reg [`DATA_WIDTH-1 : 0] r_TXDATA;
reg [3:0]               r_count;
wire                    w_SSPOE_B;

assign w_SSPOE_B = (r_count==4'b1000);


always @(negedge o_SSPCLKOUT )
begin
   if( !i_CLEAR_B )
       o_SSPOE_B <= 1'b1;
   else
       o_SSPOE_B <= w_SSPOE_B;
end

//=============clock by 2======================

always @(posedge i_PCLK )
begin
       o_SSPCLKOUT <= !o_SSPCLKOUT;
end

//==========Code startes Here==========================

always @ (posedge o_SSPCLKOUT)
begin : FSM

if (!i_CLEAR_B) 
begin
  state       <= IDLE;
  o_REQ       <= 1'b0;
  o_SSPTXD    <= 1'b0;
  o_SSPFSSOUT <= 1'b0;
  r_TXDATA    <= 0;
  r_count     <= 4'b1000;
end 

else
 case(state)
   IDLE : if (i_TX_VALID == 1'b1) begin
                state <= START_TX;
                r_TXDATA <= i_TXDATA;
                o_REQ <= 1'b1;
              end 
          else begin
                state <= IDLE;
                o_REQ <= 1'b0;
              end

   START_TX : begin
                o_SSPFSSOUT <= 1'b1;
                o_REQ <= 1'b0;
                state <= TX_LOOP;
                r_count <= 4'b0111;
              end

   TX_LOOP : begin
               if (r_count != 4'b0001) begin
                 o_SSPTXD <= r_TXDATA[r_count];
                 state <= TX_LOOP;
               end else begin
                 o_SSPTXD <= r_TXDATA[r_count];
                 state <= TX_NEXT;
               end
               o_SSPFSSOUT <= 1'b0;
               r_count <= r_count-1;
               o_REQ <= 1'b0;
             end

   TX_NEXT : begin
               if (i_TX_VALID == 1'b1) begin
                 o_SSPTXD <= r_TXDATA[r_count];
                 state <= TX_LOOP;
                 o_SSPFSSOUT <= 1'b1;
                 r_count <= 4'b0111;
                 r_TXDATA <= i_TXDATA;
                 o_REQ <= 1'b1;
               end else begin
                 o_SSPTXD <= r_TXDATA[r_count];
                 state <= IDLE;
                 r_count <= 4'b1000;
               end
             end   
   default : begin
             state <= IDLE;
             r_count <= 4'b1000;
             end
endcase
end

endmodule

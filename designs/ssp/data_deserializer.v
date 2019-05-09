// -----------------------------------------------------------------------------
// FILE NAME          : data_serializer.v
// AUTHOR             : Sharukh S. Shaikh
// AUTHOR'S EMAIL     : sharukhsshaikh@utexas.edu
// VERSION DATE       : 11/6/2016
// DESCRIPTION        : Serial to Parallel data converter
// -----------------------------------------------------------------------------
// PARAM NAME RANGE   : DESCRIPTION : DEFAULT : UNITS
// -----------------------------------------------------------------------------


`define DATA_WIDTH 8

module data_deserializer (i_SSPCLKIN, i_CLEAR_B, i_SSPFSSIN, i_SSPRXD, o_RXDATA, o_REQ );

//=============IO ports======================

input                      i_SSPCLKIN, i_CLEAR_B, i_SSPFSSIN, i_SSPRXD;

output [`DATA_WIDTH-1 : 0] o_RXDATA;
output                     o_REQ;

reg [`DATA_WIDTH-1 : 0]    o_RXDATA;
reg                        o_REQ;

//=============Internal Variables==============

parameter SIZE = 3, IDLE  = 3'b001, RX_LOOP = 3'b010, RX_NEXT = 3'b100;

reg [SIZE-1:0]          state; // State of the FSM
reg [`DATA_WIDTH-1 : 0] r_RXDATA;
reg [3:0]               r_count;

//==========FSM startes Here==========================

always @ (posedge i_SSPCLKIN)
begin : FSM

if (!i_CLEAR_B) 
begin
  state       <= IDLE;
  o_REQ       <= 1'b0;
  r_RXDATA    <= 0;
  r_count     <= 4'b1000;
  o_RXDATA    <= 0;
end 

else
 case(state)
   IDLE : if (i_SSPFSSIN == 1'b1) begin
                state <= RX_LOOP;
                r_count <= 4'b0111;
                o_REQ <= 1'b0;
              end 
          else begin
                state <= IDLE;
                o_REQ <= 1'b0;
              end

   RX_LOOP : begin
               if (r_count != 4'b0001) begin
                 r_RXDATA[r_count] <= i_SSPRXD;
                 state <= RX_LOOP;
               end else begin
                 r_RXDATA[r_count] <= i_SSPRXD;
                 state <= RX_NEXT;
               end
               r_count <= r_count-1;
               o_REQ <= 1'b0;
             end

   RX_NEXT : begin
               if (i_SSPFSSIN == 1'b1) begin
                 o_RXDATA <= {r_RXDATA[`DATA_WIDTH-1 : 1], i_SSPRXD};
                 state <= RX_LOOP;
                 r_count <= 4'b0111;
               end else begin
                 o_RXDATA <= {r_RXDATA[`DATA_WIDTH-1 : 1], i_SSPRXD};
                 state <= IDLE;
                 r_count <= 4'b1000;
               end
               o_REQ <= 1'b1;
               r_RXDATA <= 0;
             end   
   default : begin
             state <= IDLE;
             r_count <= 4'b1000;
             o_REQ <= 1'b0;
             end
endcase
end

endmodule

// -----------------------------------------------------------------------------
// FILE NAME          : TXFIFO.v
// AUTHOR             : Sharukh S. Shaikh
// AUTHOR'S EMAIL     : sharukhsshaikh@utexas.edu
// VERSION DATE       : 11/6/2016
// DESCRIPTION        : Transmission FIFO based on handshake signalling logic
// -----------------------------------------------------------------------------
// PARAM NAME RANGE   : DESCRIPTION : DEFAULT : UNITS
// -----------------------------------------------------------------------------

`define DATA_WIDTH 8
`define ADDR_WIDTH 2    // FIFO_DEPTH = 16 -> ADDR_WIDTH = 4, no. of bits to be used in read/write pointer
`define FIFO_DEPTH ( 1<<`ADDR_WIDTH )

module TXFIFO ( i_PCLK, i_PSEL, i_PWRITE, i_PWDATA, i_CLEAR_B, o_TXDATA, o_TX_VALID, i_REQ, o_SSPTXINTR );

//****************IO ports***************************//

input                     i_PCLK, i_PSEL, i_PWRITE, i_CLEAR_B; // system clock, enable, write/read sel and reset
input [`DATA_WIDTH-1 :0]  i_PWDATA;  // data input to be pushed to buffer
input                     i_REQ;     // Receiver data request

output[`DATA_WIDTH-1 :0]  o_TXDATA;  // port to output the data using pop
output                    o_SSPTXINTR;
output reg                o_TX_VALID;

//*********Internal Variables************************//

reg                   buf_empty, buf_full;       // buffer empty and full indication 
reg[`DATA_WIDTH-1 :0] buf_out;
reg[`ADDR_WIDTH :0]   fifo_counter;              // number of data pushed in to buffer  
reg[`ADDR_WIDTH-1:0]  rd_ptr, wr_ptr;            // pointer to read and write addresses  
reg[`DATA_WIDTH-1 :0] buf_mem[`FIFO_DEPTH -1 : 0]; 

wire                  wr_en, rd_en;
wire                  w_REQ_sync_del1;
wire                  w_REQ_sync_del2;
//***************************************************//

assign o_SSPTXINTR  = buf_full;
assign o_TXDATA     = buf_out;

always @(negedge i_PCLK )
begin
   if( !i_CLEAR_B )
       o_TX_VALID <= 0;
   else
      o_TX_VALID <= !buf_empty;
end

assign wr_en        = i_PSEL & i_PWRITE;

data_sync i_data_sync_req(.i_clk(i_PCLK), .i_data_in(i_REQ), .i_sync_reset_bar(i_CLEAR_B), .o_sync_out1(w_REQ_sync_del1), .o_sync_out2(w_REQ_sync_del2) );

assign rd_en = (w_REQ_sync_del1 == 1'b1) & (w_REQ_sync_del2 == 1'b0);

always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== `FIFO_DEPTH);

end

always @(posedge i_PCLK )
begin
   if( !i_CLEAR_B )
       fifo_counter <= 0;

   else if( (!buf_full && wr_en) && ( !buf_empty && rd_en ) )
       fifo_counter <= fifo_counter;

   else if( !buf_full && wr_en )
       fifo_counter <= fifo_counter + 1;

   else if( !buf_empty && rd_en )
       fifo_counter <= fifo_counter - 1;
   else
      fifo_counter <= fifo_counter;
end

always @( * )
begin
    buf_out <= buf_mem[rd_ptr];
end

always @(posedge i_PCLK )
begin

   if( wr_en && !buf_full )
      buf_mem[ wr_ptr ] <= i_PWDATA;

   else
      buf_mem[ wr_ptr ] <= buf_mem[ wr_ptr ];
end

always@(posedge i_PCLK )
begin
   if( !i_CLEAR_B )
   begin
      wr_ptr <= 0;
      rd_ptr <= 0;
   end
   else
   begin
      if( !buf_full && wr_en )    wr_ptr <= wr_ptr + 1;
          else  wr_ptr <= wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr <= rd_ptr + 1;
      else rd_ptr <= rd_ptr;
   end

end

endmodule

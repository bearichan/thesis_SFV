// -----------------------------------------------------------------------------
// FILE NAME          : SSP.v
// AUTHOR             : Sharukh S. Shaikh
// AUTHOR'S EMAIL     : sharukhsshaikh@utexas.edu
// VERSION DATE       : 11/6/2016
// DESCRIPTION        : Synchronous Serial Port (SerDes)
// -----------------------------------------------------------------------------
// PARAM NAME RANGE   : DESCRIPTION : DEFAULT : UNITS
// -----------------------------------------------------------------------------

`define DATA_WIDTH 8

module SSP ( PCLK, CLEAR_B, PSEL, PWRITE, PWDATA[7:0], SSPCLKIN, SSPFSSIN, SSPRXD, PRDATA[7:0], SSPOE_B, SSPTXD, SSPCLKOUT, SSPFSSOUT, SSPTXINTR, SSPRXINTR);

//*******************IO declaration*******************//

input        PCLK, CLEAR_B, PSEL, PWRITE, SSPCLKIN, SSPFSSIN, SSPRXD;
input  [7:0] PWDATA;

output       SSPOE_B, SSPTXD, SSPCLKOUT, SSPFSSOUT, SSPTXINTR, SSPRXINTR;
output [7:0] PRDATA;

//****************Internal Variables*****************//

wire                    w_REQ_RD, w_REQ_WR;
wire [`DATA_WIDTH-1 :0] w_TXDATA, w_RXDATA;
wire                    w_TX_VALID;

//*******************Instantiation*******************//

TXFIFO i_TXFIFO ( 
                  .i_PCLK(PCLK), 
                  .i_PSEL(PSEL),  
                  .i_PWRITE(PWRITE), 
                  .i_PWDATA(PWDATA), 
                  .i_CLEAR_B(CLEAR_B), 
                  .o_TXDATA(w_TXDATA), 
                  .o_TX_VALID(w_TX_VALID), 
                  .i_REQ(w_REQ_RD), 
                  .o_SSPTXINTR(SSPTXINTR) 
                );

data_serializer i_data_serializer (
                  .i_PCLK(PCLK), 
                  .i_CLEAR_B(CLEAR_B), 
                  .i_TXDATA(w_TXDATA), 
                  .i_TX_VALID(w_TX_VALID), 
                  .o_REQ(w_REQ_RD), 
                  .o_SSPOE_B(SSPOE_B), 
                  .o_SSPTXD(SSPTXD), 
                  .o_SSPCLKOUT(SSPCLKOUT), 
                  .o_SSPFSSOUT(SSPFSSOUT)
                 );

data_deserializer i_data_deserializer (
                 .i_SSPCLKIN(SSPCLKIN),
                 .i_CLEAR_B(CLEAR_B), 
                 .i_SSPFSSIN(SSPFSSIN),
                 .i_SSPRXD(SSPRXD), 
                 .o_RXDATA(w_RXDATA), 
                 .o_REQ(w_REQ_WR)
                );

RXFIFO i_RXFIFO ( 
                 .i_PCLK(PCLK), 
                 .i_PSEL(PSEL),  
                 .i_PWRITE(PWRITE),
                 .i_CLEAR_B(CLEAR_B),
                 .i_RXDATA(w_RXDATA),
                 .i_REQ(w_REQ_WR), 
                 .o_PRDATA(PRDATA), 
                 .o_SSPRXINTR(SSPRXINTR)
               );

endmodule

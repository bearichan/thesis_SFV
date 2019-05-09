// -----------------------------------------------------------------------------
// FILE NAME          : data_sync.v
// AUTHOR             : Sharukh S. Shaikh
// AUTHOR'S EMAIL     : sharukhsshaikh@utexas.edu
// VERSION DATE       : 11/6/2016
// DESCRIPTION        : Two-flop delay module with synchronous active low reset
// -----------------------------------------------------------------------------
// PARAM NAME RANGE   : DESCRIPTION : DEFAULT : UNITS
// -----------------------------------------------------------------------------

module data_sync (i_clk, i_data_in, i_sync_reset_bar, o_sync_out1, o_sync_out2 );


//****************IO ports***************************//
input  i_clk, i_data_in, i_sync_reset_bar;
output o_sync_out1, o_sync_out2;

reg    o_sync_out1, o_sync_out2;

//**************************************************//

always @(negedge i_clk)
begin
    if (!i_sync_reset_bar)
    begin
        o_sync_out1 <= 1'b0;
        o_sync_out2 <= 1'b0;
    end
    else
    begin
        o_sync_out1 <= i_data_in;
        o_sync_out2 <= o_sync_out1;
    end
end

endmodule

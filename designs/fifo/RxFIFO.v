/*
copyright belongs to 
        Yuxin Wang
        University of Texas at Austin
used for VLSI1 courses
*/

module RxFIFO#(
    parameter FIFO_DEPTH = 2,
    parameter DATA_WIDTH = 8
) 
(
    CLEAR_B, PCLK, PSEL, PWRITE, RxDATA, ISREADY,
    PRDATA, SSPRXINTR, EMPTY
);
//parameter FIFO_DEPTH = 2, DATA_WIDTH = 8;

input CLEAR_B; //low active reset signal
input PCLK; //global clk
input PSEL; //PSEL high active to enable read PRDATA
input PWRITE; //PWRITE low active to read data from SSP
input [DATA_WIDTH-1:0] RxDATA; 
input ISREADY;
output [DATA_WIDTH-1:0] PRDATA; 
output SSPRXINTR; //full signal
output EMPTY; 

reg [DATA_WIDTH-1:0] data_out;
reg [DATA_WIDTH-1:0] mem [2**FIFO_DEPTH-1:0];
reg [FIFO_DEPTH-1:0] wr_reg, wr_next; //points to the register that needs to be written to
reg [FIFO_DEPTH-1:0] rd_reg, rd_next; //points to the register that needs to be read from
reg full_reg, empty_reg, full_next, empty_next;

reg tmp;
always @ (posedge PCLK) tmp <= ISREADY;
wire ready_risingedge = ISREADY & ~tmp;
wire ready_fallingedge = ~ISREADY & tmp;

wire wr_en, rd_en;
assign wr_en = ~SSPRXINTR & ready_fallingedge;
assign rd_en = PSEL & ~PWRITE & ~EMPTY;

assign SSPRXINTR = full_reg;
assign EMPTY = empty_reg;
assign PRDATA = (PSEL & ~PWRITE) ? data_out : 8'bz;

//reg point change block
always @ (negedge PCLK)
begin
    wr_reg <= wr_next; 
    rd_reg <= rd_next;
    full_reg <= full_next;
    empty_reg <= empty_next;
    //created the next registers to avoid the error of mixing blocking and non blocking assignment to the same signal
end

//operation for read/write block
always @ (posedge PCLK)
begin
    if (!CLEAR_B) begin // synchronized clear signal
        wr_next = 1'b0;
        rd_next = 1'b0;
        full_next = 1'b0;
        empty_next = 1'b1;
    end
    else begin
        case ({wr_en, rd_en})  
        2'b00: //no operation
        begin
            wr_next = wr_reg;
            rd_next = rd_reg;
            full_next = full_reg;
            empty_next = empty_reg;
        end
        2'b01: //read, not empty
        begin
            data_out = mem[rd_reg];
            rd_next = rd_reg + 1;
            full_next = 1'b0; //if we read, FIFO must not be full
            if((rd_reg + 1) == wr_reg) empty_next = 1'b1; //all data been read, empty next stage
        end
        2'b10: //write, not full
        begin
            mem[wr_reg] = RxDATA;
            wr_next = wr_reg + 1;
            empty_next = 1'b0; //if we write, FIFO must not be empty
            if(wr_next == rd_reg) full_next = 1'b1; 
        end
        2'b11: // read and write
        begin
            data_out = mem[rd_reg];
            mem[wr_reg] = RxDATA;
            wr_next = wr_reg + 1;
            rd_next = rd_reg + 1;
            full_next = full_reg;
            empty_next = empty_reg;
        end
    endcase
    end
end

endmodule

/*
end of code
copyright: Yuxin Wang
*/

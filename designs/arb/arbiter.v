//EE382M-Verification of Digital Systems
//Lab 4 - Formal Property Verification
//
//
//Module - arbiter
//4-way round-robin arbiter

module arbiter(
    input clk,
    input rst,
    input  [3:0] request,
    output reg [3:0] grant
    );

wire [1:0] grant_encoded;
always @ (posedge clk)
    if(rst) begin
        grant[3:0] <= 4'h0;
    end else begin
        grant[0] <= (grant_encoded[1] & grant_encoded[0] & request[0]) |
                    (grant_encoded[1] & ~grant_encoded[0] & ~request[3] & request[0]) |
                    (~grant_encoded[1] & grant_encoded[0] & ~request[3] & ~request[2] & request[0]) |
                    (~grant_encoded[1] & ~grant_encoded[0] & ~request[3] & ~request[2] & ~request[1] & request[0]) ;
        grant[1] <= (grant_encoded[1] & grant_encoded[0] & ~request[0] & request[1]) |
                    (grant_encoded[1] & ~grant_encoded[0] & ~request[3] & ~request[0] & request[1]) |
                    (~grant_encoded[1] & grant_encoded[0] & ~request[3] & ~request[2] & ~request[0] & request[1]) |
                    (~grant_encoded[1] & ~grant_encoded[0] & request[1]) ;
        grant[2] <= (grant_encoded[1] & grant_encoded[0] & ~request[0] & ~request[1] & request[2]) |
                    (grant_encoded[1] & ~grant_encoded[0] & ~request[3] & ~request[0] & ~request[1] & request[2]) |
                    (~grant_encoded[1] & grant_encoded[0] & request[2]) |
                    (~grant_encoded[1] & ~grant_encoded[0] & ~request[1] & request[2]) ;
        grant[3] <= (grant_encoded[1] & grant_encoded[0] & ~request[0] & ~request[1] & ~request[2] & request[3]) |
                    (grant_encoded[1] & ~grant_encoded[0] & request[3]) |
                    (~grant_encoded[1] & grant_encoded[0] & ~request[2] & request[3]) |
                    (~grant_encoded[1] & ~grant_encoded[0] & ~request[1] & ~request[2] & request[3]) ;
    end

// encode the 4b grants to 2b
assign grant_encoded = {grant[3] | grant[2], grant[3] | grant[1]};

endmodule

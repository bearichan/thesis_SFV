module sequence_detector(rst,clk,ip,op);

	output reg op;
 	input clk, rst, ip;

	 reg [2:0] state;
	 reg [2:0] next_state;

	 parameter [2:0] s0=3'b000;
	 parameter [2:0] s1=3'b001;
	 parameter [2:0] s2=3'b010;
	 parameter [2:0] s3=3'b011;
	 parameter [2:0] s4=3'b100;
	 parameter [2:0] s5=3'b101;

	 always @(posedge clk, posedge rst)
	 begin
		if (rst)
   			state=s0;
  		else
   			state=next_state;
	 end

	 always @(state, next_state)
	 begin
	 	case(state)
		s0:
			if (ip)
   			begin
    				next_state=s1;
    				op=1'b0;
   			end
   			else
   			begin
    				next_state=s0;
    				op=1'b0;
   			end
  
  		s1:
   			if (ip)
   			begin
    				next_state=s1;
    				op=1'b0;
   			end
   			else
   			begin
    				next_state=s2;
    				op=1'b0;
   			end

  		s2:
   			if (ip)
   			begin
    				next_state=s3;
    				op=1'b0;
   			end
   			else
   			begin
    				next_state=s0;
    				op=1'b0;
   			end
  
  		s3:
   			if (ip)
   			begin
    				next_state=s4;
    				op=1'b0;
   			end
   			else
   			begin
    				next_state=s2;
    				op=1'b0;
   			end

  		s4:
   			if (ip)
   			begin 
    				next_state=s1;
    				op=1'b0;
   			end
   			else
   			begin
    				next_state=s5;
    				op=1'b0;
   			end
  
  		s5:
   			if (ip)
   			begin
    				next_state=s1;
    				op=1'b1;
   			end
   			else
   			begin
    				next_state=s0;
    				op=1'b0;
   			end

  		default:
   			begin
           			next_state=s0;
           			op=1'b0;
   			end
  		endcase
 	end
endmodule
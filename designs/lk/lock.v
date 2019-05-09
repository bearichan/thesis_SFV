module lock
(
    input  wire      clock,
    input  wire      reset,
    input  wire      x,
    output reg      ready,
    output reg      unlock,
    output reg      error
);

  reg [2:0] state;
  reg [2:0] next_state;

  localparam s_reset=3'b000,
             s1=3'b001,
             s2=3'b010,
             s3=3'b011,
             s4=3'b100,
             s5=3'b101,
             open=3'b110, 
             s_error=3'b111;

  always @ (posedge clock, posedge reset) begin
     if(reset)
      state <= s_reset;
    else
      state <= next_state;
  end

  always @ * begin
    case(state)
      s_reset : if(x==1'b1) begin 
                  next_state = s1; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_reset;
                  unlock = 1'b0;
                  ready = 1'b1;
                  error = 1'b0; 
                end

      s1      : if(x==1'b0) begin 
                  next_state = s2; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end

      s2      : if(x==1'b1) begin 
                  next_state = s3; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end

      s3      : if(x==1'b0) begin 
                  next_state = s4; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end

      s4      : if(x==1'b1) begin 
                  next_state = s5; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end

      s5      : if(x==1'b1) begin 
                  next_state = open; 
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end

      open    : if(x==1'b0) begin 
                  next_state = s_reset; 
                  unlock = 1'b1;
                  ready = 1'b0;
                  error = 1'b0; 
                end
                else begin
                  next_state = open;
                  unlock = 1'b1;
                  ready = 1'b0;
                  error = 1'b0; 
                end

      s_error  : if(x==1'b0) begin 
                  next_state = s_reset; 
                  unlock = 1'b0;
                  ready = 1'b1;
                  error = 1'b0; 
                end
                else begin
                  next_state = s_error;
                  unlock = 1'b0;
                  ready = 1'b0;
                  error = 1'b1; 
                end   

      default : begin
                  next_state = s_reset;
                  unlock = 1'b0;
                  ready = 1'b1;
                  error = 1'b0; 
                end
    endcase
  end   

endmodule

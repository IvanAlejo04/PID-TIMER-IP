
module PID_TOP (

    input PCLK,
    input RST,

    input signed [32:0] ERR,

    input signed [32:0] Kp,
    input signed [32:0] Ki,
    input signed [32:0] Kd,

    input signed [32:0] MAX_CLMP,
    input signed [32:0] MIN_CLMP,

    output signed [49:0] PID /* Turn to 50 based on problem I encounter where the output is not matching the 
    intended output due to its size overflowing the bit range  */

);

  wire signed [32:0] P;
  wire signed [32:0] I;
  wire signed [32:0] D;

  //======================//
  // Proportion
  //======================//

  //======================//
  // Integral
  //======================//
  reg signed [32:0] accumulate;
  //======================//
  // Derivative
  //======================//
  reg signed [32:0] past_error;

  wire signed [49:0] PID_ANS = (P + I + D) >>> 16;

  proportion pterm (
      .KP (Kp),
      .ERR(ERR),
      .P  (P)
  );

  integral iterm (
      .KI(Ki),
      .ERR(ERR),
      .MAX_CLMP(MAX_CLMP),
      .MIN_CLMP(MIN_CLMP),
      .accumulate(accumulate),  // mark
      .P(P),
      .D(D),
      .I(I)
  );



  derivative dterm (
      .KD(Kd),
      .ERR(ERR),
      .PAST_ERR(past_error),  // mark
      .D(D)
  );  

 always @(posedge PCLK or posedge RST) begin
        if (RST) begin
            accumulate <= 32'b0;
            past_error <= 32'b0;
            PID <= 51'b0;
        end else begin

          if (PID_ANS >= MAX_CLMP || PID_ANS <= MIN_CLMP) begin
              accumulate <= accumulate;  
          end else begin
              accumulate <= accumulate + ERR;
          end
            past_error <= ERR;                
            PID <= PID_ANS;
        end
    end


endmodule

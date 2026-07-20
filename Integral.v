module integral (
    input PCLK,
    input RST,
    input signed [32:0] KI,
    input signed [32:0] ERR_DT,
    input signed [32:0] MIN_CLMP,
    input signed [32:0] MAX_CLMP,
    input is_done_flag,
    input signed [32:0] P,
    input signed [32:0] D,
    output reg signed [32:0] I
);
  reg signed  [65:0] accumulate;
  wire signed [65:0] I_holder = ((accumulate + ERR_DT) * KI) >>> 16;

  always @(*) begin
    if ((P + D + I_holder) >= MAX_CLMP) begin
      I = MAX_CLMP;
    end else if ((P + D + I_holder) <= MIN_CLMP) begin
      I = MIN_CLMP;
    end else begin
      I = I_holder;
    end
  end

  always @(posedge PCLK) begin
    if (!RST) begin
      accumulate <= 18'sd0;
    end else if (is_done_flag) begin
      accumulate <= accumulate + ERR_DT;
    end
  end

endmodule

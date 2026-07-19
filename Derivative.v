module derivative (

    input PCLK,
    input RST,

    input signed [32:0] KD_dt,
    input signed [32:0] ERR,
    input NEW_DATA_FLAG,

    output signed [32:0] D

);

  reg signed  [32:0] PAST_ERR = 33'd0;

  wire signed [65:0] mul = KD_dt * (ERR - PAST_ERR);
  wire signed [32:0] D = mul >>> 16;

  always @(posedge PCLK) begin
    if (NEW_DATA_FLAG) begin
      PAST_ERR <= ERR;
    end
  end

endmodule

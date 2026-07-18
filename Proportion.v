module proportion (

    input signed [32:0] KP,
    input signed [32:0] ERR,
    output reg signed [31:0] P

);

  //---formula---//
  // P = Kp * error;
  //Q16.16

  wire signed [65:0] mul = ERR * KP;

  always @(*) begin
    P = mul >>> 16; 
    // process:
    // Q16.16 * Q16.16 = Q32.32 must shift to right with 16, >>> 16 to becomes Q16.16 again
  end

endmodule

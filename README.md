# PID-TIMER-IP

> ⚠️ **Status: Work in Progress**
> Currently implemented: Proportion, Derivative
> Not yet implemented: Integral term, Timer/CCR interface


A Verilog PID controller combined with a Timer module, where the PID output is connected directly to the Timer's CCR (Capture/Compare Register).

## Proportion Module

```verilog
module proportion (

    input signed [32:0] KP,
    input signed [32:0] ERR,
    output reg signed [32:0] P

);

  //---formula---//
  // P = Kp * error;
  //Q16.16

  wire signed [65:0] mul = ERR * KP;

  always @(*) begin
    P = mul >>> 16; 
    // process:
    // Q16.16 * Q16.16 = Q32.32 must shift right by 16 (>>>16) to become Q16.16 again
  end

endmodule
```
## Derivative Module
``` verilog
module derivative (

    input PCLK,

    input signed [32:0] KD_dt,
    input signed [32:0] ERR,
    input NEW_DATA_FLAG,

    output signed [32:0] D

);

 //---formula---// 
  // D = Kd * (error - past_error) / dt;
    
  reg signed  [32:0] PAST_ERR = 33'd0;

  wire signed [65:0] mul = KD_dt * (ERR - PAST_ERR);
  wire signed [32:0] D = mul >>> 16;

  always @(posedge PCLK) begin
    if (NEW_DATA_FLAG) begin
      PAST_ERR <= ERR;
    end
  end

endmodule
```
This project uses a **Q16.16 fixed-point format** for all PID computations.

**Key implementation details:**



- **Input width (33-bit):** `KP` and `ERR` are stored as Q16.16 (32-bit), plus 1 extra bit to account for the sign, giving 33 bits total.
- **Intermediate multiplication (66-bit):** Multiplying two 33-bit signed values requires a 66-bit result to avoid overflow, hence `wire signed [65:0] mul = ERR * KP;`.
- **Re-normalizing to Q16.16:** Multiplying two Q16.16 numbers produces a Q32.32 result. Shifting right by 16 (`>>> 16`) brings it back down to Q16.16.


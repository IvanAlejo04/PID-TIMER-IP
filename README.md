# PID-TIMER-IP

A Verilog PID controller combined with a Timer module, where the PID output is connected directly to the Timer's CCR (Capture/Compare Register).

## Proportion Module

![proportion_code](https://github.com/IvanAlejo04/PID-TIMER-IP/blob/aaab94f1bcf2c693eee31e58a530c2ade3c7a744/carbon%20(9).png?raw=true)

This project uses a **Q16.16 fixed-point format** for all PID computations.

**Key implementation details:**

- **Input width (33-bit):** `KP` and `ERR` are stored as Q16.16 (32-bit), plus 1 extra bit to account for the sign, giving 33 bits total.
- **Intermediate multiplication (66-bit):** Multiplying two 33-bit signed values requires a 66-bit result to avoid overflow, hence `wire signed [65:0] mul = ERR * KP;`.
- **Re-normalizing to Q16.16:** Multiplying two Q16.16 numbers produces a Q32.32 result. Shifting right by 16 (`>>> 16`) brings it back down to Q16.16.

```verilog
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
    // Q16.16 * Q16.16 = Q32.32 must shift right by 16 (>>>16) to become Q16.16 again
  end

endmodule
```

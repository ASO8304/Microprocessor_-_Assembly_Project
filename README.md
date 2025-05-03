# ATmega64 Guessing Game  

## Overview  
A two-player game where Player 1 sets a target value (PortD), and Player 2 has 10 chances (displayed on PortB) to guess it via PortA. LEDs (PortC) provide feedback:  
- White: Player 2's turn (5s to guess).  
- Red/Yellow: Guess is higher/lower (1s indicator).  
- Green: Correct guess (5s win).  
- All LEDs on: Loss (5s).  

## Hardware Setup  
- **Inputs**: Connect buttons/switches to PortD (Player 1) and PortA (Player 2).  
- **Outputs**: LEDs to PortC (bits 0-3 for feedback) and PortB (remaining chances).  
- **Interrupt**: INT5 (rising edge) starts the game.  

## How to Play  
1. Player 1 sets a value on PortD and triggers INT5.  
2. Player 2 guesses via PortA within 10 tries.  
3. LEDs guide Player 2 by indicating "higher," "lower," or "correct."  

## Code Notes  
- Built for ATmega64; ensure `M64DEF.INC` is included.  
- Timer0 controls delays (1s/5s via overflow interrupts).  
- Assembly code structure: Interrupt-driven with SPI/stack setup.  

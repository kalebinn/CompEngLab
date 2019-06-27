# EE42500 - Computer Engineering Lab    
**Course Instructor:** Professor Alfredo Cano  
PIC Microcontroller  
**Contributors to all code:**    
Franklin Lourido (EE, CCNY)  
Kelvin Ma (EE, CCNY)  
Ryu Ohkawa (EE, CCNY)  
  
### P1 - Square Wave Generator
**P1_Completed.asm** - Code to generate square wave from PIC microcontroller. LED (D5) blinks at the same rate.  
It is easy to modify: 
- Duty Cycle (TIMEHIGHCNT, TIMELOWCNT)
- Half period (BIGNUM)  

**Output Data** Contains output images of the square wave from the oscilloscope. 
  
### P2 - Analog-to-Digital/Digital-to-Analog  
**Source code will be uploaded soon.**

### P3 - Motor Controller
**P3_FullStepMotor.asm** - Controls a 4 phase full step motor.  
**P3_HalfStep.asm** - Controls a 4 phase half step motor.  
**P3_TwoPhase.asm** - Controls    
  
  ![Circuit](https://i.imgur.com/39GFqOA.jpg)  

### P4 - Finite Impulse Response (3rd Order Averaging) Filter   
**P4_FIR.asm** - is a simple third order averaging response filter with the following transfer function and difference equation.     
![transfer function/difference equation](https://i.imgur.com/4nwmSHN.png)  

The exact nyquist frequency is 12,500.306 hz or approximately 12.5 khz.  
The sample frequency is then 25,000.612 hz or approximately 25 khz.  


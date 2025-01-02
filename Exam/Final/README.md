# PIC Microcontroller Interface Template for Final Exam

## Overview
This [Template](template.c) allows you to control LEDs, buttons, servos and variable resistors without using any low-level code (like changing register values). You can use the high-level functions provided in the template. Here are some examples:

```c
// Set servo angle to 90
set_servo_angle(90);

// Set LED1 and LED2 on, LED3 off
set_LED_separately(1, 1, 0);
```
## Getting Started
1. Download the [template file](template.c)
2. Open MPLAB X IDE
3. Create a new project and paste the template code into main.c
4. Connect your hardware according to the [Wiring Guide](#circuit-wiring-information)
5. Build and run your project

## Usage - Function Reference
### Servo
```c
set_servo_angle(-90); 
// input: -90 ~ 90
// return value: -1 represents interrupt with button press, else 0
```
```c
get_servo_angle(); 
// return value: -90 ~ 90
```

### LED
```c
set_LED(5);
// 5 = 0b101, set LED1 and LED3 on, LED2 off
```
```c
get_LED();
// return value: an integer, bit 0 -> LED1, bit 1 -> LED2, bit 2 -> LED3
```
```c
set_LED_separately(1, 1, 0);
// set LED1 and LED2 on, LED3 off
```

```c
set_LED_analog(512); 
// input: 0 ~ 1023, represent brightness. 
// NOTICE: LED need to be plugged into the CCP1 pin.
```

### Variable Register
```c
VR_value_to_servo_angle(512);
// input: 0 ~ 1023, return value: -90 ~ 90
// Map the variable register value to servo angle
```
```c
VR_value_to_LED_analog(1023);
// input: 0 ~ 1023, return value: 0 ~ 1023
// Map the variable register value to LED brightness
```

### Delay
```c
delay(0.5); 
// delay 0.5 second
// return value: -1 represents interrupt with button press, else 0
```

### Print
```c
printf("%d\n", get_servo_angle()); 
// print servo angle on uart terminal
```

## Circuit Wiring Information

| Component | Pin Connection |
|-----------|---------------|
| LED 1     | RA1          |
| LED 2     | RA2          |
| LED 3     | RA3          |
| Variable Resistor | RA0   |
| Push Button | RB0        |
| Servo Motor | CCP1       |

![Wiring Diagram](Circuit_Wiring.png)

### Important Notes
- For analog LED control, connect the LED to the CCP1 pin
- Button press will interrupt delay and servo movement functions
- All functions are interrupt-safe
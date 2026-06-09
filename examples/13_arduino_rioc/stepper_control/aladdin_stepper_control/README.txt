Stepper Control using Aladdin Micro
===================================

Several examples demonstrate how to control stepper motors with DigiShow.

1. Prepare a stepper motor driver, typically connecting the stepper motor via A+/A- B+/B-.
2. Prepare an Aladdin Micro and upload the DigiShow RIOC program.
3. Connect PUL-/DIR-/ENA- on the driver to Aladdin OUT pins of Y0, Y1, Y2, and connect PUL+/DIR+/ENA+ to +24V pins of Y0, Y1, Y2.
4. Connect Aladdin to PC via USB, and power the stepper driver.

aladdin_stepper_simple.dgs
Simplest method to start/stop motor, adjust speed and direction.
- Y0 outputs a specific frequency square wave (connected to PUL) to control speed (steps/sec). Max range is adjustable (click gear button).
- Y1 (connected to DIR) controls rotation direction (CW/CCW).
- Y2 (connected to ENA) controls motor on/off; When enabled (motor on), it will still work in a brake state even if the speed is zero.

aladdin_stepper_positioning.dgs
Control target position of the stepper motor, like a servo, to stop at specified absolute positions.
- Set Y0 as "Stepper" output. Position range (total steps), speed (steps/sec) are adjustable (click gear button). And also set "Drive Lines" to "PUL- and DIR-". In this case, the selected pin Y0 connects to PUL, and the next pin Y1 to DIR. Changing the value of this signal output will change the target position of the stepper.
- When Y0 is set to "Stepper (SET)", output can change speed, sync position, or stop mid-travel.

aladdin_stepper_limit.dgs
The demo shows the installation of limit switches in the motion mechanism containing the stepper motor (such as at both ends of the rail), which automatically return to the zero position upon startup.
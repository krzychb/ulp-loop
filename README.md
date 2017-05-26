# ULP Loop Example

The purpose of this application is to test retaining of RTC IO output signals during hibernation of ESP32.

## How it Works

Initially the application configures three GPIOs that perform the following functions:

	1. GPIO25 - is set high when the main program is active, low when in sleep
	2. GPIO26 - toggled on each wakeup of the main program
	3. GPIO27 - toggled on each wakeup of ULP

Then the main program is sequentially put to sleep and then woken up by ULP. This process is reflected by status of GPIO25 and GPIO26.

During sleep of the main program, ULP is also put to sleep and then periodically restarted by ULP timer. Each period of activity and sleep of ULP is signaled by toggling of GPIO27.

After specific number of restarts of ULP (configured using the constant value 'toggle_cycles' inside 'loop_blink.S'), the ULP timer is disabled and the main program woken up.

After asserting of GPIO25 and GPIO26 the main program is put back to sleep, ULP is started again and the process continues.

What is special about this application? Nothing besides you need to enable holding of last state of specific output before you put chip into hiberantion mode. To do so use function `rtc_gpio_hold_en(gpio_num_t gpio_num)`. There is also equivalent `rtc_gpio_hold_dis(gpio_num_t gpio_num)` function to disable holding the last state once chip wakes up and you need to change the output.

## Example output on scope

![alt text](program-trace.bmp "Example output on scope")

	1. Red / GPIO25 - is set high when the main program is active, low when in sleep
	2. Yellow / GPIO26 - toggled on each wakeup of the main program
	3. Violet / GPIO27 - toggled on each wakeup of ULP

RTC IO output signals are retained as espected during hibernation mode.


## Example output on console

Note: GPIO15 is connected to GND to disable ROM bootloader output.

```
ULP wakeup, printing status
CPU / ULP toggle counter 0x68 / 0x348
Entering deep sleep

ULP wakeup, printing status
CPU / ULP toggle counter 0x69 / 0x350
Entering deep sleep

ULP wakeup, printing status
CPU / ULP toggle counter 0x6a / 0x358
Entering deep sleep
```

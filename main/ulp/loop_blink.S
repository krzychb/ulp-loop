/* ULP Example: testing if RTCIO signals may be retained during ESP32 hibernation

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.

   This file contains assembly code which runs on the ULP.
*/

/* ULP assembly files are passed through C preprocessor first, so include directives
   and C macros may be used in these files 
 */
#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"
#include "soc/soc_ulp.h"

	/* Define variables, which go into .bss section (zero-initialized data) */
	.bss

	.global toggle_counter
toggle_counter:
	.long 0

	/* Number of resarts of ULP to wake up the main program.
	   See couple of lines below how this value is used */
	.set toggle_cycles, 0b0000000000001111

	/* Code goes into .text section */
	.text
	.global entry
entry:
	/* Read toggle counter */
	move r3, toggle_counter
	ld r0, r3, 0
	/* Increment */
	add r0, r0, 1
	/* Save */
	st r0, r3, 0

	/* Wake up SoC periodically */
	and r0, r0, toggle_cycles
	jump wake_up, eq

	/* Toggle output */
	and r0, r0, 0x01
	jump toggle_clear, eq

	/* Set toggle output */
	WRITE_RTC_REG(RTC_GPIO_OUT_W1TS_REG,RTC_GPIO_OUT_DATA_W1TS_S+17,1,1)
	halt

	.global toggle_clear
toggle_clear:
	/* Clear toggle output */
	WRITE_RTC_REG(RTC_GPIO_OUT_W1TC_REG,RTC_GPIO_OUT_DATA_W1TC_S+17,1,1)
	halt

	.global exit
exit:
	halt

	.global wake_up
wake_up:
	/* Check if the SoC can be woken up */
	READ_RTC_REG(RTC_CNTL_DIAG0_REG, 19, 1)
	and r0, r0, 1
	jump exit, eq

	/* Wake up the SoC, end program */
	wake
	/* Stop the wakeup timer so it does not restart ULP */
	WRITE_RTC_FIELD(RTC_CNTL_STATE0_REG, RTC_CNTL_ULP_CP_SLP_TIMER_EN, 0)
	halt
; *** FILE DATA ***
;   Filename: led_trigger.asm
;   Date: June 16, 2023
;   Version: 1.0
;
;   Author: Gianni Labella
;   Company: Universidad de Montevideo


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
trigger EQU 0       ; Bit 0 of port A is the trigger
led_bit EQU 1       ; Bit 1 of port A controls the LED
timer_2 EQU 0x20    ; Variables for LED 5-second timer
timer_1 EQU 0x21 
timer_0 EQU 0x22 

; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004   ; interrupt vector location

	retfie          ; Return from interrupt


; *** Led Trigger Config Subroutine ***
led_trigger_config
    ; Change to bank 1
    bcf     STATUS, RP1
    bsf     STATUS, RP0

    ; Set PORTA as digital I/O
    bcf     ADCON1, PCFG3
    bsf     ADCON1, PCFG2
    bsf     ADCON1, PCFG1
    
    ; Set trigger pin as input
    bsf     TRISA, trigger

    ; Set LED pin as output
    bcf     TRISA, led_bit

    ; Change to bank 0
    bcf     STATUS, RP1
    bcf     STATUS, RP0

    return

; *** Led Trigger Listener Subroutine ***
led_trigger_listener
    btfss   PORTA, trigger          ; Check if trigger is on/set, skip if it is
    goto    led_trigger_listener    ; Restart listener if is off/clear
    return                          ; Returns if is on/set

; *** Led Trigger Timer Subroutine ***
led_trigger_timer
    ; Setup Timer Variables for 5 seconds
    movlw   d'48'
    movwf   timer_2
    clrf    timer_1
    clrf    timer_0

tmr nop
    decfsz  timer_0
    goto    tmr
    decfsz  timer_1
    goto    tmr
    decfsz  timer_2
    goto    tmr
    
    return

; *** Led Trigger Subroutine ***
led_trigger
    ; Listen until trigger is on
    call    led_trigger_listener

    ; Turn LED on
    bsf     PORTA, led_bit

    ; Start 5 seconds timer
    call    led_trigger_timer

    ; Turn LED off
    bcf     PORTA, led_bit

    ; Restart subroutine
    goto    led_trigger


; *** Main Routine ***
main
    call    led_trigger_config
    call    led_trigger

	END ; directive 'end of program'

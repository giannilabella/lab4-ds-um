; *** FILE DATA ***
;   Filename: XXX.asm
;   Date:
;   Version:
;
;   Author: 
;   Company:
;
;   Notes:


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
w_temp      EQU	0x7D    ; variables used for context saving 
status_temp	EQU	0x7E
pclath_temp	EQU	0x7F			


; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004   ; interrupt vector location

    ; Disable global interrupt
    bcf     INTCON, GIE

    ; Save context
    movwf   w_temp          ; copy W value to a temporary register
    swapf   STATUS, W       ; swap STATUS nibbles and save value to a temporary register
    movwf   status_temp
    swapf   PCLATH, W       ; swap PCLATH nibbles and save value to a temporary register
    movwf   pclath_temp

    ; Interrupt Service Routine (ISR) code can go here or be located as a call subroutine elsewhere

    ; Restore context
    swapf   pclath_temp, W  ; swap original PCLATH value and restore from temporary register
    movwf   PCLATH
    swapf   status_temp, W  ; swap original STATUS value and restore from temporary register
    movwf   STATUS
    swapf   w_temp, F       ; restore original W value from temporary register
    swapf   w_temp, W

    ; Enable global interrupt
    bsf     INTCON, GIE

    ; Return from interrupt
	retfie


; *** Main Routine ***
main
    ; main code goes here

	END ; directive 'end of program'

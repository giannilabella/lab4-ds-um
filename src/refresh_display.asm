; *** FILE DATA ***
;   Filename: refresh_display.asm
;   Date: June 21, 2023
;   Version: 1.0
;
;   Author: Gianni Labella
;   Company: Universidad de Montevideo


; *** Processor Config ***
	list		p=16f877a       ; list directive to define processor
	#include	<p16f877a.inc>  ; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _RC_OSC & _WRT_OFF & _LVP_ON & _CPD_OFF


; *** Variable Definition ***
; Variables used for context saving 
w_temp      EQU	0x7D
status_temp	EQU	0x7E
pclath_temp	EQU	0x7F

; Refresh Display Subroutine Variables

timer_preload   EQU d'60'   ; Preload for 10ms interrupt period on 1:128 prescaler


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
    btfsc   INTCON, TMR0IF      ; Skip when timer0 flag is clear
    call    refresh_display     ; Convert analog input if flag is set

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


; *** Refresh Display Config Subroutine ***
refresh_display_config
    ; Change to Bank 1
    bcf     STATUS, RP1
    bsf     STATUS, RP0

    ; Config Port A as Digital Outputs
    movlw   b'0110' ; Set as digital 
    movwf   ADCON1
    movlw   0       ; Set as output
    movwf   TRISA

    ; Config Port B as Output
    movlw   0
    movwf   TRISB

    ; Config Timer0
    bcf     OPTION_REG, T0CS
    bcf     OPTION_REG, PSA     ; Config prescaler (1:128)
    bsf     OPTION_REG, PS2
    bsf     OPTION_REG, PS1
    bcf     OPTION_REG, PS0

    ; Change to Bank 0
    bcf     STATUS, RP1
    bcf     STATUS, RP0

    ; Enable timer0 interrupt
    bsf     INTCON, TMR0IE
    bsf     INTCON, GIE

    ; Preload timer0
    movlw   timer_preload
    movwf   TMR0

    return

; Refresh Display Subroutine
refresh_display
test_1
    btfss   PORTA, 0
    goto    test_2
    goto    refresh_display_1

test_2
    btfss   PORTA, 3
    goto    test_3
    goto    refresh_display_2

test_3
    btfss   PORTA, 2
    goto    test_4
    goto    refresh_display_3

test_4
    btfss   PORTA, 1
    goto    end_test
    goto    refresh_display_4

end_test
    goto    refresh_display_1

refresh_display_1
    ; Turn display 1 on
    movlw   b'1000'
    movwf   PORTA
    
    ; H
    movlw   b'1110110'
    movwf   PORTB

    return

refresh_display_2
    ; Turn display 2 on
    movlw   b'0100'
    movwf   PORTA
    
    ; o
    movlw   b'1011100'
    movwf   PORTB
    return

refresh_display_3
    ; Turn display 3 on
    movlw   b'0010'
    movwf   PORTA
    
    ; L
    movlw   b'0111000'
    movwf   PORTB
    return

refresh_display_4
    ; Turn display 4 on
    movlw   b'0001'
    movwf   PORTA
    
    ; A
    movlw   b'1110111'
    movwf   PORTB
    return

; *** Main Routine ***
main
    call    refresh_display_config

loop
    goto    loop

	END ; directive 'end of program'

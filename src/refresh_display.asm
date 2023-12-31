; *** FILE DATA ***
;   Filename: refresh_display.asm
;   Date: June 21, 2023
;   Version: 3.0
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
char_0 		EQU b'0111111'
char_1 		EQU b'0000110'
char_2 		EQU b'1011011'
char_3 		EQU b'1001111'
char_4 		EQU b'1100110'
char_5 		EQU b'1101101'
char_6 		EQU b'1111101'
char_7 		EQU b'0000111'
char_8 		EQU b'1111111'
char_9 		EQU b'1101111'
char_A 		EQU b'1110111'
char_b 		EQU b'1111100'
char_c 		EQU b'1011000'
char_d 		EQU b'1011110'
char_E 		EQU b'1111001'
char_F 		EQU b'1110001'
char_G 		EQU b'0111101'
char_H 		EQU b'1110110'
char_I 		EQU b'0110000'
char_J 		EQU b'0001110'
char_L 		EQU b'0111000'
char_n 		EQU b'1010100'
char_enie   EQU b'1010101'
char_o      EQU b'1011100'
char_P      EQU b'1110011'
char_r      EQU b'1010000'
char_S      EQU b'1101101'
char_t      EQU b'1111000'
char_u      EQU b'0011100'
char_y      EQU b'1101110'
char_off    EQU b'0000000'

timer_preload   EQU d'60'   ; Preload for 10ms interrupt period on 1:128 prescaler


; *** Reset Config ***
    ; Processor reset vector
	ORG     0x000

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
    ; Interrupt vector location
	ORG     0x004

    ; Disable global interrupt
    bcf     INTCON, GIE

    ; Save context
    movwf   w_temp          ; copy W value to a temporary register
    swapf   STATUS, W       ; swap STATUS nibbles and save value to a temporary register
    movwf   status_temp
    swapf   PCLATH, W       ; swap PCLATH nibbles and save value to a temporary register
    movwf   pclath_temp

    ; Refresh display when TMR0 interupt flag is set
    btfsc   INTCON, TMR0IF      ; Skip when flag is clear
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
    movlw   b'0110' ; Set as Digital I/O
    movwf   ADCON1
    movlw   0       ; Set as Output
    movwf   TRISA

    ; Config Port B as Output
    movlw   0
    movwf   TRISB

    ; Config TMR0
    bcf     OPTION_REG, T0CS    ; Set TMR0 source to internal instruction cycle clock
    bcf     OPTION_REG, PSA     ; Set prescalet to TMR0
    bsf     OPTION_REG, PS2     ; Set prescaler to 1:128
    bsf     OPTION_REG, PS1
    bcf     OPTION_REG, PS0

    ; Change to Bank 0
    bcf     STATUS, RP1
    bcf     STATUS, RP0

    ; Enable TMR0 and global interrupt
    bsf     INTCON, TMR0IE
    bsf     INTCON, GIE

    ; Preload TMR0
    movlw   timer_preload
    movwf   TMR0

    return

; *** Refresh Display Subroutine ***
refresh_display
test_1
    btfss   PORTA, 0            ; Check if the display that is currently on is the 4th
    goto    test_2              ; If not, proceed to the next verification
    goto    refresh_display_1   ; If it is, the 1st display is refreshed

test_2
    btfss   PORTA, 3            ; Check if the display that is currently on is the 1st
    goto    test_3              ; If not, proceed to the next verification
    goto    refresh_display_2   ; If it is, the 2nd display is refreshed

test_3
    btfss   PORTA, 2            ; Check if the display that is currently on is the 2nd
    goto    test_4              ; If not, proceed to the next verification
    goto    refresh_display_3   ; If it is, the 3rd display is refreshed

test_4
    btfss   PORTA, 1            ; Check if the display that is currently on is the 3rd
    goto    end_test            ; If not, proceed to the end of the verification
    goto    refresh_display_4   ; If it is, the 4th display is refreshed

end_test
    goto    refresh_display_1   ; If none of the displays are on, the 1st display is refreshed

; *** Refresh 1st Display Subroutine ***
refresh_display_1
    ; Turn display 1 on
    movlw   b'1000'
    movwf   PORTA
    
    ; Display character "H"
    movlw   char_H
    movwf   PORTB

    goto    restart_timer

; *** Refresh 2nd Display Subroutine ***
refresh_display_2
    ; Turn display 2 on
    movlw   b'0100'
    movwf   PORTA
    
    ; Display character "o"
    movlw   char_o
    movwf   PORTB

    goto    restart_timer

; *** Refresh 3rd Display Subroutine ***
refresh_display_3
    ; Turn display 3 on
    movlw   b'0010'
    movwf   PORTA
    
    ; Display character "L"
    movlw   char_L
    movwf   PORTB

    goto    restart_timer

; *** Refresh 4th Display Subroutine ***
refresh_display_4
    ; Turn display 4 on
    movlw   b'0001'
    movwf   PORTA
    
    ; Display character "A"
    movlw   char_A
    movwf   PORTB
    
    goto    restart_timer

; *** Restart TMR0 after refreshing display ***
restart_timer
    bcf     INTCON, TMR0IF  ; Clear timer0 flag
    movlw   timer_preload   ; Set timer preload
    movwf   TMR0

    return                  ; Return to interruption

; *** Main Routine ***
main
    call    refresh_display_config

loop
    goto    loop

	END ; directive 'end of program'

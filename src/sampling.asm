; *** FILE DATA ***
;   Filename: sampling.asm
;   Date: June 17, 2023
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

; Sampling Subroutine Variables
analog_input_port   EQU PORTA
analog_input_0_bit  EQU 0       ; Bit 0 of port A is used for first analog input
analog_input_1_bit  EQU 1       ; Bit 1 of port A is used for second analog input
digital_input_0     EQU 0x20    ; First analog input converted to digital
digital_input_1     EQU 0x21    ; Second analog input converted to digital

select_input_port   EQU PORTC   ; Bit 0 of port C is used to select the analog input to be sampled
select_input_bit    EQU 0

sample_output_port  EQU PORTB   ; Port B is used to output the converted analog input

timer_preload       EQU d'61'   ; Preload for 10ms interrupt period on 1:128 prescaler


; *** Reset Config ***
	ORG     0x000   ; processor reset vector

	nop             ; nop required for icd
  	goto    main    ; go to beginning of program


; *** Interrupt Config ***
	ORG     0x004   ; interrupt vector location
    bsf     0x30, 0

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
    call    sampling_converter  ; Convert analog input if flag is set

    ; Restore context
    swapf   pclath_temp, W  ; swap original PCLATH value and restore from temporary register
    movwf   PCLATH
    swapf   status_temp, W  ; swap original STATUS value and restore from temporary register
    movwf   STATUS
    swapf   w_temp, F       ; restore original W value from temporary register
    swapf   w_temp, W

    ; Enable global interrupt
    bsf     INTCON, GIE
    bcf     0x30, 0

    ; Return from interrupt
	retfie


; *** Sampling Config Subroutine ***
sampling_config
    ; Change to Bank 1
    bcf     STATUS, RP1
    bsf     STATUS, RP0

    ; Config Analog Inputs
    bsf     analog_input_port, analog_input_0_bit   ; Set both as inputs
    bsf     analog_input_port, analog_input_1_bit
    bcf     ADCON1, PCFG1                           ; Set both as analog inputs
    bcf     ADCON1, PCFG0

    ; Config Select Input
    bsf     select_input_port, select_input_bit

    ; Config Output
    movlw   0
    movwf   sample_output_port

    ; Config Timer0
    bcf     OPTION_REG, T0CS
    bcf     OPTION_REG, PSA     ; Config prescaler (1:128)
    bsf     OPTION_REG, PS2
    bsf     OPTION_REG, PS1
    bcf     OPTION_REG, PS0

    ; Change to Bank 0
    bcf     STATUS, RP1
    bcf     STATUS, RP0

    ; Turn on A/D Converter
    bsf     ADCON0, ADON

    ; Enable timer0 interrupt
    bsf     INTCON, TMR0IE
    bsf     INTCON, GIE
    ; Preload timer0
    movlw   timer_preload
    movwf   TMR0

    return

; *** Sampling Analog to Digital Converter Subroutine ***
sampling_converter
    ; Save Converted Analog Input 0
    bcf     ADCON0, CHS2    ; Select Analog Input 0 to be converted
    bcf     ADCON0, CHS1
    bcf     ADCON0, CHS0
    bsf     ADCON0, GO      ; Start A/D conversion
wait_conversion_0
    btfsc   ADCON0, NOT_DONE    ; Skip when conversion is done
    goto    wait_conversion_0
    movf    ADRESH, W           ; Save conversion result
    movwf   digital_input_0

    ; Save Converted Analog Input 1
    bcf     ADCON0, CHS2    ; Select Analog Input 1 to be converted
    bcf     ADCON0, CHS1
    bsf     ADCON0, CHS0
    bsf     ADCON0, GO      ; Start A/D conversion
wait_conversion_1
    btfsc   ADCON0, NOT_DONE    ; Skip when conversion is done
    goto    wait_conversion_1
    movf    ADRESH, W           ; Save conversion result
    movwf   digital_input_1

    ; Restart timer0
    bcf     INTCON, TMR0IF  ; Clear timer0 flag
    movlw   timer_preload   ; Set timer preload
    movwf   TMR0

    return

; *** Sampling Sample Subroutine ***
sampling_sample
    btfss   select_input_port, select_input_bit ; Check if select is set, skip if it is
    goto    sampling_sample_input_0             ; Sample input 0 if is clear
    goto    sampling_sample_input_1             ; Sample input 1 if is set

; *** Sampling Sample Input 0 Subroutine ***
sampling_sample_input_0
    movf    digital_input_0, W
    movwf   sample_output_port
    return

; *** Sampling Sample Input 1 Subroutine ***
sampling_sample_input_1
    movf    digital_input_1, W
    movwf   sample_output_port
    return

; *** Main Routine ***
main
    call    sampling_config

loop
    call    sampling_sample
    goto    loop

	END ; directive 'end of program'

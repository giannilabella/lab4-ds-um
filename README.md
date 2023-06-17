# Digital Systems PIC assembly project
Implemented for PIC16F877A

## Tasks
- Implement "Led Trigger"
    - Bit 0 of port A is the trigger
    - Bit 1 of port A controls the LED
    - Turns on the LED for 5 seconds when triggered
    - A new trigger does not restart the 5-second timer
    - Must be implemented without interruptions
    - The microchip must be running at 10 MHz

- Implement "Sampling"
    - Inputs:
        - 2 analog inputs at AN0 and AN1
        - A digit input at the bit 0 of port C
    - Output:
        - The 8 bits of port B
    - At every 10 ms must sample at the output the converted value of one of the analog inputs
    - The sampled input is selected with the digital input
    - The microchip must be running at 10 MHz

- Implement "Refresh Display"
    - Output:
        - Bit 0 to bit 6 of port B (7 bits)
        - Bit 0 to bit 3 of port A (4 bits)
    - Must display different things at 4 7-segment display with the given output pins
    - Every 10 ms the display that is on must change, port A is used to select which it is
    - Port B bits are used to control the display segments, they are connected to all the displays at all times
    - The microchip must be running at 10 MHz

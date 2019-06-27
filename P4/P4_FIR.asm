;;;;;;; P2 for QwikFlash board ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Use this template for Part 2 of Experiment 2
;
;;;;;;; Program hierarchy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mainline
;   Initial
;
;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        list  P=PIC18F4520, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, R=DEC, X=ON
        #include <P18F4520.inc>
        __CONFIG  _CONFIG1H, _OSC_HS_1H  ;HS oscillator
        __CONFIG  _CONFIG2L, _PWRT_ON_2L & _BOREN_ON_2L & _BORV_2_2L  ;Reset
        __CONFIG  _CONFIG2H, _WDT_OFF_2H  ;Watchdog timer disabled
        __CONFIG  _CONFIG3H, _CCP2MX_PORTC_3H  ;CCP2 to RC1 (rather than to RB3)
        __CONFIG  _CONFIG4L, _LVP_OFF_4L & _XINST_OFF_4L  ;RB5 enabled for I/O
        errorlevel -314, -315          ;Ignore lfsr messages

;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cblock  0x000                  ;Beginning of Access RAM
        VAR_1                      ;Define variables as needed
		X0L 	; lower bit of first incoming signal
		X0H		; upper bit of first incoming sigmal
		X1L		; ''
		X1H		; ''
		X2L
		X2H
		X3L
		X3H
		SUML	; lower bits of summation
		SUMH	; upper bits of summation
		FINALSUM ; total 8 bits to be passed into DAC

        endc
;;;;;;; Macro definitions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MOVLF   macro  literal,dest
        movlw  literal
        movwf  dest
        endm

;;;;;;; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        org  0x0000                    ;Reset vector
        nop 
        goto  Mainline

        org  0x0008                    ;High priority interrupt vector
        goto  $                        ;Trap

        org  0x0018                    ;Low priority interrupt vector
        goto  $                        ;Trap

;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NOTE ---------------------------------------------
; Write your code for AD-DA here
; Create Subroutines to make code transparent and easier to debug
Mainline
        rcall  Initial                 ;Initialize everything		
		
L1
		MOVLF  B'00011111',ADCON0	   ; initialize ADCON0
ADWAIT
		btfsc ADCON0, 1		; check if AD == 0, skip the next line
		bra ADWAIT			; wait for Analog signal to finish reading

; MEMORY BUFFER (for 3rd degree averging filter)

		movff X2L, X3L		; shift X2 contents to X3 memory location
		movff X2H, X3H

		movff X1L, X2L		; shift X1 contents to X2 memory location
		movff X1H, X2H

		movff X0L, X1L		; shift X0 contents to X1 memory location
		movff X0H, X1H
		
		movff ADRESL, X0L	; fill X0 memory location with contents of ADRES
		movff ADRESH, X0H	; ADRES is filled by ADCON

; ADDER

		movff X0L, SUML		; SUM = contents of X0 
		movff X0H, SUMH

		movf SUML, W		; SUM += X1
		addwf X1L, W
		movwf SUML

		movf SUMH, W
		addwfc X1H, W
		movwf SUMH

		movf SUML, W		; SUM += X2
		addwf X2L, W
		movwf SUML

		movf SUMH, W
		addwfc X2H, W
		movwf SUMH

		movf SUML, W		; SUM += X3
		addwf X3L, W
		movwf SUML

		movf SUMH, W
		addwfc X3H, W
		movwf SUMH

; DIVIDER

		movf SUML, W		; Working Register = SUML
		andlw B'11110000'	; LOGIC AND performed between literal value and Working Register
		movwf SUML			; SUML = Working Register
		swapf SUML,F		; swap upper 4 bits with lower 4 bits of SUML


		movf SUMH, W		; Working Register = SUMH
		andlw B'00001111'	; LOGIC AND performed between literal value and Working Register
		movwf SUMH 			; SUMH = Working Register
		swapf SUMH,F		; swap lower 4 bits with upper 4 bits of SUMH

		movf SUML, W		
		addwf SUMH, W 
		movwf FINALSUM 		; FINALSUM contains the 8 bits that needs to be passed into the DAC

		bcf PORTC, RC0	
		bcf PIR1, SSPIF
		MOVLF 0x21,SSPBUF   ; move channel 1 to SSPBUF
WAIT
		btfss PIR1,SSPIF	; check if SSPIF == 1 
		bra WAIT			; WAIT IF SSPIF == 1
		bcf PIR1, SSPIF

		movff FINALSUM, SSPBUF	; put FINALSUM into SSBUF

WAIT2
		btfss PIR1,SSPIF	; check if SSPIF == 1 
		bra WAIT2			; WAIT IF SSPIF == 1
		bsf PORTC, RC0
 
        bra	L1


;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This subroutine performs all initializations of variables and registers.

Initial
        MOVLF  B'10001110',ADCON1      ;Enable PORTA & PORTE digital I/O pins
		MOVLF  B'10000000',ADCON2	   ;Right Justification
        MOVLF  B'11100001',TRISA       ;Set I/O for PORTA
        MOVLF  B'11011100',TRISB       ;Set I/O for PORTB
        MOVLF  B'11010000',TRISC       ;Set I/0 for PORTC
        MOVLF  B'00001111',TRISD       ;Set I/O for PORTD
        MOVLF  B'00000100',TRISE       ;Set I/O for PORTE
        MOVLF  B'10001000',T0CON       ;Set up Timer0 for a looptime of 10 ms
        MOVLF  B'00010000',PORTA       ;Turn off all four LEDs driven from PORTA
		MOVLF  B'00100000',SSPCON1	   ; Iniitialize SSPCON1
		MOVLF  B'11000000',SSPSTAT	   ; initialize SSPSTATE

		MOVLF  B'00000000', X0L
		MOVLF  B'00000000', X0H
		MOVLF  B'00000000', X1L
		MOVLF  B'00000000', X1H
		MOVLF  B'00000000', X2L
		MOVLF  B'00000000', X2H
		MOVLF  B'00000000', X3L
		MOVLF  B'00000000', X3H
		MOVLF  B'00000000', SUML
		MOVLF  B'00000000', SUMH
		MOVLF  B'00000000', FINALSUM


        return

        end


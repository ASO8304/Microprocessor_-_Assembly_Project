/*
 * OptionalProject.asm
 *
 *  Created: 12/12/2024 6:16:36 PM
 *   Author: Abolfazl
 */ 
; .include 'M64DEF.INC'
.ORG 0x0000 
	JMP INITIAL

.ORG 0x000C
	JMP EXT_INT5

.ORG 0x0020
	JMP TIM0_OVF


INITIAL: 
	LDI R20,low(RAMEND)	;Define Stack Pointer
    OUT SPL,R20

	LDI R20,high(RAMEND)
    OUT SPH,R20         ;SP=0x10FF
 
	LDI R20,0x20        ;0010 0000  --> Accept Interrupt(5) 
	OUT EIMSK,R20		;Set External Interrupt Mask Register 

	LDI R20,0x06        ;0000 1100  --> ISC5 = 11 --> interrupt(5) trigger by rising edge
	OUT EICRB,R20		;Set External Interrupt Control Register B for Interrupt(5) 
	
	LDI R20,0x00		
	OUT DDRD,R20		;Define PortD as input --> Player1 Input
	OUT DDRA,R20		;Define PortA as input --> Player2 Input

	LDI R20,0x0F		;Define PortC as output --> LEDs : PORTC.0 = White, PORTC.1 = Green , PortC.2 = Yellow , PortC.3 = Red
	OUT DDRC,R20

	LDI R20,0x0FF
	OUT DDRB,R20

	LDI R20,0x0F		;Turn off all of the lights 
	OUT PortC,R20

	LDI R20,0x07		;CS0 --> 111 
	OUT TCCR0,R20		;CLK/1024


	SEI		 	;Set Interrupt bit in SREG to accept interrupts


WAIT_FOR_START:			;loop to wait for INT5 to start the game
	JMP WAIT_FOR_START


;List of Used registers :
;		R16: Store PlayerB guess 
;		R17: Store PlayerA input 
;		R18: Counter from 10 to 0 for chances
;		R19: Used in timer to count 1 seconds. Every 4 interrupts from Timer equals to 1 second
;		R20: variant and is used as temporary register
;		R21: Store the number of seconds past



;-----------------------------Interrupt 5 code started------------------------------------------
EXT_INT5:
	SEI
	IN R17,PIND			;Store playerA input value into R17 ( target_value )
	
	LDI R18,10 

LOOP_10_CHANCE:
	OUT PORTB,R18
	CPI R18,0
	BREQ LOST_GAME 
	DEC R18

	LDI R20,0x0E			;Turn on white light --> portC.0 = 0 | PortC = 0000 1110
	OUT PortC,R20

	;*******************
	;5 seconds wait time 
	CLR R19
	CLR R21

	LDI R20,6			;256 - 250 = 6
	OUT TCNT0, R20      ;Count from 6
	 
	LDI R20,0x01			
	OUT TIMSK, R20      ;Enable to Timer Interrupt
WAIT_5_loop1:
	CPI R21,5
	BRNE WAIT_5_loop1
	LDI R20,0x00			
    	OUT TIMSK, R20      ;Disable to Timer Interrupt
	CLR R19
	CLR R21				;reset seconds
	;******** **********

	
	IN R16,PINA			;Store PlayerB input value into R16
	
	CP R17,R16 
	BREQ CORRECT_GUESS		;If (input_by_playerB == targer_value) --> jmp CORRECT 
	BRLO TARGET_IS_LOWER	;If (input_by_playerB > terget_value) --> jmp TARGET_IS_LOWER

	

TARGET_IS_HIGHER:
	LDI R20,0x07			;Turn on Red light --> portC.3 = 0 | PortC = 0000 0111
	OUT PortC,R20

	;******************** 
	;1 second wait time
	CLR R19
	CLR R21

	LDI R20,6			;256 - 250 = 6
	OUT TCNT0, R20      ;Count from 6

	LDI R20,0x01			
        OUT TIMSK, R20      ;Enable to Timer Interrupt
WAIT_1_loop1:
	CPI R21,1
	BRNE WAIT_1_loop1
	LDI R20,0x00			
   	OUT TIMSK, R20      ;Disable to Timer Interrupt
	CLR R19
	CLR R21				;reset seconds
	;********************

	LDI R20,0x0F			;Turn off Red light after 1 second --> portC.3 = 0 | PortC = 0000 1111
	OUT PortC,R20

	JMP LOOP_10_CHANCE



LOST_GAME:
	LDI R20,0x00			;Turn on all the lights --> PortC = 0000 0000
	OUT PortC,R20

	//
	;Implement 5 seconds wait time 
	CLR R19
	CLR R21

	LDI R20,6					;256 - 250 = 6
	OUT TCNT0, R20      		;Count from 6

	LDI R20,0x01				
	OUT TIMSK, R20      		;Enable to Timer Interrupt

WAIT_5_loop3:
	CPI R21,5
	BRNE WAIT_5_loop3
	LDI R20,0x00			
    OUT TIMSK, R20      		;Disable to Timer Interrupt
	CLR R19
	CLR R21						;reset seconds
	;
	//

	LDI R20,0x0F			;Turn off lights after 5 seconds -->  PortC = 0000 1111
	OUT PortC,R20

GAME_FINISHED:	
	RETI



TARGET_IS_LOWER:
	LDI R20,0x0B			;Turn on Yellow light --> portC.2 = 0 | PortC = 0000 1011
	OUT PortC,R20

	;***********************
	;1 second wait time 
	CLR R19
	CLR R21

	LDI R20,6			;256 - 250 = 6
	OUT TCNT0, R20      		;Count from 6

	LDI R20,0x01			
	OUT TIMSK, R20      		;Enable to Timer Interrupt
WAIT_1_loop2:
	CPI R21,1
	BRNE WAIT_1_loop2
	LDI R20,0x00			
	OUT TIMSK, R20      		;Disable to Timer Interrupt
	CLR R19
	CLR R21				;reset seconds
	;*************************


	LDI R20,0x0F			;Turn off Yellow light after 1 second --> portC.1 = 0 | PortC = 0000 1111
	OUT PortC,R20

	JMP LOOP_10_CHANCE




CORRECT_GUESS:
	LDI R20,0x0D			;Turn on Green light --> portC.1 = 0 | PortC = 0000 1101
	OUT PortC,R20

	;*************************
	;5 seconds wait time 
	CLR R19
	CLR R21

	LDI R20,6			;256 - 250 = 6
	OUT TCNT0, R20      ;Count from 6

	LDI R20,0x01			
    	OUT TIMSK, R20      ;Enable to Timer Interrupt
WAIT_5_loop2:
	CPI R21,5
	BRNE WAIT_5_loop2
	LDI R20,0x00			
    	OUT TIMSK, R20      ;Disable to Timer Interrupt
	CLR R19
	CLR R21				;reset seconds
	;**************************


	LDI R20,0x0F			;Turn off Green light after 5 seconds -->  PortC = 0000 1111
	OUT PortC,R20

	RETI

;-----------------------------Interrupt 5 code ended------------------------------------------





;calculations
;F.timer = F.cpu / 1024           F = Frequency
;F.timer = 1.024MHz / 1024 = 1KHz

;T.timer = 1 / F.timer 
;T.timer = 1 / 1KHz = 1 ms

;Count_number = target_time / each_increment_time
;Count_number = 1 / 1 ms = 1000 

;1000 = 4 * 250 ----> count_number = 250 
;counter_number = 256 - 250 = 6 

;Every 4 timer.interupts equals to one second. ( or each timer.interrupt = 1/4 second)
TIM0_OVF:
	LDI R20,6			;256 - 250 = 6
	OUT TCNT0, R20      ;Count from 6 

	CPI R19,4
	BRNE NOT_A_SEC		;if (R19 < 4) --> JMP NOT_A_SEC   else if (R19 == 4) --> CLR R19 and count one second
	CLR R19
	INC R21				;Count 1 second
	JMP END_TIMER
NOT_A_SEC:
	INC R19
END_TIMER:
	RETI


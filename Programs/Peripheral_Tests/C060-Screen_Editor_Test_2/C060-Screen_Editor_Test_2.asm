hello:	.string "R32V2020> "
screenPtr:	.long 0x0
currCharLocPtr:	.long 0x0

;
; Read UART character and put it to the XVGA Display
;

main:
	lix		r8,0x0			; set screen position to home
	bsr		setCharPos
	bsr		clearScreen
readDataMemory:
	lix		r8,hello.lower
	bsr		printString
readUartStatus:
	bsr		waitGetCharFromUART
putCharToScreenAndUART:
	bsr		putCharToScreen	; put the character to the screen
	lix		r9,0x0d
	cmp		r8,r9
	bne		putOutChar
	push	r8
	lix		r8,0x0a
	bsr		putCharToUART
	pull	r8
putOutChar:
	bsr		putCharToUART
	bra		readUartStatus

;
; waitGetCharFromUART
; returns character received in r8
; function is blocking until a character is received from the UART
;

waitGetCharFromUART:
	push	PAR
	lix		PAR,0x1800	; UART Status
waitUartRxStat:
	lpl		r8			; Read Status into r8
	and 	r8,r8,ONE
	bez 	waitUartRxStat
	lix 	PAR,0x1801
	lpl		r8
	pull	PAR
	pull	PC

;
; putCharToUART - Put a character to the UART
; passed character in r8 is sent out the UART
;

putCharToUART:
	push	r9
	push	PAR
	push	r10
	lix		r10,0x2
	lix		PAR,0x1800	; UART Status
waitUartTxStat:
	lpl		r9			; Read Status into r9
	and 	r9,r9,r10
	bez 	waitUartTxStat
	lix 	PAR,0x1801
	spl		r8			; echo the character
	pull	r10
	pull	PAR
	pull	r9
	pull	PC
	
;
; printString - Print a screen to the current screen position
; pass value : r8 points to the start of the string in Data memory
; strings are bytes packed into long words
; strings are null terminated
;

printString:
	push	r8				; save r8
	push	DAR
	add		DAR,r8,ZERO		; set the start of the string
nextChar:
	ldb		r8				; get the character
	cmp		r8,ZERO			; Null terminated string
	beq		donePrStr		; done if null
	bsr		putCharToANSIScreen	; write out the character
	add		DAR,DAR,r1		; Point to next character
	bra		nextChar
donePrStr:
	pull	DAR				; restore DAR
	pull	r8				; restore r8
	pull	PC				; rts

;
; clearScreen - Clear the screen routine
; Fills the screen with space characters
; Screen is memory mapped
; Screen is 64 columns by 32 rows = 2KB total space
; Return address (-1) is on the stack - need to increment before return
; Sets the pointer to the screen to the first location
;

clearScreen:
	push	r9				; save r9
	push	r8				; save r8
	lix		r8,0x0020		; fill with spaces
	lix 	r9,0x7FE		; loopCount	(1K minus 1)
looper:
	bsr		putCharToScreen
	add 	r9,r9,MINUS1	; decrement character counter
	bne		looper			; loop until complete
	lix		r8,0x0			; Move cursor to home position
	bsr		setCharPos
	pull	r8
	pull	r9
	pull	PC				; rts

;
; putCharToScreen - Put a character to the screen and increment the address
; Character to put to screen is in r8
; Return address (-1) is on the stack - need to increment before return
;

putCharToScreen:
	push	r11					; save r11
	push	r10					; save r10
	push	r9					; save r9
	push	DAR
	push	PAR
	lix		r9,screenPtr.lower	; r9 is the ptr to screenPtr
	add		DAR,r9,ZERO			; DAR points to screenPtr
	ldl		r10					; r10 has screenPtr value
; look for specific characters
	lix		r11,0x7F			; RUBOUT key
	cmp		r8,r11
	beq		gotBS
	lix		r11,0xe0			; 0x0-0x1f are ctrl chars
	and		r11,r11,r8
	bnz		notCtlChar
; Check for CR	
	lix		r11,0x0d			; CR
	cmp		r8,r11
	beq		gotCR
; Check for BELL
	lix		r11,0x07			; BELL
	cmp		r8,r11
	bne		skipPrintChar
	bsr		makeBuzz
; Goes here
	bra		skipPrintChar
gotBS:
	add		r10,r10,MINUS1
	add		PAR,r10,ZERO
	lix		r8,0x20
	spb		r8
	bra		skipPrintChar
gotCR:
	lix		r11,0xffc0			; Go to the start of the line
	and		r10,r10,r11
	lix		r11,0x40			; Go down a line
	add		r10,r10,r11
	add		PAR,r10,ONE			; Set PAR to screenPtr
	bra		skipPrintChar
notCtlChar:
	add		PAR,r10,ZERO		; Set PAR to screenPtr
	spb		r8					; write character to screen
	add		r10,r10,ONE			; increment screen pointer
skipPrintChar:
	sdl		r10					; save new pointer
	pull 	PAR					; restore PAR
	pull 	DAR					; restore DAR
	pull 	r9					; restore r9
	pull 	r10					; restore r10
	pull 	r11					; restore r11
	pull	PC					; rts

;
; setCharPos - Move to x,y position
; x,y value is passed in r8
;	First 6 least significant bits (0-63 columns)
; 	Next 5 bits (row on the screen)
; currCharLocPtr has the base address of the screen memory
; screenPtr contains the address of the current char position
;

setCharPos:
	push	r9						; save r9
	push	r10						; save r10
	push	DAR						; save DAR
	lix		r10,currCharLocPtr.lower
	add		DAR,r10,ZERO			; DAR points to the currCharLocPtr
	ldl		r10						; r10 has the screen base address
	add		r10,r8,ZERO				; add passed position to base
	lix		r9,screenPtr.lower		; r9 is the ptr to screenPtr
	add		DAR,r9,ZERO				; DAR points to screenPtr
	sdl		r10						; store new screen address
	pull	DAR						; restore DAR
	pull	r10						; restore r10
	pull	r9						; restore r9
	pull	PC						; rts

makeBuzz:
	push	r8
	lix		r8,0			; first note is 0
	bsr 	setNote
	bsr		enableBuzzer
	lix		r8,250			; count for 1 Sec
	bsr		delay_mS		; call delay_ms
	bsr		disableBuzzer
	pull	r8
	pull	PC

;
; setNote - Set the note
; pass note in r8
;

setNote:
	push	r8
	push	PAR
	lix		PAR,0x4000
	spl		r8
	pull	PAR
	pull	r8
	pull	PC

;
; enableBuzzer
;

enableBuzzer:
	push	r9
	push	r8
	push	PAR
	lix		r9,0x0010		; Buzzer Enable line
	lix		PAR,0x2800
	lpl		r8
	or		r8,r8,r9
	spl		r8
	pull	PAR
	pull	r8
	pull	r9
	pull	PC

;
; disableBuzzer
;

disableBuzzer:
	push	r9
	push	r8
	push	PAR
	lix		r9,0xffef		; Buzzer Disable line
	lix		PAR,0x2800
	lpl		r8
	and		r8,r8,r9
	spl		r8
	pull	PAR
	pull	r8
	pull	r9
	pull	PC
	
;
; putCharToANSIScreen - Put a character to the screen
; Character to put to screen is in r8
;

putCharToANSIScreen:
	push	r9
	push	PAR
	push	r10
	lix		r10,0x2		; TxReady bit
	lix		PAR,0x0		; UART Status
waitScreenTxStat:
	lpl		r9			; Read Status into r9
	and 	r9,r9,r10
	bez 	waitScreenTxStat
	lix 	PAR,0x1
	spl		r8			; echo the character
	pull	r10
	pull	PAR
	pull	r9
	pull	PC
	
; delay_mS - delay for the number of mSecs passed in r8
; pass mSec delay in r8
; Uses routine uses r9

delay_mS:
	push	r9
	lix		PAR,0x3802		; address of the mSec counter
	lpl		r9				; read the peripheral counter into r9
	add		r8,r9,r8		; terminal counter to wait until is in r8
loop_delay_mS:
	lpl		r9				; check the elapsed time counter
	cmp		r8,r9
	blt		loop_delay_mS
	pull	r9
	pull	PC

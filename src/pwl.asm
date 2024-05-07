; ***************************************************
; * Автор:		Alexpot	                            *
; * Версия:		1.0                                 *
; * Дата        27 иня 2011                         *
; * Device:     PIC12F675                           *
; ***************************************************

;    #include    p12f675.inc
;    #include    pwl_10_16.inc
;    __CONFIG    _CPD_OFF & _CP_OFF & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
 ;   ERRORLEVEL -302
;
;	cblock 0x20	 
;	Input		; 
;	Output		; 
;	Index		; 
;	SlopeLo		;16 bit
;	SlopeHi		; 
;	OffsetLo	;16 bit
;	OffsetHi	; 
;	endc		
;
; ******************************************************************

;	org	0
;	movlw	high Segment	; Point PCLATH to the beginning of the lookup table
;	movwf	PCLATH	
;main
;
;	movlw	.15
;	movwf	Input		; Очищаем входные данные
;		
;test
;	call	PwLI		; Время выполнения от 59 до 81 такта, размер 68 байт без таблицы.
;	movf 	Output,w	; 
;	goto	main		; 



PwLI							
; Подпрограмма интерполяции
; Если разница между точками будет не больше 15 подпрограму можно уменьшить
; Input - Входные данные от 0 до 255, 1 байт 
; Output - Выходные данные от 0 до 255, 1 байт
; Span = Input AND 0x0F
; Index = Input / 16
; Slope = Segment[Index+1] – Segment[Index]
; Offset = (Slope * Span) / 16
; Output = Segment[Index] + Offset 

	swapf	Input,w		; Находим Index=Input/16 
	andlw	0x0F		;
	movwf	Index		; Находим значение Segment для Index+1
	addlw	.1			;
	call	Segment		; 
	movwf	SlopeLo		;  
	movf	Index,w		;
	call	Segment		; Находим значение Segment для Index
	movwf	Output		;   
	subwf	SlopeLo,f	; Находим значение Slope равноее разнеце Output и Slope	 
	btfsc	STATUS,C	; по модулю.
	goto	_pwli01		;
	bsf		Index,7		;
	comf	SlopeLo,f	; 
	incf	SlopeLo,f	;
_pwli01 
	clrf	OffsetLo	; Умнажаем Span на Slope результат
	clrf	OffsetHi	; в Offset 
	clrf	SlopeHi		;
	btfss	Input,0		; 
	goto	_pwli02		;
	movf	SlopeLo,w	;
	addwf	OffsetLo,f	;
	btfsc	STATUS,C	;
	incf	OffsetHi,f	;
	movf	SlopeHi,w	;
	addwf	OffsetHi,f	;	
_pwli02 
	bcf		STATUS,C	; 
	rlf		SlopeLo,f	;
	rlf		SlopeHi,f	; 
	btfss	Input,1		; 
	goto	_pwli03		;
	movf	SlopeLo,w	;
	addwf	OffsetLo,f	; 
	btfsc	STATUS,C	;
	incf	OffsetHi,f	;
	movf	SlopeHi,w	;
	addwf	OffsetHi,f	;	
_pwli03
	rlf		SlopeLo,f	;
	rlf		SlopeHi,f	; 
	btfss	Input,2		; 
	goto	_pwli04		;
	movf	SlopeLo,w	;
	addwf	OffsetLo,f	; 
	btfsc	STATUS,C	;
	incf	OffsetHi,f	;
	movf	SlopeHi,w	;
	addwf	OffsetHi,f	;	
_pwli04
	rlf		SlopeLo,f	;
	rlf		SlopeHi,f	; 
	btfss	Input,3		; 
	goto	_pwli05		;
	movf	SlopeLo,w	;
	addwf	OffsetLo,f	;
	btfsc	STATUS,C	;
	incf	OffsetHi,f	;
	movf	SlopeHi,w	;
	addwf	OffsetHi,f	;	
_pwli05
	swapf	OffsetLo,w	; Делим Offset на 16
	andlw	0x0F		; результат в Offset
	movwf	OffsetLo	;
	swapf	OffsetHi,w	;
	andlw	0xF0		;
	iorwf	OffsetLo,w	;
	btfss	Index,7		;  
	addwf	Output,f	; Сумируем Offset и Output результат в Output
	btfsc	Index,7		;
	subwf	Output,f	;
	return				; Конец подпрограммы интерполяции

Segment ORG 700
   addwf   PCL,F   ; Jump into lookup table to look up segment endpoints (Segment_EP) value
    retlw   0	;0
    retlw   5	;16
    retlw   10	;32
    retlw   15	;48
    retlw   20	;64
    retlw   25	;80
    retlw   30	;96
    retlw   35	;112
    retlw   40	;128
    retlw   45	;144
    retlw   50	;160
    retlw   55	;176
    retlw   60	;192
    retlw   65	;208
    retlw   70	;224
    retlw   75	;240
    retlw   80	;256

	
;	end			; End of file delimiter



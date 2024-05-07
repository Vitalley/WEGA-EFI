;	list      p=16f628A           ; list directive to define processor
;	#include <p16F628A.inc>       ; processor specific variable definitions
;	errorlevel  -302              ; suppress message 302 from list file

;-------------------------------------------------------------------------------------------------------------
;П/п перемножения 16х8. Операнды находятся в Mul1Lo,Mul1Hi и MULc
;Результат помещается в Mul1Lo, Mul1Hi, ResHi.
;Продолжительность до 200 циклов.
#define	Tmp2	Flag_Math,1
MUL16_8 
	clrf Temp6
	clrf Temp7
	clrf Temp8
	clrf Temp9
	clrf ResHi
	movlw 8
	movwf Cnt
Ml_3
	rrf MULc,1
	btfss STATUS,C
	goto Ml_5
	movf Mul1Lo,0
	addwf Temp7,1
	btfss  STATUS,C
	goto Ml_1
	incfsz Temp8,1
	goto Ml_1
	incf ResHi,1
	
Ml_1
	movf Mul1Hi,0
	addwf Temp8,1
	btfss  STATUS,C
	goto Ml_2
	incf ResHi,1
	
Ml_2	movf Temp6,0
	addwf ResHi,1
Ml_5
	decfsz Cnt,1
	goto Ml_4
	goto Fin_Mul

Ml_4	bcf STATUS,C
	rlf Mul1Lo,1
	rlf Mul1Hi,1
	rlf Temp6,1
	goto Ml_3	
Fin_Mul
	movf Temp7,0
	movwf Mul1Lo
	movf Temp8,0
	movwf Mul1Hi
	return




Sub_
	bcf Tmp2
	movf DivLo,0		
	Subwf Temp6,1		
	btfsc STATUS,C		
	goto Subnd		
	decf Temp8,1		
	movlw 0xff		
	Subwf Temp8,0		
	btfss STATUS,Z		
	goto Subnd		
	decf Temp9,1		
	movlw 0xff		
	Subwf Temp9,0		
	btfsc STATUS,Z		
	bsf Tmp2			


Subnd
	movf DivHi,0
	Subwf Temp8,1
	btfsc STATUS,C
	return
	decf Temp9,1
	movlw 0xff
	Subwf Temp9,0
	btfsc STATUS,Z
	bsf Tmp2
	return

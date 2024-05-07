;	list      p=16f628A           ; list directive to define processor
;	#include <p16F628A.inc>       ; processor specific variable definitions
;	errorlevel  -302              ; suppress message 302 from list file

;------------------------------------------------------------------------------------------------
;П/п деления Mul2Lo, Mul2Hi, Res2Hi на DivLo, DivHi. Результат помещается в Mul2Lo, Mul2Hi.
;!!! Mul2Lo, Mul2Hi, Res2Hi и Res1,Res2,Res3 должны быть в ОЗУ друг за другом
;udata_ovr 
;Temp 1
;Temp2 1
;Temp3 1
;Cnt2 1
#define	Tmp	Flag_Math,0
Div24_16
	clrf Temp
	clrf Temp2
	clrf Temp3
	clrf Cnt2
	clrf Res1
	clrf Res2
	clrf Res3


	movlw 0xf0
	andwf DivHi,0
	btfsc STATUS,Z
	goto chknxt
	
	movf Res2Hi,0
	movwf Temp2
	movf Mul2Hi,0
	movwf Temp
	movlw .2
	movwf CntDiv
	goto StartDiv	
	
	
chknxt
	movf DivHi,1
	btfsc STATUS,Z
	goto chknxt1
	movlw 0xf0
	andwf Res2Hi,0
	movwf Temp2
	swapf Temp2,1
	
	movlw 0x0f
	andwf Res2Hi,0
	movwf Temp
	swapf Temp,1

	movlw 0xf0
	andwf Mul2Hi,0
	movwf Temp3
	swapf Temp3,0
	iorwf Temp,1
	clrf Temp3
	movlw .3
	movwf CntDiv
	goto StartDiv
chknxt1

	movlw 0xf0
	andwf DivLo,0
	btfsc STATUS,Z
	goto chknxt2

	movf Res2Hi,0
	movwf Temp
	movlw .4
	movwf CntDiv
	goto StartDiv
chknxt2
	movlw 0xf0
	andwf Res2Hi,0
	movwf Temp
	swapf Temp,1
	movlw .5
	movwf CntDiv

StartDiv


sbagn	CLRWDT
	call Sub
	btfsc Tmp
	goto FinSub
	incf Cnt2,1
	goto sbagn




FinSub
	movf DivLo,0
	addwf Temp,1	
	btfss STATUS,C
	goto add2nd
	incfsz Temp2,1
	goto add2nd
	incf Temp3,1
	
add2nd
	movf DivHi,0	
	addwf Temp2,1
	btfss STATUS,C	
	goto jpqm
	incf Temp3,1
jpqm
	bcf STATUS,C
	rrf CntDiv,0
	movwf FSR
	movlw Res1
	addwf FSR,1
	btfss CntDiv,0
	goto nnhjuq
	swapf Cnt2,0
	iorwf INDF,1
	goto ffr
nnhjuq
	movf Cnt2,0
	iorwf INDF,1
ffr
	decf CntDiv,1
	movlw 0xff
	subwf CntDiv,0
	btfss STATUS,Z

	goto notFin
	goto FinDiv
notFin	
	bcf STATUS,C
	rlf Temp,1
	rlf Temp2,1
	rlf Temp3,1
	bcf STATUS,C	
	rlf Temp,1
	rlf Temp2,1
	rlf Temp3,1
	bcf STATUS,C	
	rlf Temp,1
	rlf Temp2,1
	rlf Temp3,1
	bcf STATUS,C	
	rlf Temp,1
	rlf Temp2,1
	rlf Temp3,1

	bcf STATUS,C
	rrf CntDiv,0
	movwf FSR
	movlw Mul2Lo
	addwf FSR,1
	btfsc CntDiv,0
	goto nnhq
	movlw 0x0f
	andwf INDF,0
	iorwf Temp,1
	goto jjddsak
nnhq
	swapf INDF,0
	andlw 0x0f
	iorwf Temp,1
jjddsak
	clrf Cnt2
	goto sbagn	
FinDiv
	bcf STATUS,C		;Округление
	rrf DivHi,1
	rrf DivLo,1
	movf DivHi,0
	subwf Temp2,0
	btfss STATUS,C
	goto dsgfadsg
	btfss STATUS,Z
	goto cxv
	movf DivLo,0
	subwf Temp,0
	btfss STATUS,C	
	goto dsgfadsg
cxv
	incfsz Res1,1
	goto dsgfadsg
	incfsz Res2,1
	goto dsgfadsg
	incf Res3,1
dsgfadsg
	movf Res1,0
	movwf Mul2Lo
	movf Res2,0
	movwf Mul2Hi
	movf Res3,0
	movwf Res2Hi
	return
Sub
	bcf Tmp
	movf DivLo,0		
	subwf Temp,1		
	btfsc STATUS,C		
	goto sub2nd		
	decf Temp2,1		
	movlw 0xff		
	subwf Temp2,0		
	btfss STATUS,Z		
	goto sub2nd		
	decf Temp3,1		
	movlw 0xff		
	subwf Temp3,0		
	btfsc STATUS,Z		
	bsf Tmp			
sub2nd
	movf DivHi,0
	subwf Temp2,1
	btfsc STATUS,C
	return
	decf Temp3,1
	movlw 0xff
	subwf Temp3,0
	btfsc STATUS,Z
	bsf Tmp
	return

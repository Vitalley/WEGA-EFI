	list      p=16f876a          ; list directive to define processor
	#include <p16F876a.inc>       ; processor specific variable definitions
	errorlevel  -302              ; suppress message 302 from list file
	#include macro.asm
	#define first_address 1fffh-.100+.1 ; 100 word in size
;***********************************************************************************
IFDEF __DEBUG
	__config _CP_OFF & _BODEN_ON & _LVP_OFF & _PWRTE_ON & _WDT_OFF & _HS_OSC
ELSEIF
	__config _CP_OFF & _BODEN_ON & _LVP_OFF & _PWRTE_ON & _WDT_ON & _HS_OSC
ENDIF
;************************************************************************************
#include Variable.asm		; ������� ������������� ��������� ������ ��� ��������
#include Config.inc		; �������� ���������� ������������


GO_BOOT	ORG	0		; processor reset vector
;	PAGESEL 	Bootloader
;	GOTO    	Bootloader
;	nop
GO_INIT	GOTO	INIT		; go to beginning of program
;------------------------------------------------------------------
;		��������� ����������
;{------------------------------------------------------------------
	ORG	4		; ������ ����������
	MOVWF 	W_TEMP		; ���������� W �� ��������� ������� ���������� �� �������� �����
	SWAPF 	STATUS,W		; �������� ��������� � �������� STATUS � �������� � W		
	CLRF 	STATUS
	MOVWF 	STATUS_TEMP		; ��������� STATUS �� ��������� �������� ����� 0
	MOVF 	PCLATH, W 		;
	MOVWF 	PCLATH_TEMP		;
	CLRF 	PCLATH 		;
	BTFSC	PIR1,CCP1IF		; ������ ���������
	GOTO	COMP_EVNT
	BTFSC	INTCON,INTF		; ������� ���������?
	GOTO	SPARK
	BTFSC	PIR1,TMR1IF		; �������� ������������ ������� ���1
	GOTO	TMR_OF
 	BTFSC 	PIR1,ADIF		; ���������� ���
	GOTO 	Int_AD
	BTFSC	INTCON,T0IF		; ����� ������������� �� ���0
	GOTO	TMR_EV		
   	BTFSC 	PIR1,RCIF    	; ���� ����� USART Rx?
	GOTO 	Int_RX


;------------------------ INT exit-----------------------
RET 	MOVF	PCLATH_TEMP, W 	;
	MOVWF	PCLATH 		;
	SWAPF	STATUS_TEMP,W 	;�������� ��������� ������������� �������� STATUS � �������� � W (������������ ������� ����)
	MOVWF	STATUS		;������������ �������� STATUS �� �������� W
	SWAPF	W_TEMP,F		;�������� ��������� � �������� W_TEMP � ��������� ��������� � W_TEMP
	SWAPF	W_TEMP,W		;�������� ��������� � �������� W_TEMP � ������������ ������������ �������� W ��� ����������� �� STATUS
	RETFIE
;}

;------------------------------------------------------------------
;		�������������
;{------------------------------------------------------------------
 INIT	CLRF	ERR
	CLRF	STAT
	CLRF	eSTAT
	bank1
	let	TRISA,b'00111111'
	let	TRISB,b'00000001'
	let	TRISC,b'10000000'
	let	OPTION_REG,b'11000111'	; ������������� ��������� ��������(������������ �� tmr0)
	let	PIE1,B'01100101' 	; �������� ����� ���������� � ������� PIE1
; ��������� ����
	MOVLW	.103       		; ���������� �������� ������ �������(F=9615 Hz)
	MOVWF	SPBRG
	MOVLW	B'00100110'  	; �������� 8 - ��������� ������, �������� ����������,
 	MOVWF	TXSTA		; ���������������� ����������� �����
	let	ADCON1,b'00000010'	;
; ����������� ���� ������ �����������
	BTFSS	PCON,NOT_POR
	GOTO	SETPOR
	BTFSS	PCON,NOT_BOR	; BOR - ���� ������ �� �������� ����������
	CALL	ERR_BOR
SETPOR	BSF	PCON,NOT_POR
	BSF	PCON,NOT_BOR
	bank0
; ����� ����������������� ��� ���� �������� ����������� ��
	let	ADCON0,ADC_COLT	;
	CLRF	TMR0
	CLRF	TMR1L
	CLRF	TMR1H
; ����������� ���� ������ �����������
	BTFSS	STATUS,NOT_TO	; TO - WDT - ���� ���������!!!
	BSF	ERR,0
	CLRF	PORTC
	CLRF 	PORTB
	let	T1CON,B'00110000'	; ������������� ���1, ������������ 1:8 (��� - 2���, ���� �� 128��)
	CLRF	CCP1CON		; ������������� CCP1
  	MOVLW	B'10010000'  	; ����� 8 - ��������� ������, �������� ��������,
   	MOVWF	RCSTA       	; �������� ������ USART 
;------------------------------------------------------------------
;		��������� ����������
;------------------------------------------------------------------   
	CLRWDT 
	BSF	PUMP		; �������� ����������

	CLRF	BT_CNT
	let	AF,0AFH		; ���� ��������� ���������
	let	VERSION,010H	; ����� ������ ���������
	let	SIZE,.38		; ������ ������������� ������
	let	INJ_LAG_L,low LAG134	; ����� �������� ��������
	let	INJ_LAG_H,high LAG134	; ����� �������� ��������


	let	RCOh,0H
	let	RCOl,0C0H
	let	RqFh,high ReqFuel
	let	RqFl,low ReqFuel
	let	WARM_80,WARM_ENR_80
	let	WARM_50,WARM_ENR_50
	let	WARM_20,WARM_ENR_20
	let	ENR_12,WARM_ENR_12
	let	WARM_40,WARM_ENR_40
	CLRF	ADC_SEL
	CLRF	TPS
	CLRF	TPS1
	CLRF	STP_CNT_DWN
	CLRF	STP_CNT_UP
	CLRF	CHK_SUM_TX
	CLRF	PMPC
	CLRF	SPD
	CLRF	COLT
	let	BUF_IND,4
	banksel	SPD_BUF
	CLRF	SPD_BUF
	CLRF	SPD_BUF+1
	CLRF	SPD_BUF+2
	CLRF	SPD_BUF+3
	let	PWR_BUF_IND,4
	CLRF	PWR_BUF
	CLRF	PWR_BUF+1
	CLRF	PWR_BUF+2
	CLRF	PWR_BUF+3
	bank0
	CLRF	FLAG
	CLRF	FLAG2
	BANKSEL	TIME_DIV
	let	TIME_DIV,.1
	let	TIME_DIV+1,.1
	bank0

	let	T_INJ_H, high PR_PULSE
	let	T_INJ_L, low PR_PULSE
	CALL	DELEY20
	BSF	ADCON0,GO
WTGO1	BTFSC	ADCON0,GO
;	CLRWDT
	GOTO	WTGO1
	CALL	GET_COLT
	BCF	PIR1,ADIF
	BSF	STAT,7
	let 	INTCON,B'11110000'	; ���������� ���������� ����������
	CALL	STPINIT		; ����� ������� �������� ���������
;	BSF	INTCON,GIE
IFDEF PR_PULSE
	BSF	INTCON,INTF		; ���������������� ������
ENDIF
	GOTO 	MAIN
;}
;------------------------------------------------------------------
;		������� ���� ���������
;{------------------------------------------------------------------
MAIN	CLRWDT
	bank0
#IFDEF Debug
	BTFSC	PIN1
	BSF	ERR,7
	BTFSS	PIN1
	BCF	ERR,7		
#ENDIF


 	BTFSS	FLAG,0		; �������� �������?
	GOTO	NEXT
	
	bank1 
	BTFSS	TXSTA,TRMT		; �������� 
	GOTO	NX		; ������
	bank0
	CALL	TX
NX	bank0
	GOTO	NX2

NEXT	BTFSC	TXSTA,TRMT		; ����� ���������� �������� � ����������� ������ ��������
	BSF	RCSTA,CREN		; �������� �������

NX2	BTFSC	FLAG,7		; ������ �������� ������
	CALL	M_CALC
	BTFSC	FLAG,1		; ���� ������� �������� ���������
	GOTO	M_SPD
	BTFSC	FLAG,3		; ������������ �������� ���������
	CALL	STAB
	BTFSC	FLAG,5
	CALL	ADC_SELECT
	BTFSC	FLAG,2		; ������ ������������� �����
	GOTO	CORR
	BTFSC	FLAG2,0		; ������� ���������
	CALL	WRT_CNTR
	BTFSC	FLAG,6
	CALL	LAG		; ��������� ��� ��������
	BTFSS	RCSTA,OERR		;������ ������������ ����������� ������, ���������������� �0� ��� ������ ���� CREN
	GOTO	MAIN
	BCF	RCSTA,CREN	
	BSF	RCSTA,CREN
	GOTO	MAIN
;-----------------------------------------------------
;	�������� ������
;-----------------------------------------------------
TX	MOVF	BT_CNT,W		; ���������� ���� � ������ +1
	SUBWF	SIZE,W		;
	BTFSC	STATUS,Z		; ��������� �� ������������
	GOTO	CLR_TX		; ��������� �ר����� � ����������� �����
	BTFSS	STATUS,C		; ��������� �� ������������
	GOTO	CLR_TX		; ��������� �ר����� � ����������� �����
	movab	BT_CNT,FSR		; ��������� �ר���� ���� � ������� ��������� ���������	
	MOVLW	20H		; ��������� ������ ����� ����������
	ADDWF	FSR,F		; ��������� FSR �� ��������� ��������
	Movfw	INDF		; ������ ���� � ������	
	ADDWF	CHK_SUM_TX,F		; ��������� ���� ��� ���ר�� ����������� �����
	MOVWF	TXREG
;	bank1 
;	BTFSS    	TXSTA,TRMT		; �������� 
;	GOTO    	 $-1		; ������
;	bank0
	INCF	BT_CNT,F
	RETURN
WRT_CNTR
	BCF	FLAG2,0
	RETURN
;-----------------------------------------------------
;	������ �������������
;-----------------------------------------------------
CORR	BCF	FLAG,2
IFDEF MANSETRqF
	BTFSC	PIN1
	GOTO	CORR_RCO
	let	RqFh,high (ReqFuel-.3000)
	let	RqFl,low (ReqFuel-.3000)
	SWAPF	MAN_CORR,W
	ANDLW	0F0H		; ������� ��������
	ADDWF	RqFl,F		; � ������� �������
	BTFSC	STATUS,C
	INCF	RqFh,F	
	SWAPF	MAN_CORR,W		; �������� �������� ������� �������
	ANDLW	0FH		; ������� ��������
	ADDWF	RqFh,F		; � ������� �������
endif	

CORR_RCO
;	BCF	STATUS,C
;	RRF	MAN_CORR,F
;
;	let	RCOh,0H
;	let	RCOl,0C0H
;	SWAPF	MAN_CORR,W		; �������� �������� ������� �������
;	ANDLW	0FH		; ������� ��������
;	ADDWF	RCOh,F		; � ������� �������
;	SWAPF	MAN_CORR,W
;	ANDLW	0F0H		; ������� ��������
;	MOVWF	RCOl		; � ������� �������

CORR_LAG;	CALL	LAG		; ��������� ��� ��������
	GOTO	MAIN



;-----------------------------------------------------
;	���������� �������� ���������
;-----------------------------------------------------
M_SPD	BCF	FLAG,1
	let	Mul2Lo,low SPD_CONST; 0C0H
	let	Mul2Hi,high SPD_CONST;027H
	let	Res2Hi,upper SPD_CONST;09H
	BCF	INTCON,INTE ;���������� ���������� ��� ������ ����������� ����������
	MOVF	TMRL,W
	MOVWF	DivLo
	MOVF	TMRH,W
	MOVWF	DivHi
	BSF	INTCON,INTE
; �������� �� ����������� �������
	MOVF	DivLo,F
	BTFSS	STATUS,Z	
	GOTO	$+4
	MOVF	DivHi,F
	BTFSC	STATUS,Z
	GOTO	SPD_NULL
	CALL	Div24_16	; ��������� ������� ���������
	MOVF	Mul2Hi,W	; �������� �� ���������� ��������
	BTFSC	STATUS,Z
	GOTO	SPD_INTPL
	MOVLW	0FFH	; ������������ ������� ��������� � ������ ������� ���������
	MOVWF	Mul2Lo


;���� � ����� �������� ���������� ��������
SPD_INTPL	MOVLW	SPD_BUF-1	; ��������� ���������� ������
	ADDWF	BUF_IND,W
	MOVWF	FSR
	Movfw	Mul2Lo		; ��������� ����������� ��������
	MOVWF	INDF		; � ������ ���������� ������
	decfsz	BUF_IND,F
	GOTO	$+3
	MOVLW	.4
	MOVWF	BUF_IND

; ��������� ���������� �������
	CLRF	TEMP
	banksel	SPD_BUF
	Movfw	SPD_BUF
	ADDWF	SPD_BUF+1,W
	BTFSC	STATUS,C
	INCF	TEMP,F

	ADDWF	SPD_BUF+2,W
	BTFSC	STATUS,C
	INCF	TEMP,F

	ADDWF	SPD_BUF+3,W
	BTFSC	STATUS,C
	INCF	TEMP,F
	bank0
	MOVWF	SPD
	RRF	TEMP,F
	RRF	SPD,F
	RRF	TEMP,F
	RRF	SPD,F
; ���������� ����������/������� ���������
	Movf 	SPD,W	
	SUBLW	D'16'		; 400/25 ������� ������
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	GOTO	MTR_ON
	BCF	STAT,0 		; ��������� ����������
	GOTO	MTR_OFF
MTR_ON	BSF	STAT,0		; ��������� �������
	GOTO	MAIN
SPD_NULL	CLRF	SPD
MTR_OFF	BSF	STAT,7		; �������� ���������� ��� ������	
	BCF	STAT,0
	GOTO	MAIN
;}
;-----------------------------------------------------
;	��������� ��������� ���������
;{-----------------------------------------------------
SPARK	BCF	T1CON,TMR1ON	;��������� ������
	BCF    	INTCON,INTF   	;����� ����� ����������  
	MOVF	TMR1L,W
	MOVWF	TMRL
	MOVF	TMR1H,W
	MOVWF	TMRH		;���������� �������� �������

	CLRF	TMR1L
	CLRF	TMR1H
	BSF	T1CON,TMR1ON		; �������� ������
	BCF	PIR1,ADIF		; ����� ���������� ADC
	let	ADCON0,ADC_MAP		; ����� ������ MAP Sensor
	BTFSC	INJ2		; ��������� �� ���������� ����������� ����� �������
	BSF	ERR,2		; ��������� ����� ����������� ������� �������
	BSF	INJ1		; �������� ��������
	BSF	FLAG,1
	CLRF	PMPC

	; �������� �������� ������� �������� ��������
	BCF	STATUS,C
	RRF	INJ_LAG_H,W		; ������� 
	ANDLW	03h		; ������ �� ���������� ����, ���� 2047���
	MOVWF	CCPR1H		; � ������� �������

	RRF	INJ_LAG_L,W
	MOVWF	CCPR1L		; � ������� �������

	BTFSS	STAT,0		; ��� ����� ����������� ����� ��������
	INCF	CCPR1H,F		; �������� �� 512���
	let	CCP1CON,B'00001010'	; ��������� CCP1
	BSF	INJ2
	BSF	FLAG,7
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	BSF	PUMP
	BSF	ADCON0,GO
	BTFSC	STAT,5		; �������� ����
	GOTO	INJ_CLS		; ������� �� �������� ��������
	GOTO	RET
;}


;-----------------------------------------------------
;	��������� ������� ������ ���������
;{-----------------------------------------------------
COMP_EVNT	BCF	PIR1,CCP1IF		; ���������� ���� ���������
	CLRF	CCP1CON		; ���������� ���������
	BTFSC	STAT,5		; �������� ����
	GOTO	INJ_CLS		; ������� �� �������� ��������
	BTFSC	INJ1		; �������� ������ PEAK
	GOTO	INJ_HOLD
	BTFSC	INJ2		; �������� �� ���������� �������
	GOTO	INJ_CLS		; ����� ������������ ���������� ��������
	BSF	ERR,3		; ���������� ��� ������ ��������� ������� ���������	
	GOTO	RET

INJ_HOLD	BCF	INJ1		; ��������� ���� ������ ������ ����������
	MOVF	T_INJ_H,W
	BTFSS	STATUS,Z
	GOTO	INJ_LOAD
	MOVLW	0FH
	SUBWF	T_INJ_L,W
	BTFSS	STATUS,C
	GOTO	INJ_CLS

INJ_LOAD   	RRF	T_INJ_H,W		; ����� �����������
	RRF	T_INJ_L,W
	ADDWF	CCPR1L,F

	BTFSC	STATUS,C		; ��������� CARRY
	INCF 	CCPR1H,F

	BCF	STATUS,C
	RRF	T_INJ_H,W
	ANDLW	07FH
	ADDWF	CCPR1H,F		; ��������� �� ���������
	let	CCP1CON,B'00001010'	; ��������� CCP1

;	let	ADCON0,ADC_TPS
;	let	ADC_SEL,.4
;	CALL	DELEY20
;	BSF	ADCON0,GO
	GOTO	RET

;}




;------------------------------------------------------------------
; ������������ ��������� ������� ������������ ������� TMR1
;{----------------------------------------------------------------
TMR_OF	BCF	T1CON,TMR1ON	; ������������� ������
	BCF	PIR1,TMR1IF		; ���������� ���� ����������
	BCF	FLAG,1		; ����� ����� ������� ��������
	CLRF	TMR1H
	CLRF	TMR1L	
	BSF	FLAG,4		; �������� ��� �� �������� ��������
	CLRF	SPD		; ������� ����� 0
	BCF	STAT,0		;
	BSF	STAT,7		;
INJ_CLS	CLRF	CCP1CON		; ���������� ���������
	BCF	INJ2		; ��������� ������ ���������� �� ��������
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF	INJ1		; ������ ����������
	GOTO	RET

;}

;-----------------------------------------------------
;	��������� ������� ������ TMR0
;{-----------------------------------------------------
TMR_EV	BCF	INTCON,T0IF		; ����� ����� ����������
	let	TMR0,.255-.156	; ���� ������� 10��(100��)
	INCFSZ	PMPC,F		; ��������� �������� �����������
	GOTO	TMRM2		;
	BCF	PUMP		; ��������� ����������

TMRM2	DECFSZ	TX_DEL_CNT,F
	GOTO	TMRM3
	let	TX_DEL_CNT,.10	; �������� ����� ��������
; �������� �������� �� ������� ��Ȩ� ������ � �������� �� ����������� �� �������!!!!!!!
	BCF	RCSTA,CREN		; ������������� �������
	BSF	FLAG,0		; ��� ������������� �������� ������
TMRM3
; ������� ������������� ���� ��������� ������������ �������� ���������
TMR_EX	BTFSS	STAT,0
	BSF	FLAG,3	
	BTFSC	Flag_Math,3
	GOTO	$+4
	BSF	FLAG,3	; ������������ �������� � ������ ���ר��
	BSF	Flag_Math,3
	GOTO	$+2
	BCF	Flag_Math,3	
	BSF	FLAG,5
	
	

; ������� ���������
	banksel	TIME_DIV
	DECFSZ	TIME_DIV,F
	GOTO	TMROUT
	TSTF	TIME_DIV+1
	BZ	HCNSET
	DECFSZ	TIME_DIV+1,F
	GOTO	TMROUT
HCNSET	let	TIME_DIV+1,high hctn
	let	TIME_DIV,low hctn
	BSF	FLAG2,0
	DECFSZ	MINUTE_CNT,F
	GOTO	TMROUT
	let	MINUTE_CNT,.60
	bank0
	INCFSZ	MCKl,F
	GOTO	TMROUT
	INCF	MCKh,F
TMROUT	bank0
	GOTO	RET
;}
;-----------------------------------------------------
;	 ������������ ������ ������  ���
;{-----------------------------------------------------
ADC_SELECT	BTFSC	ADCON0,GO
	RETURN	
	BCF	PIR1,ADIF		; ����� ����������
	BCF	FLAG,5
	DECFSZ	ADC_SEL,F
	GOTO	ADC1
	let	ADC_SEL,.5
ADC1	MOVF	ADC_SEL,W
	XORLW	01H		; Correction
	BTFSS	STATUS,Z
	GOTO 	ADC2
	let	ADCON0,ADC_CORR
	GOTO	SEL

ADC2	MOVF	ADC_SEL,W
	XORLW	02H		; PWR
	BTFSS	STATUS,Z
	GOTO 	ADC3
	let	ADCON0,ADC_PWR
	GOTO	SEL

ADC3	MOVF	ADC_SEL,W
	XORLW	03H		; COLT
	BTFSS	STATUS,Z
	GOTO 	ADC4
	let	ADCON0,ADC_COLT
	GOTO	SEL

ADC4	BTFSC	STAT,0
	RETURN

	MOVF	ADC_SEL,W
	XORLW	04H		; MAP
	BTFSS	STATUS,Z
	GOTO 	ADC5
	let	ADCON0,ADC_MAP
	GOTO	SEL

ADC5	MOVF	ADC_SEL,W
	XORLW	05H		; TPS
	BTFSS	STATUS,Z
	GOTO 	SEL
SET_ADC_TPS	let	ADCON0,ADC_TPS
	GOTO	SEL

SEL
;���������� 20��� �������� ����� ������ ������ ����� �������� ��������������
	CALL	DELEY20
	BSF	ADCON0,GO
	RETURN
;}


	
;-------------------------------------------------------
;	������ �������� � ������ ������
;{ ������������ ������������� ��������(6.4��)
DELAY	let	dil_t2,d'20'
	CLRWDT
DEL1	CALL 	DEL
	CLRWDT
	DECFSZ	dil_t2,f
	GOTO 	DEL1
	RETURN
; �������� ��� ������������� ������������ ��������(318���)
DEL	let 	dil_t,d'255'
dilt	DECFSZ 	dil_t,f
	GOTO 	dilt
	RETURN
DELEY20	let 	dil_t,d'25'
	GOTO	dilt

; ������������ ��������� ���� ������ �� �������� �������
ERR_BOR	bank0
	BSF	ERR,1
	bank1
	RETURN
; ������������ ��������� �ר����� ���� �������� � ����������� �����
CLR_TX	bank0
	CLRF	BT_CNT		; ��������� �ר�����
	CLRF	CHK_SUM_TX
	BCF	FLAG,0		; ����� ��������-�������� �����������
	RETURN
	
READ_STR	MOVLW	HIGH EngSC
	MOVWF	PCLATH
	MOVF	TEMP,W		; ������ ������� DT �������� ����
	MOVWF	PCL 
READ_STR2	MOVLW	HIGH Lamb
	MOVWF	PCLATH
	MOVF	temp,W		; ������ ������� DT � �����������
	MOVWF	PCL 


	;}
;-----------------------------------------------------
; ������������ ��������� ���������� ���
;{-----------------------------------------------------
Int_AD	BCF	PIR1,ADIF		; ����� ����������
	BTFSC	ADCON0,GO
	GOTO	RET

 	MOVF	ADCON0,W
	XORLW	ADC_COLT
	BTFSS	STATUS,Z		; ����?
	GOTO	ADC01
	CALL	GET_COLT
	GOTO	RET

ADC01	MOVF	ADCON0,W
	XORLW	ADC_TPS
	BTFSS	STATUS,Z
	GOTO	GET_DAD
	MOVF	TPS,W		; ��������� �������� ����
	MOVWF	TPS1
	MOVF	ADRESH,W
	MOVWF	TPS		; ���������� ��������� ��	


	SUBLW	IAC_SKIP*.255/.5000	; ����� ������������ ��������� ����
	BTFSS	STATUS,C		; ���� ��������� �� ������ ������
	GOTO	CLR_IAC		; �� ��������� �� ����, �����
	BSF	STAT,2		; ������ ���� ��������� ����
	BSF	EPHH		; �������� �������� ��������� ��
	GOTO	RET
CLR_IAC	BCF	STAT,2		; ��������� ���� ��
	BCF	EPHH
	GOTO	RET



GET_DAD	MOVF	ADCON0,W		; ���
	XORLW	ADC_MAP
	BTFSS	STATUS,Z
	GOTO	ADC02
	MOVF	ADRESH,W
	MOVWF	MAP
; �������� ������� �������
	ADDLW	0FH		; ���
	BTFSS	STATUS,C
	GOTO	$+2
	BSF	ERR,5		; ��������� ���� ������
	MOVLW	05H		; �������� ������ �������
	SUBWF	MAP,W
	BTFSC	STATUS,C
	GOTO 	RET
	BTFSS	STAT,2
	BSF	ERR,5		; ��������� ���� ������
	GOTO	RET

ADC02	MOVF	ADCON0,W		; ���������� ��������
	XORLW	ADC_PWR
	BTFSS	STATUS,Z
	GOTO	ADC03
	MOVF	ADRESH,W
	BTFSS	STAT,0		; ���� ����� ������� -�� ����������
	MOVWF	POWER
	banksel	ADC_POWER
	MOVWF	ADC_POWER
	bank0
	BSF	FLAG,6
	GOTO	RET
ADC03	MOVF	ADCON0,W
	XORLW	ADC_CORR
	BTFSS	STATUS,Z
	GOTO	RET		; ����� �� ���������
; ��������� �������� ����� �� ���������� ������
	MOVF	ADRESH,W
	MOVWF	MAN_CORR
	BSF	FLAG,2
	ANDLW	B'11000000'
	BTFSS	STATUS,Z
	GOTO	O2S_OFF
	bank1
	RLF	ADRESL,F	;����� � ����
	bank0
	RLF	ADRESH,F	;
	bank1
	RLF	ADRESL,F
	bank0
	RLF	ADRESH,W
	MOVWF	temp
; ������ ������� �������������� ���������� ������-�����
O2Zr	BCF	ERR,06H
	CALL	READ_STR2
O2SET	MOVWF	O2S
	PAGESEL	RET
	GOTO	RET
O2S_OFF	MOVLW	00H
	BSF	ERR,06H
	GOTO	O2SET
;}
;-----------------------------------------------------
; ������������ ��������� ���������� UART RxD
;{-----------------------------------------------------
Int_RX	BCF	PIR1,RCIF
	Movfw	RCREG
Read_RX;	MOVWF	RX_DATA
;	BCF	FLAG,7
	GOTO	RET
;}
;-----------------------------------------------------
; ������������ ��������� ����, ����������� COLT=FFH-ADC+75H, 75H<ADRESH<0B4H
;{-----------------------------------------------------
GET_COLT	MOVF	ADRESH,W	; ��������� �� ��������� � ��������� ��������� ������� �����������
	ADDLW	-075H	; ���������� � ����������� ���������
	ADDLW	-(0CAH-075H)	; ����-���+1
	BTFSC	STATUS,C
	GOTO	COLT_ERR

	MOVLW	075H	; �������� ������
	SUBWF	ADRESH,F
	MOVF	ADRESH,W	; ���� >B4 ��������� ����� ��������
	SUBLW	0B4H-075H
	BSF	STAT,1	;
	BTFSS	STATUS,C
	BCF	STAT,1	; ����� ���� ��������

	MOVF	ADRESH,W	; ���� ������ B3 �������� ����� ��������
	SUBLW	0B2H-075H
	BTFSC	STATUS,C
	BSF	STAT,1

	BCF	STATUS,C
	bank1
	RLF	ADRESL,F	;����� � ����
	bank0
	RLF	ADRESH,F	;� ADRESH ���� ������� ��������� ��������
; ��������� - ����� ������� ���������� ������� ����������
 
	MOVF	ADRESH,W
	MOVWF	ColtF


	BTFSS	STAT,1
	GOTO	GC_1
	BCF	STATUS,C
	bank1
	RLF	ADRESL,F
	bank0
	RLF	ADRESH,F

;����� �������� �������������� COLT
	MOVLW	0FFH
	XORWF	ADRESH,W	; ����� �������� � ������������
	XORWF	ADRESH,F	; �������
	XORWF	ADRESH,W
	SUBWF	ADRESH,W	; �������� �� FF ���������� ���
	MOVWF	COLT

	BTFSS	WARM_UP
	BSF	WARM_UP	;
	BCF	ERR,4
	RETURN

COLT_ERR	BSF	ERR,4
	BCF	STAT,1	; ����� ���� ��������
	CLRF	ColtF
	GOTO	$+2
GC_1	BCF	ERR,4	
	CLRF	COLT
	BTFSC	WARM_UP
	BCF	WARM_UP	; ��������� ��������� ��������
	RETURN
;}
;---------------------------------------------
; ������ ������� �������� ��������
;{---------------------------------------------
LAG	BSF	FLAG,6
;������ ����������� ��������
;{	
	BTFSC	STAT,0
	GOTO	GETLAG
	banksel	PWR_BUF_IND
	MOVLW	PWR_BUF-1	; ��������� ���������� ������
	ADDWF	PWR_BUF_IND,W
	MOVWF	FSR
	banksel	ADC_POWER
	Movfw	ADC_POWER		; ��������� 
	MOVWF	INDF		; � ������ ���������� ������
	decfsz	PWR_BUF_IND,F
	GOTO	$+3
	MOVLW	.4
	MOVWF	PWR_BUF_IND

; ��������� ���������� �������
	CLRF	TEMP
	banksel	PWR_BUF
	Movfw	PWR_BUF
	ADDWF	PWR_BUF+1,W
	BTFSC	STATUS,C
	INCF	TEMP,F

	ADDWF	PWR_BUF+2,W
	BTFSC	STATUS,C
	INCF	TEMP,F

	ADDWF	PWR_BUF+3,W
	BTFSC	STATUS,C
	INCF	TEMP,F
	bank0
	MOVWF	POWER
	RRF	TEMP,F
	RRF	POWER,F
	RRF	TEMP,F
	RRF	POWER,F
	Movf 	POWER,W		
	
;}


GETLAG	Movfw	POWER
	SUBLW	96H	; ����� 15 �����
	BTFSS	STATUS,C
	GOTO	HVOLT
	MOVLW	57H
	SUBWF	POWER,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	GOTO	LVOLT	; ������ 8,6�

;	BCF	FLG_C,7
	MOVWF	TEMP	
	ANDLW	0FH
	SUBLW	0FH;3FH
	MOVWF	MULc
	BTFSC	TEMP,5
	GOTO	NTX11V
	BTFSC	TEMP,4
	GOTO	PWR102

PWR086	MOVLW	low (LAG086-LAG102)
	MOVWF	Mul1Lo
	MOVLW	high (LAG086-LAG102)	
	MOVWF	Mul1Hi

	MOVLW	low LAG102
	MOVWF	Temp5

	MOVLW	high LAG102
	MOVWF	Temp4
	GOTO	PWR_CALC

PWR102	MOVLW	low (LAG102-LAG118)
	MOVWF	Mul1Lo
	MOVLW	high (LAG102-LAG118)	
	MOVWF	Mul1Hi

	MOVLW	low LAG118
	MOVWF	Temp5

	MOVLW	high LAG118
	MOVWF	Temp4
	GOTO	PWR_CALC


NTX11V	BTFSC	TEMP,4
	GOTO	PWR134
PWR118	MOVLW	low (LAG118-LAG134)
	MOVWF	Mul1Lo
	MOVLW	high (LAG118-LAG134)	
	MOVWF	Mul1Hi

	MOVLW	low LAG134
	MOVWF	Temp5

	MOVLW	high LAG134
	MOVWF	Temp4

	GOTO	PWR_CALC


PWR134	MOVLW	low (LAG134-LAG150)
	MOVWF	Mul1Lo
	MOVLW	high (LAG134-LAG150)	
	MOVWF	Mul1Hi

	MOVLW	low LAG150
	MOVWF	Temp5

	MOVLW	high LAG150
	MOVWF	Temp4
	GOTO	PWR_CALC

PWR_CALC	CALL	MUL16_8
	BCF	STATUS,C
	RRF	ResHi,F
	RRF	Mul1Hi,F
	RRF	Mul1Lo,F

	BCF	STATUS,C
	RRF	ResHi,F
	RRF	Mul1Hi,F
	RRF	Mul1Lo,F


	BCF	STATUS,C
	RRF	ResHi,F
	RRF	Mul1Hi,F
	RRF	Mul1Lo,F


	BCF	STATUS,C
	RRF	ResHi,F
	RRF	Mul1Hi,F
	RRF	Mul1Lo,F

	Movfw	Mul1Lo
	ADDWF	Temp5,W

	MOVWF	INJ_LAG_L

	BTFSC	STATUS,C
	INCF	Mul1Hi,F

	Movfw	Mul1Hi
	ADDWF	Temp4,W

	MOVWF	INJ_LAG_H

	RETURN
HVOLT	let	INJ_LAG_H,high LAG150
	let	INJ_LAG_L,low LAG150
	RETURN
LVOLT	let	INJ_LAG_H,high LAG086
	let	INJ_LAG_L,low LAG086
	RETURN
;}
;---------------------------------------------------------------------


;------------------ ������� ��������� -----------------------

;tm2	btfss	PIR1,CCP1IF		 ;���� ������ ���������
;	goto	tm2
;tm3	bsf	PORTC,0		;    ;������� ���������
;	call	zadimp	       ;����� ��������	
;	bcf	PORTC,0		      ;����� �������� ���������
;	goto	RET         ;�������                  


EE_ADR	; ��������� ������ ������ � ����������������� �������	
	banksel	EEADR
	movwf	EEADR       ; ����������� W � ������� EEAdr
	bank0
	return
EE_READ	; ������ ������ �� ����������������� ������ EEPROM (���)	
	banksel	EECON1
	bsf	EECON1,RD    ; ���������������� ������.
	banksel	EEDATA
	movf	EEDATA,W    ; ����������� � W �� EEPROM
	bank0
	return

EE_WRITE	; ������ ������ � ����������������� ������ EEPROM (���)
	BCF	INTCON,GIE      ; ���������� ������ ����������
            movwf	EEDATA      ; ����������� W � EEPROM
	banksel	EECON1
           bsf	EECON1,WR    ; ��������� ������.
                                   
            movlw      55h         ; ������������
           movwf      EECON2      ; ���������
           movlw      0AAh         ; ��� ������.
           movwf      EECON2      ; ----"----
           bsf        EECON1,WR    ; ----"----

           bcf        EECON1,EEIF    ; �������� ���� ���������� �� ���������
           bank0		; ������� � ������� ����.
	BSF	INTCON,GIE
	RETURN


	#include DIV24x16.asm

	#include MUL8x8.asm
	#include rhh.asm
	#include calc.asm
	#include MUL16x8.asm

;	#include pwl.asm
	#include VE.asm
	#include lambda.asm
; ��������������� ������
            org         2100h       ; ��������� � EEPROM ������ ������.
            DE          8h,4h,2h   
            DE          1h,3h,5h,7h,8h,6h,4h,2h 	
;�������� �������� ���������
            org         2100h+0F0H  ; ��������� � EEPROM ������ ������.
MH_main     DE          00h,00h,2h	; ����.HSB:����.LSB:��
MH_res      DE          00h,00h,2h
MH_min_m    DE          00h,00h
MH_min_r    DE          00h,00h  
;	ORG 	1F9CH 
;	PAGESEL 	GO_INIT
;	GOTO	GO_INIT
;	nop
;	nop
;Bootloader org 	1FA0H

	END                       ; directive 'end of program'

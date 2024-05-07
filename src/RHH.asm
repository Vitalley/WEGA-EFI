;-------------------------------------------------------------
;      ���������� ���������� ������� ����������
;-------------------------------------------------------------
;
;        DELAY    - ������������ ��������
;
;        STPINIT  - ������������� �������� ���������, ������ 255 ����� �� ��������, � 70 �� ��������
;        STPUP    - ������� �������� �� ���� ���
;        STPDOWN  - �� ���� ��� �������
;
;
;        STPCNT  - ���������� ��������� ������� ������� �������� ���������

;====================================================
;#DEFINE	STEPA	PORTB,0	 ;
;#DEFINE	STEPB	PORTB,1	 ;
;=====================================================
STPINIT	let	STPCNT,IAC_MAX	;���������� ������� �����
STPI	CALL	STPDOWN		;������ IAC_MAX ����� � ������� ��������
	CALL	DELAY		;�������� ����� ����������
	DECFSZ	STPCNT,F
	GOTO	STPI
	BSF	FLAG,4		;�������� ���� �� ���������������� ���
	let	IAC_INIT,IAC_WARM
	RETURN

ST_INI	BTFSC	STAT,0
	GOTO	SET_STEP
 NOP
;��������� ������� ������������ ������������
	movab	COLT,MULc		; COLT^2
	movab	COLT,MULp
	CALL	MUL8
	movab	H_byte,MULc
; ���� ������������
;	movab	COLT,MULc
	let	MULp,IAC_COLT-IAC_WARM
	CALL	MUL8

	MOVF	H_byte,W
	ADDLW	IAC_WARM
	MOVWF	IAC_INIT

SET_STEP	;CALL	SETSTP
	CALL	STPUP			;���������� ������� � ��������� ���������
	MOVFW	STPCNT
	SUBWF	IAC_INIT,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	BCF	FLAG,4
	RETURN

;	����:	F1	F2	F3	F4
;	PORTB,0	1	0	0	1	- ����� �
;	PORTB,1	1	1	0	0	- ����� �
; ��������� ��� �������� ���������� ������ ����������
IFDEF MANSETIAC
SET_MAN	BCF	STATUS,C
	RRF	MAN_CORR,W	
; ��������� � ������� �������� � W
SETSTP	SUBWF	STPCNT,W		; �������� �� ������������ ��������� ���
	BTFSS	STATUS,C
	GOTO	STPUP	

	BTFSS	STATUS,Z
	GOTO	STPD
	RETURN
endif





; ===========================================================================
; ������������ �������� ����������� ���� ���������
; ===========================================================================
STAB	BCF	FLAG,3		; ����� ����� ���������
	BTFSC	FLAG,4		; ���� ���������������� ���
	GOTO	ST_INI
IFDEF MANSETIAC
	BTFSC	PIN1		; ������ ���������� ���
	GOTO	SET_MAN
endif
	BTFSS	STAT,0		; �������� ������� ���������
	RETURN
IFDEF IAC_TRSH
; ����� ���������� �������� �������� ���
	MOVLW	IAC_TRSH
	SUBWF	STPCNT,W		; 
	BTFSC	STATUS,C
	GOTO	STABSTAT
	BTFSC	Flag_Math,2
	GOTO	STABSTAT
	BSF	Flag_Math,2		
	RETURN
STABSTAT	BCF	Flag_Math,2
ENDIF	

IFDEF DEMFER
	BTFSC	STAT,2		; �������� ��������� ����
	GOTO	DEMFEROUT
	MOVLW	DEMFER
	SUBWF	STPCNT,W		; �������� �� ������������ ��������� ���
	BTFSS	STATUS,C
	GOTO	STPUP
DEMFEROUT
ENDIF
IFDEF WARM_TRSH
#define	TRSHH	(WARM_TRSH+.273)*.51 ;MPASM ������ ��� ������ �� ������������
	MOVLW	.255-(((TRSHH/.100)-075H)*.4)
	SUBWF	COLT,W
	BTFSC	STATUS,C
	GOTO	WST
	BTFSC	STAT,7
	GOTO	WST
ENDIF
IFNDEF WARM_TRSH
	BTFSC	COLT,7; STAT,1	; �������� �������� ���������
	GOTO	WST
	BTFSC	STAT,7
	GOTO	WST
ENDIF


STABILIZE	MOVLW	(SPD_HOT/.25)-.1	; ������ ����� ��������
	SUBWF	SPD,W		; 
	BTFSC	STATUS,C
	GOTO	STABH
	CLRF	STP_CNT_DWN
	ADDLW	.9
	BTFSS	STATUS,C	
	GOTO	STABOPN
	MOVLW	(SPD_HOT/.25)-.1	; ������ ����� ��������
	SUBWF	SPD,W		; 
	CALL	DELT_DEL_UP
	INCF	STP_CNT_UP,F		;
	MOVF	STP_CNT_UP,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
STABOPN	CALL	STPUP		; �� ���� ��� ������� ����������� �����
	RETURN

STABH	CLRF	STP_CNT_UP
	BTFSS	STAT,2		; �������� ��������� ����
	RETURN
		
	MOVLW	(SPD_HOT/.25)+.2	; ������� ����� ��������
	SUBWF	SPD,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C	
	RETURN
	SUBLW	020H		; ����� 20*25��/��� ��� ��������
	BTFSS	STATUS,C		; ��� ��������
	GOTO	CLWWHTDEL

	MOVF	SPD,W
	SUBLW	(SPD_HOT/.25)+.2	; ������� ����� ��������
	CALL	DELT_DEL
	INCF	STP_CNT_DWN,F
	MOVF	STP_CNT_DWN,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
CLWWHTDEL	CALL	STPD
	RETURN
;������������ �������� �� ��������
WST	MOVLW	(SPD_WARM/.25)-.2	; ������ ����� ��������
	SUBWF	SPD,W		; 
	BTFSC	STATUS,C
	GOTO	STABHWR
	CLRF	STP_CNT_DWN
	ADDLW	.9
	BTFSS	STATUS,C	
	GOTO	STABOPN
	MOVLW	(SPD_WARM/.25)-.2	; ������ ����� ��������
	SUBWF	SPD,W		; 
	CALL	DELT_DEL_UP
	INCF	STP_CNT_UP,F
	MOVF	STP_CNT_UP,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	CALL	STPUP		; �� ���� ��� ������� ����������� �����
	RETURN

STABHWR	CLRF	STP_CNT_UP
	BTFSS	STAT,2		; �������� ��������� ����
	RETURN
	
	MOVLW	(SPD_WARM/.25)+.2	; ������� ����� ��������
	SUBWF	SPD,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C	
	RETURN
	SUBLW	020H		; ����� 20*25��/��� ��� ��������
	BTFSS	STATUS,C		; ��� ��������
	GOTO	CLWWHTDELWR

	MOVF	SPD,W
	SUBLW	(SPD_WARM/.25)+.2	; ������� ����� ��������
	CALL	DELT_DEL
	INCF	STP_CNT_DWN,F
	MOVF	STP_CNT_DWN,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
CLWWHTDELWR	CALL	STPD
	RETURN

;----------------------------------------------------
;     �������� ��������� �� ��� �������
;----------------------------------------------------
STPUP	CLRF	STP_CNT_UP
	MOVF	STPCNT,W		; �������� �� ������������ ��������
	SUBLW	IAC_MAX		; ���� ���������� �����
	BTFSS	STATUS,C		;
	RETURN			; ���� ��-�� �������
	INCF	STPCNT,F
	BTFSS 	STEPA		; �������� ��� �
	GOTO	STUA0
	BTFSS 	STEPB
	GOTO	STUB0
	BCF	STEPA		;F2
	RETURN
STUB0	BSF	STEPB		;F1
	RETURN
STUA0	BTFSS	STEPB
	GOTO	STUB20
	BCF	STEPB		;F3
	RETURN
STUB20	BSF	STEPA		;F4
	RETURN

;-------------------------------------------
;   �������� ��������� �� ����������
;-------------------------------------------
STPD	CLRF	STP_CNT_DWN
	MOVLW	IAC_MIN
	BTFSC	STAT,1
	MOVLW	IAC_MIN	; �������� �� ����������� ��������� ���
	SUBWF	STPCNT,W
	BTFSC	STATUS,C
	BTFSC	STATUS,Z
	RETURN
	DECF	STPCNT,F
STPDOWN 	BTFSS 	STEPA		; �������� ��� �
	GOTO	STDA0
	BTFSS 	STEPB
	GOTO	STDB0
	BCF	STEPB		;F4
	RETURN
STDB0	BCF	STEPA		;F3
	RETURN
STDA0	BTFSS	STEPB
	GOTO	STDB20
	BSF	STEPA	;F1
	RETURN
STDB20	BSF	STEPB		;F2
	RETURN

; ������������ ���������� �������� �������� ���
; 
DELT_DEL	ADDLW	.1
	BTFSS	STATUS,Z
	GOTO	$+4
	MOVLW	0FFH		; ������������ �������� ��� ������� 25 ��/���
	MOVWF	STP_SPEED
	RETURN
	CLRF	STP_SPEED
	BSF	STP_SPEED,7		; STP_CN=80H
DEL_LOOP	ADDLW	.2		; ����� ����������
	BTFSC	STATUS,C
	RETURN
	RRF	STP_SPEED,F
	GOTO	DEL_LOOP

; DELTA TO DELAY UP
DELT_DEL_UP	ADDLW	.1
	BTFSS	STATUS,Z
	GOTO	$+4
	MOVLW	0FFH		; ������������ �������� ��� ������� 25 ��/���
	MOVWF	STP_SPEED
	RETURN
	CLRF	STP_SPEED
	BSF	STP_SPEED,7		; STP_CN=80H
DEL_LOOP_UP	ADDLW	.1
	BTFSC	STATUS,C
	RETURN
	RRF	STP_SPEED,F
	GOTO	DEL_LOOP_UP

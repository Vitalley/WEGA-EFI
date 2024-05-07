MB0	udata ;20
;	cblock	20
AF	RES .1		; ���� b'10101111'
BT_CNT	RES .1		; ������� ������ ��������, ��� �������� ������ 01H
VERSION	RES .1		; ����� ������ ������ 10H
SIZE	RES .1		; ������ ������
STAT	RES .1		; ���������� ����� ������ (���������) 
			;[0]-Motor on [1]-Warm_Up on [2]-IAC [3]-Accel 
			;[4]-D.Accel [5]-���� [6]-��� [7] AFTER START ENR
ERR	RES .1		; ���� ������ 
			;Bit:[0]-WDT, [1]-BOR, [2]-T.Inj, [3]-Err.Copm, [4]-COLT,
			;[5]-MAP [6]-O2S [7] - IAT
STPCNT	RES .1		; ������� �������� ���������
ColtF	RES .1;5		; *��������� ��� ����������� ���������
COLT	RES .1;6		; ��������� ����
MAP	RES .1;7		; ���������� �� �������� ���������
TPS	RES .1;8		; ��������� ����������� ��������
O2S	RES .1;9		; ��������� ������� ��������� Lambda=(O2S/2+64)/128
POWER	RES .1;10		; ���������� ��������� ����/10,2
SPD	RES .1;11		; ������� ��������� (SPD*25)
T_INJ_L	RES .1;12
T_INJ_H	RES .1;13		; ����� �������(���)
;
INJ_LAG_L	RES .1;14 		; ����� ������������ ��������
INJ_LAG_H	RES .1;15


RqFl	RES .1;16		; ����� ������� ��� �������� 110���
RqFh	RES .1;17
RCOl	RES .1;18		; 
RCOh	RES .1;19
MCKl	RES .1;20		; ������� ���������
MCKh	RES .1;21


WARM_80	RES .1;22		; ���������� ��� �������� �������� ��������� (+80)
WARM_20	RES .1;23		;+20 ���������� ��� �������� ��������� ��������� (-40)

eSTAT	RES .1		; ����������� ������ �����

WARM_40	RES .1;25		;-40
WARM_50	RES .1;26		;+50
D_TPS	RES .1		; Delta TPS
ENR_12	RES .1;28		;-12
;----
RESERV	RES .2		; ������ 2 ����� � ���������
;----
UOZ	RES .1
MAN_CORR	RES .1		; ���������� ������������ ������ �������������
SPD_ENR	RES .1;33		; �������� ����� �� ��������
WARM_ENR	RES .1;34		; ENRICHMENT
;����� ������ ��������
CHK_SUM_TX	RES .1		; ����������� �����
;-------------------------------------------------------------------
CHK_SUM_RX RES .1
;
STP_CNT_UP RES .1		; ������� ���������� ��
PMPC RES .1			; ������� ���������� ���
STP_SPEED RES .1
STP_CNT_DWN RES .1
TPS1 RES .1
;Mul
Cnt RES .1
Temp6 RES .1
Temp7 RES .1
Temp8 RES .1
Temp9 RES .1
Mul1Lo RES .1
Mul1Hi RES .1
ResHi RES .1
;Div
Cnt2 RES .1
DivLo RES .1
DivHi RES .1
Mul2Lo RES .1
Mul2Hi RES .1
Res2Hi RES .1
Res1 RES .1
Res2 RES .1
Res3 RES .1
Mul2 RES .1
CntDiv RES .1
Temp RES .1
Temp1 RES .1
Temp2 RES .1
Temp3 RES .1
Temp4 RES .1
Temp5 RES .1
Flag_Math RES .1	; 1 - MUL16X8, 0- DIV 24/16, 2- 9bit multp



MULc RES .1		; 8 bit multiplicand
MULp RES .1		; 8 bit multiplier
H_byte RES .1		; High byte of the 16 bit result
L_byte RES .1		; Low byte of the 16 bit result


BUF_IND RES .1

RQF2 RES .1


 
; ���������� ������ ��������� �� ���� ������ �����������
MB1 UDATA_SHR

;RQF2 RES .1
;FLG_C RES .1
ADC_SEL RES .1		; Select chenal ADC

FLAG RES .1		; [0] - ���������� �� �������� ������ ���������,
		; [1] - ���� ������� �������� 
		; [2] - ������ ������������� 
		; [3] - ������������ �������� ��������� 
		; [4] - ���������������� ��� 
		; [5] - ����� ������ ���
		; [6] - ��������� ������ � ��� �������
		; [7] - ������ �������� ������ �������
FLAG2 RES .1	; [0] - ��������� ����� � ������
IAC_INIT RES .1		; ��������� ��������� ��� ��� ������� ���������
TX_DEL_CNT RES .1		; ������� �������� ��� �������� �������
dil_t RES .1
dil_t2 RES .1
;TMPI
TMRL RES .1
TMRH RES .1
D_TPS1 RES .1
TEMP	RES .1	; ��������� ������ ��� ��������� �����
temp	RES .1	; ��������� ������ ��� ����������
; �������� ���������� ��� ����������
STATUS_TEMP RES .1	; ������� ���������� �������� �������
PCLATH_TEMP RES .1	; 
W_TEMP	RES .1


MB2 udata 0A0H
SPD_BUF_IND res .1 ; �� ����������
SPD_BUF	RES .4
PWR_BUF	res .4
PWR_BUF_IND res .1
ADC_POWER	res .1
;Input	RES .1 		; 
;Output 	RES .1	; 
;Index 	RES .1	; 
;SlopeLo 	RES .1	;16 bit
;SlopeHi 	RES .1	; 
;OffsetLo	RES .1;16 bit
;OffsetHi 	RES .1; 

;INPUTBUF	RES .63
;!!!�������� ��������!!!
RX_DATA RES .1	; �������� ����
TIME_DIV RES .2	; �������� ��������
MINUTE_CNT RES .1	; �������� �������
TEMP_MULT RES .3
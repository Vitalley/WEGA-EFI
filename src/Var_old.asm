	cblock	20
AF		; ���� b'10101111'
BT_CNT		; ������� ������ ��������, ��� �������� ������ �������
VERSION		; ����� ������
SIZE		; ������ ������
STAT		; ���������� ����� ������ (���������) [0]-Motor on [1]-Warm_Up on [2]-IAC [3]-Accel [4]-D.Accel [5]-���� [6]-��� [7] AFTER START ENR
ERR		; ���� ������ Bit:[0]-WDT, [1]-BOR, [2]-T.Inj, [3]-Err.Copm, [4]-COLT,[5]-MAP
STPCNT		; ������� �������� ���������
A_TMP		; *��������� ��� ����������� ���������
COLT		; ��������� ����
MAP		; ���������� 0FH -Offset, 0FAH - 100���
TPS		; ��������� ����������� �������� <14H IAC
O2S		; *��������� ������� ���������
POWER		; ���������� ��������� ����/10,29
SPD		; ������� ���������
T_INJ_L
T_INJ_H		; ����� �������(���)
;
INJ_LAG_L 
INJ_LAG_H

RqFl		; ����� ������� ��� �������� 110���
RqFh
CRANK_COLT_L	; ����� ������� ��� ����� �� �������� 30ms
CRANK_COLT_H
CRANK_WARM_L	; ����� ������� ��� ����� �� ������� 5ms
CRANK_WARM_H
WARM_80		; ���������� ��� �������� �������� ��������� (+80)
WARM_20		; ���������� ��� �������� ��������� ��������� (-40)

MAN_CORR		; ���������� ������������ ������ �������������

WARM_40
WARM_50
D_TPS		; Delta TPS
ENR_12

RCOl		; 
RCOh
MCKl		; ������� ���������
MCKh 

SPD_ENR
WARM_ENR		; ENRICHMENT

CHK_SUM_TX		; ����������� �����
CHK_SUM_RX
;
STP_CN_UP		; ������� ���������� ��
PMPC		; ������� ���������� ���
STP_SPEED
STP_CN
TPS1
;Mul
Cnt,Temp6,Temp7,Temp8,Temp9,Mul1Lo,Mul1Hi,ResHi
;Div
Cnt2,DivLo,DivHi,Mul2Lo,Mul2Hi,Res2Hi,Res1,Res2,Res3
Mul2,CntDiv,Temp,Temp1,Temp2,Temp3,Temp4,Temp5,Flag

MULc		; 8 bit multiplicand
MULp		; 8 bit multiplier
H_byte		; High byte of the 16 bit result
L_byte		; Low byte of the 16 bit result

SPD_BUF
SPD_BUF1
SPD_BUF2
SPD_BUF3
BUF_IND

RQF1,RQF2
ADC_SEL		; Select chenal ADC

FLAG		; [0]- �������� ������, [1]-���� ������� �������� [2] - ������ ������������� [3] - ������������ �������� ��������� [4] ���������������� ���
IAC_INIT		; ��������� ��������� ��� ��� ������� ���������
TX_DEL_CNT		; ������� �������� ��� �������� �������
dil_t
dil_t2
;TMPI
TMRL
TMRH
D_TPS1
TEMP
FLG_C
STATUS_TEMP	; ������� ���������� �������� �������
PCLATH_TEMP	; 
	endc
W_TEMP	EQU		07FH
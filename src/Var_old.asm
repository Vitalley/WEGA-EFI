	cblock	20
AF		; БАЙТ b'10101111'
BT_CNT		; Счётчик байтов передачи, при передаче всегда нулевой
VERSION		; НОМЕР ВЕРСИИ
SIZE		; Размер пакета
STAT		; Отображает режим работы (побитовый) [0]-Motor on [1]-Warm_Up on [2]-IAC [3]-Accel [4]-D.Accel [5]-ЭПХХ [6]-ЭМР [7] AFTER START ENR
ERR		; Биты ошибок Bit:[0]-WDT, [1]-BOR, [2]-T.Inj, [3]-Err.Copm, [4]-COLT,[5]-MAP
STPCNT		; Позиция шагового двигателя
A_TMP		; *Показания ДТВ Температура двигателя
COLT		; Показания ДТОЖ
MAP		; Разряжение 0FH -Offset, 0FAH - 100КПа
TPS		; Положение дроссельной заслонки <14H IAC
O2S		; *Показаняи датчика кислорода
POWER		; Напряжение боротовой сети/10,29
SPD		; Обороты двигателя
T_INJ_L
T_INJ_H		; Время впрыска(мкс)
;
INJ_LAG_L 
INJ_LAG_H

RqFl		; Время впрыска при давлении 110КПа
RqFh
CRANK_COLT_L	; Время впрыска при пуске на холодную 30ms
CRANK_COLT_H
CRANK_WARM_L	; Время впрыска при пуске на горячую 5ms
CRANK_WARM_H
WARM_80		; Обогащение при прогреве горячего вдигателя (+80)
WARM_20		; Обогащение при прогреве холодного двигателя (-40)

MAN_CORR		; ПЕРЕМЕННАЯ ВЫСТАВЛЯЕМАЯ РУЧНУЮ КОРРЕКТИРОВКУ

WARM_40
WARM_50
D_TPS		; Delta TPS
ENR_12

RCOl		; 
RCOh
MCKl		; Счётчик моточасов
MCKh 

SPD_ENR
WARM_ENR		; ENRICHMENT

CHK_SUM_TX		; Контрольная сумма
CHK_SUM_RX
;
STP_CN_UP		; Счётчик регулятора ХХ
PMPC		; Счётчик выключения ЭБН
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

FLAG		; [0]- Передача пакета, [1]-Флаг расчёта оборотов [2] - расчёт корректировки [3] - стабилизация оборотво двигателя [4] позиционирование РХХ
IAC_INIT		; Начальное положение РХХ для запуска двигателя
TX_DEL_CNT		; Счётчик задержки для передачи пакетов
dil_t
dil_t2
;TMPI
TMRL
TMRH
D_TPS1
TEMP
FLG_C
STATUS_TEMP	; Регистр сохранения регистра статуса
PCLATH_TEMP	; 
	endc
W_TEMP	EQU		07FH
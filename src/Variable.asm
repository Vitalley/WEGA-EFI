MB0	udata ;20
;	cblock	20
AF	RES .1		; БАЙТ b'10101111'
BT_CNT	RES .1		; Счётчик байтов передачи, при передаче всегда 01H
VERSION	RES .1		; НОМЕР ВЕРСИИ пакета 10H
SIZE	RES .1		; Размер пакета
STAT	RES .1		; Отображает режим работы (побитовый) 
			;[0]-Motor on [1]-Warm_Up on [2]-IAC [3]-Accel 
			;[4]-D.Accel [5]-ЭПХХ [6]-ЭМР [7] AFTER START ENR
ERR	RES .1		; Биты ошибок 
			;Bit:[0]-WDT, [1]-BOR, [2]-T.Inj, [3]-Err.Copm, [4]-COLT,
			;[5]-MAP [6]-O2S [7] - IAT
STPCNT	RES .1		; Позиция шагового двигателя
ColtF	RES .1;5		; *Показания ДТВ Температура двигателя
COLT	RES .1;6		; Показания ДТОЖ
MAP	RES .1;7		; Разряжение во впускном коллеторе
TPS	RES .1;8		; Положение дроссельной заслонки
O2S	RES .1;9		; Показаняи датчика кислорода Lambda=(O2S/2+64)/128
POWER	RES .1;10		; Напряжение боротовой сети/10,2
SPD	RES .1;11		; Обороты двигателя (SPD*25)
T_INJ_L	RES .1;12
T_INJ_H	RES .1;13		; Время впрыска(мкс)
;
INJ_LAG_L	RES .1;14 		; Время срабатывания форсунки
INJ_LAG_H	RES .1;15


RqFl	RES .1;16		; Время впрыска при давлении 110КПа
RqFh	RES .1;17
RCOl	RES .1;18		; 
RCOh	RES .1;19
MCKl	RES .1;20		; Счётчик моточасов
MCKh	RES .1;21


WARM_80	RES .1;22		; Обогащение при прогреве горячего вдигателя (+80)
WARM_20	RES .1;23		;+20 Обогащение при прогреве холодного двигателя (-40)

eSTAT	RES .1		; Расширенный статус блока

WARM_40	RES .1;25		;-40
WARM_50	RES .1;26		;+50
D_TPS	RES .1		; Delta TPS
ENR_12	RES .1;28		;-12
;----
RESERV	RES .2		; Резерв 2 байта в протоколе
;----
UOZ	RES .1
MAN_CORR	RES .1		; ПЕРЕМЕННАЯ ВЫСТАВЛЯЕМАЯ РУЧНУЮ КОРРЕКТИРОВКУ
SPD_ENR	RES .1;33		; Корреция смени по скорости
WARM_ENR	RES .1;34		; ENRICHMENT
;конец пакета передачи
CHK_SUM_TX	RES .1		; Контрольная сумма
;-------------------------------------------------------------------
CHK_SUM_RX RES .1
;
STP_CNT_UP RES .1		; Счётчик регулятора ХХ
PMPC RES .1			; Счётчик выключения ЭБН
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


 
; Размещение данных доступных из всех банков контроллера
MB1 UDATA_SHR

;RQF2 RES .1
;FLG_C RES .1
ADC_SEL RES .1		; Select chenal ADC

FLAG RES .1		; [0] - Разрешение на передачу пакета состояния,
		; [1] - Флаг расчёта оборотов 
		; [2] - расчёт корректировки 
		; [3] - стабилизация оборотво двигателя 
		; [4] - позиционирование РХХ 
		; [5] - выбор канала АЦП
		; [6] - обработка данных с АЦП питания
		; [7] - Расчёт цикловой подачи топлива
FLAG2 RES .1	; [0] - Сохраняем время в ЕЕПРОМ
IAC_INIT RES .1		; Начальное положение РХХ для запуска двигателя
TX_DEL_CNT RES .1		; Счётчик задержки для передачи пакетов
dil_t RES .1
dil_t2 RES .1
;TMPI
TMRL RES .1
TMRH RES .1
D_TPS1 RES .1
TEMP	RES .1	; временные данные для основного цикла
temp	RES .1	; временные данные для прерываний
; Регистры сохранения для прерываний
STATUS_TEMP RES .1	; Регистр сохранения регистра статуса
PCLATH_TEMP RES .1	; 
W_TEMP	RES .1


MB2 udata 0A0H
SPD_BUF_IND res .1 ; не реализован
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
;!!!ВРЕМЕННО ПЕРЕСЕНА!!!
RX_DATA RES .1	; ПРинятый байт
TIME_DIV RES .2	; Делитель минутный
MINUTE_CNT RES .1	; Делитель часовой
TEMP_MULT RES .3
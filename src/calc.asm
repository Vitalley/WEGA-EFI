;-----------------------------------------------------
; Расчёт цикловой подачи топлива, работает в основном цикле
;-----------------------------------------------------
M_CALC	BCF	FLAG,7
	BTFSC	STAT,0		; Проверяем двигатель
	GOTO	CALC		; Двигатель включён и имеет обороты >400
	BCF	STAT,6
;-----------------------------------------------------------
; Вычисление времени впрыска на пуске двигателя
;{----------------------------------------------------------
	MOVF	TPS,W		; Записываем положение ДЗ	
	SUBLW	FL_CLEAR*.255/.5000	; Порог включения режима продувки
	BTFSC	STATUS,C		; Если положение ДЗ меньше порога
	GOTO	$+4
	CLRF	T_INJ_H		; Минимальное время открытия форсунки
	CLRF	T_INJ_L
	RETURN
;ДОБАВЛЕНА ФУНКЦИЯ КВАДРАТИЧНОЙ ИНТЕРПОЛЯЦИИ
	movab	COLT,MULc		; COLT^2
	movab	COLT,MULp
	CALL	MUL8
	movab	H_byte,MULc
; САМА ИНТЕРПОЛЯЦИЯ
	CLRF	Mul1Hi
;	movab	COLT,MULc		; Температура двигателя - множитель
	MOVLW	low (CRANK_COLT-CRANK_HOT)
	MOVWF	Mul1Lo		; Разность врмён впрыска - множимое
	
	MOVLW	high (CRANK_COLT-CRANK_HOT)
	MOVWF	Mul1Hi		; Разность врмён впрыска - множимое

	CALL	MUL16_8		; Умножение 16х8
	MOVF	Mul1Hi,W
	ADDLW	low CRANK_HOT
	MOVWF	T_INJ_L
	BTFSC	STATUS,C		; проверяем CARRY
	INCF 	ResHi,F
	MOVF	ResHi,W
	ADDLW	high CRANK_HOT
	MOVWF	T_INJ_H

;	BSF	STAT,7
	CLRF	D_TPS
	BCF	ERR,2
	;CALL	STPUP		; по шагу открываем дроссель
	RETURN
;}
;-----------------------------------------------------
; Основной расчёт времени впрыска
; TI = RCO + ((MAP-Offset)(RqF - RCO) / 256) 
;-----------------------------------------------------
CALC	CLRF	Mul1Hi
; Вычисляем уровень обогащения при прогреве
;{-------------------------------------------------------
; ENR_12 = -12   B8h
; ENR_COLT +20   40h
; ENR_MID  +50   09h
; ENR_HOT  +80   0h
 ;let COLT,079H
	BTFSS	COLT,7
	GOTO	COLT_MID
	BTFSS	COLT,6
	GOTO	COLT_MID2
; -12 to -43
	movab	COLT,MULc
	BCF	MULc,7
	BCF	MULc,6
	MOVF	ENR_12,W
	SUBWF	WARM_40,W
	MOVWF	MULp
	CALL	MUL8
	RLF	L_byte,W
	RLF	H_byte,W
	RLF	H_byte,W
	ADDWF	ENR_12,W
	MOVWF	WARM_ENR
	GOTO	GO_MAP

; +20 to -12
COLT_MID2	movab	COLT,MULc
	BCF	MULc,7
	BCF	MULc,6
	MOVF	WARM_20,W
	SUBWF	ENR_12,W
	MOVWF	MULp
	CALL	MUL8	
	RLF	L_byte,F
	RLF	H_byte,F
	RLF	L_byte,F
	RLF	H_byte,W
	ADDWF	WARM_20,W
	MOVWF	WARM_ENR
	GOTO	GO_MAP
; UP +20
COLT_MID	BTFSS	COLT,6
	GOTO	COLT_MID3
; Up to +50
	movab	COLT,MULc
	BCF	MULc,7
	BCF	MULc,6
	MOVF	WARM_50,W
	SUBWF	WARM_20,W
	MOVWF	MULp
	CALL	MUL8
	RLF	L_byte,F
	RLF	H_byte,F
	RLF	L_byte,F
	RLF	H_byte,W
	ADDWF	WARM_50,W
	MOVWF	WARM_ENR
	GOTO	GO_MAP

; +50 to +80
COLT_MID3	movab	COLT,MULc
	BCF	MULc,7
	BCF	MULc,6
	MOVF	WARM_80,W
	SUBWF	WARM_50,W
	MOVWF	MULp
	CALL	MUL8
	RLF	L_byte,F
	RLF	H_byte,F
	RLF	L_byte,F
	RLF	H_byte,W
	ADDWF	WARM_80,W
	MOVWF	WARM_ENR
;	CLRF	WARM_ENR
;}
;-------------------------------------------------------------
GO_MAP	RRF	WARM_ENR,F
	BSF	WARM_ENR,7	
; Обогащение смеси после пуска двигателя
	BTFSS	STAT,7		; Проверка флага включения обогащения после старта
	GOTO	GET_ACCEL
	DECF	D_TPS,F
	BTFSC	D_TPS,7
	GOTO	SPD_E
	BCF	STAT,7
; вычисление режима обогащения
GET_ACCEL	MOVF	TPS1,W		; Предыдущее ПДЗ
	SUBWF	TPS,W		; Вычитаем из предыдущего положения ДЗ настоящее
	MOVWF	D_TPS1		; сохраняем как дельту

	BTFSS	STATUS,C		; Проверяем на наличие ускорения
	GOTO	D_ACCL

	BTFSC	STATUS,Z		; Проверяем на наличие ускорения
	GOTO	ACCL_END

	SUBLW	ACL_THR		; Вычитаем  дельту с порога ускорения
	BTFSC	STATUS,C		; Проверяем порог ускорения
	GOTO	ACCL_END

	BCF	STATUS,C
	RRF	D_TPS1,F		; Поделить на 2 коэфф. обогащения
	BCF	STATUS,C
	RRF	D_TPS1,F		; Поделить на 2 коэфф. обогащения

	MOVF	D_TPS,W		; текущее обогащение
	ANDLW	B'01111111'
	SUBWF	D_TPS1,W		; вычитаем текущее обогащение из вычисленного
	BTFSC	STATUS,Z
	GOTO	$+5
	BTFSS	STATUS,C		; если текущее обогащение меньше вычисленного, то
	GOTO	$+3
	MOVF	D_TPS1,W
	MOVWF	D_TPS
	
ACLEE	BSF	ACCEL		; Вкл. светодиод акселерации
	BSF	STAT,3		; Вкл. флаг акселерации
	BSF	D_TPS,7
	GOTO	SPD_E
; Подпрограмма обеднения смеси при сбрасывании тапка
D_ACCL	SUBLW	0FFH
	SUBLW	80H
	MOVWF	D_TPS
	BSF	STAT,4
	GOTO	SPD_E

ACCL_END	MOVF	D_TPS,W
	BTFSC	STATUS,Z
	GOTO	$+4
	DECF	D_TPS,F
	BTFSC	D_TPS,7
	GOTO	ACLEE

	BCF	ACCEL
;	CLRF	D_TPS
	BCF	STAT,3
	BCF	STAT,4
; Обработка таблицы объёмной эффективности в зависимости от оборотов двигателя
SPD_E	movab	SPD,TEMP
	CALL	READ_STR
	MOVWF	SPD_ENR
	PAGESEL	SPD_E	
; SPD_ENR=(обог%)/100*256
; Обогащение по скорости=SPD_ENR/256*100
IFDEF ECON_CORR
; Экономайзер тапки в пол Основная смесь - 12,5
	MOVF	TPS,W	
	SUBLW	0CCH		; Порог 4.5v
	BTFSC	STATUS,C
	GOTO	TR_EN
	BTFSC	STAT,1		; Проверка флага прогрева двигателя
	GOTO	TR_EN
	MOVLW	D'100'		; Нижний порог оборотов 2500
	SUBWF	SPD,W
	BTFSS	STATUS,C
	GOTO	TR_EN
	let	Mul1Lo,0B3H		;  1.339
	let	Mul1Hi,0H
	GOTO	MUL_ENR
; Экономайзер мощностных режимов Основная смесь - 13,5
TR_EN	MOVF	MAP,W	
	SUBLW	099H		; Порог 80H-60KPa, 99H-70KPa, B3H-80KPa, BD-85KPa
	BTFSC	STATUS,C		; 
	GOTO	EMR_OFF
	let	Mul1Lo,09DH		; 1.244*127
	let	Mul1Hi,0H
	
MUL_ENR	BSF	ACCEL
	BSF	STAT,6
	MOVF	SPD_ENR,W
	MOVWF	MULc
	CALL	MUL16_8
	RLF	Mul1Lo,W		; Помещаем бит 7 в С
	RLF	Mul1Hi,W		; Перемещаем карри в 1 бит
	MOVWF	SPD_ENR
	GOTO	ECON
ENDIF
EMR_OFF	BCF	STAT,6
	BCF	STATUS,C
	RLF	SPD_ENR,F
;-----------------------------------------------------



;-----------------------------------------------------
;  ЭКОНОМАЙЗЕР ПРИНУДИТЕЛЬНОГО ХОЛОСТОГО ХОДА
;{-----------------------------------------------------
ECON	BTFSS	STAT,7	
	BTFSS	STAT,2		; Проверка холостого хода
	GOTO	Ln_Int
; Добавил для устранения подёргивания на прогреве и ухода в ЭПХХ
	BTFSC	COLT,7
	GOTO	Ln_Int



	BTFSC	STAT,5		; Проверка 
	GOTO	$+9	
	MOVF	SPD,W		; Верхний порог оборотов	
	SUBLW	(SPD_EPHH/.25)+4
	BTFSC	STATUS,C	
	GOTO	Ln_Int
	BSF	STAT,5		; Ставим бит включённого экономайзера
	CLRF	T_INJ_H
	CLRF	T_INJ_L
	GOTO	EXT

	MOVLW	(SPD_EPHH/.25)-1		; Нижний порог оборотов
	SUBWF	SPD,W
	BTFSS	STATUS,C
	GOTO	Ln_Int
	CLRF	T_INJ_H
	CLRF	T_INJ_L
	GOTO	EXT
;}
;-----------------------------------------------------
;  ЛИНЕЙНАЯ ИНТЕРПОЛЯЦИЯ ВЫЧИСЛЕНИЯ ВРЕМЕНИ ВПРЫСКА
;{-----------------------------------------------------
Ln_Int	BCF	STAT,5
IFNDEF LineIntFuelEqual
; Выравнивание для датчика MPX4100AP
; Pres=(MAP+Offcet)*Slope/256 
	BCF	Flag_Math,2
	CLRF	Mul1Hi
	MOVLW	OFFSET	;Добавка для выравнивания характеристики ДАД
	ADDWF	MAP,W
	ADDCF	Mul1Hi,F
	MOVWF	Mul1Lo		; Mul1=(MAP+Offset)
	let	MULc,SLOPE	; Наклон характеристики ДАД
	CALL	MUL16_8		; Умножение 16х8
	TSTF	ResHi
;	SKPZ
;	BSF	Flag_Math,2	
	SKPNZ
	GOTO	$+3
	let	Mul1Hi,0FFH
	movab	Mul1Hi,MULc		; Выравненное значение в MULc
movab Mul1Hi,UOZ
	MOVF	RqFl,W
	MOVWF	Mul1Lo		; MULp=low RqF
	MOVF	RqFh,W
	MOVWF	Mul1Hi		; MULp=high RqF

	CALL	MUL16_8		; Умножение 16х8

;	BTFSS	Flag_Math,2		; Домножаем на старшый бит 255
;	GOTO	Sreslt

;	MOVF	Mul1Lo,W		; СОХРАНЕНИЕ РЕГИСТРОВ
;	banksel	TEMP_MULT
;	MOVWF	TEMP_MULT
;	bank0
;	MOVF	Mul1Hi,W
;	banksel	TEMP_MULT
;	MOVWF	TEMP_MULT+1
;	bank0
;	MOVF	ResHi,W
;	banksel	TEMP_MULT
;	MOVWF	TEMP_MULT+2
;	bank0
;	MOVLW	0FFH
;	MOVWF	MULc
;	MOVF	RqFl,W
;	MOVWF	Mul1Lo		; MULp=low RqF
;	MOVF	RqFh,W
;	MOVWF	Mul1Hi		; MULp=high RqF
;
;	CALL	MUL16_8		; Умножение 16х8
;
;	MOVF	Mul1Lo,W		; СЛОЖЕНИЕ С СОХРАНЁННЫМИ РЕГИСТРАМИ
;	banksel	TEMP_MULT
;	ADDWF	TEMP_MULT,W
;	bank0
;	MOVWF	Mul1Lo
;
;	BTFSS	STATUS,C
;	GOTO	$+3
;	MOVLW	.1	
;	ADDWF	Mul1Hi,F

;	BTFSC	STATUS,C
;	INCF	ResHi,F

;	MOVF	Mul1Hi,W
;	banksel	TEMP_MULT
;	ADDWF	TEMP_MULT+1,W
;	bank0
;	MOVWF	Mul1Hi

;	BTFSC	STATUS,C
;	INCF	ResHi,F
;	MOVF	ResHi,W
;	banksel	TEMP_MULT
;	ADDWF	TEMP_MULT+2,W
;	bank0
;	MOVWF	ResHi



Sreslt	MOVF	Mul1Hi,W
	MOVWF	T_INJ_L
	MOVF	ResHi,W
	MOVWF	T_INJ_H

EqlOut
ENDIF
IFDEF LineIntFuelEqual
	MOVF	MAP,W
	MOVWF	MULc		; MULc=MAP

	CLRF	Mul1Hi
	MOVF	RCOl,W
	SUBWF	RqFl,W
	MOVWF	Mul1Lo		; MULp=low (RqF-RCO)
	BTFSC	STATUS,C
;-- тут ошибка
	DECF	Mul1Hi,F
;---
	MOVF	RCOl,W
	SUBWF	RqFh,W
	MOVWF	Mul1Hi		; MULp=high (RqF-RCO)

	CALL	MUL16_8		; Умножение 16х8
	MOVF	Mul1Hi,W
	ADDWF	RCOl,W
	MOVWF	T_INJ_L
	BTFSC	STATUS,C
	INCF	ResHi,F
	MOVF	ResHi,W
	ADDWF	RCOh,W
	MOVWF	T_INJ_H
ENDIF
;}
; Выбор канала АЦП ДПДЗ
;	let	ADCON0,ADC_TPS	; AN0 TPS
; Корректировка смеси в зависимости от оборотов
	movab	SPD_ENR,MULc
	movab	T_INJ_L,Mul1Lo
	movab	T_INJ_H,Mul1Hi
	CALL	MUL16_8		; Умножение 16х8
	RLF	Mul1Lo,W
	RLF	Mul1Hi,W
	MOVF	Mul1Hi,W
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	; получается здесь не сходятся коэффифиенты коррекции
IFDEF VE_CORR
	MOVWF	T_INJ_L
	RLF	ResHi,W
	MOVF	ResHi,W
	MOVWF	T_INJ_H
ENDIF
	BTFSS	STAT,1		; Проверка флага прогрева двигателя
	GOTO	ACCL
	

Warm_Enr	;RRF	WARM_ENR,F
	;BSF	WARM_ENR,7
	movab	WARM_ENR,MULc

	movab	T_INJ_L,Mul1Lo
	movab	T_INJ_H,Mul1Hi
	CALL	MUL16_8		; Умножение 16х8
IFDEF WARM_CORR
	RLF	Mul1Lo,W
	RLF	Mul1Hi,W
	MOVWF	T_INJ_L
	RLF	ResHi,W
	MOVWF	T_INJ_H
ENDIF
; Програмный модуль вычисления обогащения
ACCL	BTFSC	STAT,7	
	GOTO	Corr
IFDEF ACCEL_CORR
	BTFSS	STAT,3
	BTFSC	STAT,4
	GOTO	$+2
ENDIF
	GOTO	EXT2
Corr	movab	D_TPS,MULc
	movab	T_INJ_L,Mul1Lo
	movab	T_INJ_H,Mul1Hi
	CALL	MUL16_8		; Умножение 16х8
	RLF	Mul1Lo,W
	RLF	Mul1Hi,W

	MOVWF	T_INJ_L
	RLF	ResHi,W
	MOVWF	T_INJ_H

; запуск вычисления АЦП ДПДЗ
EXT2	BCF	STAT,5
;	BSF	ADCON0,GO
;	RETURN
; Выход в режиме экономайзера ПХХ
EXT	let	ADCON0,ADC_TPS
	CALL	DELEY20
	BSF	ADCON0,GO
	RETURN

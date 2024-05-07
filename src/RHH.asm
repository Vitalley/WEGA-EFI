;-------------------------------------------------------------
;      Библиотека управления шаговым двигателем
;-------------------------------------------------------------
;
;        DELAY    - Подпрограмма задержки
;
;        STPINIT  - Инициализация шагового двигателя, делает 255 шагов на закрытие, и 70 на открытие
;        STPUP    - Открыть заслонку на один шаг
;        STPDOWN  - На один шаг закрыть
;
;
;        STPCNT  - Переменная указывает текущую позицию шагового двигателя

;====================================================
;#DEFINE	STEPA	PORTB,0	 ;
;#DEFINE	STEPB	PORTB,1	 ;
;=====================================================
STPINIT	let	STPCNT,IAC_MAX	;Сбрасываем счётчик ходов
STPI	CALL	STPDOWN		;Делаем IAC_MAX ходов в сторону закрытия
	CALL	DELAY		;Задержка между импульсами
	DECFSZ	STPCNT,F
	GOTO	STPI
	BSF	FLAG,4		;Включаем флаг на позиционирование РХХ
	let	IAC_INIT,IAC_WARM
	RETURN

ST_INI	BTFSC	STAT,0
	GOTO	SET_STEP
 NOP
;ДОБАВЛЕНА ФУНКЦИЯ КВАДРАТИЧНОЙ ИНТЕРПОЛЯЦИИ
	movab	COLT,MULc		; COLT^2
	movab	COLT,MULp
	CALL	MUL8
	movab	H_byte,MULc
; САМА ИНТЕРПОЛЯЦИЯ
;	movab	COLT,MULc
	let	MULp,IAC_COLT-IAC_WARM
	CALL	MUL8

	MOVF	H_byte,W
	ADDLW	IAC_WARM
	MOVWF	IAC_INIT

SET_STEP	;CALL	SETSTP
	CALL	STPUP			;выставляем шаговик в начальное положение
	MOVFW	STPCNT
	SUBWF	IAC_INIT,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	BCF	FLAG,4
	RETURN

;	ФАЗА:	F1	F2	F3	F4
;	PORTB,0	1	0	0	1	- Линия А
;	PORTB,1	1	1	0	0	- Линия Б
; УСТАНОВКА РХХ СОГЛАСНО ПЕРЕМЕННОЙ РУЧНОЙ КАЛИБРОВКИ
IFDEF MANSETIAC
SET_MAN	BCF	STATUS,C
	RRF	MAN_CORR,W	
; УСТАНОВКА В ПОЗИЦИЮ УКАЗАНУЮ В W
SETSTP	SUBWF	STPCNT,W		; Вычитаем из аккумулятора положение РХХ
	BTFSS	STATUS,C
	GOTO	STPUP	

	BTFSS	STATUS,Z
	GOTO	STPD
	RETURN
endif





; ===========================================================================
; Стабилизация оборотов коленчатого вала двигателя
; ===========================================================================
STAB	BCF	FLAG,3		; Сброс флага обработки
	BTFSC	FLAG,4		; Флаг позиционирования РХХ
	GOTO	ST_INI
IFDEF MANSETIAC
	BTFSC	PIN1		; Ручное управление РХХ
	GOTO	SET_MAN
endif
	BTFSS	STAT,0		; Проверка запуска двигателя
	RETURN
IFDEF IAC_TRSH
; Схема замедления скорости движения РХХ
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
	BTFSC	STAT,2		; Проверка холостого хода
	GOTO	DEMFEROUT
	MOVLW	DEMFER
	SUBWF	STPCNT,W		; Вычитаем из аккумулятора положение РХХ
	BTFSS	STATUS,C
	GOTO	STPUP
DEMFEROUT
ENDIF
IFDEF WARM_TRSH
#define	TRSHH	(WARM_TRSH+.273)*.51 ;MPASM больше трёх скобок не обрабатывает
	MOVLW	.255-(((TRSHH/.100)-075H)*.4)
	SUBWF	COLT,W
	BTFSC	STATUS,C
	GOTO	WST
	BTFSC	STAT,7
	GOTO	WST
ENDIF
IFNDEF WARM_TRSH
	BTFSC	COLT,7; STAT,1	; Проверка прогрева двигателя
	GOTO	WST
	BTFSC	STAT,7
	GOTO	WST
ENDIF


STABILIZE	MOVLW	(SPD_HOT/.25)-.1	; Нижний порог оборотов
	SUBWF	SPD,W		; 
	BTFSC	STATUS,C
	GOTO	STABH
	CLRF	STP_CNT_DWN
	ADDLW	.9
	BTFSS	STATUS,C	
	GOTO	STABOPN
	MOVLW	(SPD_HOT/.25)-.1	; Нижний порог оборотов
	SUBWF	SPD,W		; 
	CALL	DELT_DEL_UP
	INCF	STP_CNT_UP,F		;
	MOVF	STP_CNT_UP,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
STABOPN	CALL	STPUP		; На один шаг открыть дроссельный канал
	RETURN

STABH	CLRF	STP_CNT_UP
	BTFSS	STAT,2		; Проверка холостого хода
	RETURN
		
	MOVLW	(SPD_HOT/.25)+.2	; Верхний порог оборотов
	SUBWF	SPD,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C	
	RETURN
	SUBLW	020H		; более 20*25об/мин без задержки
	BTFSS	STATUS,C		; без задержки
	GOTO	CLWWHTDEL

	MOVF	SPD,W
	SUBLW	(SPD_HOT/.25)+.2	; Верхний порог оборотов
	CALL	DELT_DEL
	INCF	STP_CNT_DWN,F
	MOVF	STP_CNT_DWN,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
CLWWHTDEL	CALL	STPD
	RETURN
;Стабилизация оборотов на прогреве
WST	MOVLW	(SPD_WARM/.25)-.2	; Нижний порог оборотов
	SUBWF	SPD,W		; 
	BTFSC	STATUS,C
	GOTO	STABHWR
	CLRF	STP_CNT_DWN
	ADDLW	.9
	BTFSS	STATUS,C	
	GOTO	STABOPN
	MOVLW	(SPD_WARM/.25)-.2	; Нижний порог оборотов
	SUBWF	SPD,W		; 
	CALL	DELT_DEL_UP
	INCF	STP_CNT_UP,F
	MOVF	STP_CNT_UP,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	CALL	STPUP		; На один шаг открыть дроссельный канал
	RETURN

STABHWR	CLRF	STP_CNT_UP
	BTFSS	STAT,2		; Проверка холостого хода
	RETURN
	
	MOVLW	(SPD_WARM/.25)+.2	; Верхний порог оборотов
	SUBWF	SPD,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C	
	RETURN
	SUBLW	020H		; более 20*25об/мин без задержки
	BTFSS	STATUS,C		; без задержки
	GOTO	CLWWHTDELWR

	MOVF	SPD,W
	SUBLW	(SPD_WARM/.25)+.2	; Верхний порог оборотов
	CALL	DELT_DEL
	INCF	STP_CNT_DWN,F
	MOVF	STP_CNT_DWN,W
	SUBWF	STP_SPEED,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
CLWWHTDELWR	CALL	STPD
	RETURN

;----------------------------------------------------
;     ДВИЖЕНИЕ ШАГОВИКОМ НА ШАГ ОТКРЫТЬ
;----------------------------------------------------
STPUP	CLRF	STP_CNT_UP
	MOVF	STPCNT,W		; ПРОВЕРКА НА МАКСИМАЛЬНОЕ ОТКРЫТИЕ
	SUBLW	IAC_MAX		; МАКС КОЛИЧЕСТВО ШАГОВ
	BTFSS	STATUS,C		;
	RETURN			; ЕСЛИ ДА-ТО ВЫХОДИМ
	INCF	STPCNT,F
	BTFSS 	STEPA		; ПРОВЕРКА ЛИИ А
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
;   ДВИЖЕНИЕ ШАГОВИКОМ НА ЗАКРЫВАНИЕ
;-------------------------------------------
STPD	CLRF	STP_CNT_DWN
	MOVLW	IAC_MIN
	BTFSC	STAT,1
	MOVLW	IAC_MIN	; Проверка на минимальное полодение РХХ
	SUBWF	STPCNT,W
	BTFSC	STATUS,C
	BTFSC	STATUS,Z
	RETURN
	DECF	STPCNT,F
STPDOWN 	BTFSS 	STEPA		; ПРОВЕРКА ЛИИ А
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

; Подпрограммы вычисления скорости движения РХХ
; 
DELT_DEL	ADDLW	.1
	BTFSS	STATUS,Z
	GOTO	$+4
	MOVLW	0FFH		; МАКСИМАЛЬНАЯ ЗАДЕРЖКА ПРИ РАЗНИЦЕ 25 ОБ/МИН
	MOVWF	STP_SPEED
	RETURN
	CLRF	STP_SPEED
	BSF	STP_SPEED,7		; STP_CN=80H
DEL_LOOP	ADDLW	.2		; коэфф замедления
	BTFSC	STATUS,C
	RETURN
	RRF	STP_SPEED,F
	GOTO	DEL_LOOP

; DELTA TO DELAY UP
DELT_DEL_UP	ADDLW	.1
	BTFSS	STATUS,Z
	GOTO	$+4
	MOVLW	0FFH		; МАКСИМАЛЬНАЯ ЗАДЕРЖКА ПРИ РАЗНИЦЕ 25 ОБ/МИН
	MOVWF	STP_SPEED
	RETURN
	CLRF	STP_SPEED
	BSF	STP_SPEED,7		; STP_CN=80H
DEL_LOOP_UP	ADDLW	.1
	BTFSC	STATUS,C
	RETURN
	RRF	STP_SPEED,F
	GOTO	DEL_LOOP_UP

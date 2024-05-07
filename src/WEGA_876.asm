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
#include Variable.asm		; Вариант динамического выделения памяти при линковке
#include Config.inc		; Вынесена аппаратная конфигурация


GO_BOOT	ORG	0		; processor reset vector
;	PAGESEL 	Bootloader
;	GOTO    	Bootloader
;	nop
GO_INIT	GOTO	INIT		; go to beginning of program
;------------------------------------------------------------------
;		ОБРАБОТКА ПРЕРЫВАНИЙ
;{------------------------------------------------------------------
	ORG	4		; Вектор прерываний
	MOVWF 	W_TEMP		; Копировать W во временный регистр независимо от текущего банка
	SWAPF 	STATUS,W		; Обменять полубайты в регистре STATUS и записать в W		
	CLRF 	STATUS
	MOVWF 	STATUS_TEMP		; Сохранить STATUS во временном регистре банка 0
	MOVF 	PCLATH, W 		;
	MOVWF 	PCLATH_TEMP		;
	CLRF 	PCLATH 		;
	BTFSC	PIR1,CCP1IF		; Модуль сравнения
	GOTO	COMP_EVNT
	BTFSC	INTCON,INTF		; импульс зажигания?
	GOTO	SPARK
	BTFSC	PIR1,TMR1IF		; Проверка переполнение таймера ТМР1
	GOTO	TMR_OF
 	BTFSC 	PIR1,ADIF		; Прерывание АЦП
	GOTO 	Int_AD
	BTFSC	INTCON,T0IF		; Общая синхронизация по ТМР0
	GOTO	TMR_EV		
   	BTFSC 	PIR1,RCIF    	; Приём байта USART Rx?
	GOTO 	Int_RX


;------------------------ INT exit-----------------------
RET 	MOVF	PCLATH_TEMP, W 	;
	MOVWF	PCLATH 		;
	SWAPF	STATUS_TEMP,W 	;Обменять полубайты оригинального значения STATUS и записать в W (восстановить текущий банк)
	MOVWF	STATUS		;Восстановить значение STATUS из регистра W
	SWAPF	W_TEMP,F		;Обменять полубайты в регистре W_TEMP и сохранить результат в W_TEMP
	SWAPF	W_TEMP,W		;Обменять полубайты в регистре W_TEMP и восстановить оригинальное значение W без воздействия на STATUS
	RETFIE
;}

;------------------------------------------------------------------
;		ИНИЦИАЛИЗАЦИЯ
;{------------------------------------------------------------------
 INIT	CLRF	ERR
	CLRF	STAT
	CLRF	eSTAT
	bank1
	let	TRISA,b'00111111'
	let	TRISB,b'00000001'
	let	TRISC,b'10000000'
	let	OPTION_REG,b'11000111'	; Подтягивающие резисторы включены(Предделитель на tmr0)
	let	PIE1,B'01100101' 	; Записать маску прерываний в регистр PIE1
; Настройка УАПП
	MOVLW	.103       		; Установить скорость обмена данными(F=9615 Hz)
	MOVWF	SPBRG
	MOVLW	B'00100110'  	; Передача 8 - разрядных данных, включить передатчик,
 	MOVWF	TXSTA		; ВЫСОКОСКОРОСТНОЙ асинхронный режим
	let	ADCON1,b'00000010'	;
; Определение типа сброса контроллера
	BTFSS	PCON,NOT_POR
	GOTO	SETPOR
	BTFSS	PCON,NOT_BOR	; BOR - Флаг сброса по снижению напряжения
	CALL	ERR_BOR
SETPOR	BSF	PCON,NOT_POR
	BSF	PCON,NOT_BOR
	bank0
; Перед позиционированием РХХ надо измерить температуру ОЖ
	let	ADCON0,ADC_COLT	;
	CLRF	TMR0
	CLRF	TMR1L
	CLRF	TMR1H
; Определение типа сброса контроллера
	BTFSS	STATUS,NOT_TO	; TO - WDT - БИТЫ ИНВЕРСНЫЕ!!!
	BSF	ERR,0
	CLRF	PORTC
	CLRF 	PORTB
	let	T1CON,B'00110000'	; Инициализация ТМР1, предделитель 1:8 (тик - 2мкс, счёт до 128мс)
	CLRF	CCP1CON		; Инициализация CCP1
  	MOVLW	B'10010000'  	; Прием 8 - разрядных данных, включить приемник,
   	MOVWF	RCSTA       	; включить модуль USART 
;------------------------------------------------------------------
;		УСТАНОВКА ПЕРЕМЕННЫХ
;------------------------------------------------------------------   
	CLRWDT 
	BSF	PUMP		; Включаем бензонасос

	CLRF	BT_CNT
	let	AF,0AFH		; Байт заголовка протокола
	let	VERSION,010H	; Номер версии протокола
	let	SIZE,.38		; Размер передаваемого пакета
	let	INJ_LAG_L,low LAG134	; Время открытия форсунки
	let	INJ_LAG_H,high LAG134	; Время открытия форсунки


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
	let 	INTCON,B'11110000'	; ГЛОБАЛЬНЕО РАЗРЕШЕНИЕ ПРЕРЫВАНИЙ
	CALL	STPINIT		; Сброс позиции ШАГОВОГО ДВИГАТЕЛЯ
;	BSF	INTCON,GIE
IFDEF PR_PULSE
	BSF	INTCON,INTF		; Подготовительный впрыск
ENDIF
	GOTO 	MAIN
;}
;------------------------------------------------------------------
;		ОНОВНОЙ ЦИКЛ ПРОГРАММЫ
;{------------------------------------------------------------------
MAIN	CLRWDT
	bank0
#IFDEF Debug
	BTFSC	PIN1
	BSF	ERR,7
	BTFSS	PIN1
	BCF	ERR,7		
#ENDIF


 	BTFSS	FLAG,0		; ПЕРЕДАЧА АКТИВНА?
	GOTO	NEXT
	
	bank1 
	BTFSS	TXSTA,TRMT		; ПЕРЕДАЧА 
	GOTO	NX		; ДАННЫХ
	bank0
	CALL	TX
NX	bank0
	GOTO	NX2

NEXT	BTFSC	TXSTA,TRMT		; После завершения передачи И опустошения буфера передачи
	BSF	RCSTA,CREN		; Включаем приёмник

NX2	BTFSC	FLAG,7		; Расчёт цикловой подачи
	CALL	M_CALC
	BTFSC	FLAG,1		; Флаг расчёта оборотов двигателя
	GOTO	M_SPD
	BTFSC	FLAG,3		; Стабилизация оборотов двигателя
	CALL	STAB
	BTFSC	FLAG,5
	CALL	ADC_SELECT
	BTFSC	FLAG,2		; Расчёт корректировки смеси
	GOTO	CORR
	BTFSC	FLAG2,0		; Счётчик моточасов
	CALL	WRT_CNTR
	BTFSC	FLAG,6
	CALL	LAG		; Вычисляем лаг форсунки
	BTFSS	RCSTA,OERR		;Ошибка переполнения внутреннего буфера, устанавливаетсяв ‘0’ при сбросе бита CREN
	GOTO	MAIN
	BCF	RCSTA,CREN	
	BSF	RCSTA,CREN
	GOTO	MAIN
;-----------------------------------------------------
;	ПЕРЕДАЧА ДАННЫХ
;-----------------------------------------------------
TX	MOVF	BT_CNT,W		; КОЛИЧЕСТВО БАЙТ В ПАКЕТЕ +1
	SUBWF	SIZE,W		;
	BTFSC	STATUS,Z		; ПРОВЕРЯЕМ НА ПЕРЕПОЛНЕНИЕ
	GOTO	CLR_TX		; ОБНУЛЕНИЕ СЧЁТЧИКА И КОНТРОЛЬНОЙ СУММЫ
	BTFSS	STATUS,C		; ПРОВЕРЯЕМ НА ПЕРЕПОЛНЕНИЕ
	GOTO	CLR_TX		; ОБНУЛЕНИЕ СЧЁТЧИКА И КОНТРОЛЬНОЙ СУММЫ
	movab	BT_CNT,FSR		; ЗАГРУЖАЕМ СЧЁТЧИК БАЙТ В РЕГИСТР КОСВЕННОЙ АДРЕСАЦИИ	
	MOVLW	20H		; Добавляем начало блока переменных
	ADDWF	FSR,F		; Приращаем FSR на начальное значение
	Movfw	INDF		; Читаем байт с памяти	
	ADDWF	CHK_SUM_TX,F		; ДОБАВЛЯЕМ БАЙТ ДЛЯ РАСЧЁТА КОНТРОЛЬНОЙ СУММЫ
	MOVWF	TXREG
;	bank1 
;	BTFSS    	TXSTA,TRMT		; ПЕРЕДАЧА 
;	GOTO    	 $-1		; ДАННЫХ
;	bank0
	INCF	BT_CNT,F
	RETURN
WRT_CNTR
	BCF	FLAG2,0
	RETURN
;-----------------------------------------------------
;	Расчёт корректировок
;-----------------------------------------------------
CORR	BCF	FLAG,2
IFDEF MANSETRqF
	BTFSC	PIN1
	GOTO	CORR_RCO
	let	RqFh,high (ReqFuel-.3000)
	let	RqFl,low (ReqFuel-.3000)
	SWAPF	MAN_CORR,W
	ANDLW	0F0H		; Старший полубайт
	ADDWF	RqFl,F		; в младший регистр
	BTFSC	STATUS,C
	INCF	RqFh,F	
	SWAPF	MAN_CORR,W		; Загрузка значения времени ВПРЫСКА
	ANDLW	0FH		; Младший полубайт
	ADDWF	RqFh,F		; в старший регистр
endif	

CORR_RCO
;	BCF	STATUS,C
;	RRF	MAN_CORR,F
;
;	let	RCOh,0H
;	let	RCOl,0C0H
;	SWAPF	MAN_CORR,W		; Загрузка значения времени ВПРЫСКА
;	ANDLW	0FH		; Младший полубайт
;	ADDWF	RCOh,F		; в старший регистр
;	SWAPF	MAN_CORR,W
;	ANDLW	0F0H		; Старший полубайт
;	MOVWF	RCOl		; в младший регистр

CORR_LAG;	CALL	LAG		; Вычисляем лаг форсунки
	GOTO	MAIN



;-----------------------------------------------------
;	ВЫЧИСЛЕНИЕ ОБОРОТОВ ДВИГАТЕЛЯ
;-----------------------------------------------------
M_SPD	BCF	FLAG,1
	let	Mul2Lo,low SPD_CONST; 0C0H
	let	Mul2Hi,high SPD_CONST;027H
	let	Res2Hi,upper SPD_CONST;09H
	BCF	INTCON,INTE ;Блокировка прерывания для защиты целостности переменной
	MOVF	TMRL,W
	MOVWF	DivLo
	MOVF	TMRH,W
	MOVWF	DivHi
	BSF	INTCON,INTE
; Проверка на минимальные обороты
	MOVF	DivLo,F
	BTFSS	STATUS,Z	
	GOTO	$+4
	MOVF	DivHi,F
	BTFSC	STATUS,Z
	GOTO	SPD_NULL
	CALL	Div24_16	; Вычисляем обороты двигателя
	MOVF	Mul2Hi,W	; Проверка на превышение оборотов
	BTFSC	STATUS,Z
	GOTO	SPD_INTPL
	MOVLW	0FFH	; Максимальные обороты доступные в данной системе счисления
	MOVWF	Mul2Lo


;Сюда в пишем алгоритм усреднения оборотов
SPD_INTPL	MOVLW	SPD_BUF-1	; Указатель кольцевого буфера
	ADDWF	BUF_IND,W
	MOVWF	FSR
	Movfw	Mul2Lo		; ЗАГРУЖАЕМ ВЫЧИСЛЕННУЮ СКОРОСТЬ
	MOVWF	INDF		; В ЯЧЕЙКУ КОЛЬЦЕВОГО БУФЕРА
	decfsz	BUF_IND,F
	GOTO	$+3
	MOVLW	.4
	MOVWF	BUF_IND

; Вычисляем скользящее среднее
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
; определяем остановлен/запущен двигатель
	Movf 	SPD,W	
	SUBLW	D'16'		; 400/25 обороты порога
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	GOTO	MTR_ON
	BCF	STAT,0 		; Двигатель остановлен
	GOTO	MTR_OFF
MTR_ON	BSF	STAT,0		; Двигатель запущен
	GOTO	MAIN
SPD_NULL	CLRF	SPD
MTR_OFF	BSF	STAT,7		; Включаем обогащение при старте	
	BCF	STAT,0
	GOTO	MAIN
;}
;-----------------------------------------------------
;	ОБРАБОТКА ИМПУЛЬСОВ ЗАЖИГАНИЯ
;{-----------------------------------------------------
SPARK	BCF	T1CON,TMR1ON	;выключаем таймер
	BCF    	INTCON,INTF   	;сброс флага прерывания  
	MOVF	TMR1L,W
	MOVWF	TMRL
	MOVF	TMR1H,W
	MOVWF	TMRH		;запоминаем значение таймера

	CLRF	TMR1L
	CLRF	TMR1H
	BSF	T1CON,TMR1ON		; Включаем таймер
	BCF	PIR1,ADIF		; СБРОС ПРЕРЫВАНИЯ ADC
	let	ADCON0,ADC_MAP		; Выбор канала MAP Sensor
	BTFSC	INJ2		; проверяем на завершение предыдушего цикла впрыска
	BSF	ERR,2		; Установка флага ограничения времени впрыска
	BSF	INJ1		; Включаем форсунку
	BSF	FLAG,1
	CLRF	PMPC

	; Загрузка значения времени открытия форсунки
	BCF	STATUS,C
	RRF	INJ_LAG_H,W		; старший 
	ANDLW	03h		; Защита от превышения лага, макс 2047мкс
	MOVWF	CCPR1H		; в старший регистр

	RRF	INJ_LAG_L,W
	MOVWF	CCPR1L		; в младший регистр

	BTFSS	STAT,0		; При пуске увеличиваем время открытия
	INCF	CCPR1H,F		; форсунки на 512мкс
	let	CCP1CON,B'00001010'	; Запускаем CCP1
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
	BTFSC	STAT,5		; Проверка ЭПХХ
	GOTO	INJ_CLS		; Переход на закрытие фосрунки
	GOTO	RET
;}


;-----------------------------------------------------
;	ОБРАБОТКА СОБЫТИЙ МОДУЛЯ СРАВНЕНИЯ
;{-----------------------------------------------------
COMP_EVNT	BCF	PIR1,CCP1IF		; Сбрасываем флаг сравнения
	CLRF	CCP1CON		; Остановить сравнение
	BTFSC	STAT,5		; Проверка ЭПХХ
	GOTO	INJ_CLS		; Переход на закрытие фосрунки
	BTFSC	INJ1		; ПРоверка режима PEAK
	GOTO	INJ_HOLD
	BTFSC	INJ2		; Проверка на завершение впрыска
	GOTO	INJ_CLS		; Вызов подпрограммы выключения форсунки
	BSF	ERR,3		; Установить бит ошибки обработки события сравнения	
	GOTO	RET

INJ_HOLD	BCF	INJ1		; Выключаем ключ прямой подачи напряжения
	MOVF	T_INJ_H,W
	BTFSS	STATUS,Z
	GOTO	INJ_LOAD
	MOVLW	0FH
	SUBWF	T_INJ_L,W
	BTFSS	STATUS,C
	GOTO	INJ_CLS

INJ_LOAD   	RRF	T_INJ_H,W		; Обмен полубайтами
	RRF	T_INJ_L,W
	ADDWF	CCPR1L,F

	BTFSC	STATUS,C		; проверяем CARRY
	INCF 	CCPR1H,F

	BCF	STATUS,C
	RRF	T_INJ_H,W
	ANDLW	07FH
	ADDWF	CCPR1H,F		; суммируем со значением
	let	CCP1CON,B'00001010'	; Запускаем CCP1

;	let	ADCON0,ADC_TPS
;	let	ADC_SEL,.4
;	CALL	DELEY20
;	BSF	ADCON0,GO
	GOTO	RET

;}




;------------------------------------------------------------------
; Подпрограмма обработки событий переполнения таймера TMR1
;{----------------------------------------------------------------
TMR_OF	BCF	T1CON,TMR1ON	; Останавливаем таймер
	BCF	PIR1,TMR1IF		; Сбрасываем флаг прерывания
	BCF	FLAG,1		; Сброс флага расчёта оборотов
	CLRF	TMR1H
	CLRF	TMR1L	
	BSF	FLAG,4		; ВЫСТАВИМ РХХ НА ПУСКОВОЕ ЗНАЧЕНИЕ
	CLRF	SPD		; ОБОРОТЫ РАВНЫ 0
	BCF	STAT,0		;
	BSF	STAT,7		;
INJ_CLS	CLRF	CCP1CON		; Остановить сравнение
	BCF	INJ2		; Выключаем подачу напряжения на форсунки
	NOP
	NOP
	NOP
	NOP
	NOP
	BCF	INJ1		; Впрыск закончился
	GOTO	RET

;}

;-----------------------------------------------------
;	ОБРАБОТКА СОБЫТИЙ ТАЙМРА TMR0
;{-----------------------------------------------------
TMR_EV	BCF	INTCON,T0IF		; Сброс флага прерывания
	let	TMR0,.255-.156	; Счёт таймера 10мс(100Гц)
	INCFSZ	PMPC,F		; Инкремент счётчика бензонасоса
	GOTO	TMRM2		;
	BCF	PUMP		; Выключаем бензонасос

TMRM2	DECFSZ	TX_DEL_CNT,F
	GOTO	TMRM3
	let	TX_DEL_CNT,.10	; ИНТЕРВАЛ МЕЖДУ ПАКЕТАМИ
; ДОПИСАТЬ ПРОВЕРКУ НА ТЕКУЩИЙ ПРИЁМ ДАННЫХ И ПРОВЕРКУ НА ОГРАНИЧЕНИЕ ПО ВРЕМЕНИ!!!!!!!
	BCF	RCSTA,CREN		; Останавливаем приёмник
	BSF	FLAG,0		; Бит инициализации передачи пакета
TMRM3
; ДОБАВКА Устанавливаем флаг обработки стабилизации оборотов двигателя
TMR_EX	BTFSS	STAT,0
	BSF	FLAG,3	
	BTFSC	Flag_Math,3
	GOTO	$+4
	BSF	FLAG,3	; СТАБИЛИЗАЦИЯ ОБОРОТОВ И ДРУГИЕ РАСЧЁТЫ
	BSF	Flag_Math,3
	GOTO	$+2
	BCF	Flag_Math,3	
	BSF	FLAG,5
	
	

; Счётчик моточасов
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
;	 ПОДПРОГРАММА ВЫБОРА КАНАЛА  АЦП
;{-----------------------------------------------------
ADC_SELECT	BTFSC	ADCON0,GO
	RETURN	
	BCF	PIR1,ADIF		; СБРОС ПРЕРЫВАНИЯ
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
;Необходимо 20мкс задержки после выбора канала перед запуском преобразования
	CALL	DELEY20
	BSF	ADCON0,GO
	RETURN
;}


	
;-------------------------------------------------------
;	Модули задержки и прочие модули
;{ Подпрограмма вырабатывания задержки(6.4мс)
DELAY	let	dil_t2,d'20'
	CLRWDT
DEL1	CALL 	DEL
	CLRWDT
	DECFSZ	dil_t2,f
	GOTO 	DEL1
	RETURN
; Задержка для вырабатывания длительности импульса(318мкс)
DEL	let 	dil_t,d'255'
dilt	DECFSZ 	dil_t,f
	GOTO 	dilt
	RETURN
DELEY20	let 	dil_t,d'25'
	GOTO	dilt

; ПОДПРОГРАММА УСТАНОВКИ БИТА СБРОСА ПО СНИЖЕНИЮ ПИТАНИЯ
ERR_BOR	bank0
	BSF	ERR,1
	bank1
	RETURN
; ПОДПРОГРАММА ОБНУЛЕНИЯ СЧЁТЧИКА БАЙТ ПЕРЕДАЧИ И КОНТРОЛЬНОЙ СУММЫ
CLR_TX	bank0
	CLRF	BT_CNT		; ОБНУЛЕНИЕ СЧЁТЧИКА
	CLRF	CHK_SUM_TX
	BCF	FLAG,0		; Пакет закончен-передача остановлена
	RETURN
	
READ_STR	MOVLW	HIGH EngSC
	MOVWF	PCLATH
	MOVF	TEMP,W		; Чтение таблицы DT основной цикл
	MOVWF	PCL 
READ_STR2	MOVLW	HIGH Lamb
	MOVWF	PCLATH
	MOVF	temp,W		; Чтение таблицы DT в прерываниях
	MOVWF	PCL 


	;}
;-----------------------------------------------------
; ПОДПРОГРАММА ОБРАБОТКИ ПРЕРЫВАНИЙ АЦП
;{-----------------------------------------------------
Int_AD	BCF	PIR1,ADIF		; СБРОС ПРЕРЫВАНИЯ
	BTFSC	ADCON0,GO
	GOTO	RET

 	MOVF	ADCON0,W
	XORLW	ADC_COLT
	BTFSS	STATUS,Z		; ДТОЖ?
	GOTO	ADC01
	CALL	GET_COLT
	GOTO	RET

ADC01	MOVF	ADCON0,W
	XORLW	ADC_TPS
	BTFSS	STATUS,Z
	GOTO	GET_DAD
	MOVF	TPS,W		; СОХРАНЯЕМ ЗНАЧЕНИЕ ДПДЗ
	MOVWF	TPS1
	MOVF	ADRESH,W
	MOVWF	TPS		; Записываем положение ДЗ	


	SUBLW	IAC_SKIP*.255/.5000	; Порог стабилизации холостого хода
	BTFSS	STATUS,C		; Если положение ДЗ меньше порога
	GOTO	CLR_IAC		; То переходим на след, метку
	BSF	STAT,2		; Ставим флаг холостого хода
	BSF	EPHH		; Включаем эмуляцию концевика ХХ
	GOTO	RET
CLR_IAC	BCF	STAT,2		; Выключаем флаг ХХ
	BCF	EPHH
	GOTO	RET



GET_DAD	MOVF	ADCON0,W		; ДАД
	XORLW	ADC_MAP
	BTFSS	STATUS,Z
	GOTO	ADC02
	MOVF	ADRESH,W
	MOVWF	MAP
; Проверка верхней границы
	ADDLW	0FH		; ДАД
	BTFSS	STATUS,C
	GOTO	$+2
	BSF	ERR,5		; Выставить флаг ошибки
	MOVLW	05H		; ПРоверка нижней границы
	SUBWF	MAP,W
	BTFSC	STATUS,C
	GOTO 	RET
	BTFSS	STAT,2
	BSF	ERR,5		; Выставить флаг ошибки
	GOTO	RET

ADC02	MOVF	ADCON0,W		; Напряжение бортсети
	XORLW	ADC_PWR
	BTFSS	STATUS,Z
	GOTO	ADC03
	MOVF	ADRESH,W
	BTFSS	STAT,0		; если мотор запущен -то пропускаем
	MOVWF	POWER
	banksel	ADC_POWER
	MOVWF	ADC_POWER
	bank0
	BSF	FLAG,6
	GOTO	RET
ADC03	MOVF	ADCON0,W
	XORLW	ADC_CORR
	BTFSS	STATUS,Z
	GOTO	RET		; ВЫХОД ИЗ ОБРАБОТКИ
; РЕГУЛЯТОР КАЧЕСТВА СМЕСИ НА МОЩНОСТНОМ РЕЖИМЕ
	MOVF	ADRESH,W
	MOVWF	MAN_CORR
	BSF	FLAG,2
	ANDLW	B'11000000'
	BTFSS	STATUS,Z
	GOTO	O2S_OFF
	bank1
	RLF	ADRESL,F	;сдвиг в лево
	bank0
	RLF	ADRESH,F	;
	bank1
	RLF	ADRESL,F
	bank0
	RLF	ADRESH,W
	MOVWF	temp
; Чтение таблицы преобразования напряжения лямбда-зонда
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
; ПОДПРОГРАММА ОБРАБОТКИ ПРЕРЫВАНИЙ UART RxD
;{-----------------------------------------------------
Int_RX	BCF	PIR1,RCIF
	Movfw	RCREG
Read_RX;	MOVWF	RX_DATA
;	BCF	FLAG,7
	GOTO	RET
;}
;-----------------------------------------------------
; ПОДПРОГРАММА ОБРАБОТКИ ДТОЖ, ВЫЧИСЛЯЕТСЯ COLT=FFH-ADC+75H, 75H<ADRESH<0B4H
;{-----------------------------------------------------
GET_COLT	MOVF	ADRESH,W	; Проверяем на попадание в диаппазон показаний датчика температуры
	ADDLW	-075H	; складываем с минимальным значением
	ADDLW	-(0CAH-075H)	; Макс-Мин+1
	BTFSC	STATUS,C
	GOTO	COLT_ERR

	MOVLW	075H	; Вычитаем ОФФСЕТ
	SUBWF	ADRESH,F
	MOVF	ADRESH,W	; Если >B4 выключаем режим прогрева
	SUBLW	0B4H-075H
	BSF	STAT,1	;
	BTFSS	STATUS,C
	BCF	STAT,1	; Гасим флаг прогрева

	MOVF	ADRESH,W	; Если меньше B3 включаем режим прогрева
	SUBLW	0B2H-075H
	BTFSC	STATUS,C
	BSF	STAT,1

	BCF	STATUS,C
	bank1
	RLF	ADRESL,F	;сдвиг в лево
	bank0
	RLF	ADRESH,F	;в ADRESH весь рабочий диаппазон прогрева
; Добавлено - вывод полного диаппазона рабочих температур
 
	MOVF	ADRESH,W
	MOVWF	ColtF


	BTFSS	STAT,1
	GOTO	GC_1
	BCF	STATUS,C
	bank1
	RLF	ADRESL,F
	bank0
	RLF	ADRESH,F

;Задаём обрахную характеристику COLT
	MOVLW	0FFH
	XORWF	ADRESH,W	; ОБМЕН РЕГИСТРА И АККУМУЛЯТОРА
	XORWF	ADRESH,F	; МЕСТАМИ
	XORWF	ADRESH,W
	SUBWF	ADRESH,W	; ВЫЧИТАЕМ ИЗ FF СОДЕРЖИМОЕ АЦП
	MOVWF	COLT

	BTFSS	WARM_UP
	BSF	WARM_UP	;
	BCF	ERR,4
	RETURN

COLT_ERR	BSF	ERR,4
	BCF	STAT,1	; Гасим флаг прогрева
	CLRF	ColtF
	GOTO	$+2
GC_1	BCF	ERR,4	
	CLRF	COLT
	BTFSC	WARM_UP
	BCF	WARM_UP	; Выключаем светодиод прогрева
	RETURN
;}
;---------------------------------------------
; Расчёт времени открытия форсунки
;{---------------------------------------------
LAG	BSF	FLAG,6
;Модуль скользящего среднего
;{	
	BTFSC	STAT,0
	GOTO	GETLAG
	banksel	PWR_BUF_IND
	MOVLW	PWR_BUF-1	; Указатель кольцевого буфера
	ADDWF	PWR_BUF_IND,W
	MOVWF	FSR
	banksel	ADC_POWER
	Movfw	ADC_POWER		; ЗАГРУЖАЕМ 
	MOVWF	INDF		; В ЯЧЕЙКУ КОЛЬЦЕВОГО БУФЕРА
	decfsz	PWR_BUF_IND,F
	GOTO	$+3
	MOVLW	.4
	MOVWF	PWR_BUF_IND

; Вычисляем скользящее среднее
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
	SUBLW	96H	; Более 15 вольт
	BTFSS	STATUS,C
	GOTO	HVOLT
	MOVLW	57H
	SUBWF	POWER,W
	BTFSS	STATUS,Z
	BTFSS	STATUS,C
	GOTO	LVOLT	; Меньше 8,6в

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


;------------------ Импульс зажигания -----------------------

;tm2	btfss	PIR1,CCP1IF		 ;ждем момент зажигания
;	goto	tm2
;tm3	bsf	PORTC,0		;    ;импульс зажигания
;	call	zadimp	       ;длина импульса	
;	bcf	PORTC,0		      ;сброс импульса зажигания
;	goto	RET         ;выходим                  


EE_ADR	; Установка адреса работы с энергонезависимой памятью	
	banksel	EEADR
	movwf	EEADR       ; Скопировать W в регистр EEAdr
	bank0
	return
EE_READ	; чтение данных из энергонезависимой памяти EEPROM (ПЗУ)	
	banksel	EECON1
	bsf	EECON1,RD    ; Инициализировать чтение.
	banksel	EEDATA
	movf	EEDATA,W    ; Скопировать в W из EEPROM
	bank0
	return

EE_WRITE	; запись данных в энергонезависимую память EEPROM (ПЗУ)
	BCF	INTCON,GIE      ; Глобальный запрет прерываний
            movwf	EEDATA      ; Скопировать W в EEPROM
	banksel	EECON1
           bsf	EECON1,WR    ; Разрешить запись.
                                   
            movlw      55h         ; Обязательная
           movwf      EECON2      ; процедура
           movlw      0AAh         ; при записи.
           movwf      EECON2      ; ----"----
           bsf        EECON1,WR    ; ----"----

           bcf        EECON1,EEIF    ; Сбросить флаг прерывания по окончании
           bank0		; Переход в нулевой банк.
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
; предварительная запись
            org         2100h       ; Обращение к EEPROM памяти данных.
            DE          8h,4h,2h   
            DE          1h,3h,5h,7h,8h,6h,4h,2h 	
;Хранение счётчика моточасов
            org         2100h+0F0H  ; Обращение к EEPROM памяти данных.
MH_main     DE          00h,00h,2h	; Часы.HSB:Часы.LSB:КС
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

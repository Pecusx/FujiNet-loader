

     ;MICRO SPARTA DOS 4.7
	 
; w wersji 4.7 dodac mo¿naby przechodzenie po kolejnych "ekranach" z lista plikow klawiszami
; "prawo"/"lewo" albo "gora"/"dol" ... ... ale to b.trudne
; ze wzgledu na mozliwosc roznej liczby plikow (stron) w zaleznosci czy wyswietlamy
; dlugie nazwy czy nie - nie da sie tego latwo zliczyc

; dodany "Backspace" jako powrot do katalogu wyzej.

; w wersji 4.6c zmieniony sposob rozpoznawania wielkosci sektora, dodane czytanie
; bloku PERCOM przy zmianie dysku...
; UWAGA! Bufor na pierwszy sektor ma dalej 128b, bezposrednio za nim jest bufor na sektor
; mapy, ktory moze byc zamazywany w chwili odczytu pierwszego sektora bez problemow.


; w wersji 4.6b poprawione dwa male bugi i dodane kulturalne wyjscie do DOS (Shift+Esc) ...
; ..... moznaby w tym momencie sprawdzac czy jest w ogole DOS w pamieci, bo bez DOS bedzie SelfTest
	 
; w wersji 4.6 wyeliminowane chwilowe przelaczanie na domyslne kolory, ró¿ne poprawki procedur,
; ¿eby wiêcej gier siê uruchamia³o (zmiany w resecie i zmiennych systemowych)
	 
; w wersji 4.5 obsluga napedow 9-15 pod Ctrl-litera gotowa (napedy 1-8 zdublowane pod klawiszami 1-8 i Ctrl-litera
; wyswietlanie "numeru" napedu w zaleznosci jak sie go wybierze (Dn: lub n: - cyfra lub litera)
	 
; w wersji 4.4 (niepublikowanej) poprawiony blad. Nie moze byc dwa razy po sobie znacznika dziury w skompresowanej mapie
; czyli dziura max 127 sektorow a nie jak porzednio 254
; dodatkowo zapamietanie (na czas resetu przed czyszczeniem pamieci)
; stanu aktywnych urzadzen PBI i odtworzenie go po resecie (dzieki Drac030)

; stan urzadzen na szynie PBI	 
PDVMASK = $0247
	 
; nowa koncepcja zrobiona:

; 1. wywaliæ turbo 'top-drive'

; 2. przerobiæ loader i menu na obs³ugê sektorów dow. d³ugoœci

; 3. przepisac czytanie tablicy sektorów indeksowych z loadera do menu:
;    a. w menu odczytywane s¹ wszystkie sektory tablicy indeksowej
;    b. budowana jest "skompresowana" tablica offsetów w stosunku do pierwszego sektora na nast. zasadzie:
;       mamy nast. znaczniki : (nowa koncepcja)
;       1xxxxxxx  -- (0xxxxxxx = ile sektorów omin¹æ) . Op³aci siê u¿ywaæ do max 255 sektorów do przeskoczenia.
;       0xxxxxxx  -- (0xxxxxxx = ile kolejnych sektorów wczytaæ)
;       00000000  -- nastêpne 2 bajty to numer kolejnego sektora do odczytania
;               

; 4. nowa 'skompresowana' tablica indeksowa podwyzsza memlo

	 
     ;START ADDR = 1FFD
     ;END ADDR = 28C9
         ;.OPT noList
         
           icl 'lib/SYSEQU.ASM'

     
acktimeout = $a
readtimeout = 2


STACKP = $0318
CRITIC = $42
DRETRY = $02BD
CASFLG = $030F
CRETRY = $029C


CASINI = $02
;WARMST = $08
BOOT   = $09
DOSVEC = $0a
DOSINI = $0c
;APPMHI = $0e

IRQENS = $10


; zmienne procedury ladowania pliku (w miejscu zmiennych CIO - ktore sa nieuzywane - niestety teraz sa)

; najmlodszy z trzech bajtow zliczajacych do konca pliku - patrz ToFileEndH
ToFileEndL = $28
CompressedMapPos = $3D ; pozycja w skompresowanej mapie pliku

SecLenUS = $30
CheckSUM = $31
SecBuffer = $32
CRETRYZ = $34
TransmitError =$35
Looperka = $36
StackCopy = $37


SAVMSC = $58
; Adres bufora przechowywania Aktualnie obrabianego sektora zawierajacego
; katalog
CurrentDirBuf = $CA
; adres konca tego bufora (2 bajty)
CurrentDirBufEnd = $CC
; Adres (w buforze CurrentDirBuff, ale bezwzgledny) poczatku informacji
; o obrabianym pliku (skok co $17)
CurrentFileInfoBuff = $D0
; Numer sektora ktory nalezy przeczytac - mapy sektorow aktualnego katalogu (2 bajty)
DirMapSect = $D2
; Flaga ustawiana na 1 kiedy skoncza sie pliki do wyswietlenia w danym katalogu
; oznacza wyswietlanie ostatniej strony i jednoczesnie mowi o tym, ze po spacji
; ma byc wyswietlany katalog od poczatku
LastFilesPageFlag = $D6
; Licznik nazw plikow wyswietlonych aktualnie na ekranie, po wyswietleniu strony
; zawiera liczbe widocznych na ekranie plikow (1 bajt)
NamesOnScreen = $D9
; wskaznik pozycji w mapie sektorow czytanego katalogu (2 bajty) - nowa zmienna
; wczesniej byl 1 bajt w $D6
InMapPointer = $E2
; zmienna tymczasowa na ZP (2 bajty)
TempZP = $E4

VSERIN = $020a
COLPF1S = $02c5
COLPF2S = $02c6
COLBAKS = $02c8

COLDST = $0244
;MEMTOP = $02e5
;MEMLO  = $02e7

KBCODES = $02fc

DDEVIC = $0300
DUNIT  = $0301
DCOMND = $0302
DBUFA  = $0304
DBYT   = $0308
DAUX1  = $030a
DAUX2  = $030b

ICCMD = $0342
ICBUFA = $0344
;ICBUFA+1 = $0345
ICBUFL = $0348
;ICBUFL+1 = $0349
ICAX1 = $034a
ICAX2 = $034b

GINTLK = $03FA ; 0 brak carta - potrzebne przy wylaczaniu Sparty X by oszukac OS ze nie bylo carta

AUDF3  = $d204
AUDF4 = $d206
AUDC4 = $d207
AUDCTL = $d208
SKSTRES = $d20a
SEROUT = $D20d
SERIN = $D20d
IRQEN = $D20e
IRQST = $D20e


SKSTAT = $d20f
SKCTL = $d20f


PBCTL  = $d303
PORTB  = $d301

VCOUNT = $D40B

JCIOMAIN   = $e456
JSIOINT   = $e459
JTESTROM = $e471
JRESETWM = $e474
JRESETCD = $e477


	org $0600

; tutaj procka turbo US (opcjonalnie wy³¹czana)
; UWAGA !!!!!!!!!!!!!!
; Ta procedura ma maksymalna dlugosc jaka moze miec!!!!!
; powiekszenie jej O BAJT spowoduje ze przekroczy strone
; i nie przepisze sie prawidlowo na swoje miejsce !!!!!	 
HappyUSMovedProc ;

	LDA DBUFA
	STA SecBuffer
	LDA DBUFA+1
	STA SecBuffer+1

	LDA DBYT
	STA SecLenUS

	SEI
	TSX
	STX StackCopy
	LDA #$0D
	STA CRETRYZ
	 ;command retry on zero page
CommandLoop
HappySpeed = *+1
	LDA #$28 ;here goes speed from "?"
	STA AUDF3
	LDA #$34
	STA PBCTL ;ustawienie linii command
	LDX #$80
DelayLoopCmd
	DEX
	BNE DelayLoopCmd
	STX AUDF4 ; zero
	STX TransmitError
;	pokey init
	LDA #$23
xjsr1	JSR SecTransReg
	;

	CLC
	LDA DDEVIC    ; tu zawsze jest $31 (przynajmniej powinno)
	ADC DUNIT     ; dodajemy numer stacji
	ADC #$FF	; i odejmujemy jeden (jak w systemie Atari)
	STA CheckSum
	STA SEROUT
	LDA DCOMND
xjsr2	JSR PutSIOByte
	LDA DAUX1
xjsr3	JSR PutSIOByte
	LDA DAUX2
xjsr4	JSR PutSIOByte
	LDA CheckSum
xjsr5	JSR PutSIOByte

waitforEndOftransmission
	LDA IRQST
	AND #$08
	BNE waitforEndOftransmission

	LDA #$13
xjsr6	JSR SecTransReg

	LDA #$3c
	STA PBCTL ;command line off
; two ACK's
	LDY #2
DoubleACK
xjsr7	JSR GetSIOByte
	CMP #$44
	BCS ErrorHere
	DEY
	BNE DoubleACK
    
	;ldy #0
	STY CheckSum

    bit DSTATS  ; send or recieve data?
    bmi WriteSectorLoop

ReadSectorLoop
xjsr8	JSR GetSIOByte
	STA (SecBuffer),y
xjsr9	JSR AddCheckSum
	INY
	CPY SecLenUS
	BNE ReadSectorLoop

xjsrA	JSR GetSIOByte
	CMP CheckSum
	BEQ EndOfTransmission
    BNE ErrorHere

WriteSectorLoop
	LDA (SecBuffer),y
xjsr8x	JSR PutSIOByte
	INY
	CPY SecLenUS
	BNE WriteSectorLoop
    lda CheckSUM
    JSR PutSIOByte
    ;.....
    
;error!!!
ErrorHere
	LDY #$90
	STY TransmitError
	LDX StackCopy
	TXS
	DEC CRETRYZ
	BNE CommandLoop

EndOfTransmission
	LDA #0
	STA AUDC4
	LDA IRQENS
	STA IRQEN
	CLI
	LDY TransmitError
	RTS

SecTransReg
	STA SKCTL
	STA SKSTRES
	LDA #$38
	STA IRQEN
	LDA #$28
	STA AUDCTL
	LDA #$A8
	STA AUDC4
	RTS

PutSIOByte
	TAX
waitforSerial
	LDA IRQST
	AND #$10
	BNE waitforSerial

	STA IRQEN
	LDA #$10
	STA IRQEN

	TXA
	STA SEROUT

AddCheckSum
	CLC
	ADC CheckSum
	ADC #0
	STA CheckSum
	RTS

GetSIOByte
	LDX #10  ;acktimeout
ExternalLoop
	LDA #0
	STA looperka
InternalLoop
	LDA IRQST
	AND #$20
	BEQ ACKReceive
	DEC looperka
	BNE InternalLoop
	DEX
	BNE ExternalLoop
	BEQ ErrorHere
ACKReceive
	; zero we have now
	STA IRQST
	LDA #$20
	STA IRQST
	LDA SKSTAT
	STA SKSTRES
	AND #$20
	BEQ ErrorHere
	;
	LDA SERIN
	RTS
EndHappyUSProc

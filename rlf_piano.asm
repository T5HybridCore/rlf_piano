;Imprime un caracter en pantalla
print_char MACRO character
    
    ;Impresion mediante la funcion '02' de la 'int 21h'
    MOV AX,0200h
    MOV DL,character
    INT 21h
    
ENDM    

;Imprime una cadena de caracteres en pantalla
print_string MACRO string
    
    ;Impresion mediante la funcion '09' de la 'int 21h'
    MOV AX,0900h
    MOV DX,OFFSET string
    INT 21h
    
ENDM

;Limpia la pantalla
clear_screen MACRO
    
    ;Limpiar la pantalla mediante la funcion
    ;'06' de la 'int 10h'
    MOV AX,0600h
    MOV BH,71h
    MOV CX,0000h
    MOV DX,184Fh
    INT 10h
    
ENDM

;Posiciona el cursor en las coordenadas indicadas
cursor_position MACRO page, row, column
    
    ;Mueve el cursor mediante la funcion '02'
    ;de la 'int 10h'
    MOV AX,0200h
    MOV BH,page
    MOV DH,row
    MOV DL,column
    INT 10h
    
ENDM

;Mueve el cursor a la columna indicada, la fila no se afecta
move_cursor MACRO page, column
    
    ;Obtiene la posicion actual del cursor mediante
    ;la funcion '03' de la 'int 10h'
    MOV AX,0300h
    MOV BH,page
    INT 10h
    
    ;Mueve el cursor a la columna indicada
    MOV AX,0200h
    MOV DL,column
    INT 10h 
    
ENDM    

;Cambia a una nueva pagina de video
change_page MACRO page
    
    ;Limpia la pantalla de la pagina actual
    clear_screen
    
    ;Cambiar a otra pagina de video mediante la funcion
    ;'05' de la 'int 10h'
    MOV AH,05h
    MOV AL,page
    INT 10h
    
    ;Limpia la pantalla de la nueva pagina
    clear_screen
    
    ;Posiciona el cursor el la coordenada 0,0
    cursor_position page, 0, 0
    
ENDM

;Cambia la octava actual, esto produce sonidos diferentes para la misma tecla
change_octave MACRO
    
    LOCAL reset, return
    
    CMP octave,02h
    JGE reset
    
    INC octave
    JMP return
    
    reset:
        MOV octave,00h
    
    return:    
    
ENDM

;Cambia el idioma en el cual se muestran las notas
change_naming MACRO
    
    LOCAL reset, return
    
    CMP naming,01h
    JGE reset
    
    INC naming
    JMP return
    
    reset:
        MOV naming,00h
        
    return:
    
ENDM    

;Menu Principal
print_main_menu MACRO
    
    change_page 00h
    
    print_string menu_title
    print_string menu_empty
    print_string menu_subtitle
    print_string menu_empty
    print_string menu_empty
    print_string menu_main_info
    print_string menu_empty
    print_string menu_main_op1
    print_string menu_main_op2
    print_string menu_main_op3
    print_string menu_empty
    print_string menu_fill
    print_string empty_line
    print_string menu_main_choice
    
ENDM

;Menu Modo Reproduccion
print_play_menu MACRO
    
    change_page 01h
    
    print_string menu_title
    print_string menu_empty
    print_string menu_play_subtitle
    print_string menu_empty
    print_string menu_esc
    print_string menu_empty
    print_string menu_play_info
    print_string menu_empty
    print_string menu_play_op1
    print_string menu_play_op2
    print_string menu_empty
    print_string menu_fill
    print_string empty_line
    print_string menu_play_choice
    
ENDM

;Menu Reproduciendo (Progreso)
print_playing_menu_progress MACRO
    
    LOCAL return
    
    ;Preservar los datos de los registros
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX,CX
    XOR BX,BX
    MOV BL,update_interval
    DIV BL
    
    CMP AH,00h
    JNE return
    
    MOV BL,0Dh
    ADD BL,AL
    
    move_cursor 03h,BL
    print_char '#'
        
    return:
        POP DX
        POP CX
        POP BX
        POP AX        
    
ENDM

;Menu Reproduciendo
print_playing_menu MACRO
    
    LOCAL melody2, next, continue, status_playing, status_stopped, stopped
    
    change_page 03h
    
    print_string menu_title
    print_string menu_empty
    print_string menu_play_subtitle
    print_string menu_empty
    
    CMP play,01h
    JNE melody2
    
    CMP status,00h
    JNE status_playing
    
    print_string menu_playing_info1s
    JMP next
    
    status_playing:
        print_string menu_playing_info1
        JMP next
    
    melody2:
        CMP status,00h
        JE status_stopped
        
        print_string menu_playing_info2
        JMP next
        
    status_stopped:    
        print_string menu_playing_info2s
    
    next:
    
    print_string menu_empty
    
    CMP status,00h
    JE stopped
    
        print_string menu_playing_loop
        JMP continue
    
    stopped:
        print_string menu_playing_op
        
    continue:
        print_string menu_empty
        print_string menu_fill
        print_string empty_line
    
ENDM
    

;Menu Modo Libre (Octava)
print_free_menu_octave MACRO
    
    LOCAL octave1, octave2, return
    
    cursor_position 02h, 06h, 00h
    CMP octave,00h
    JE octave1
    
    CMP octave,01h
    JE octave2
    
    print_string menu_free_octave3
    JMP return
    
    octave1:
        print_string menu_free_octave1
        JMP return
        
    octave2:
        print_string menu_free_octave2
        JMP return
    
    return:
    
ENDM

;Menu Modo Libre (Idioma)
print_free_menu_naming MACRO
    
    LOCAL naming1, return
    
    cursor_position 02h, 08h, 00h
    CMP naming,00h
    JE naming1
    
    print_string menu_free_naming2
    JMP return
    
    naming1:
        print_string menu_free_naming1
    
    return:
    
ENDM

;Menu Modo Libre (Notas)
print_free_menu_notes1 MACRO
    
    LOCAL english, return
    
    cursor_position 02h, 0Ch, 00h
    CMP naming,00h
    JE english
    
    print_string menu_free_notes_lat1
    JMP return
    
    english:
        print_string menu_free_notes_eng1
    
    return:
    
ENDM

;Menu Modo Libre (Notas)
print_free_menu_notes2 MACRO
    
    LOCAL english, return
    
    cursor_position 02h, 0Fh, 00h
    CMP naming,00h
    JE english
    
    print_string menu_free_notes_lat2
    JMP return
    
    english:
        print_string menu_free_notes_eng2
    
    return:
    
ENDM

;Menu Modo Libre
print_free_menu MACRO
    
    change_page 02h
    
    print_string menu_title
    print_string menu_empty
    print_string menu_free_subtitle
    print_string menu_empty
    print_string menu_esc
    print_string menu_empty
    
    print_free_menu_octave
    
    print_string menu_empty
    
    print_free_menu_naming
    
    print_string menu_empty
    print_string menu_fill
    print_string menu_empty
    
    print_free_menu_notes1
    
    print_string menu_free_notes_key1
    print_string menu_empty
    
    print_free_menu_notes2
    
    print_string menu_free_notes_key2
    print_string menu_empty
    print_string menu_fill
    print_string empty_line
    print_string menu_free_choice
    
ENDM

;Enciende el parlante del equipo
set_speaker_on MACRO
    
    IN AL,61h           ;Obtener el valor del puerto 61h
    OR AL,00000011b     ;Asignar los bits 1 y 0
    OUT 61h,AL          ;Enviar el nuevo valor
    
ENDM

;Apaga el parlante del equipo
set_speaker_off MACRO
    
    IN AL,61h           ;Obtener el valor del puerto 61h
    AND AL,11111100b     ;Asignar los bits 1 y 0
    OUT 61h,AL          ;Enviar el nuevo valor
    
ENDM

;Hace una espera de cierta cantidad de tiempo
delay MACRO
    
    LOCAL _wait, return
    
    ;Con la interrupcion 15h se escucha raro :( (Eliminar)
    ;MOV CX,06h
    ;MOV DX,01A80h
    ;MOV AH,86h
    ;INT 15h 
    
    MOV AX,40h              ;ES apuntara al BIOS Data Area (0040h:006Ch)
    MOV ES,AX
    
    MOV DX,ES:[006Eh]       ;Obtiene el valor del contador de tiempo de la BIOS
    MOV AX,ES:[006Ch]       ;Este se almacena en un DW por eso se usa el registro ES
    
    ADD AX,note_duration    ;La duracion de la nota es 07h, que es aproximadamente 385ms.
    ADC DX,0                ;El contador del tiempo incrementa 18.2 veces por segundo,
                            ;1000ms / 18.2 = 55ms; 55ms * 7 = 385ms 
    _wait:
        CMP DX,ES:[006Eh]   ;Ciclar hasta que DX/AX este por debajo del valor del contador
        JA _wait            ;de la BIOS.
        JB return
    
        CMP AX,ES:[006Ch]
        JA _wait
        
    return:
    
ENDM    

;Seleciona la nota a reproducir dependiendo de la octava elegida
select_note MACRO note
    
    LOCAL next
    
    MOV AX,note     ;Nota a reproducir
    MOV BX,02h      ;Se multiplica x2 ya que las notas estan divididas
    MUL BX          ;en 2 bytes cada 1
    MOV BX,AX
           
    MOV AX,18h      ;24d (Desplazamiento entre octavas)
                    ;cada nota esta dividida en 2 bytes
    
    XOR CX,CX       ;Desplazamiento a la octava seleccionada
    MOV CL,octave
    MUL CX
    
    CMP octave,03h
    JE next
       
    ADD BX,AX
    
    next:
        MOV SI,OFFSET frequencies
        MOV AH,[SI+BX]
        INC BX
        MOV AL,[SI+BX]
    
ENDM    

;Reproducir nota
play_note MACRO note
    
    LOCAL return
    
    MOV AL,0B6h         ;Preparacion del puerto para reproducir la nota
    OUT 43h,AL
    
    select_note note    ;Nota
    
    OUT 42h,AL          ;Low Byte (Puerto paralelo - 378H)
    
    MOV AL,AH
    OUT 42h,AL          ;High Byte (Puerto serial - 3F8H)
    
    set_speaker_on
    
    CMP octave,03h
    JE return
    
    delay               ;Espera un tiempo para reproducir la nota
    set_speaker_off
    
    return:
    
ENDM

;Cambia la frecuencia del timer
change_timer_frequency MACRO frequency
    
    MOV BX,frequency        ;Numero que se usa como divisor de la frequencia. 
                            ;La senal de entrada del Timer Chip es 1,193,180 hz.
                            ;Al elegir la nueva frequencia, por ejemplo, una melodia con
                            ;sampling rate = 25 utilizaria una frequencia de reproduccion
                            ;dada por 1,193,180 / 25 = 47727.2 (BA6Fh)
                            ;ese es el numero que la macro recibe para cambiar la frequencia
                            ;del chip.
                            ;Considerar asignar el valor mas bajo (01h) a la duracion
                            ;de la nota cuando se cambia la frequencia del timer a una mas
                            ;rapida 
    
    CLI                     ;Desahabilitar interrupciones
	
	MOV AL,00110110b        ;Preparar timer 0 para enviar la nueva frequencia
	OUT 43h,AL
	
	MOV AL,BL               ;Low Byte
	OUT 40h,AL
	
	MOV AL,BH               ;High Byte
	OUT 40h,AL              
	
	STI                     ;Habilitar interrupciones
    
ENDM    

;Reproducir una melodia completa
start_melody MACRO
    
    LOCAL begin, skip, stop_note, melody2, next
    
    ;Velocidad de reproduccion (mas bajo -> mas rapido)
    
    ; Valor  Notas por segundo
    ; E90Bh  20
    ; BA6Fh  25
    change_timer_frequency 0E90Bh
    
    MOV note_duration,0001h
    MOV status,01h                  ;01h = Reproduciendo
    
    print_playing_menu
    cursor_position 03h, 06h, 00h
    
    CMP play,01h
    JNE melody2
    
    MOV SI,OFFSET notes_table_melody1
    MOV AX,notes_size_melody1
    
    JMP next
    
    melody2:
        MOV SI,OFFSET notes_table_melody2
        MOV AX,notes_size_melody2
    
    next:
        MOV notes_size,AX           ;Total de notas a reproducir
        MOV BX,0019h                ;25d. Total de # indicadores del progreso
        DIV BL
        MOV update_interval,AL      ;Contiene la frecuencia en como se agregan
        INC update_interval         ;# al indicador del progreso (+1 para redondeo)
        
        XOR CX,CX
    
    begin:
        XOR BX,BX
        MOV BL,[SI]
        
        CMP BL,0FFh
        JE skip
        
        CMP BL,0FEh
        JE stop_note
        
        MOV current_note,BX
        
        ;Reproduce la nota
        PUSH SI                     ;Guardar el valor de SI
        PUSH CX
        MOV octave,03h              ;Para no hacer desplazamientos entre octavas
        play_note current_note      ;Reproduce la nota 
        POP CX
        POP SI                      ;Restaura el valor de SI
        JMP skip
        
    stop_note:
        set_speaker_off             ;Detiene la reproduccion de la nota    
    
    skip:
        delay
        print_playing_menu_progress
        INC CX
        INC SI
	    CMP CX,notes_size
	    JB begin
		
    set_speaker_off                 ;Detener los sonidos en caso de que una nota
                                    ;no se haya detenido
		
	change_timer_frequency 0000h    ;Reiniciar velocidad de reproduccion
	
	MOV note_duration,0007h
	
	MOV status,00h                  ;00h = Detenido
	print_playing_menu
    
ENDM    

.MODEL SMALL

.STACK

.DATA
    
    ;Linea vacia
    empty_line              DB  "",0Dh,0Ah,"$"
    
    ;Menu (General)
    menu_title              DB  "==================== RLF PIANO ====================",0Dh,0Ah,"$"
    menu_empty              DB  "=                                                 =",0Dh,0Ah,"$"
    menu_subtitle           DB  "=             [Riffs, Licks & Fills]              =",0Dh,0Ah,"$"
    menu_fill               DB  "===================================================",0Dh,0Ah,"$"
    menu_esc                DB  "=                                  ESC: Main Menu =",0Dh,0Ah,"$"
    
    ;Menu (Principal)
    menu_main_info          DB  "= Select a mode                                   =",0Dh,0Ah,"$"
    menu_main_op1           DB  "=  1) Play Mode (Preset Melody)                   =",0Dh,0Ah,"$"
    menu_main_op2           DB  "=  2) Free Mode (Virtual Piano)                   =",0Dh,0Ah,"$"
    menu_main_op3           DB  "=  3) Exit                                        =",0Dh,0Ah,"$"
    menu_main_choice        DB  "Your choice: $"
    
    ;Menu (Modo Reproduccion)
    menu_play_subtitle      DB  "=           [Play Mode - Preset Melody]           =",0Dh,0Ah,"$"
    menu_play_info          DB  "= Select a melody to play                         =",0Dh,0Ah,"$"
    menu_play_op1           DB  "=  1) Super Mario Bros (Ground Theme)             =",0Dh,0Ah,"$"
    menu_play_op2           DB  "=  2) Dance Monkey                                =",0Dh,0Ah,"$"
    menu_play_choice        DB  "Your choice: $"
    
    ;Menu (Reproduciendo)
    menu_playing_info1      DB  "= Playing: Super Mario Bros (Ground Theme)        =",0Dh,0Ah,"$"
    menu_playing_info2      DB  "= Playing: Dance Monkey                           =",0Dh,0Ah,"$"
    menu_playing_info1s     DB  "= Stopped: Super Mario Bros (Ground Theme)        =",0Dh,0Ah,"$"
    menu_playing_info2s     DB  "= Stopped: Dance Monkey                           =",0Dh,0Ah,"$"
    menu_playing_op         DB  "= ESC: Back                                       =",0Dh,0Ah,"$"
    menu_playing_loop       DB  "=           [                         ]           =",0Dh,0Ah,"$"
    
    
    ;Menu (Modo Libre)
    menu_free_subtitle      DB  "=           [Free Mode - Virtual Piano]           =",0Dh,0Ah,"$"
    menu_free_octave1       DB  "= Octave: C3 (Small) .......... press 1 to change =",0Dh,0Ah,"$"
    menu_free_octave2       DB  "= Octave: C4 (1 Line) ......... press 1 to change =",0Dh,0Ah,"$"
    menu_free_octave3       DB  "= Octave: C5 (2 Line) ......... press 1 to change =",0Dh,0Ah,"$"
    menu_free_naming1       DB  "= Naming: English ............. press 2 to change =",0Dh,0Ah,"$" 
    menu_free_naming2       DB  "= Naming: Latin ............... press 2 to change =",0Dh,0Ah,"$"
    
    menu_free_notes_eng1    DB  "= [ C#-Db ][ D#-Eb ][ F#-Gb  ][  G#-Ab ][ A#-Bb ] =",0Dh,0Ah,"$"
    menu_free_notes_lat1    DB  "= [Do#-Reb][Re#-Mib][Fa#-Solb][Sol#-Lab][La#-Sib] =",0Dh,0Ah,"$"
    menu_free_notes_key1    DB  "= [   W   ][   E   ][   T    ][    Y   ][   U   ] =",0Dh,0Ah,"$"
    
    menu_free_notes_eng2    DB  "=          [C ][D ][E ][F ][ G ][A ][B ]          =",0Dh,0Ah,"$"
    menu_free_notes_lat2    DB  "=          [Do][Re][Mi][Fa][Sol][La][Si]          =",0Dh,0Ah,"$"
    menu_free_notes_key2    DB  "=          [A ][S ][D ][F ][ G ][H ][J ]          =",0Dh,0Ah,"$"
    menu_free_choice        DB  "Press the key indicated for the note: $"                        
    
    ;Frecuencias
    frequencies:            DB  03Ah, 014h, 01Ah, 015h, 0FBh, 0E2h, 0DFh, 060h, 0C4h, 079h, 0ABh, 013h, 093h, 01Bh, 07Ch, 07Bh, 067h, 020h, 052h, 0F8h, 03Fh, 0F2h, 02Dh, 0FDh
                        	DB  01Dh, 00Ah, 00Dh, 00Ah, 0FDh, 0F1h, 0EFh, 0B0h, 0E2h, 03Ch, 0D5h, 089h, 0C9h, 08Dh, 0BEh, 03Dh, 0B3h, 090h, 0A9h, 07Ch, 09Fh, 0F9h, 096h, 0FEh
                        	DB  08Eh, 085h, 086h, 085h, 07Eh, 0F8h, 077h, 0D8h, 071h, 01Eh, 06Ah, 0C4h, 064h, 0C6h, 05Fh, 01Eh, 059h, 0C8h, 054h, 0BEh, 04Fh, 0FCh, 04Bh, 07Fh
                        	DB  047h, 042h, 043h, 042h, 03Fh, 07Ch, 03Bh, 0ECh, 038h, 08Fh, 035h, 062h, 032h, 063h, 02Fh, 08Fh, 02Ch, 0E4h, 02Ah, 05Fh, 027h, 0FEh, 025h, 0BFh
                        	DB  023h, 0A1h, 021h, 0A1h, 01Fh, 0BEh, 01Dh, 0F6h, 01Ch, 047h, 01Ah, 0B1h, 019h, 031h, 017h, 0C7h, 016h, 072h, 015h, 02Fh, 013h, 0FFh, 012h, 0DFh
                        	DB  011h, 0D0h, 010h, 0D0h, 00Fh, 0DFh, 00Eh, 0FBh, 00Eh, 023h, 00Dh, 058h, 00Ch, 098h, 00Bh, 0E3h, 00Bh, 039h, 00Ah, 097h, 009h, 0FFh, 009h, 06Fh
                        	DB  008h, 0E8h, 008h, 068h, 007h, 0EFh, 007h, 07Dh, 007h, 011h, 006h, 0ACh, 006h, 04Ch, 005h, 0F1h, 005h, 09Ch, 005h, 04Bh, 004h, 0FFh, 004h, 0B7h
                        	DB  004h, 074h, 004h, 034h, 003h, 0F7h, 003h, 0BEh, 003h, 088h, 003h, 056h, 003h, 026h, 002h, 0F8h, 002h, 0CEh, 002h, 0A5h, 002h, 07Fh, 002h, 05Bh
                        	DB  002h, 03Ah, 002h, 01Ah, 001h, 0FBh, 001h, 0DFh, 001h, 0C4h, 001h, 0ABh, 001h, 093h, 001h, 07Ch, 001h, 067h, 001h, 052h, 001h, 03Fh, 001h, 02Dh
                        	DB  001h, 01Dh, 001h, 00Dh, 000h, 0FDh, 000h, 0EFh, 000h, 0E2h, 000h, 0D5h, 000h, 0C9h, 000h, 0BEh, 000h, 0B3h, 000h, 0A9h, 000h, 09Fh, 000h, 096h
                        	DB  000h, 08Eh, 000h, 086h, 000h, 07Eh, 000h, 077h, 000h, 071h, 000h, 06Ah, 000h, 064h, 000h, 05Fh
    
    ;Melodias precargadas
    
    ;Cada valor representa una accion a realizar, esta dada por:
    ;   00-7F   =   Nota musical a reproducir
    ;   0FE     =   Nota de apagado de sonido
    ;   0FF     =   Saltar la nota, no se reproduce ni se apaga nada 
    
    notes_size_melody1      DW  500;1779 ;Total de notas
     
	notes_table_melody1:    DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 040h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 046h, 0FFh, 0FEh, 045h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 04Fh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 047h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 040h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 046h, 0FFh, 0FEh, 045h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 04Fh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 047h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  044h, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 048h
                        	DB  0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  054h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 054h, 0FFh, 0FEh, 054h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  044h, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 048h
                        	DB  0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  044h, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 048h
                        	DB  0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  054h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 054h, 0FFh, 0FEh, 054h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh, 04Eh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  044h, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 048h
                        	DB  0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Bh, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 040h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 046h, 0FFh, 0FEh, 045h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 04Fh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 047h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 040h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 046h, 0FFh, 0FEh, 045h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 04Fh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 047h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh, 0FFh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Ah, 0FFh, 0FEh, 0FFh, 048h, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh, 0FFh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Ah, 0FFh, 0FEh, 0FFh, 048h, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ah, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 048h, 0FFh, 0FEh, 04Ch, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Fh, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 051h, 0FFh, 0FEh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 04Fh, 0FFh, 0FEh, 0FFh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh
                        	DB  048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh, 043h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 0FFh, 0FEh, 048h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 043h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 044h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 045h, 0FFh, 0FEh
                        	DB  04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 047h, 0FFh, 0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 04Dh, 0FFh
                        	DB  0FEh, 04Dh, 0FFh, 0FEh, 0FFh, 04Ch, 0FFh, 0FEh, 0FFh, 04Ah, 0FFh, 0FEh, 0FFh, 048h, 0FFh, 0FEh
                        	DB  02Fh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh
    
    
    notes_size_melody2      DW  500;1679 ;Total de notas
    
    notes_table_melody2:    DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  055h, 042h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 0FEh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 055h, 0FFh, 0FFh
                        	DB  0FEh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 042h, 0FFh, 0FEh, 051h, 0FFh
                        	DB  0FEh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 040h, 0FFh, 0FEh, 053h
                        	DB  0FFh, 0FEh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 042h, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 0FEh, 055h, 0FFh, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h
                        	DB  0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 045h
                        	DB  0FFh, 0FEh, 055h, 0FFh, 0FFh, 0FEh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 051h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh
                        	DB  042h, 0FFh, 0FEh, 051h, 0FFh, 0FEh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 053h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 053h, 0FFh, 0FEh
                        	DB  0FFh, 040h, 0FFh, 0FEh, 053h, 0FFh, 0FEh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 0FFh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 042h, 055h, 0FFh, 0FFh, 0FEh, 0FFh
                        	DB  0FFh, 0FEh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh, 055h, 0FFh, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  055h, 0FFh, 0FFh, 0FEh, 045h, 0FFh, 0FEh, 055h, 0FFh, 0FFh, 0FEh, 051h, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h
                        	DB  0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh, 0FFh, 051h, 0FFh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 051h, 0FFh, 0FEh, 0FFh, 042h, 0FFh, 0FEh, 051h, 0FFh, 0FEh, 0FFh, 053h, 0FFh, 0FEh, 028h
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh
                        	DB  034h, 025h, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FEh, 0FEh, 0FFh, 036h, 04Eh, 042h, 055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh
                        	DB  0FEh, 04Eh, 055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 04Eh, 055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 04Eh
                        	DB  055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh, 0FEh, 0FEh
                        	DB  0FEh, 0FFh, 0FFh, 04Eh, 055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 045h, 0FFh, 0FEh, 04Eh, 055h
                        	DB  051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FEh, 04Eh, 051h, 04Ah, 032h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h
                        	DB  04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Eh, 051h, 04Ah, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 042h, 0FFh
                        	DB  0FEh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FEh, 050h, 053h, 04Ch, 034h, 0FFh, 0FEh
                        	DB  0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ch, 053h, 050h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 050h, 053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 053h, 050h, 0FFh, 0FEh
                        	DB  0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 053h, 050h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 050h
                        	DB  053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 053h, 050h, 0FFh, 0FEh, 0FEh, 0FEh
                        	DB  0FFh, 040h, 0FFh, 0FEh, 04Ch, 053h, 050h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FEh, 04Ch, 050h, 049h
                        	DB  031h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 049h, 050h, 04Ch, 0FFh, 0FEh, 0FEh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 049h, 050h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 049h, 050h
                        	DB  04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ch, 050h, 049h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh
                        	DB  0FFh, 0FFh, 049h, 050h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 049h, 050h, 04Ch, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FEh, 036h, 0FFh, 051h, 055h, 042h
                        	DB  04Eh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FEh, 051h, 055h, 04Eh, 0FFh, 0FFh, 0FEh, 0FEh
                        	DB  0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh
                        	DB  0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh
                        	DB  0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 051h, 055h, 04Eh, 0FFh, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 045h, 0FFh, 0FEh, 04Eh, 055h, 051h, 0FFh, 0FFh, 0FEh, 0FEh, 0FEh, 0FEh, 04Eh
                        	DB  051h, 04Ah, 032h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh
                        	DB  04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh
                        	DB  0FEh, 0FFh, 0FFh, 0FFh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 04Eh, 051h
                        	DB  04Ah, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 042h, 0FFh, 0FEh, 04Ah, 051h, 04Eh, 0FFh, 0FEh, 0FEh, 0FEh
                        	DB  0FFh, 0FEh, 050h, 053h, 04Ch, 034h, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 050h
                        	DB  053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh
                        	DB  0FFh, 0FFh, 0FFh, 050h, 053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 053h, 04Ch
                        	DB  0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 050h, 053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh
                        	DB  0FFh, 050h, 053h, 04Ch, 0FFh, 0FEh, 0FEh, 0FEh, 0FFh, 040h, 0FFh, 0FEh, 04Ch, 053h, 050h, 0FFh
                        	DB  0FEh, 0FEh, 0FEh, 0FFh, 0FEh, 04Ch, 050h, 049h, 0FEh, 0FEh, 0FEh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh
                        	DB  0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 065h, 064h, 006h, 00Ah, 007h, 0FEh
    
    ;Modo reproduccion
    play                    DB  00h
    status                  DB  00h
    current_note            DW  0000h
    notes_size              DW  0000h
    update_interval         DB  00h
    
    ;Modo libre
    octave                  DB  01h
    naming                  DB  01h
    
    ;General
    note_duration           DW  0007h       ;Default (0007h)

.CODE    

start:
    MOV AX,@DATA
    MOV DS,AX
    
    ;Menu Principal
    m_menu:
        print_main_menu
        
        m_menu_key:
            MOV AH,08h
            INT 21h
                
        ;Opcion 1, modo de reproduccion      
        CMP AL,31h
        JE p_menu
                           
        ;Opcion 2, modo libre                   
        CMP AL,32h
        JE f_menu
        
        ;Opcion 3, salir
        CMP AL,33h
        JE exit_app
        
        JMP m_menu_key
    
    ;Menu Modo Reproduccion    
    p_menu:
        print_play_menu
        
        p_menu_key:
            MOV AH,08h
            INT 21h
            
        ;Opcion 1, melodia 1
        CMP AL,31h
        JNE no_melody1
        
        MOV play,01h
        JMP sm
        
        no_melody1:
        
        ;Opcion 2, melodia 2
        CMP AL,32h
        JNE no_melody2
        
        MOV play,02h
            
        sm: 
            start_melody
            cursor_position 03h, 32h, 00h
        
            p1_menu_key:
                MOV AH,08h
                INT 21h
                    
                ;ESC
                CMP AL,1Bh
                JE p_menu
                
                JMP p1_menu_key             
        
        no_melody2:
        
        ;ESC
        CMP AL,1Bh
        JE m_menu
        
        JMP p_menu_key    
    
    ;Menu Modo Libre    
    f_menu:
        
        MOV octave,01h
        
        print_free_menu
        
        f_menu_key:
            MOV AH,08h
            INT 21h
        
        ;Cambiar octava
        CMP AL,31h
        JNE no_octave
        change_octave
        print_free_menu_octave
        cursor_position 02h, 14h, 26h
        JMP f_menu_key
        
        no_octave:
        
        ;Cambiar idioma
        CMP AL,32h
        JNE no_naming
        change_naming
        print_free_menu_naming
        print_free_menu_notes1
        print_free_menu_notes2
        cursor_position 02h, 14h, 26h
        JMP f_menu_key
        
        no_naming:
        
        ;Comprobar la tecla presionada
        
        ;DO#-REb
        CMP AL,'w'
        JNE skipw
        play_note 31h
        JMP f_menu_key
        
        skipw:
        
        ;RE#-MIb
        CMP AL,'e'
        JNE skipe
        play_note 33h
        JMP f_menu_key
        
        skipe:
        
        ;FA#-SOLb
        CMP AL,'t'
        JNE skipt
        play_note 36h
        JMP f_menu_key
        
        skipt:
        
        ;SOL#-LAb
        CMP AL,'y'
        JNE skipy
        play_note 38h
        JMP f_menu_key
        
        skipy:
        
        ;LA#-SIb
        CMP AL,'u'
        JNE skipu
        play_note 3Ah
        JMP f_menu_key
        
        skipu:      
              
        ;DO
        CMP AL,'a'
        JNE skipa
        play_note 30h
        JMP f_menu_key
        
        skipa:
        
        ;RE
        CMP AL,'s'
        JNE skips
        play_note 32h
        JMP f_menu_key
        
        skips:
        
        ;MI
        CMP AL,'d'
        JNE skipd
        play_note 34h
        JMP f_menu_key
        
        skipd:
        
        ;FA
        CMP AL,'f'
        JNE skipf
        play_note 35h
        JMP f_menu_key
        
        skipf:
        
        ;SOL
        CMP AL,'g'
        JNE skipg
        play_note 37h
        JMP f_menu_key
        
        skipg:
        
        ;LA
        CMP AL,'h'
        JNE skiph
        play_note 39h
        JMP f_menu_key
        
        skiph:
        
         ;SI
        CMP AL,'j'
        JNE skipj
        play_note 3Bh
        JMP f_menu_key
        
        skipj:
        
        ;ESC
        CMP AL,1Bh
        JE m_menu
        
        JMP f_menu_key    
    
           
    exit_app:           
        MOV AH,4Ch
        INT 21h
END start

END
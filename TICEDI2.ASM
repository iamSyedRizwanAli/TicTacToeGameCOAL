.MODEL SMALL      
.STACK 100H
.DATA
        GAMETITLE DB '----------TIC TAC TOE GAME--------------------THE GAME IS ON NOW------------'
        PLAYERS   DB ' '
		PLYR1NAME DB 'PLAYER1 NAME'
		          DB ' = X AND '
		PLYR2NAME DB 'PLAYER2 NAME'
		          DB ' = O'
        MATRIX DB '1  |  2  |  3 '
               DB '-  |  -  |  - '
               DB '4  |  5  |  6 '
               DB '-  |  -  |  - '
               DB '7  |  8  |  9 '
        ENTRPLR1  DB 'PLAYER ONE       ENTER A POSITION              '
        ENTRPLR1A DB 'PLAYER ONE       ENTER A CORRECT POSITION      '
        ENTRPLR2A DB 'PLAYER TWO       ENTER A CORRECT POSITION      '
        ENTRPLR2  DB 'PLAYER TWO       ENTER A POSITION              '
        WIN1 DB      'PLAYER ONE       WON THE GAME                  '
        WIN2 DB      'PLAYER TWO       WON THE GAME                  '
        WIN3 DB      '            GAME DRAW                          '
        MSG5 DB      '    HIT ANY KEY TO CONTINUE...                 '
		
        ENTRNAME DB ' ENTER NAME:'
				
        HANDLE          DW ?
        FILENAME        DB 'Database.txt', 0
.386
.CODE
MAIN PROC
		
		MOV AX, @DATA
		MOV DS, AX

		MOV AX, 0B800H
		MOV ES, AX
		
                LEA AX, FILENAME
                PUSH AX
                LEA AX, HANDLE
                PUSH AX
                CALL OPEN_FILE

		LEA AX, PLYR1NAME
		PUSH AX
		LEA AX, PLYR2NAME
		PUSH AX
		LEA AX, ENTRNAME
		PUSH AX
		CALL INPUT_USERS

		LEA AX, PLYR1NAME
		PUSH AX
		LEA AX, PLYR2NAME
		PUSH AX
		LEA AX, ENTRPLR1
		PUSH AX
		CALL USERNAMES_UPDATE
	
		LEA AX, GAMETITLE
		PUSH AX
		LEA AX, MATRIX
		PUSH AX
		LEA AX, ENTRPLR1
		PUSH AX
		LEA AX, ENTRPLR1A
		PUSH AX
		LEA AX, ENTRPLR2
		PUSH AX
		LEA AX, ENTRPLR2A
		PUSH AX
		LEA AX, WIN1
		PUSH AX
		LEA AX, WIN2
		PUSH AX
		LEA AX, WIN3
		PUSH AX
		LEA AX, MSG5
		PUSH AX
		CALL GAMEPLAY
		
		MOV AH, 1
		INT 21H

                CMP BH, 0
                JNE P1
                LEA DX, WIN3
                JMP RESULT
		
                P1:
                        CMP BH, 1
                        JNE P2
                        LEA DX, WIN1
                        JMP RESULT
		
                P2:
                        LEA DX, WIN2
                RESULT:

                MOV BX, HANDLE
                PUSH BX
                PUSH DX
                MOV CX, 47
                PUSH CX
                CALL WRITE_FINAL_RESULT

MOV AH, 4CH
INT 21H
MAIN ENDP

OPEN_FILE PROC
;this function takes offset address of filename
; and offset address of HANDLE
	
	PUSH BP
	MOV BP, SP
	
	PUSH AX
	PUSH DX
	PUSH BX

        MOV AH, 3DH
	MOV DX, [BP + 6]
	MOV AL, 2
	INT 21H

	JC NOT_OPEN

	MOV BX, [BP + 4]
	MOV [BX], AX

	NOT_OPEN:

	POP BX
	POP DX
	POP AX
	POP BP
	RET 4
OPEN_FILE ENDP

WRITE_FINAL_RESULT PROC
; this function takes Handle of file; OFFSET OF BUFFER
; and size of data to write

	PUSH BP
	MOV BP, SP
	
	PUSH BX
	PUSH AX
	PUSH CX

	MOV AL, 2
	MOV AH, 42H
	MOV BX, [BP + 8]
	XOR CX, CX
    XOR DX, DX
	INT 21H
	
	MOV AH, 40H
	MOV BX, [BP + 8]
	LEA DX, PLAYERS
	MOV CX, 38
	INT 21H

	MOV AL, 2
	MOV AH, 42H
	MOV BX, [BP + 8]
	XOR CX, CX
    XOR DX, DX
	INT 21H

	MOV AH, 40H
	MOV DX, [BP + 6]
	MOV CX, [BP + 4]
	INT 21H



	MOV AH, 3EH
	INT 21H

	POP CX
	POP AX
	POP BX

	POP BP
	RET 6
WRITE_FINAL_RESULT ENDP

USERNAMES_UPDATE PROC
;this function takes 3 arguements in its parameter; first the name of player 1
;second the name of player 2 and third the offset adress of messages
	PUSH BP
	MOV BP, SP

	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DI
	PUSH ES
	PUSH BX

	MOV AX, DS
	MOV ES, AX

	MOV CX, 12
	MOV SI, [BP + 8]	;
	MOV DI, [BP + 4]	; PLAYER ONE PROMPT
	REP MOVSB

	MOV CX, 12
	ADD DI, 35			;
	SUB SI, 12			; PLAYER ONE WRONG INPUT
	REP MOVSB

	MOV CX, 12
	ADD DI, 35			;
	MOV SI, [BP + 6]	; PLAYER TWO PROMPT
	REP MOVSB

	MOV CX, 12
	ADD DI, 35			; PLAYER TWO WRONG INPUT
	SUB SI, 12			;
	REP MOVSB

	MOV CX, 12
	MOV SI, [BP + 8]	; PLAYER ONE WON
	ADD DI, 35			; 
	REP MOVSB

	MOV CX, 12
	MOV SI, [BP + 6]	; PLAYER TWO WON
	ADD DI, 35			; 
	REP MOVSB

	POP BX
	POP ES
	POP DI
	POP SI
	POP CX
	POP AX
	POP BP
	RET 6 
USERNAMES_UPDATE ENDP

SYSTEM_CLS_COLOR PROC
; this recieves the color scheme of screen
	PUSH BP
	MOV BP, SP

	PUSH AX
	PUSH CX
	PUSH DI

	XOR DI, DI
	MOV CX, 2000
	MOV AX, [BP + 4]
	SHL AX, 8

	MOV AL, 32

	REP STOSW

	POP DI
	POP CX
	POP AX
	POP BP
	RET 2
SYSTEM_CLS_COLOR ENDP

INPUT_USERS PROC
; this function recieves 3 arguements in its parameter.
; first is the offset address of player1 and second is offset address of player2
; and 3rd is the offset address of Enter name string
	
	PUSH BP
	MOV BP, SP

	PUSH SI
	PUSH DI
	PUSH AX
	PUSH CX

	MOV AX, 1CH
	PUSH AX
	CALL SYSTEM_CLS_COLOR

	MOV AX, 1C20H
	XOR DI, DI
	MOV DI, 520
	MOV CX, 12

	MOV SI, [BP + 8]
	FOR1:
		LODSB
		STOSW
		LOOP FOR1

	MOV CX, 12
	MOV SI, [BP + 4]
	FOR2:
		LODSB
		STOSW
		LOOP FOR2

	MOV CX, [BP + 8]
	PUSH CX
	MOV CX, 12
	PUSH CX
	CALL INPUT_STRING

	MOV DI, 840
	MOV CX, 12

	MOV SI, [BP + 6]
	FOR3:
		LODSB
		STOSW
		LOOP FOR3
	
	MOV SI, [BP + 4]
	MOV CX, 12
	FOR4:
		LODSB
		STOSW
		LOOP FOR4

	MOV AX, [BP + 6]
	PUSH AX
	MOV AX, 12
	PUSH AX
	CALL INPUT_STRING

	POP CX
	POP AX
	POP DI
	POP SI
	POP BP

	RET 6
INPUT_USERS ENDP

INPUT_STRING PROC
; this function takes 2 arguements, offset address of char array destination and size

	PUSH BP
	MOV BP, SP

	PUSH BX
	PUSH CX
	PUSH AX

	MOV CX, [BP + 4]
	MOV BX, [BP + 6]
	MOV AH, 1
	INT 21H
	
	WHILE1:
		CMP AL, 13
		JE END_WHILE1

		CMP CX, 0
		JE END_WHILE1

		MOV [BX], AL

		INC BX
		DEC CX

		INT 21H

		JMP WHILE1
		END_WHILE1:

	CMP CX, 12
	JE WHILE1

	MOV AL, 20H
	FOR1:
		MOV [BX], AL
		INC BX
		LOOP FOR1

	POP AX
	POP CX
	POP BX

	POP BP
	RET 4
INPUT_STRING ENDP

DISPLAY_TURN_STATEMENT PROC
;this function only recieves the offset address of message as a parameter

		PUSH BP
		MOV BP, SP

		PUSH DI
		PUSH CX
		PUSH AX

		MOV SI, [BP + 4]
		MOV AH, 1CH
		XOR CX, CX
		MOV DI, 2926

		WHILE01:
                        CMP CL, 46
                        JE END_WHILE01

                        LODSB
                        STOSW
                        INC CL

                        JMP WHILE01
                END_WHILE01:
		
		POP AX
		POP CX
		POP DI

		POP BP
		RET 2
DISPLAY_TURN_STATEMENT ENDP

SHOW_HEADING1 PROC
;this function recieves 2 paramater first is the offset address 
;of title message and second is the offset address of turn message

        PUSH BP
        MOV BP, SP

        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI
		  
        XOR DI, DI
        MOV CX, 160

        MOV AX, 1020H
        REP STOSW

        MOV SI, [BP + 6]
        XOR DX,DX

        WHILE11:

                CMP DX, 3
                JE END_WHILE11

                MOV AX, 1C20H
                MOV CX, 21
                REP STOSW

                MOV CL, 0
        
                WHILE01:
                        CMP CL, 38
                        JE END_WHILE01

                        LODSB
                        STOSW
                        INC CL

                        JMP WHILE01
                        END_WHILE01:

                MOV AX, 1F20H
                MOV CX, 101
                REP STOSW

                INC DX

                JMP WHILE11
        END_WHILE11:

        MOV AX, 3020H
        MOV CX, 160
        REP STOSW

		PUSH SI
		CALL SHOW_MATRIX

		ADD DI, 1120

		MOV AX, 1020H
		MOV CX, 640
		REP STOSW

		MOV AX, [BP + 4]
		PUSH AX
		CALL DISPLAY_TURN_STATEMENT

		POP SI
		POP DI
		POP DX
		POP CX
		POP AX

		POP BP
		RET 4
SHOW_HEADING1 ENDP

SHOW_MATRIX PROC
        PUSH BP
        MOV BP, SP
		
        PUSH AX
        PUSH CX
        PUSH DI
        PUSH SI

        MOV DI, 1280

        MOV AX, 3020H
        MOV CX, 160
        REP STOSW

        MOV SI, [BP + 4]

        MOV CX, 33
        MOV AX, 3420H
        REP STOSW

        MOV CL, 0
        MOV CH, 1

        WHILE1:
                CMP CL, 70
                JE END_WHILE1

                CMP CH, 14
                JNA CONTINUE1

                MOV AL, 32
                PUSH CX
                MOV CX, 66
                REP STOSW
                POP CX
                MOV CH, 1
                CONTINUE1:
                
                LODSB
                STOSW
                INC CH
                INC CL
                JMP WHILE1

                END_WHILE1:


        MOV AL, 20H
        MOV CX, 193
        REP STOSW

        POP SI
        POP DI
        POP CX
        POP AX
        POP BP

        RET 2
SHOW_MATRIX ENDP

GAMEPLAY PROC
;this function takes ten (10) arguements in its parameters. First is the offset of tilte message,
;second is the offset address of matrix, third is offset address of player1 prompt message,
;fourth is the offset address of player1 prompt message(incorrect input),
;fifth is the offset address of player2 prompt message, sixth is the offset address of player2 prompt message(incorrect input)
;seventh is the winning message of player1, eigth is the winning message of player2
;ninth is the game draw message ; tenth is the hit key message  
; and return results in BH register

        PUSH BP
        MOV BP, SP

        PUSH AX
        PUSH CX
        PUSH SI
        PUSH DI

        XOR AX, AX
        XOR DX, DX
        XOR CX, CX
		XOR BX, BX

        WHILE1:

                PLAYER1_TURN:

                MOV AX, [BP + 22]
                PUSH AX
                MOV AX, [BP + 18]
                PUSH AX
                CALL SHOW_HEADING1

                MOV AH, 1
                INT 21H
			
                INPUT_VALIDATION:
                CMP AL, '0'                                             ; if input is below range
                JE WRONG_INPUT_PLAYER1                  ;
                CMP AL, '9'                                             ; if input is above range
                JA WRONG_INPUT_PLAYER1                  ;
                XOR AH, AH                                              ;
					
					MOV BX, [BP + 20]
					PUSH BX
					PUSH AX
					MOV BX, 'X'
					PUSH BX							
					CALL IMPLEMENT_CHOICE			; calling function to make changes in matrix
					CMP DH, 0						; if DH has 0 then input was wrong else it was right
					JE WRONG_INPUT_PLAYER1
					
					INC CL
								
					JMP IS_PLAYER1_WINNER			
					
					WRONG_INPUT_PLAYER1:
						MOV AX, [BP + 22]
						PUSH AX
						MOV AX, [BP + 16]
						PUSH AX
						CALL SHOW_HEADING1

						MOV AH, 1
						INT 21H
						JMP INPUT_VALIDATION
					
					IS_PLAYER1_WINNER:
						CMP CL, 5
						JB PLAYER2_TURN
						MOV BX, 'X'
						PUSH BX
						CALL FOUND_WINNER	
						JNZ PLAYER2_TURN

					MOV BX, [BP + 22]
					PUSH BX
					MOV BX, [BP + 10]
					PUSH BX
					CALL SHOW_HEADING1
					MOV BH, 1
					JMP GAME_NOT_DRAW

			PLAYER2_TURN:

				CMP CL, 8
				JAE END_WHILE1

				MOV AX, [BP + 22]
				PUSH AX
				MOV AX, [BP + 14]
				PUSH AX
				CALL SHOW_HEADING1
				
				MOV AH, 1
				INT 21H
			
				INPUT_VALIDATION2:
					CMP AL, '0'						; if input is below range
					JE WRONG_INPUT_PLAYER2			;
					CMP AL, '9'						; if input is above range
					JA WRONG_INPUT_PLAYER2			;
					XOR AH, AH						;
					
					MOV BX, [BP + 20]
					PUSH BX
					PUSH AX
					MOV BX, 'O'
					PUSH BX							;
					CALL IMPLEMENT_CHOICE			; calling function to make changes in matrix
					CMP DH, 0						; if DH has 0 then input was wrong else it was right
					JE WRONG_INPUT_PLAYER2			;
					JMP IS_PLAYER2_WINNER			;
					
					WRONG_INPUT_PLAYER2:
						MOV AX, [BP + 22]
						PUSH AX
						MOV AX, [BP + 12]
						PUSH AX
						CALL SHOW_HEADING1

						MOV AH, 1
						INT 21H
						JMP INPUT_VALIDATION2
					
					IS_PLAYER2_WINNER:
						CMP CL, 5
						JB END_PLAYER2_TURN
						MOV BX, 'O'
						PUSH BX
						CALL FOUND_WINNER	
						JNZ END_PLAYER2_TURN

					MOV BX, [BP + 22]
					PUSH BX
					MOV BX, [BP + 8]
					PUSH BX
					CALL SHOW_HEADING1
					MOV BH, 2
					JMP GAME_NOT_DRAW
					
			END_PLAYER2_TURN:
			
			INC CL

			CMP CL, 9
			JB WHILE1

			END_WHILE1:
					

			MOV BX, [BP + 22]
			PUSH BX
			MOV BX, [BP + 6]
			PUSH BX
			CALL SHOW_HEADING1
			MOV BH, 00
			
			GAME_NOT_DRAW:

			MOV DI, 3246
			MOV SI, [BP + 4]

			MOV AH, 1CH
			MOV CL, 0
        
            WHILE01:
				CMP CL, 38
                JE END_WHILE01
				
				LODSB
                STOSW
                INC CL

                        JMP WHILE01
            END_WHILE01:

		POP DI
		POP SI
		POP CX
		POP AX
		POP BP

		RET 20
GAMEPLAY ENDP

IMPLEMENT_CHOICE PROC
; this function takes three arguements in parameter, first is the offset address of matrix
; second arguement is players choice
; third arguement is players sign
; returns result in DH, if DH is 1 then player is winner and vice versa
	
	PUSH BP
	MOV BP, SP

	PUSH AX
	PUSH BX
	PUSH CX
	PUSH SI
	
	MOV SI, [BP + 8]
	MOV BX, [BP + 6]
	MOV DX, [BP + 4]

	XOR CX, CX
	
	LODSB

	WHILE1:
		CMP CX, 75
		JE END_FOUND

		CMP AL , BL
		JE FOUND

		LODSB
		INC CX

		JMP WHILE1
		END_WHILE1:
		
		FOUND:
			DEC SI
			MOV [SI], DL
			MOV DH, 1
			JMP FOUND_END
		END_FOUND:
			MOV DH, 0
			FOUND_END:

	POP SI
	POP CX
	POP BX
	POP AX

	POP BP

	RET 6
IMPLEMENT_CHOICE ENDP

FOUND_WINNER PROC
;this function will recieve one parameter which is the sign of user. The output will be given in Zero Flag, if ZF is On then incoming user is winner else not now.

		PUSH BP
		MOV BP, SP
		PUSH SI
		PUSH BX
		PUSH AX

		MOV AX, [BP + 4]
		MOV BX, 0
		MOV SI, 0

		CASE1:										;if(matrix[0][0] == matrix[0][6] && matrix[0][6] == matrix[0][12] && matrix[0][12] == sign)
			
			MOV BX, 0
			MOV SI, 0
			
			CMP MATRIX[BX][SI], AL ; (MATRIX[0][0])
			JNE CASE4
			
			ADD SI, 6

			CMP  MATRIX[BX][SI], AL ; (MATRIX[0][6])
			JNE CASE2

			ADD SI, 6 

			CMP MATRIX[BX][SI], AL ; (MATRIX[0][12])
			JE END_CASES

		CASE2:										;else if(matrix[0][0] == matrix[2][6] && matrix[2][6] == matrix[4][12] && matrix[4][12] == sign)
						
			MOV BX, 0
			MOV SI, 0
			
			CMP MATRIX[BX][SI], AL ; (MATRIX[0][0])
			JNE CASE4
			
			MOV SI, 6
			ADD BX, 28

			CMP MATRIX[BX][SI], AL ; (MATRIX[2][6])
			JNE CASE3

			ADD SI, 6
			ADD BX, 28

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][12])
			JE END_CASES

		CASE3:										;else if(matrix[0][0] == matrix[2][0] && matrix[2][0] == matrix[4][0] && matrix[4][0] == sign)
			
			MOV BX, 0
			MOV SI, 0
			
			CMP MATRIX[BX][SI], AL ; (MATRIX[0][0])
			JNE CASE4
	
			MOV BX, 28

			CMP MATRIX[BX][SI], AL ; (MATRIX[2][0])
			JNE CASE4

			ADD BX, 28

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][0])
			JE END_CASES

		CASE4:										;else if(matrix[2][0] == matrix[2][6] && matrix[2][6] == matrix[2][12] && matrix[2][12] == sign)
			
			MOV BX, 28
			MOV SI, 0
			
			CMP MATRIX[BX][SI], AL ; (MATRIX[2][0])
			JNE CASE5
	
			ADD SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[2][6])
			JNE CASE5

			ADD SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[2][12])
			JE END_CASES

		CASE5:										;else if(matrix[4][0] == matrix[4][6] && matrix[4][6] == matrix[4][12] && matrix[4][12] == sign)
			
			MOV BX, 56
			MOV SI, 0

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][0])
			JNE CASE6

			ADD SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][6])
			JNE CASE6

			ADD SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][12])
			JE END_CASES

		CASE6:										;else if(matrix[0][12] == matrix[2][6] && matrix[2][6] == matrix[4][0] && matrix[4][0] == sign)
			
			MOV BX, 0
			MOV SI, 12

			CMP MATRIX[BX][SI], AL ; (MATRIX[0][12])
			JNE CASE7

			MOV BX, 28
			MOV SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[2][6])
			JNE CASE7

			ADD BX, 28
			MOV SI, 0

			CMP MATRIX[BX][SI], AL ; (MATRIX[4][0])
			JE END_CASES

		CASE7:										;else if(matrix[0][6] == matrix[2][6] && matrix[2][6] == matrix[4][6] && matrix[4][6] == sign)

			MOV BX, 0
			MOV SI, 6

			CMP MATRIX[BX][SI], AL ; (MATRIX[0][6])
			JNE CASE8

			ADD BX, 28
			CMP MATRIX[BX][SI], AL ; (MATRIX[2][6])
			JNE CASE8

			ADD BX, 28
			CMP MATRIX[BX][SI], AL ; (MATRIX[4][6])
			JE END_CASES

		CASE8:										;else if(matrix[0][12] == matrix[2][12] && matrix[2][12] == matrix[4][12] && matrix[4][12] == sign)

			MOV BX, 0
			MOV SI, 12

			CMP MATRIX[BX][SI], AL ; (MATRIX[0][12])
			JNE END_CASES

			ADD BX, 28
			CMP MATRIX[BX][SI], AL ; (MATRIX[2][12])
			JNE END_CASES

			ADD BX, 28
			CMP MATRIX[BX][SI], AL ; (MATRIX[4][12])

		END_CASES:

		POP AX
		POP BX
		POP SI
		POP BP

		RET 2
FOUND_WINNER ENDP

END MAIN

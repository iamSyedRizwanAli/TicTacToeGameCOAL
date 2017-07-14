.MODEL SMALL
.STACK 100H
.DATA
        INSTRUCTIONS DB "You have to choose a single coloumn out of following 9 coloumns", 13, 10, "Once a coloumn is selected either by system or you, cannot be selected again", 13, 10, '$'
        MATRIX DB 49, 50, 51
               DB 52, 53, 54
               DB 55, 56, 57
        PROMPT1 DB 10, 13, "Select a coloumn: $"
		PROMPT2 DB 10, 13, "WRONG INPUT! Select a column: $"
        MSG1 DB 10, 13, "System selected: $"
        MSG2 DB 10, 13, 10, 13, "Result: YOU WON (Nach beta! Nach!)", 10, 13, '$'
        MSG3 DB 10, 13, 10, 13, "Result: SYSTEM WON (yeh cheez)", 10, 13, '$'
        MSG4 DB 10, 13, 10, 13, "Result: GAME DRAW (agli baar nahi chooro ga)", 10, 13, '$'
        MSG5 DB 10, 13, "Hit any key to continue...$"
.CODE
MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        MOV AX, 0B800H
        MOV ES, AX

        CALL SYSTEM_CLS

        MOV AH, 9
        LEA DX, INSTRUCTIONS
        INT 21H

        LEA DX, MATRIX
        PUSH DX

        CALL DISPLAY_MATRIX
		
		LEA DX, MATRIX
		PUSH DX
		LEA DX, PROMPT1
		PUSH DX
		LEA DX, PROMPT2
		PUSH DX
		LEA DX, MSG1
		PUSH DX
		LEA DX, MSG2
		PUSH DX
		LEA DX, MSG3
		PUSH DX
		LEA DX, MSG4
		PUSH DX

		CALL GAMEPLAY	; driver function for gaming

		MOV AH, 9
		LEA DX, MSG5	; this message has no particular affect on the working of game
		INT 21H

		MOV AH, 1
		INT 21H

MOV AH, 4CH
INT 21H
MAIN ENDP

GAMEPLAY PROC ; this function recieves 7 arguements in its parameter and returns nothing. Offset address of matrix must be first entered, then the offset address of prompt1 message 1 and consecutively prompt message 2; then offset address of player winnig message, then of system winning message and then of game draw message
		PUSH BP
		MOV BP, SP
		
		PUSH CX
		PUSH DX
		PUSH AX
		PUSH BX
		MOV AX, 49	; this number is passed onto stack so that for random function it can be used
		PUSH AX
		
		XOR AX, AX
		XOR DX, DX
		XOR CX, CX

		WHILE1:
			
			CMP CL, 9	; this statement checks the number of total marks on the game sketch, marks must not be more than 9
			JA END_WHILE1

			MOV AH, 9
			MOV DX, [BP + 14]	; this is the first prompt message (Select a coloumn:)
			INT 21H

			USER_CHOICE:
				MOV AH, 1		; taking input from player
				INT 21H

				MOV BL, AL		; the input character is stored in BL so that system can use it, while choosing a coloumn

				MOV AH, 0

				PUSH [BP + 16]	; passing offset address of matrix to the IMPLEMENT_CHOICE function
				PUSH AX			; passing the choice of player to the IMPLEMENT_CHOICE function
                MOV AX, 'X'		; passing the sign of player to IMPLEMENT_CHOICE function
                PUSH AX

				CALL IMPLEMENT_CHOICE
				JZ END_USER_CHOICE	; zero flag will be effected by IMPLEMENT_CHOICE function; if zero flag is ON then the input is correct; if it is not then input is wrong

				MOV AH, 9
				MOV DX, [BP + 12]	; this is the second prompt message; it will be shown when player has entered wrong input
				INT 21H

				JMP USER_CHOICE
				END_USER_CHOICE:

			INC CL		; this is the counter, which will count the number of marks
			
			CMP CL, 5	; if there are atleast 5 marks on sheet, then there is probability that we have a winner
			JB SYSTEM_TURN

			PUSH [BP + 16]		; passing offset address of Matrix to FOUND_WINNER function
			MOV AX, 'X'			; passing sign of current player to FOUND_WINNER function
			PUSH AX

			CALL FOUND_WINNER	; this function will affect the Zero flag, if Zero flag is ON we have a winner, if not then not yet
			JNZ SYSTEM_TURN		; if there are no winners

			MOV AH, 9
			MOV DX, [BP + 8]	; this is the winner message for player that he/she has won the game
			INT 21H

			JMP GAME_NOT_DRAWN

			SYSTEM_TURN:
			XOR BH, BH
			
			CMP CL, 9
			JE	END_SYSTEM_CHOICE		
			
			CMP CL, 2			; when system will be playing its first turn then SYSTEM_THINKING function will not be called
			JA SYSTEM_CHOICE

			MOV AX, '5'
			MOV BL, '5'			; first choice of system will be '5' unless it has been selected by the player
			PUSH [BP + 16]		; passing offset address of matrix to IMPLEMENT_CHOICE function
			PUSH AX				; passing 5 to IMPLEMENT_CHOICE function
            MOV AX, 'O'			; passing the sign used to system to IMPLEMENT_CHOICE function
            PUSH AX
			CALL IMPLEMENT_CHOICE

			JNZ RANDOM_CHOICE	; if zero flag is turned ON by the IMPLEMENT_CHOICE function then the program will continue in manner else RANDOM_CHOICE function will be called
			JZ END_SYSTEM_CHOICE1			

			SYSTEM_CHOICE:
			
			PUSH [BP + 16]		; passing the offset address of matrix to SYSTEM_THINKING function
			PUSH BX				; passing the choice of player to the SYSTEM_THINKING function so that it can be used for further decision making
			CALL SYSTEM_THINKING

			MOV BX, AX			; the function SYSTEM_THINKING will return the coloumn selected by it and success of implementation of choice in AX register, success of implementation will be in AH, if AH is 0 then it is failed, if 1 then success; the value selected by function will be in AL 

			CMP BH, 1			; checking the success of SYSTEM_THINKING function; if zero flag in turned ON then success else failed
			JZ END_SYSTEM_CHOICE1
			
				RANDOM_CHOICE:	; upon failure of SYSTEM_THINKING function Random function will be called
				POP AX			; popping the value into AX which was pushed in the start of GAMEPLAY function or last values pushed during the previous iterations of this loop 
				CALL RANDOM		 
				PUSH AX			; pushing the new value from RANDOM function on stack, so it can be used again for RANDOM function

				XOR DX, DX
				MOV BX, 9
				DIV BX			; these set of lines divide the newly emerged random with 9
				MOV AX, DX
				INC AX			; since answer will lie between 0 to 8. So, adding 1 will bring answer between 1-9
				OR AL, 30H
				MOV BX, AX		; saving selected value in BX so it could be shown on screen
						
				PUSH [BP + 16]	; passing offset address of matrix
				PUSH AX			; passing the new value
				MOV AX, 'O'		; passing the sign of system
				PUSH AX
				CALL IMPLEMENT_CHOICE
				JNZ RANDOM_CHOICE
			
			END_SYSTEM_CHOICE1:
		
			MOV AH, 9
			MOV DX, [BP + 10]	; this message is (System selected:)
			INT 21H

			MOV DH, 0			; clearing DH so output can not be disturbed
				
			MOV AH, 2
			MOV DL, BL		
			INT 21H

			CMP CL, 5			; same condition for finding the winner of game
			JBE END_SYSTEM_CHOICE

			PUSH [BP + 16]		; passing offset of matrix to FOUND_WINNER function
			MOV AX, 'O'			; passing sign of system to FOUND_WINNER function
			PUSH AX

			CALL FOUND_WINNER
			JNZ END_SYSTEM_CHOICE	; if ZERO FLAG is setted ON then system is winner else not

			MOV AH, 9
			MOV DX, [BP + 6]		; this message will be displayed when system have won the game
			INT 21H

			JMP GAME_NOT_DRAWN
			END_SYSTEM_CHOICE:

			INC CL

			MOV AH, 2
			MOV DL, 10
			INT 21H			; these lines take cursor to next line
			MOV DL, 13
			INT 21H

			PUSH [BP + 16]		; passig offset address of matrix to DISPLAY_MATRIX function
			CALL DISPLAY_MATRIX

			JMP WHILE1
			END_WHILE1:
		
		CMP CL, 10			; if there are no winner and CL has reached 10 then game has drawn
		JNZ GAME_NOT_DRAWN
		
		MOV AH, 9
		MOV DX, [BP + 4]	; this is the message of game drawn
		INT 21H

		GAME_NOT_DRAWN:

		PUSH [BP + 16]		; passing offset address of matrix to DISPLAY_MATRIX function
		CALL DISPLAY_MATRIX	


		POP AX
		POP BX				; poping all values which were pushed in the start of this function
		POP AX
		POP DX
		POP CX

		POP BP
		RET 14	; happy ending :)
GAMEPLAY ENDP

DISPLAY_MATRIX PROC	; this function recieves a parameter that is the offset address of matrix and has void return type
        PUSH BP
        MOV BP, SP

        PUSH DX
        PUSH AX
        PUSH CX
        PUSH SI

        XOR CX, CX

        MOV AH, 2
        MOV SI, [BP + 4]	; loading offset address of matrix on SI register

        WHILE1:
                CMP CH, 3		; since the matrix is of 3 by 3 therefore outter loop will iterate 3 times and inner loop will iterate 9 times
                JE END_WHILE1

                WHILE2:
                        CMP CL, 3
                        JE END_WHILE2

                        MOV BYTE PTR  DL, [SI]
                        INT 21H

                        MOV DL, 32	; this is for displaying space between characters
                        INT 21H

                        INC CL	; here CL is the counter for inner loop
                        INC SI	; with display of each character SI pointer points to next value

                        JMP WHILE2
                        END_WHILE2:

                MOV DL, 13
                INT 21H
                MOV DL, 10	; these lines take cursor to next line on console
                INT 21H

                INC CH	; here CH is counter for outer loop
                XOR CL, CL ; clearing CL so next iteration can be made

                JMP WHILE1
                END_WHILE1:

        POP SI
        POP CX
        POP AX	; restoring the original values of registers
        POP DX
        POP BP

        RET 2	; happy ending :)
DISPLAY_MATRIX ENDP

RANDOM PROC			; this function recieves a paremeter in AX register and gives output in AX register
					; this function is implemented as it is described in book
        PUSH BP
        PUSH DX

        XOR DX, DX

        SHL AX, 1
        OR DL, AH

        AND DL, 0C0H	

        JZ ZERO_BIT_ZERO
        CMP DL, 0C0H
        JE ZERO_BIT_ZERO

        OR AL, 1
        JMP END_ZERO_BIT_ZERO

        ZERO_BIT_ZERO:
                AND AL, 0FEH
                END_ZERO_BIT_ZERO:
        AND AH, 7FH

        POP DX
        POP BP
        RET      ; since no values are passed through stack
RANDOM ENDP

IMPLEMENT_CHOICE PROC		; this function has BOOL type of return type, the output of this function will be in Zero Flag; if Zero flag is ON then insertion is successful, else it is failed. This function has three parameters Offset address of Matrix, the user choice and the sign used by user
		PUSH BP					
		MOV BP, SP

		PUSH AX
		PUSH SI

		MOV BYTE PTR AL, [BP + 6]     ; user choice
		MOV BYTE PTR AH, [BP + 4]     ; sign of user
		MOV SI, [BP + 8]			  ; offset address of matrix	

		AND AL, 0FH	 ; getting integral value of user
		
		DEC AL
                		; getting index location
                PUSH AX
                MOV AH , 0

                ADD SI, AX  ; pointing SI to the required index

                POP AX

		INC AL		; getting integral value

		OR AL, 30H  ; again changing value for comparison

                CMP BYTE PTR [SI], AL
                JE  IMPLEMENT
		JMP END_IMPLEMENT

		IMPLEMENT:
				MOV BYTE PTR [SI], AH
				END_IMPLEMENT:

		POP SI
		POP AX
		POP BP
		RET 6
IMPLEMENT_CHOICE ENDP

FOUND_WINNER PROC ; this function will recieve two parameter 1st the offset address of matrix and 2nd the sign of user. The output will be given in Zero Flag, if ZF is On then incoming user is winner else not now.
		PUSH BP		; this function have compound conditional statements, there alike codes of C++ are written for better understanding
		MOV BP, SP
		PUSH SI
		PUSH BX
		PUSH AX

		MOV AX, [BP + 4]
		MOV SI, [BP + 6]

		
		CMP BYTE PTR [SI], AL  ;if(matrix[0][0] == matrix[0][1] && matrix[0][1] == matrix[0][2] && matrix[0][2] == sign)
		JNZ ELSE1

		MOV BX, [SI + 1]
		CMP BYTE PTR [SI], BL
		JNZ ELSE1

		MOV BX, [SI + 2]
		CMP BYTE PTR [SI], BL
		JNZ ELSE1
		JMP END_ELSES

		ELSE1:					;else if(matrix[0][0] == matrix[1][1] && matrix[1][1] == matrix[2][2] && matrix[2][2] == sign)
		CMP BYTE PTR [SI], AL
		JNZ ELSE2

		MOV BX, [SI + 4]
		CMP BYTE PTR [SI], BL
		JNZ ELSE2

		MOV BX, [SI + 8]
		CMP BYTE PTR [SI], BL
		JNZ ELSE2
		JMP END_ELSES

		ELSE2:				;else if(matrix[0][0] == matrix[1][0] && matrix[1][0] == matrix[2][0] && matrix[2][0] == sign)
		CMP BYTE PTR [SI], AL
		JNZ ELSE3

		MOV BX, [SI + 3]
		CMP BYTE PTR [SI], BL
		JNZ ELSE3

		MOV BX, [SI + 6]
		CMP BYTE PTR [SI], BL
		JNZ ELSE3
		JMP END_ELSES

		ELSE3:				;else if(matrix[1][0] == matrix[1][1] && matrix[1][1] == matrix[1][2] && matrix[1][2] == sign)
		CMP BYTE PTR [SI + 3], AL
		JNZ ELSE4

		MOV BX, [SI + 4]
		CMP BYTE PTR [SI + 3], BL
		JNZ ELSE4

		MOV BX, [SI + 5]
		CMP BYTE PTR [SI + 3], BL
		JNZ ELSE4
		JMP END_ELSES

		ELSE4:				;else if(matrix[2][0] == matrix[2][1] && matrix[2][1] == matrix[2][2] && matrix[2][2] == sign)
		CMP BYTE PTR [SI + 6], AL
		JNZ ELSE5

		MOV BX, [SI + 7]
		CMP BYTE PTR [SI + 6], BL
		JNZ ELSE5

		MOV BX, [SI + 8]
		CMP BYTE PTR [SI + 6], BL
		JNZ ELSE5
		JMP END_ELSES

		ELSE5:				;else if(matrix[0][1] == matrix[1][1] && matrix[1][1] == matrix[2][1] && matrix[2][1] == sign)
		CMP BYTE PTR [SI + 1], AL
		JNZ ELSE6

		MOV BX, [SI + 4]
		CMP BYTE PTR [SI + 1], BL
		JNZ ELSE6

		MOV BX, [SI + 7]
		CMP BYTE PTR [SI + 1], BL
		JNZ ELSE6
		JMP END_ELSES

		ELSE6:					;else if(matrix[0][2] == matrix[1][2] && matrix[1][2] == matrix[2][2] && matrix[2][2] == sign)
		CMP BYTE PTR [SI + 2], AL
		JNZ ELSE7

		MOV BX, [SI + 5]
		CMP BYTE PTR [SI + 2], BL
		JNZ ELSE7

		MOV BL, [SI + 8]
		CMP BYTE PTR [SI + 2], BL
		JNZ ELSE7
		JMP END_ELSES

		ELSE7:				;else if(matrix[0][2] == matrix[1][1] && matrix[1][1] == matrix[2][0] && matrix[2][0] == sign)
		CMP BYTE PTR [SI + 2], AL
		JNZ END_ELSES

		MOV BX, [SI + 4]
		CMP BYTE PTR [SI + 2], BL
		JNZ END_ELSES

		MOV BX, [SI + 6]
		CMP BYTE PTR [SI + 2], BL
		
		END_ELSES:

		POP AX
		POP BX
		POP SI
		POP BP
		RET 4
FOUND_WINNER ENDP

SYSTEM_THINKING PROC	; this function recieves 2 parameters via stack; first parameter is the offset address of matrix and then the choice of player; the output of the function will be in AX register, success of choice implementation will be in AH, and choice of character will be in AL
		PUSH BP			; by checking the characters where user may have marked, this function will decide where to mark. If decision made this functoin is success full then BH will have 1 in it and BL will value in it within the function when function will be in end, the value of BX will be transferred in to AX
		MOV BP, SP		; there are certain combination of checks for each of the 9 value. There equivalent code in C++ are written in comments for better understanding
						; each of the 9 conditions has further atmost 8 conditions
		PUSH SI
		PUSH BX

		XOR AX, AX
		MOV SI, [BP + 6]	;loading offset address of matrix to SI
		MOV AX, [BP + 4]	; loading choice of player in AX register
		
		XOR BH, BH		

		;if ax == 5

		CMP AL, '5'		; 5 is checked first because it has the largest number of checks
		JNE ELSE1

		;if5a ; if(matrix[0][0] == matrix[1][1] && matrix[2][2] != 'O')

			MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
			CMP BYTE PTR [SI], BL		; SI = matrix[0][0]
			JNE ELSE_IF5B

			CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
			JE ELSE_IF5B

			MOV BYTE PTR [SI + 8], 'O'
			MOV BH, 1
			MOV BL, '9'
			JMP END_ELSES

		ELSE_IF5B:		;else if(matrix[0][1] == matrix[1][1] && matrix[2][1] != 'O') 
			
			MOV BYTE PTR BL, [SI + 1]	; SI + 1 = matrix[0][1]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5C
			
			CMP BYTE PTR [SI + 7], 'O'	; SI + 7 = matrix[2][1]
			JE ELSE_IF5C

			MOV BYTE PTR [SI + 7], 'O'
			MOV BH, 1
			MOV BL, '8'
			JMP END_ELSES
			  
		ELSE_IF5C:		;else if(matrix[0][2] == matrix[1][1] && matrix[2][0] != 'O')
		
			MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5D
			
			CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
			JE ELSE_IF5D

			MOV BYTE PTR [SI + 6], 'O'
			MOV BH, 1
			MOV BL, '7'
			JMP END_ELSES
			
		ELSE_IF5D:		;else if(matrix[1][0] == matrix[1][1] && matrix[1][2] != 'O')
		
			MOV BYTE PTR BL, [SI + 3]	; SI + 3 = matrix[1][0]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5C
			
			CMP BYTE PTR [SI + 5], 'O'	; SI + 5 = matrix[1][2]
			JE ELSE_IF5C

			MOV BYTE PTR [SI + 5], 'O'
			MOV BH, 1
			MOV BL, '6'
			JMP END_ELSES
			
		ELSE_IF5E:		;else if(matrix[1][2] == matrix[1][1] && matrix[1][0] != 'O')
		
			MOV BYTE PTR BL, [SI + 5]	; SI + 5 = matrix[1][2]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5C
			
			CMP BYTE PTR [SI + 3], 'O'	; SI + 3 = matrix[1][0]
			JE ELSE_IF5C

			MOV BYTE PTR [SI + 3], 'O'
			MOV BH, 1
			MOV BL, '4'
			JMP END_ELSES
			
		ELSE_IF5F:		;else if(matrix[2][0] == matrix[1][1] && matrix[0][2] != 'O')
		
			MOV BYTE PTR BL, [SI + 6]	; SI + 6 = matrix[2][0]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5C
			
			CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
			JE ELSE_IF5C

			MOV BYTE PTR [SI + 2], 'O'
			MOV BH, 1
			MOV BL, '3'
			JMP END_ELSES
			
		ELSE_IF5G:		;else if(matrix[2][1] == matrix[1][1] && matrix[0][1] != 'O')
		
			MOV BYTE PTR BL, [SI + 7]	; SI + 7 = matrix[2][1]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE ELSE_IF5H
			
			CMP BYTE PTR [SI + 1], 'O'	; SI + 1 = matrix[0][1]
			JE ELSE_IF5H

			MOV BYTE PTR [SI + 1], 'O'
			MOV BH, 1
			MOV BL, '2'
			JMP END_ELSES
		
		ELSE_IF5H:		;else if(matrix[2][2] == matrix[1][1] && matrix[0][0] != 'O')
			
			MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
			CMP BYTE PTR [SI + 4], BL	; SI + 4 = matrix[1][1]
			JNE END_ELSES

			CMP BYTE PTR [SI], 'O'		; SI = matrix[0][0]
			JE END_ELSES

			MOV BYTE PTR [SI], 'O'
			MOV BH, 1
			MOV BL, '1'
			JMP END_ELSES

			ELSE1:

			CMP AL, '1'
			JA ELSE_IF2

			;if ax == 1
				;if1a			;if(matrix[0][0] ==	matrix[0][1] && matrix[0][2] != 'O')
				
					MOV BYTE PTR BL, [SI + 1]	; SI + 1 = matrix[0][1]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE ELSE_IF1B
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE ELSE_IF1B

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
				ELSE_IF1B:		;else if(matrix[0][0] == matrix[1][0] && matrix[2][0] != 'O')
						
					MOV BYTE PTR BL, [SI + 3]	; SI + 3 = matrix[1][0]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE ELSE_IF1C
			
					CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
					JE ELSE_IF1C

					MOV BYTE PTR [SI + 6], 'O'
					MOV BH, 1
					MOV BL, '7'
					JMP END_ELSES
			
				ELSE_IF1C:		;else if(matrix[0][0] == matrix[1][1] && matrix[2][2] != 'O')
					
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE ELSE_IF1D
			
					CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
					JE ELSE_IF1D

					MOV BYTE PTR [SI + 8], 'O'
					MOV BH, 1
					MOV BL, '9'
					JMP END_ELSES
			
				ELSE_IF1D:		;else if(matrix[0][0] == matrix[2][2] && matrix[1][1] != 'O')
					
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE ELSE_IF1E
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE ELSE_IF1E

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
				ELSE_IF1E:		;else if(matrix[0][0] == matrix[0][2] && matrix[0][1] != 'O')
					
					MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE ELSE_IF1F
			
					CMP BYTE PTR [SI + 1], 'O'	; SI + 1 = matrix[0][1]
					JE ELSE_IF1F

					MOV BYTE PTR [SI + 1], 'O'
					MOV BH, 1
					MOV BL, '2'
					JMP END_ELSES
			
				ELSE_IF1F:		;else if(matrix[0][0] == matrix[2][0] && matrix[1][0] != 'O')
					
					MOV BYTE PTR BL, [SI + 6]	; SI + 6 = matrix[2][0]
					CMP BYTE PTR [SI], BL	; SI = matrix[0][0]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 3], 'O'	; SI + 3 = matrix[1][0]
					JE END_ELSES

					MOV BYTE PTR [SI + 3], 'O'
					MOV BH, 1
					MOV BL, '4'
					JMP END_ELSES
			
			ELSE_IF2:	;if ax == 2

			CMP AL, '2'
			JA ELSE_IF3

				;if2a			;if(matrix[0][1] == matrix[0][0] && matrix[0][2] != 'O')
					
					MOV BYTE PTR BL, [SI]	; SI = matrix[0][0]
					CMP BYTE PTR [SI + 1], BL	; SI + 1 = matrix[0][1]
					JNE ELSE_IF2B
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE ELSE_IF2B

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
				ELSE_IF2B:		;else if(matrix[0][1] == matrix[0][2] && matrix[0][0] != 'O')
						
					MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
					CMP BYTE PTR [SI + 1], BL	; SI + 1 = matrix[0][1]
					JNE ELSE_IF2C
			
					CMP BYTE PTR [SI], 'O'	; SI= matrix[0][0]
					JE ELSE_IF2C

					MOV BYTE PTR [SI], 'O'
					MOV BH, 1
					MOV BL, '1'
					JMP END_ELSES
			
				ELSE_IF2C:		;else if(matrix[0][1] == matrix[1][1] && matrix[2][1] != 'O')
						
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 1], BL	; SI + 1 = matrix[0][1]
					JNE ELSE_IF2D
			
					CMP BYTE PTR [SI + 7], 'O'	; SI + 7 = matrix[2][1]
					JE ELSE_IF2D

					MOV BYTE PTR [SI + 7], 'O'
					MOV BH, 1
					MOV BL, '8'
					JMP END_ELSES
			
				ELSE_IF2D:		;else if(matrix[0][1] == matrix[2][1] && matrix[1][1] != 'O')		
			
					MOV BYTE PTR BL, [SI + 7]	; SI + 7 = matrix[2][1]
					CMP BYTE PTR [SI + 1], BL	; SI + 1 = matrix[0][1]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE END_ELSES

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
			ELSE_IF3:	;if ax == 3
			
			CMP AL, '3'
			JA ELSE_IF4
				;if3a			;if(matrix[0][2] == matrix[0][1] && matrix[0][0] != 'O')
						
					MOV BYTE PTR BL, [SI + 1]	; SI + 1= matrix[0][1]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE ELSE_IF3B
			
					CMP BYTE PTR [SI], 'O'	; SI = matrix[0][0]
					JE ELSE_IF3B

					MOV BYTE PTR [SI], 'O'
					MOV BH, 1
					MOV BL, '1'
					JMP END_ELSES
			
				ELSE_IF3B:		;else if(matrix[0][2] == matrix[1][2] && matrix[2][2] != 'O')
					
					MOV BYTE PTR BL, [SI + 5]	; SI + 5 = matrix[1][2]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE ELSE_IF3C
			
					CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
					JE ELSE_IF3C

					MOV BYTE PTR [SI + 8], 'O'
					MOV BH, 1
					MOV BL, '9'
					JMP END_ELSES
			
				ELSE_IF3C:		;else if(matrix[0][2] == matrix[1][1] && matrix[2][0] != 'O')
					
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE ELSE_IF3D
			
					CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
					JE ELSE_IF3D

					MOV BYTE PTR [SI + 6], 'O'
					MOV BH, 1
					MOV BL, '7'
					JMP END_ELSES
			
				ELSE_IF3D:		;else if(matrix[0][2] == matrix[0][0] && matrix[0][1] != 'O')
					
					MOV BYTE PTR BL, [SI]	; SI = matrix[0][0]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE ELSE_IF3E
			
					CMP BYTE PTR [SI + 1], 'O'	; SI + 1 = matrix[0][1]
					JE ELSE_IF3E

					MOV BYTE PTR [SI + 1], 'O'
					MOV BH, 1
					MOV BL, '2'
					JMP END_ELSES
			
				ELSE_IF3E:		;else if(matrix[0][2] == matrix[2][2] && matrix[1][2] != 'O')
					
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE ELSE_IF3F
			
					CMP BYTE PTR [SI + 5], 'O'	; SI + 5 = matrix[1][2]
					JE ELSE_IF3F

					MOV BYTE PTR [SI + 5], 'O'
					MOV BH, 1
					MOV BL, '6'
					JMP END_ELSES
			
				ELSE_IF3F:		;else if(matrix[0][2] == matrix[2][0] && matrix[1][1] != 'O')
					
					MOV BYTE PTR BL, [SI + 6]	; SI + 6 = matrix[2][0]
					CMP BYTE PTR [SI + 2], BL	; SI + 2 = matrix[0][2]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE END_ELSES

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
			ELSE_IF4:	;if ax == 4

			CMP AL, '4'
			JA ELSE_IF6
				;if4a			;if(matrix[1][0] ==	matrix[1][1] && matrix[1][2] != 'O')
					
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 3], BL	; SI + 3 = matrix[1][0]
					JNE ELSE_IF4B
			
					CMP BYTE PTR [SI + 5], 'O'	; SI + 5 = matrix[1][2]
					JE ELSE_IF4B

					MOV BYTE PTR [SI + 5], 'O'
					MOV BH, 1
					MOV BL, '6'
					JMP END_ELSES
			
				ELSE_IF4B:		;else if(matrix[1][0] == matrix[2][0] && matrix[0][0] != 'O')
						
					MOV BYTE PTR BL, [SI + 6]	; SI + 4 = matrix[2][0]
					CMP BYTE PTR [SI + 3], BL	; SI + 3 = matrix[1][0]
					JNE ELSE_IF4C
			
					CMP BYTE PTR [SI], 'O'	; SI = matrix[0][0]
					JE ELSE_IF4C

					MOV BYTE PTR [SI], 'O'
					MOV BH, 1
					MOV BL, '1'
					JMP END_ELSES
			
				ELSE_IF4C:		;else if(matrix[1][0] == matrix[0][0] && matrix[2][0] != 'O')
						
					MOV BYTE PTR BL, [SI]		; SI = matrix[0][0]
					CMP BYTE PTR [SI + 3], BL	; SI + 3 = matrix[1][0]
					JNE ELSE_IF4D
			
					CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
					JE ELSE_IF4D

					MOV BYTE PTR [SI + 6], 'O'
					MOV BH, 1
					MOV BL, '7'
					JMP END_ELSES
			
				ELSE_IF4D:		;else if(matrix[1][0] == matrix[1][2] && matrix[1][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 5]	; SI + 5 = matrix[1][2]
					CMP BYTE PTR [SI + 3], BL	; SI + 3 = matrix[1][0]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE END_ELSES

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
			ELSE_IF6:	;if ax == 6

			CMP AL, '6'
			JA ELSE_IF7

				;if6a			;if(matrix[1][2] ==	matrix[1][1] && matrix[1][0] != 'O')
									
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 5], BL	; SI + 5 = matrix[1][2]
					JNE ELSE_IF6B
			
					CMP BYTE PTR [SI + 3], 'O'	; SI + 3 = matrix[1][0]
					JE ELSE_IF6B

					MOV BYTE PTR [SI + 3], 'O'
					MOV BH, 1
					MOV BL, '4'
					JMP END_ELSES
			
				ELSE_IF6B:		;else if(matrix[1][2] == matrix[0][2] && matrix[2][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
					CMP BYTE PTR [SI + 5], BL	; SI + 5 = matrix[1][2]
					JNE ELSE_IF6C
			
					CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
					JE ELSE_IF6C

					MOV BYTE PTR [SI + 8], 'O'
					MOV BH, 1
					MOV BL, '9'
					JMP END_ELSES
			
				ELSE_IF6C:		;else if(matrix[1][2] == matrix[2][2] && matrix[0][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI + 5], BL	; SI + 5 = matrix[1][2]
					JNE ELSE_IF6D
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE ELSE_IF6D

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
				ELSE_IF6D:		;else if(matrix[1][2] == matrix[2][2] && matrix[0][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI + 5], BL	; SI + 5 = matrix[1][2]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE END_ELSES

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
			ELSE_IF7:	;if ax == 7

			CMP AL, '7'
			JA ELSE_IF8
				;if7a			;if(matrix[2][0] ==	matrix[2][1] && matrix[2][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 7]	; SI + 7 = matrix[2][1]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE ELSE_IF7B
			
					CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
					JE ELSE_IF7B

					MOV BYTE PTR [SI + 8], 'O'
					MOV BH, 1
					MOV BL, '9'
					JMP END_ELSES
			
				ELSE_IF7B:		;else if(matrix[2][0] == matrix[1][0] && matrix[0][0] != 'O')
									
					MOV BYTE PTR BL, [SI + 3]	; SI + 3 = matrix[1][0]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE ELSE_IF7C
			
					CMP BYTE PTR [SI], 'O'		; SI = matrix[0][0]
					JE ELSE_IF7C

					MOV BYTE PTR [SI], 'O'
					MOV BH, 1
					MOV BL, '1'
					JMP END_ELSES
			
				ELSE_IF7C:		;else if(matrix[2][0] == matrix[1][1] && matrix[0][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE ELSE_IF7D
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE ELSE_IF7D

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
				ELSE_IF7D:		;else if(matrix[2][0] == matrix[0][0] && matrix[1][0] != 'O')
									
					MOV BYTE PTR BL, [SI]		; SI = matrix[0][0]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE ELSE_IF7E
			
					CMP BYTE PTR [SI + 3], 'O'	; SI + 3 = matrix[1][0]
					JE ELSE_IF7E

					MOV BYTE PTR [SI + 3], 'O'
					MOV BH, 1
					MOV BL, '4'
					JMP END_ELSES
			
				ELSE_IF7E:		;else if(matrix[2][0] == matrix[0][2] && matrix[1][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE ELSE_IF7B
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 8 = matrix[1][1]
					JE ELSE_IF7B

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
				ELSE_IF7F:		;else if(matrix[2][0] == matrix[2][2] && matrix[2][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI + 6], BL	; SI + 6 = matrix[2][0]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 7], 'O'	; SI + 7 = matrix[2][1]
					JE END_ELSES

					MOV BYTE PTR [SI + 7], 'O'
					MOV BH, 1
					MOV BL, '8'
					JMP END_ELSES
			
			ELSE_IF8:	;if ax == 8

			CMP AL, '8'
			JA ELSE_IF9

				;if8a			;if(matrix[2][1] == matrix[2][0] && matrix[2][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 6]	; SI + 6 = matrix[2][0]
					CMP BYTE PTR [SI + 7], BL	; SI + 7 = matrix[2][1]
					JNE ELSE_IF8B
			
					CMP BYTE PTR [SI + 8], 'O'	; SI + 8 = matrix[2][2]
					JE ELSE_IF8B

					MOV BYTE PTR [SI + 8], 'O'
					MOV BH, 1
					MOV BL, '9'
					JMP END_ELSES
			
				ELSE_IF8B:		;else if(matrix[2][1] == matrix[2][2] && matrix[2][0] != 'O')
									
					MOV BYTE PTR BL, [SI + 8]	; SI + 8 = matrix[2][2]
					CMP BYTE PTR [SI + 7], BL	; SI + 7 = matrix[2][1]
					JNE ELSE_IF8C
			
					CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
					JE ELSE_IF8C

					MOV BYTE PTR [SI + 6], 'O'
					MOV BH, 1
					MOV BL, '7'
					JMP END_ELSES
			
				ELSE_IF8C:		;else if(matrix[2][1] == matrix[1][1] && matrix[0][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 7], BL	; SI + 7 = matrix[2][1]
					JNE ELSE_IF8D
			
					CMP BYTE PTR [SI + 1], 'O'	; SI + 1 = matrix[0][1]
					JE ELSE_IF8D

					MOV BYTE PTR [SI + 1], 'O'
					MOV BH, 1
					MOV BL, '2'
					JMP END_ELSES
			
				ELSE_IF8D:		;else if(matrix[2][1] == matrix[0][1] && matrix[1][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 1]	; SI + 1 = matrix[0][1]
					CMP BYTE PTR [SI + 7], BL	; SI + 7 = matrix[2][1]
					JNE END_ELSES
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE END_ELSES

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					JMP END_ELSES
			
			ELSE_IF9:	;if ax == 9

			CMP AL, 9
			JNE END_ELSES

				;if9a			;if(matrix[2][2] == matrix[2][1] && matrix[2][0] != 'O')
									
					MOV BYTE PTR BL, [SI + 7]	; SI + 7 = matrix[2][1]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9B
			
					CMP BYTE PTR [SI + 6], 'O'	; SI + 6 = matrix[2][0]
					JE ELSE_IF9B

					MOV BYTE PTR [SI + 6], 'O'
					MOV BH, 1
					MOV BL, '7'
					JMP END_ELSES
			
				ELSE_IF9B:		;else if(matrix[2][2] == matrix[1][2] && matrix[0][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 5]	; SI + 5 = matrix[1][2]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9C
			
					CMP BYTE PTR [SI + 2], 'O'	; SI + 2 = matrix[0][2]
					JE ELSE_IF9C

					MOV BYTE PTR [SI + 2], 'O'
					MOV BH, 1
					MOV BL, '3'
					JMP END_ELSES
			
				ELSE_IF9C:		;else if(matrix[2][2] == matrix[1][1] && matrix[0][0] != 'O')
									
					MOV BYTE PTR BL, [SI + 4]	; SI + 4 = matrix[1][1]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9D
			
					CMP BYTE PTR [SI], 'O'		; SI = matrix[0][0]
					JE ELSE_IF9D

					MOV BYTE PTR [SI], 'O'
					MOV BH, 1
					MOV BL, '1'
					JMP END_ELSES
			
				ELSE_IF9D:		;else if(matrix[2][2] == matrix[2][0] && matrix[2][1] != 'O')
									
					MOV BYTE PTR BL, [SI + 6]	; SI + 6 = matrix[2][0]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9E
			
					CMP BYTE PTR [SI + 7], 'O'	; SI + 7 = matrix[2][1]
					JE ELSE_IF9E

					MOV BYTE PTR [SI + 7], 'O'
					MOV BH, 1
					MOV BL, '8'
					JMP END_ELSES
			
				ELSE_IF9E:		;else if(matrix[0][2] == matrix[2][2] && matrix[1][2] != 'O')
									
					MOV BYTE PTR BL, [SI + 2]	; SI + 2 = matrix[0][2]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9F
			
					CMP BYTE PTR [SI + 5], 'O'	; SI + 5 = matrix[1][2]
					JE ELSE_IF9F

					MOV BYTE PTR [SI + 5], 'O'
					MOV BH, 1
					MOV BL, '6'
					JMP END_ELSES
			
				ELSE_IF9F:		;else if(matrix[2][2] == matrix[0][0] && matrix[1][1] != 'O')
									
					MOV BYTE PTR BL, [SI]		; SI = matrix[0][0]
					CMP BYTE PTR [SI + 8], BL	; SI + 8 = matrix[2][2]
					JNE ELSE_IF9B
			
					CMP BYTE PTR [SI + 4], 'O'	; SI + 4 = matrix[1][1]
					JE ELSE_IF9B

					MOV BYTE PTR [SI + 4], 'O'
					MOV BH, 1
					MOV BL, '5'
					
		END_ELSES:
		
		MOV AX, BX

		POP BX
		POP SI
		POP BP
		RET 4
SYSTEM_THINKING ENDP
SYSTEM_CLS PROC
        PUSH AX
        PUSH CX
        PUSH DI

        XOR DI, DI
        MOV AX, 0720H
        MOV CX, 2000
        REP STOSW

        POP DI
        POP CX
        POP AX
        RET
SYSTEM_CLS ENDP
END MAIN


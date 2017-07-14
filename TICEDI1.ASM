.MODEL SMALL
.STACK 100H
.DATA
        VAR3 DB 0
        VAR2 DB 0
        VAR DW 0
        ARR DB 1,2,3,4,5,6,7,8,9
        DRAW DB "GAME DRAW!!!$"
        TITLE1 DB "...TIC TAC TOE...$"
        TITLE2 DB "Player1  = X    PLAYER2  = O$"
        BORDER DB "-----------$"
        LINE DB "--------------$"
        MSG1 DB "PLAYER 1! Plesase Enter A Number$"
        MSG2 DB "PLAYER 2! Plesase Enter A Number$"
        MSG3 DB "CONGRATULATIONS !!! Player 1 wins the game... :)$"
        MSG4 DB "CONGRATULATIONS !!! Player 2 wins the game... :)$"
        MSG5 DB "Invalid Input.. Please enter again$"

		FILENAME DB "TTRECORD.txt",0
		HANDLE1 DW ?

		ERROR1 DB "ERROR$"

.CODE
 MAIN PROC

        MOV AX,@DATA
        MOV DS,AX

        MOV AX,0B800h
        MOV ES,AX

		LEA AX, FILENAME
		PUSH AX
		LEA AX, HANDLE1
		PUSH AX

		CALL FILING_ONE
		
        CALL DISPLAY      ;prints the board

        CALL INPUT        ;takes input from players

MOV AH,4CH
INT 21H
MAIN ENDP

FILING_ONE PROC
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

	JC EROR

	MOV BX, [BP + 4]
	MOV [BX], AX
	JMP END_EROR

	EROR:

		MOV AH, 9
		LEA DX, ERROR1
		INT 21H

	END_EROR:

	POP BX
	POP DX
	POP AX
	POP BP
	RET 4

FILING_ONE ENDP

DISPLAY PROC

       PUSH BX
       PUSH SI
       PUSH AX
       PUSH CX
       PUSH DI

       CALL CLEARSCREEN
       LEA SI,TITLE1
       MOV DI,380
       MOV AH,02H
WHILE0:                                         ;displays tictactoe
       LODSB
       CMP AL,"$"
       JE END_WHILE0

       STOSW
       JMP WHILE0
END_WHILE0:

       LEA SI,TITLE2
       ADD DI,116
       MOV AH,06H
WHILE1:                                         ;displays PLAYERS
       LODSB
       CMP AL,"$"
       JE END_WHILE1

       STOSW
       JMP WHILE1
END_WHILE1:

       ADD DI,120
       LEA SI,BORDER
       MOV AH,05H                           ;display border
WHILE2:
       LODSB 
       CMP AL,"$"
       JE END_WHILE2
       STOSW
       JMP WHILE2
END_WHILE2:

       MOV BL,0
       LEA SI,ARR
       ADD DI,136
       MOV CX,9
FOR1:
       CMP BL,3
       JE NEWLINE

       MOV AL,"|"
       MOV AH,05H
       STOSW                       ;display array
       ADD DI,2


       LODSB
       ADD AL,48
       MOV AH,09h
       STOSW
       ADD DI,2
       INC BL

       LOOP FOR1
       JMP END_FOR1

NEWLINE:

       MOV AL,"|"
       MOV AH,05h
       STOSW
       ADD DI,2

        ADD DI,132
        MOV BL,0
        JMP FOR1
END_FOR1:

       MOV AL,"|"
       MOV AH,05h
       STOSW


       ADD DI,136
       LEA SI,BORDER
       MOV AH,05h
WHILE3:                                     ;bottom border
       LODSB 
       CMP AL,"$"
       JE END_WHILE3
       STOSW
       JMP WHILE3

END_WHILE3:

        POP DI
        POP CX
        POP AX
        POP SI
        POP BX
        RET
DISPLAY ENDP


CLEARSCREEN PROC       ;this functions clear the screen
        PUSH DI
        PUSH AX
        PUSH CX
        CLD
        XOR DI,DI
        MOV AX,0720h       ;space and background clr
        MOV CX,2000
        
        REP STOSW

        POP CX
        POP AX
        POP DI
        RET
CLEARSCREEN ENDP
     
        
INPUT PROC           ;this function takes input from user and check invlid
                       ;  input or not
        PUSH DI
        PUSH AX
        PUSH CX
     
        MOV CL,0
FOR1:
        CMP CL,9
        JE END_FOR1

        MOV AL,CL
        XOR AH,AH                  ;change player
        MOV DL,2
        DIV DL
CHECK1:
        CMP AH,0
        JNE PLAYER2
      

PLAYER1:
        LEA DI,ARR
        MOV VAR,0

        PUSH SI
        PUSH DI                   ;display msg1 for player1's input
        PUSH AX
        LEA SI,MSG1
        MOV DI,1450
        MOV AH,06H
FOR9:
        LODSB
        CMP AL,"$"
        JE END_FOR9
        STOSW
        JMP FOR9
END_FOR9:
        POP AX

        POP DI
        POP SI

        MOV AH,1                          ;taking input here
        INT 21H

        MOV CH,AL
        SUB CH,48

        MOV VAR2,0
       
FOR2:
      CMP VAR2,9            ;if invalid than move at invalid
      JE INVALID1

      CMP [DI],CH
      JE END_FOR2

      INC DI
      INC VAR
      INC VAR2


      JMP FOR2

INVALID1:

        PUSH SI
        PUSH DI
        PUSH AX
        
        LEA SI,MSG5              ;displays msg5 player's invalid input
        MOV DI,1610
        MOV AH,06H
FOR6:
        LODSB
        CMP AL,"$"
        JE END_FOR6
        STOSW
        JMP FOR6
END_FOR6:
        POP AX
        POP DI
        POP SI
        
        JMP  PLAYER1  
END_FOR2:
     

      MOV CH,"X"
      SUB CH,48

      LEA DI,ARR

      ADD DI,VAR
      MOV [DI],CH

      JMP PRINT

PLAYER2:

      LEA DI,ARR
      MOV VAR,0

        PUSH AX
        PUSH SI                ;player2's input
        PUSH DI
        
        LEA SI,MSG2
        MOV DI,1450
        MOV AH,06H
FOR8:
        LODSB
        CMP AL,"$"
        JE END_FOR8
        STOSW
        JMP FOR8
END_FOR8:
        POP DI
        POP SI
        POP AX


      MOV AH,1
      INT 21H
      MOV CH,AL
      SUB CH,48
  
      MOV VAR2,0
FOR3:
      CMP VAR2,9
      JE INVALID2                      ;checks invalid

      CMP [DI],CH
      JE END_FOR3
      INC DI
      INC VAR
      INC VAR2
      JMP FOR3


INVALID2:

        PUSH AX
        PUSH SI
        PUSH DI
        
        LEA SI,MSG5
        MOV DI,1610
        MOV AH,06H
FOR7:
        LODSB
        CMP AL,"$"
        JE END_FOR7
        STOSW
        JMP FOR7
END_FOR7:
        POP DI
        POP SI
        POP AX

        JMP PLAYER2

END_FOR3:
      
      MOV CH,"O"
      SUB CH,48
      LEA DI,ARR
      ADD DI,VAR
      MOV [DI],CH
      MOV VAR,0
PRINT:
      INC CL
      CALL CHECKWIN
      CALL DISPLAY
      JMP FOR1
END_FOR1:        
      POP CX
      POP AX
      POP DI
      RET
INPUT ENDP


CHECKWIN PROC               ;this function checks the winner and display msg
        PUSH BX
        PUSH AX

        INC VAR3
        LEA BX,ARR

CHECK1:
        MOV AL,[BX]
        INC BX
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK2
        INC BX
        MOV AL,[BX]
        
        CMP AL,AH
        JE WINNER

CHECK2:
        LEA BX,ARR

        ADD BX,3
        MOV AL,[BX]

        INC BX
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK3
        INC BX
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER


CHECK3:
        LEA BX,ARR
        ADD BX,6
        MOV AL,[BX]

        INC BX
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK4
        INC BX
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER
CHECK4:
        LEA BX,ARR
        MOV AL,[BX]
        ADD BX,3
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK5

        
        ADD BX,3
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER

CHECK5:
        LEA BX,ARR
        INC BX
        MOV AL,[BX]
        ADD BX,3
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK6

        ADD BX,3
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER

CHECK6:
        LEA BX,ARR
        ADD BX,2
        MOV AL,[BX]
        ADD BX,3
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK7

        ADD BX,3
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER


CHECK7:
        LEA BX,ARR
        MOV AL,[BX]
        ADD BX,4
        MOV AH,[BX]
        CMP AL,AH
        JNE CHECK8

        ADD BX,4
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER

CHECK8:

        LEA BX,ARR
        ADD BX,2
        MOV AL,[BX]
        ADD BX,2
        MOV AH,[BX]
        CMP AL,AH
        JNE END_

        ADD BX,2
        MOV AL,[BX]
        CMP AL,AH
        JE WINNER 
        JMP END_

WINNER:
        CALL DISPLAY                 ;winners msg
               
        MOV AH,2
        MOV DL,10
        INT 21H

        MOV DL,[BX]
        ADD DL,48
        
        CMP DL,"X"
        JE P1WINS

        PUSH SI
        PUSH DI
        PUSH AX
        
        LEA AX,MSG4                  ;if winner is player2
		PUSH AX
		MOV AX, HANDLE1
		PUSH AX

		CALL FILING_TWO

		LEA SI, MSG4
        MOV DI,1800
        MOV AH,02h
FOR12:
        LODSB
        CMP AL,"$"
        JE END_FOR12
        STOSW
        JMP FOR12
END_FOR12:
        POP AX
        POP DI
        POP SI

        JMP END1

P1WINS: 

        PUSH SI                   ;if winner is player 1
        PUSH DI
        PUSH AX
        
		LEA AX, MSG3
		PUSH AX
		MOV AX, HANDLE1
		PUSH AX

		CALL FILING_TWO
		
        LEA SI,MSG3
        MOV DI,1800
        MOV AH,02H
FOR11:
        LODSB
        CMP AL,"$"
        JE END_FOR11
        STOSW
        JMP FOR11
END_FOR11:
        POP AX
        POP DI
        POP SI

END1:
MOV AH,4CH
INT 21H       

DRAW1:
        CALL DISPLAY
        
        PUSH SI
        PUSH DI                ;for draw game
        PUSH AX

		LEA AX, DRAW
		PUSH AX
		MOV AX, HANDLE1
		PUSH AX

		CALL FILING_TWO

        LEA SI,DRAW
        MOV DI,1800
        MOV AH,02h
FOR10:
        LODSB
        CMP AL,"$"
        JE END_FOR10
        STOSW
        JMP FOR10
END_FOR10:
        POP DI
        POP SI
        POP AX
      

  MOV AH,4CH
  INT 21H


END_:

        CMP VAR3,9
        JE DRAW1

        POP AX
        POP BX
        RET
CHECKWIN ENDP

FILING_TWO PROC
; this function takes Handle of file
; OFFSET OF BUFFER

	PUSH BP
	MOV BP, SP
	
	PUSH BX
	PUSH AX
	PUSH CX

	MOV AL, 2
	MOV AH, 42H
	MOV BX, [BP + 4]
	XOR CX, CX
    XOR DX, DX
	INT 21H
	
	MOV AH, 40H
	MOV BX, [BP + 4]
	MOV DX, [BP + 6]
	MOV CX, 48
	INT 21H

	MOV AH, 3EH
	INT 21H

	POP CX
	POP AX
	POP BX

	POP BP
	RET 4
FILING_TWO ENDP

END MAIN



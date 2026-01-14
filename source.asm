INCLUDE Irvine32.inc

EXTERN  PlaySoundA@12 : PROC
INCLUDELIB winmm.lib 

.data
SND_FILENAME EQU 20000h
start Byte "start.wav",0
beep Byte "beep.wav",0
engine Byte "engine.wav",0
crash Byte "crash.wav",0

time Byte 40
initialTime Byte 40 

prompt2 BYTE "Time Left = ",0
timerCounter DD 350000000
tO DD 350000000

Rows = 20
Cols = 20
carDam Byte ?
buildDamage Byte ?
dirNPC BYTE 0, 1, 1, 0, -1, 0, 0, -1

booljup BYTE 0
booljup2 BYTE 0
boardX BYTE 35, 39, 43, 47, 51,55, 59, 63, 67, 71, 75, 79, 83, 87, 91, 95, 99, 103, 107, 111   ;Storing board corrdinates
boardY BYTE 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44      ;to access using index of board
carColor DD ?
pCar BYTE 0, 0
score DD 0
scorePos BYTE 11,6
prompt Byte "Score = ",0
NPC Byte ? , ? , ? , ? , ? , ?

xPosWall BYTE 33, 33, 113, 113
yPosWall BYTE 5, 46, 5, 46
xWall BYTE 81 DUP(219), 0
Board db Rows * Cols dup(0)   ;0 = empty 1 = pCar 2 = NPC 3 = obstacle 4 = passenger 5 = dropoff 6 = box
npcSpeed DD 100000000
npcSpeedO DD 100000000
numObstacles = 80

boxX Byte ?
boxY Byte ?
temp byte ?

obstX BYTE numObstacles DUP(? )
obstY BYTE numObstacles DUP(? )
passengers Byte ?,?,?,?,?,?
passNo Byte ?
drop Byte ?,?
boolPicked Byte 0
carSpeedO DD ?
carSpeed DD ?
Namme Byte 20 Dup(?)
npcColors DD 241,242,245

leaderNames BYTE 200 DUP(0)
leaderScores DWORD 10 DUP(0)
CurrentModeStr DWORD ? 

gameMode BYTE 1 
CareerGoal DWORD 200

;============================ ALL PRINTING STRING BELOW THIS POINT

MenuTitle BYTE "====== RUSH HOUR: SELECT MODE ======",0
MenuOpt1 BYTE "1. CAREER (Goal: 200 Pts)",0
MenuOpt2 BYTE "2. TIME MODE (40s Limit)",0
MenuOpt3 BYTE "3. ENDLESS (Survival)",0
MenuOpt4 BYTE "4. Instructions",0
MenuOpt5 BYTE "5. Leaderboard",0
ChoicePrompt BYTE "Select Option (1-5): ",0

MenuOpt7 BYTE "1.Yellow Taxi",0
MenuOpt8 BYTE "2.Red Taxi",0
MenuOpt9 BYTE "3.Random",0
ChoicePrompt2 BYTE "Select Option (1 or 2): ",0
MenuOptDiff BYTE "Choose Difficulty(1-10) (10=Easy, 1=Hard)",0
MenuOpt10 BYTE "Enter Your Name:",0
diff Byte ?
endg byte 0
clearStr Byte "        ",0
name1 BYTE "n1.txt",0
name2 BYTE "n2.txt",0
name3 BYTE "n3.txt",0
name4 BYTE "n4.txt",0
name5 BYTE "n5.txt",0
name6 BYTE "n6.txt",0
name7 BYTE "n7.txt",0
name8 BYTE "n8.txt",0
name9 BYTE "n9.txt",0
name10 BYTE "n10.txt",0

score1 BYTE "s1.txt",0
score2 BYTE "s2.txt",0
score3 BYTE "s3.txt",0
score4 BYTE "s4.txt",0
score5 BYTE "s5.txt",0
score6 BYTE "s6.txt",0
score7 BYTE "s7.txt",0
score8 BYTE "s8.txt",0
score9 BYTE "s9.txt",0
score10 BYTE "s10.txt",0

nameFiles DWORD OFFSET name1,OFFSET name2,OFFSET name3,OFFSET name4,OFFSET name5,OFFSET name6,OFFSET name7,OFFSET name8,OFFSET name9,OFFSET name10
scoreFiles DWORD OFFSET score1,OFFSET score2,OFFSET score3,OFFSET score4,OFFSET score5,OFFSET score6,OFFSET score7,OFFSET score8,OFFSET score9,OFFSET score10

MenuBorder BYTE "==============================================",0
MenuTaxi1 BYTE "        _____",0
MenuTaxi2 BYTE "   ____/|_||_\.__",0
MenuTaxi3 BYTE "  /o_  \____    _0",0
MenuTaxi4 BYTE " =-(0)--------(0)-=",0

titlee BYTE "============== LEADERBOARD ==============",0
colH BYTE "Rank   Score        Name",0
gameOverTitle BYTE "============== GAME OVER ===============",0
gameWinTitle  BYTE "============== YOU WIN! ===============",0
yourScoreMsg BYTE "Your Score: ",0
pressKeyMsg BYTE "Press any key to return to menu...",0
emptyName BYTE "----------",0
ModeStrCareer BYTE "MODE: CAREER (Goal: 200)",0
ModeStrTime   BYTE "MODE: TIME ATTACK       ",0
ModeStrEndless BYTE "MODE: ENDLESS SURVIVAL  ",0

InstrTitle BYTE "====== INSTRUCTIONS ======",0
Instr1 BYTE "1. ARROWS to move.",0
Instr2 BYTE "2. Pick up passengers (O) with SPACE.",0
Instr3 BYTE "3. Drop at Green Spot with SPACE.",0
Instr4 BYTE "4. Avoid obstacles and other cars.",0
Instr5 BYTE "MODES:",0
Instr6 BYTE "- Career: Reach 200 Points to Win.",0
Instr7 BYTE "- Time: Fixed time limit.",0
Instr8 BYTE "- Endless: Each drop adds +10 seconds.",0

.code
;============================

main PROC
    call LoadLeaderboard        ;LOADS LEADERBOARD INTO ARRAY WHEN GAME STARTS

menuLoop:
    call ShowMainMenu
    call readChar

    cmp al, '1'
    je SetCareer
    cmp al, '2'
    je SetTime
    cmp al, '3'
    je SetEndless
    cmp al, '4'
    je ShowInstr
    cmp al, '5'
    je showlb
    jmp MenuLoop

ShowInstr:
    call ClearBlackScreen     ;CLEARING SCRREN BEFORE MOVING TO NEXT SCREEN
    call ShowInstructions
    jmp MenuLoop

showlb:
    call ClearBlackScreen
    call ShowLeaderboard
    call ReadChar
    jmp MenuLoop
                                    ;GAME  MODE LOGIC HERE
SetCareer:
    mov gameMode, 1
    mov CurrentModeStr, OFFSET ModeStrCareer
    jmp GameSetup
SetTime:
    mov gameMode, 2
    mov CurrentModeStr, OFFSET ModeStrTime
    jmp GameSetup
SetEndless:
    mov gameMode, 3
    mov CurrentModeStr, OFFSET ModeStrEndless
    jmp GameSetup

GameSetup:
    mov score, 0
    mov endg, 0
    
    cmp gameMode, 1
    je SetCareerTime
    mov al, 40
    jmp SaveTime
SetCareerTime:
    mov al, 100
SaveTime:
    mov time, al
    mov initialTime, al

    call ClearBlackScreen
    mov dh, 13
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET MenuOpt7
    call WriteString
    mov dh, 14
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET MenuOpt8
    call WriteString
    mov dh, 15
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET MenuOpt9
    call WriteString
    mov dh, 16
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET ChoicePrompt2
    call WriteString
    call readChar
    cmp al, '1'
    je yelloww
    cmp al, '2'
    je redd
    cmp al,'3'
    jne redd
    mov eax,2
    call RandomRange
    cmp al,1
    je yelloww
    jmp redd
yelloww:                                ;TAXI TYPE LOGIC HERE
    mov carSpeedO,130000000
    mov carSpeed,130000000
    mov carColor,246 
    mov carDam,2
    mov buildDamage,4
    jmp difficulty
redd:
    mov carSpeedO,250000000
    mov carSpeed,250000000
    mov carColor,244
    mov carDam,3
    mov buildDamage,2

difficulty:                 ;SETTING GAME DIFFICULTY HERE BY ADJUSTING NPC SPEED
    call ClearBlackScreen
    mov dh, 12
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET MenuOptDiff
    call WriteString
    call ReadInt
    mov diff,al
    movzx eax,diff
    mov ebx,npcSpeedO
    mul ebx
    mov npcSpeedO,eax
    mov npcSpeed,eax
    
    mov dh, 13
    mov dl, 28
    call Gotoxy
    mov edx, OFFSET MenuOpt10
    call WriteString
    mov edx, offset Namme
    mov ecx,20
    call ReadString

    call ClearBlackScreen

    call ClearWhiteScreen
    mov eax, black + (white * 16)
    call SetTextColor
    
    mov dl, 2
    mov dh, 3
    call Gotoxy
    mov edx, CurrentModeStr
    call WriteString

    mov dl,2
    mov dh,6
    call Gotoxy
    mov edx, OFFSET prompt
    call WriteString
    mov dl,2
    mov dh,5
    call Gotoxy
    mov edx, OFFSET Namme
    call WriteString
    mov dl,11
    mov dh,6
    call Gotoxy
    mov eax, score
    call WriteDec
    call Randomize
    mov Board[0], 1
    mov dl,2
    mov dh,12
    call Gotoxy
    mov edx, OFFSET prompt2
    call WriteString
    call TimerDraw
    
    call initializePass
    call initializeNPC
    call initializeObs
    call DrawCar
    call DrawWall
    call drawObstacle
    call drawNPC
    call drawPass
    call boxInitialize
    call drawBox
    push    SND_FILENAME
    push    0
    push    OFFSET start
    call    PlaySoundA@12
    mov eax,2000
    call Delay
    call lop
    call GameEndScreen
    jmp menuLoop
main ENDP

;============================

lop PROC    ;GAME LOOPS KEEPS GOING ON
l1 :
    dec carSpeed                        ;WORKS ON MOD LOGIC TO MOVE NPC AFTER A INTERVAL
    dec npcSpeed
    dec timerCounter
    cmp carSpeed,0
    jne npcc
    call MoveCar
    mov eax,carSpeedO
    mov carSpeed,eax
npcc:
    cmp npcSpeed,0
    jne timerr
    call MoveNPC
    call DrawNPC
    mov eax,npcSpeedO
    mov npcSpeed,eax
    cmp endg,1
    je genddd
    cmp endg,2
    je genddd
timerr:
    cmp timerCounter,0
    jne done
    mov eax,tO
    mov timerCounter,eax
    dec time
    call TimerDraw
    cmp time,0
    je TimeIsZero
done:
    jmp l1
TimeIsZero:
    mov endg, 1
    jmp genddd
genddd:
    ret
lop ENDP

;============================

boxInitialize Proc     ;RANDOM INITIALIZE BONUS BOX
    pushA
again2222:
    call Ran
    mov bl, al
    call Ran
    mov bh, al
    mov esi, 20
    mul esi
    add al, bl
    mov dl, bl
    mov dh, bh
    movzx ebx, ax
    cmp board[ebx], 0
    jne again2222
    mov boxX[0],dl
    mov boxY[0],dh
    mov board[ebx],6
    popA
    ret
boxInitialize endp

;============================

drawBox Proc      
    pusha
    mov eax, 246    
    call SetTextColor
    movzx ebx, boxX[0]
    mov dl, boardX[ebx]
    movzx ebx, boxY[0]
    mov dh, boardY[ebx]
    inc dh
    call Gotoxy
    mov al, 219
    call WriteChar
    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    mov eax, black + (white * 16)
    call SetTextColor
    popA
    ret
drawBox endp

;============================

TimerDraw proc
    mov dl,13
    mov dh,12
    call Gotoxy
    mov edx, OFFSET clearStr
    call WriteString
    mov dl,13
    mov dh,12
    call Gotoxy
    movzx eax, Time
    call WriteDec
    ret
TimerDraw endp

;============================

passBack Proc     
    pushA
againn22:
    call Ran
    mov cl, al
    call Ran
    mov ch, al
    mov esi, 20
    mul esi
    add al, cl
    mov dl, cl
    mov dh, ch
    movzx ebx, ax
    cmp board[ebx], 0
    jne againn22
    mov board[ebx],4
    movzx ebx,passNo     ;REINITIALIZES RANDOMLY THE DROPPED PASSENDGER
    mov passengers[ebx*2],cl
    mov passengers[ebx*2+1],ch
    call drawPass
    mov eax,score
    add eax,10
    mov score,eax
    mov dl,11
    mov dh,6
    call Gotoxy
    mov eax, score
    call WriteDec
    popA
    ret
passBack endp

;============================

dropPass proc       ;
    pushA
    mov edi,3
dir2: 
    pushA
    mov dl, dirNPC[edi * 2]
    mov dh, dirNPC[edi * 2 + 1]
    mov al,bl
    mov ah,bh
    add al,dl
    add ah,dh
    cmp al,drop[0]
    jne noteq2
    cmp ah,drop[1]
    jne noteq2
    mov boolPicked,0
    jmp dropped
noteq2:
    popA
    dec edi
    cmp edi,0
    jge dir2
    cmp boolPicked,0
    jne endpick2
dropped:
    pushA
    push    SND_FILENAME
    push    0
    push    OFFSET beep
    call    PlaySoundA@12
    mov bl,drop[0]
    mov bh,drop[1]
    mov eax,0
    mov al,bh
    mov esi,20
    mul esi
    add al,bl
    movzx ebx,ax
    mov board[ebx],0
    movzx ecx, drop[0]
    mov dl, boardX[ecx]
    movzx ecx, drop[1]
    mov dh, boardY[ecx]
    inc dh
    call Gotoxy
    mov al," "
    call WriteChar
    call passBack
    
    cmp gameMode, 1
    je CareerLogic
    
    cmp gameMode, 3
    je EndlessLogic
    
    mov eax,1000000
    sub npcSpeedO,eax
    sub npcSpeed,eax
    jmp ModeDone
                        ;DIFFERENT LOGICS FOR DIFFERENT GAME MODES
EndlessLogic:
    add time, 10
    call TimerDraw
    mov eax,2000000
    sub npcSpeedO,eax
    sub npcSpeed,eax
    jmp ModeDone

CareerLogic:
    mov eax, score
    cmp eax, CareerGoal
    jge CareerWin
    mov eax, 2000000
    sub npcSpeedO, eax
    mov npcSpeed, eax
    jmp ModeDone

CareerWin:
    mov endg, 2
    jmp ModeDone

ModeDone:
    popA
    popA
endpick2:
    popA
    ret
dropPass endp

;============================
pickBox proc         ;PICKS THE BONUS BOX FOR AND ADDS BONUS SCORE
    pusha
    mov edi,3
directi: 
    pushA
    mov dl, dirNPC[edi * 2]
    mov dh, dirNPC[edi * 2 + 1]
    mov al,bl
    mov ah,bh
    add al,dl
    add ah,dh
    cmp al,boxX
    jne notequa
    cmp ah,boxY
    jne notequa
    
    jmp pickeddd
notequa:
    popA
    dec edi
    cmp edi,0
    jge directi
    jmp endpickkk
pickeddd:
    push    SND_FILENAME
    push    0
    push    OFFSET beep
    call    PlaySoundA@12
    pushA
    mov edi,0
    mov bl,boxX
    mov bh,boxY
    mov al,bh
    mov esi,20
    mul esi
    add al,bl
    movzx ebx,ax
    mov board[ebx],0
    mov eax, black + (white * 16)
    call SetTextColor
    movzx ebx, boxX
    mov dl, boardX[ebx]
    movzx ebx, boxY
    mov dh, boardY[ebx]
    inc dh
    call Gotoxy
    mov al, ' ' 
    call WriteChar
    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    call boxInitialize
    call drawBox
    mov eax,10
    add score,eax
    mov dl,11
    mov dh,6
    call Gotoxy
    mov edx, OFFSET clearStr
    call WriteString
    mov dl,11
    mov dh,6
    call Gotoxy
    mov eax, score
    call WriteDec
    popA
    popA
endpickkk:
    popa
    ret
pickBox endp
;============================

pickPass Proc       ;PICKS PASSENGER
    pushA
    mov ecx,3
pickPassLoop:
    mov edi,3
dir: 
    pushA
    mov dl, dirNPC[edi * 2]
    mov dh, dirNPC[edi * 2 + 1]
    mov al,bl
    mov ah,bh
    add al,dl
    add ah,dh
    cmp al,passengers[ecx*2-2]
    jne noteq
    cmp ah,passengers[ecx*2-1]
    jne noteq
    mov passNo,cl
    dec passNo
    mov boolPicked,1      ;CHANGES THE TAXI TO PASSENGER PICKED SO CANNOT PICK ANY OTHER
    call dropPointInitialize
    call drawDrop
    call erasePass
    jmp picked
noteq:
    popA
    dec edi
    cmp edi,0
    jge dir
    cmp boolPicked,1
    je endpick
    loop pickPassLoop
    jmp endpick
picked:
    push    SND_FILENAME
    push    0
    push    OFFSET beep
    call    PlaySoundA@12
    pushA
    movzx edi,passNo
    mov bl,passengers[edi*2]
    mov bh,passengers[edi*2+1]
    mov al,bh
    mov esi,20
    mul esi
    add al,bl
    movzx ebx,ax
    mov board[ebx],0
    popA
    popA
endpick:
    popA
    ret
pickPass endp

;============================

erasePass proc
    mov bl,al
    mov eax,0
    mov al,ah
    mov esi,20
    mul esi
    add al,bl
    mov board[esi],0
    movzx ebx, passengers[ecx*2-2]
    mov dl, boardX[ebx]
    movzx ebx, passengers[ecx*2-1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    call WriteChar

    mov ebx, ecx
    movzx ebx, passengers[ebx * 2 - 2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, " "
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    inc dl
    call Gotoxy
    mov al, " "
    call WriteChar
    ret
erasePass endp


dropPointInitialize Proc
    pushA
again222:
    call Ran
    mov bl, al
    call Ran
    mov bh, al
    mov esi, 20
    mul esi
    add al, bl
    mov dl, bl
    mov dh, bh
    movzx ebx, ax
    cmp board[ebx], 0
    jne again222
    mov drop[0],dl
    mov drop[1],dh
    mov board[ebx],5
    popA
    ret
dropPointInitialize endp

;============================

drawDrop Proc
    pushA
    mov eax, 242     
    call SetTextColor
    movzx ebx, drop[0]
    mov dl, boardX[ebx]
    movzx ebx, drop[1]
    mov dh, boardY[ebx]
    inc dh
    call Gotoxy
    mov al, 219
    call WriteChar
    mov eax, black + (white * 16)
    call SetTextColor
    popA
    ret
drawDrop endp

;============================

initializePass Proc
     pushA
    mov ecx, 3
loop122:
again22:
    call Ran
    mov bl, al
    call Ran
    mov bh, al
    mov esi, 20
    mul esi
    add al, bl
    mov dl, bl
    mov dh, bh
    movzx ebx, ax
    cmp board[ebx], 0
    jne again22
    mov board[ebx], 4
    mov ebx, ecx
    mov passengers[ebx * 2 - 2], dl
    mov passengers[ebx * 2 - 1], dh
    loop loop122
    popA
    ret
initializePass endp

;============================

drawPass proc

    pushA
    mov eax, 0 + (15 * 16)
    call SetTextColor
    mov ecx, 3
    loop133:
    mov ebx, ecx
    movzx ebx, passengers[ebx * 2 - 2]
    mov dl, boardX[ebx]
    mov ebx, ecx
    movzx ebx, passengers[ebx * 2 - 1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, 'O'
    call WriteChar

    mov ebx, ecx
    movzx ebx, passengers[ebx * 2 - 2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, "-"
    call WriteChar

    mov eax, 246  
    call SetTextColor
    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    mov eax, 0 + (15 * 16)
    call SetTextColor
    inc dl
    call Gotoxy
    mov al, "-"
    call WriteChar
    loop loop133
    popA
    ret

drawPass endp

;============================


MoveNPC PROC      ;MOVES EACH NPC USING PARTICULAR FUNCTIONS
    pushA
    call NPC1
    call NPC2
    call NPC3
    popA
    ret
MoveNPC ENDP

;============================

NPC1 PROC
    mov bl, NPC[0]
    mov bh, NPC[1]
again1:
    mov eax, 4
    call RandomRange
    movzx eax, al
    mov dl, dirNPC[eax * 2]
    mov dh, dirNPC[eax * 2 + 1]
    mov cl, bl
    mov ch, bh
    add cl, dl
    add ch, dh
    cmp cl, 0
    jl again1
    cmp cl, 19
    jg again1
    cmp ch, 0
    jl again1
    cmp ch, 19
    jg again1
    movzx eax, ch
    push edx
    push ebx
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, cl
    movzx edi, ax
    movzx eax, ax
    cmp board[edi], 0
    jne again1
    push edx
    push ebx
    movzx eax, bh
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, bl
    movzx esi, ax
    mov board[esi], 0
    mov board[edi], 2
    movzx ebx, NPC[0]
    mov dl, boardX[ebx]
    movzx ebx, NPC[1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    call WriteChar
    movzx ebx, NPC[0]
    mov dl, boardX[ebx]
    movzx ebx, NPC[1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    movzx ebx, NPC[0]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    movzx ebx, NPC[0]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    pushA
    mov cl, NPC[0]
    mov ch, NPC[1]
    inc ch
    movzx eax, ch
    cmp ch, 20
    je endnpc111
    mov bl, 20
    mul bl
    add al, cl
    movzx esi, ax
    cmp board[esi], 3
    je endnpc1
    cmp board[esi],4
    je endnpc12
    popA
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    jmp end2
endnpc1 :
    popA
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar
    jmp end2
endnpc111 :
    popA
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    jmp end2
endnpc12:
    popA
    call Gotoxy
    mov al, " "
    call WriteChar
    inc dl
    call Gotoxy
    mov al, 'O'
    call WriteChar
    inc dl
    call Gotoxy
    mov al, " "
    call WriteChar
end2 :
    mov NPC[0], cl
    mov NPC[1], ch
    ret
NPC1 ENDP

;============================

NPC2 PROC
    mov bl, NPC[2]
    mov bh, NPC[3]
again2:
    mov eax, 4
    call RandomRange
    movzx eax, al
    mov dl, dirNPC[eax * 2]
    mov dh, dirNPC[eax * 2 + 1]
    mov cl, bl
    mov ch, bh
    add cl, dl
    add ch, dh
    cmp cl, 0
    jl again2
    cmp cl, 19
    jg again2
    cmp ch, 0
    jl again2
    cmp ch, 19
    jg again2
    movzx eax, ch
    push edx
    push ebx
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, cl
    movzx edi, ax
    movzx eax, ax
    cmp board[edi], 0
    jne again2
    push edx
    push ebx
    movzx eax, bh
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, bl
    movzx esi, ax
    mov board[esi], 0
    mov board[edi], 2
    movzx ebx, NPC[2]
    mov dl, boardX[ebx]
    movzx ebx, NPC[3]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    call WriteChar
    movzx ebx, NPC[2]
    mov dl, boardX[ebx]
    movzx ebx, NPC[3]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    movzx ebx, NPC[2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    movzx ebx, NPC[2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    pushA
    mov cl, NPC[2]
    mov ch, NPC[3]
    inc ch
    movzx eax, ch
    cmp ch, 20
    je endnpc222
    mov bl, 20
    mul bl
    add al, cl
    movzx esi, ax
    cmp board[esi], 3
    je endnpc2
    cmp board[esi], 4
    je endnpc22
    popA
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    jmp end3
endnpc2 :
    popA
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar
    jmp end3
endnpc222 :
    popA
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    jmp end3
endnpc22:
    popA
    call Gotoxy
    mov al, " "
    call WriteChar
    inc dl
    call Gotoxy
    mov al, 'O'
    call WriteChar
    inc dl
    call Gotoxy
    mov al, " "
    call WriteChar
end3 :
    mov NPC[2], cl
    mov NPC[3], ch
    ret
NPC2 ENDP

;============================

NPC3 PROC
    mov bl, NPC[4]
    mov bh, NPC[5]
again3:
    mov eax, 4
    call RandomRange
    movzx eax, al
    mov dl, dirNPC[eax * 2]
    mov dh, dirNPC[eax * 2 + 1]
    mov cl, bl
    mov ch, bh
    add cl, dl
    add ch, dh
    cmp cl, 0
    jl again3
    cmp cl, 19
    jg again3
    cmp ch, 0
    jl again3
    cmp ch, 19
    jg again3
    movzx eax, ch
    push edx
    push ebx
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, cl
    movzx edi, ax
    movzx eax, ax
    cmp board[edi], 0
    jne again3
    push edx
    push ebx
    movzx eax, bh
    mov bl, 20
    mul bl
    pop ebx
    pop edx
    add al, bl
    movzx esi, ax
    mov board[esi], 0
    mov board[edi], 2
    movzx ebx, NPC[4]
    mov dl, boardX[ebx]
    movzx ebx, NPC[5]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    call WriteChar
    movzx ebx, NPC[4]
    mov dl, boardX[ebx]
    movzx ebx, NPC[5]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, ' '
    movzx ebx, NPC[4]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    movzx ebx, NPC[4]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    pushA
    mov cl, NPC[4]
    mov ch, NPC[5]
    inc ch
    movzx eax, ch
    cmp ch, 20
    je endnpc333
    mov bl, 20
    mul bl
    add al, cl
    movzx esi, ax
    cmp board[esi], 3
    je endnpc3
    cmp board[esi],4
    je endnpc32
    popA
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    jmp end4
endnpc3 :
    popA
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar
    jmp end4
endnpc333:
    popA
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    jmp end4
endnpc32:
    popA
    call Gotoxy
    mov al, " "
    call WriteChar
    inc dl
    call Gotoxy
    mov al, 'O'
    call WriteChar
    inc dl
    call Gotoxy
    mov al, " "
    call WriteChar
    end4 :
    mov NPC[4], cl
    mov NPC[5], ch
    ret
NPC3 ENDP

;============================

DrawCar PROC

    pushA
    mov eax, carColor
    call SetTextColor

    movzx ebx, pCar[0]
    mov dl, boardX[ebx]
    movzx ebx, pCar[1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, 219 
    call WriteChar

    movzx ebx, pCar[0]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    movzx ebx, pCar[0]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, 'o'
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 'o'
    call WriteChar
    mov eax, 240
    call SetTextColor
    popA
    ret
DrawCar ENDP

;============================

ClearWhiteScreen PROC
    mov dl, 0
    mov dh, 0
    call Gotoxy

    mov eax, 0 + (15 * 16)
    call SetTextColor

    mov ecx, 8000
    mov al, ' '

FillLoop :
    call WriteChar
    loop FillLoop

    mov dl, 0
    mov dh, 0
    call Gotoxy
    
    ret
ClearWhiteScreen ENDP

;============================

ClearBlackScreen PROC
    mov dl, 0
    mov dh, 0
    call Gotoxy
    mov eax, 0          
    call SetTextColor

    mov ecx, 7000     
    mov al, ' '

FillLoop:
    call WriteChar
    loop FillLoop
    
    mov dl, 0
    mov dh, 0
    call Gotoxy
    
    mov eax, 15          
    call SetTextColor
    ret
ClearBlackScreen ENDP

;============================

DrawWall PROC
    pushA
    mov dl, xPosWall[0]
    mov dh, yPosWall[0]
    call Gotoxy
    mov edx, OFFSET xWall
    call WriteString

    mov dl, xPosWall[1]
    mov dh, yPosWall[1]
    call Gotoxy
    mov edx, OFFSET xWall
    call WriteString

    mov dl, xPosWall[2]
    mov dh, yPosWall[2]
    mov eax, 219
    inc yPosWall[3]
L11:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosWall[3]
    jl L11

    mov dl, xPosWall[0]
    mov dh, yPosWall[0]
    mov eax, 219
L12:
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosWall[3]
    jl L12

    mov dl, xPosWall[0]
    mov ecx, 19
    dec yPosWall[3]
    colLop:
    add dl, 4
    mov dh, yPosWall[0]
    inc dh
    mov eax, "|"
L13 :
    call Gotoxy
    call WriteChar
    inc dh
    cmp dh, yPosWall[3]
    jl L13
    loop colLop
    inc yPosWall[3]
    popA
    ret
DrawWall ENDP

 ;============================

Ran Proc
    mov eax, 20
    call RandomRange
    ret
Ran Endp

;============================

initializeNPC Proc
    pushA
    mov ecx, 3
loop1:
again:
    call Ran
    mov bl, al
    call Ran
    mov bh, al
    mov esi, 20
    mul esi
    add al, bl
    mov dl, bl
    mov dh, bh
    movzx ebx, ax
    cmp board[ebx], 0
    jne again
    mov board[ebx], 2
    mov ebx, ecx
    mov NPC[ebx * 2 - 2], dl
    mov NPC[ebx * 2 - 1], dh
    loop loop1
    popA
    ret
initializeNPC Endp

;============================

initializeObs Proc    ;RANDOMLY INITIALIZES ALL 80 OBSTACKES
    pushA
    mov ecx, numObstacles
loop1 :
again:                  ;AGAIN IF THE PLACE IS ALREADY OCCUPIED
    call Ran
    mov bl, al
    call Ran
    mov bh, al
    mov eax,0
    mov al,bh
    mov esi, 20
    mul esi
    add al, bl
    mov dl, bl
    mov dh, bh
    movzx ebx, ax
    cmp board[ebx], 0
    jne again
    mov board[ebx], 3
    mov ebx, ecx
    mov obstX[ebx - 1], dl
    mov obstY[ebx - 1], dh
    loop loop1
    popA
    ret
initializeObs Endp

;============================

drawNPC Proc
    pushA

    mov ecx, 3
    loop1:
    mov eax, npcColors[ecx*4-4]
    call SetTextColor
    mov booljup, 0
    mov ebx, ecx
    movzx ebx, NPC[ebx * 2 - 2]
    mov dl, boardX[ebx]
    mov ebx, ecx
    movzx ebx, NPC[ebx * 2 - 1]
    mov dh, boardY[ebx]
    call Gotoxy
    mov al, 219
    call WriteChar

    mov ebx, ecx
    movzx ebx, NPC[ebx * 2 - 2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
up :
    cmp booljup, 0
    jne loop1
    mov ebx, ecx
    movzx ebx, NPC[ebx * 2 - 2]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    call Gotoxy
    mov al, 'o'
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 'o'
    call WriteChar
    mov booljup, 1
    loop up
    mov eax, black + (white * 16)
    call SetTextColor
    popA
    ret
drawNPC Endp

;============================

drawObstacle PROC
    pushA
    mov eax, 0 + (15 * 16)
    call SetTextColor

    mov ecx, numObstacles
    loop1:
    mov ebx, ecx
    mov al, obstX[ebx - 1]
    movzx ebx, al
    mov dl, boardX[ebx]
    mov ebx, ecx
    mov al, obstY[ebx - 1]
    movzx ebx, al
    mov dh, boardY[ebx]

    dec dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    dec dl
    dec dl
    add dh, 1

    call Gotoxy
    mov al,178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar
    loop loop1
    popA
    ret
drawObstacle ENDP

;============================

MoveCar PROC            ;Reads key and performs appropriate actions
    call ReadKey
    jz no_key        

    mov bl, pCar[0]   
    mov bh, pCar[1]  


    cmp ah, 48h
    jne check_s
    cmp bh, 0
    je no_move
    dec bh
    jmp try_move

check_s:

    cmp ah, 50h
    jne check_a
    cmp bh, 19
    je no_move
    inc bh
    jmp try_move

check_a:

    cmp ah, 04Bh
    jne check_d
    cmp bl, 0
    je mcend
    dec bl
    jmp try_move

check_d:
    cmp ah, 04Dh
    jne check_sp
    cmp bl, 19
    je mcend
    inc bl
    jmp try_move
check_sp:
    cmp al,' '
    jne check_p
    call pickBox
    cmp boolPicked,1
    je dropp
    call pickPass
    jmp mcend
check_p:
    cmp al,'p'
    jne check_e
    call pausee
    jmp mcend
    
check_e:
    cmp al, 'e'
    je manual_finish
    jmp mcend
    
manual_finish:
    mov endg, 1
    jmp mcend

dropp:
    call dropPass
    jmp mcend

try_move:
    movzx eax, bh
    mov esi, 20
    mul esi
    add al, bl
    movzx esi, ax

    cmp board[esi], 0
    jne no_move      

    movzx eax, pCar[1]
    mov esi, 20
    mul esi
    add al, pCar[0]
    movzx esi, ax
    mov board[esi], 0

    call EraseCar

    mov pCar[0], bl
    mov pCar[1], bh
    movzx eax, bh
    mov esi, 20
    mul esi
    add al, bl
    movzx esi, ax
    mov board[esi], 1
    call DrawCar
    push    SND_FILENAME
    push    0
    push    OFFSET engine
    call    PlaySoundA@12
    jmp mcend
no_move:
    cmp board[esi],3
    je obss
    cmp board[esi],2
    je kar
obss:
    movzx eax,buildDamage
    sub score,eax
    movzx eax,carDam
    sub score,eax
    push    SND_FILENAME
    push    0
    push    OFFSET crash
    call    PlaySoundA@12
    jmp no_key
kar:
    movzx eax,carDam
    sub score,eax
    mov eax, score
    call WriteDec
    push    SND_FILENAME
    push    0
    push    OFFSET crash
    call    PlaySoundA@12
    jmp no_key
no_key:
    cmp score,0
    jl finish
    jmp mcend
finish:
    mov score,0
    mov endg, 1
    mov dl,11
    mov dh,6
    call Gotoxy
    mov edx, OFFSET clearStr
    call WriteString
    mov dl,11
    mov dh,6
    call Gotoxy
    mov eax, score
mcend:
    mov dl,11
    mov dh,6
    call Gotoxy
    mov edx, OFFSET clearStr
    call WriteString
    mov dl,11
    mov dh,6
    call Gotoxy
    mov eax, score
    call WriteDec
    ret
MoveCar ENDP

;============================

EraseCar PROC     ;When car moves it erases the car from previous position
    pushA

    movzx ebx, pCar[0]      
    mov dl,  boardX[ebx]    
    movzx ebx, pCar[1]      
    mov dh,  boardY[ebx]    

 
    call Gotoxy
    mov al, ' '            
    call WriteChar

  
    movzx ebx, pCar[0]
    mov dl, boardX[ebx]
    dec dl                  
    inc dh                  
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl                  
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl                 
    call Gotoxy
    mov al, ' '
    call WriteChar

    movzx ebx, pCar[0]
    mov dl, boardX[ebx]
    dec dl
    inc dh
    pushA
    mov cl, pCar[0]
    mov ch, pCar[1]
    inc ch
    movzx eax, ch
    cmp ch, 20
    je endpcar56
    mov bl, 20
    mul bl
    add al, cl
    movzx esi, ax
    cmp board[esi], 3
    je endpcar
    cmp board[esi],4
    je endpcar2
    popA
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar

    inc dl
    call Gotoxy
    mov al, ' '
    call WriteChar
    jmp end5
endpcar :
    popA
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 178
    call WriteChar
    jmp end5
endpcar56 :
    popA
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar

    inc dl
    call Gotoxy
    mov al, 219
    call WriteChar
    jmp end5
endpcar2:
    popA
    call Gotoxy
    mov al, " "
    call WriteChar
    inc dl
    call Gotoxy
    mov al, 'O'
    call WriteChar
    inc dl
    call Gotoxy
    mov al, " "
    call WriteChar
    end5:

    popA
    ret
EraseCar ENDP

;============================

ShowMainMenu PROC    ;Prints main menu options
    pushad
    call ClearBlackScreen

    mov eax, yellow + (blue * 16)
    call SetTextColor

    mov dh,3
    mov dl,10
    call Gotoxy
    mov edx, OFFSET MenuBorder
    call WriteString

    mov dh,4
    mov dl,10
    call Gotoxy
    mov edx, OFFSET MenuTitle
    call WriteString

    mov dh,5
    mov dl,10
    call Gotoxy
    mov edx, OFFSET MenuBorder
    call WriteString

    mov eax, yellow + (black * 16)
    call SetTextColor

    mov dh,7
    mov dl,15
    call Gotoxy
    mov edx, OFFSET MenuTaxi1
    call WriteString

    mov dh,8
    mov dl,15
    call Gotoxy
    mov edx, OFFSET MenuTaxi2
    call WriteString

    mov dh,9
    mov dl,15
    call Gotoxy
    mov edx, OFFSET MenuTaxi3
    call WriteString

    mov dh,10
    mov dl,15
    call Gotoxy
    mov edx, OFFSET MenuTaxi4
    call WriteString

    mov eax, white + (black * 16)
    call SetTextColor

    mov dh,13
    mov dl,20
    call Gotoxy
    mov edx, OFFSET MenuOpt1
    call WriteString

    mov dh,14
    mov dl,20
    call Gotoxy
    mov edx, OFFSET MenuOpt2
    call WriteString

    mov dh,15
    mov dl,20
    call Gotoxy
    mov edx, OFFSET MenuOpt3
    call WriteString
    
    mov dh,16
    mov dl,20
    call Gotoxy
    mov edx, OFFSET MenuOpt4
    call WriteString
    
    mov dh,17
    mov dl,20
    call Gotoxy
    mov edx, OFFSET MenuOpt5
    call WriteString

    mov dh,19
    mov dl,20
    call Gotoxy
    mov edx, OFFSET ChoicePrompt
    call WriteString

    popad
    ret
ShowMainMenu ENDP

;============================
ShowInstructions PROC                   ;Just prints game instructions
    pushad
    call ClearBlackScreen
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET InstrTitle
    call WriteString

    mov dh, 7
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr1
    call WriteString

    mov dh, 8
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr2
    call WriteString

    mov dh, 9
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr3
    call WriteString

    mov dh, 10
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr4
    call WriteString

    mov dh, 12
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr5
    call WriteString

    mov dh, 13
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr6
    call WriteString

    mov dh, 14
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr7
    call WriteString
    
    mov dh, 15
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET Instr8
    call WriteString

    mov dh, 18
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET pressKeyMsg
    call WriteString

    call ReadChar
    popad
    ret
ShowInstructions ENDP

;============================

LoadLeaderboard PROC        ;When games starts it reads from eah file and saves ina array
    pusha
    mov esi,0
LLoop:
    cmp esi,10
    jge DoneLD

    mov eax,OFFSET nameFiles
    mov edx,[eax+esi*4]
    call OpenInputFile
    cmp eax,0
    jl skipName
    mov ebx,eax
    mov eax,esi
    mov edi,20
    mul edi
    mov edx,offset leaderNames
    add edx,eax
    mov ecx,20
    mov eax,ebx
    call ReadFromFile
    mov eax,ebx
    call CloseFile
skipName:
    mov eax,OFFSET scoreFiles
    mov edx,[eax+esi*4]
    call OpenInputFile
    cmp eax,0
    jl skipScore
    mov ebx,eax
    mov eax,esi
    mov edi,4
    mul edi
    mov edx,offset leaderScores
    add edx,eax
    mov ecx,4
    mov eax,ebx
    call ReadFromFile
    mov eax,ebx
    call CloseFile
skipScore:
    inc esi
    jmp LLoop

DoneLD:
    popa
    ret
LoadLeaderboard ENDP

;============================

SaveLeaderboard PROC
    pushad
    mov esi,0
SVLoop:                             ;Save each and every score from both arrays into separate files
    cmp esi,10
    jge DoneSV

    mov eax,OFFSET nameFiles
    mov edx,[eax+esi*4]
    call CreateOutputFile
    mov ebx,eax
    mov eax,esi
    mov edi,20
    mul edi
    mov edx,offset leaderNames
    add edx,eax
    mov ecx,20
    mov eax,ebx
    call WriteToFile
    mov eax,ebx
    call CloseFile

    mov eax,OFFSET scoreFiles
    mov edx,[eax+esi*4]
    call CreateOutputFile
    mov ebx,eax
    mov eax,esi
    mov edi,4
    mul edi
    mov edx,offset leaderScores
    add edx,eax
    mov ecx,4
    mov eax,ebx
    call WriteToFile
    mov eax,ebx
    call CloseFile

    inc esi
    jmp SVLoop

DoneSV:
    popad
    ret
SaveLeaderboard ENDP

;============================

InsertCurrentScore PROC  
    pushad

    mov eax, score
    mov esi, 0

FindPos:                   ; Search top 10 to see if player has score greater
    cmp esi, 10          
    jge DoneInsert
    mov edx, leaderScores[esi*4]
    cmp eax, edx
    jg InsertHere
    inc esi
    jmp FindPos

InsertHere:                
    mov ebp, esi
    mov ecx, 9
    mov edi, offset leaderNames

ShiftLoop:                 ; Loop up to down
    cmp ecx, ebp
    jl DoInsert

    mov eax, ecx
    dec eax
    shl eax, 2
    mov edx, leaderScores[eax]

    mov eax, ecx
    shl eax, 2
    mov leaderScores[eax], edx

    mov eax, ecx
    dec eax
    mov edx, 20
    mul edx
    mov esi, eax

    mov eax, ecx
    mov edx, 20
    mul edx
    mov ebx, eax

    mov edx, 20
CopyLoop1:                 ; Copy names down basically shifting them down
    mov al, [edi+esi]
    mov [edi+ebx], al
    inc esi
    inc ebx
    dec edx
    jnz CopyLoop1

    dec ecx
    jmp ShiftLoop

DoInsert:                  ; insert the new high score into its place
    mov eax, score
    mov ebx, ebp
    shl ebx, 2
    mov leaderScores[ebx], eax

    mov esi, offset Namme
    mov eax, ebp
    mov edx, 20
    mul edx
    mov edi,offset leaderNames
    add edi, eax

    mov edx, 20
CopyLoop2:                 ; insetr the new player's name characters into the array
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec edx
    jnz CopyLoop2

DoneInsert:               
    popad
    ret
InsertCurrentScore ENDP

;============================

ShowLeaderboard PROC    ;Only prints the leaderboard
    pushad
    mov eax, black + (white * 16)
    call SetTextColor

    mov dh,2
    mov dl,15
    call Gotoxy
    mov edx, OFFSET titlee
    call WriteString

    mov dh,4
    mov dl,15
    call Gotoxy
    mov edx, OFFSET colH
    call WriteString

    mov ecx,10            
    mov ebx,0             

LBLoop:
    mov dh,6
    mov al,bl
    add dh,al

    mov dl,15
    call Gotoxy
    mov eax,ebx
    inc eax             
    call WriteDec

    mov dl,21
    call Gotoxy
    mov eax,leaderScores[ebx*4]
    cmp eax,0
    jne HasScoreRow

    mov dl,33
    call Gotoxy
    mov edx,OFFSET emptyName
    call WriteString
    jmp NextRow

HasScoreRow:
    call WriteDec
    mov dl,33
    call Gotoxy
    mov eax,ebx
    mov edx,20
    mul edx             
    mov edx,offset leaderNames
    add edx,eax
    call WriteString

NextRow:
    inc ebx
    loop LBLoop

    popad
    ret
ShowLeaderboard ENDP


;============================

GameEndScreen PROC  ;Called when game ends
    pushad
    call InsertCurrentScore 
    call SaveLeaderboard
    call ClearBlackScreen

    mov eax, yellow + (black * 16)
    call SetTextColor
    
    cmp endg, 2 
    je ShowWinMsg
    
    mov dh,1
    mov dl,18
    call Gotoxy
    mov edx, OFFSET gameOverTitle
    call WriteString
    jmp ShowStats

ShowWinMsg:
    mov dh,1
    mov dl,18
    call Gotoxy
    mov edx, OFFSET gameWinTitle
    call WriteString

ShowStats:
    call ShowLeaderboard

    mov dh,18
    mov dl,15
    call Gotoxy
    mov edx, OFFSET yourScoreMsg
    call WriteString
    mov eax,score
    call WriteDec

    mov dh,20
    mov dl,15
    call Gotoxy
    mov edx, OFFSET pressKeyMsg
    call WriteString

    call ReadChar
    popad
    ret
GameEndScreen ENDP

;============================

pausee proc    ;Function for pausing 
    pusha
    push    SND_FILENAME
    push    0
    push    OFFSET beep
    call    PlaySoundA@12
keeploop:    ;Keeps looping untill p is pressed
    mov eax,0
    call ReadKey
    cmp al, 'p'
    jne keeploop
     push    SND_FILENAME
    push    0
    push    OFFSET beep
    call    PlaySoundA@12
    popa
    ret
pausee endp
END main
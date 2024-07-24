section .data
developer db "Juan Manuel Fernandez Reyes",0

;Constant that is also defined in C.
DIMMATRIX equ 5

section .text

;Variables defined in Assembly language.
global developer

;Assembly language subroutines called from C.
global posCurScreenP1, updateColP1, updateMatrixBoardP1, getSecretPlayP1
global printSecretP1, checkSecretP1, printHitsP1, checkPlayP1, printMessageP1, playP1

;Global variables defined in C.
extern charac, rowScreen, colScreen, mSecretPlay
extern col, state, tries, hX

;C functions that are called from assembly code.
extern clearScreen_C,  gotoxyP1_C, printchP1_C, getchP1_C
extern printBoardP1_C, printMessageP1_C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Global variables used:
; (rowScreen) : Row of the screen where the cursor is placed.
; (colScreen) : Column of the screen where the cursor is placed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxyP1:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers state because
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call gotoxyP1_C

   ;restore the register's state that have been saved in the stack.
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Global variables used:
; (charac) : Character to show.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchP1:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers state because
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call printchP1_C

   ;restore the register's state that have been saved in the stack.
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Global variables used:
; (charac) : Character read from the keyboard.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchP1:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers state because
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call getchP1_C

   ;restore the register's state that have been saved in the stack.
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Place the cursor inside the board according to the position of the
; cursor (col), the remaining tries (tries) and the game state (state).
; If we are typing the secret code (state==0) we will place
; the cursor in row 3 (rowScreen=3), if we are typing a try (state==1)
; the row is calculated with the formula: (rowScreen=9+(DIMMATRIX-tries)*2).
; The column is calculated with the formula (colScreen= 8+(pos*2)).
; Place the cursor calling the gotoxyP1 subroutine.
; 
; Global variables used:
; (rowScreen): Row of the screen where the cursor is placed.
; (colScreen): Column of the screen where the cursor is placed.
; (state)    : State of the game.
; (tries)    : Remaining tries.
; (col)      : Column where the cursor is.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreenP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

      cmp DWORD[state], 0 ;The state variable is of type int.
      jne not_state_0_posCurScreenP1
      mov DWORD[rowScreen], 3 ;The variable rowScreen is of type int.
      jmp calculate_colScreen_posCurScreenP1

   not_state_0_posCurScreenP1:
      mov eax, DIMMATRIX
      sub eax, DWORD[tries] ; Tries should be QWORD, but since the result
                            ; of the operations should be stored in an int (rowScreen in c),
                            ; we must store the value in a DWORD and,
                            ; if the value of tries does not fit, it will be truncated.

      imul eax, 2 ;We multiply by 2 to respect the order of the arithmetic operands.
      add eax, 9 ;We add 9 to respect the order of the arithmetic operands.
      mov DWORD[rowScreen], eax ;The rowScreen variable is of type int.

   calculate_colScreen_posCurScreenP1:
      mov ebx, DWORD[col] ;The col variable is of type int.
      imul ebx, 2 ;We multiply by 2 to respect the order of the arithmetic operands.
      add ebx, 8 ;We add 8 to respect the order of the arithmetic operands.
      mov DWORD[colScreen], ebx ;The colScreen variable is of type int.
      call gotoxyP1

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update the column (col) where the cursor is.
; If we read (charac=='j') move left or (charac=='k') right
; update cursor position (col +/- 1)
; checking that it does not leave the array [0..DIMMATRIX-1].
; 
; Global variables used:
; (charac) : Character read from the keyboard.
; (col)    : Column where the cursor is.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;j;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateColP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

      cmp BYTE[charac], 'j' ;The charac variable is of type char.
      jne check_k_updateColP1
      cmp DWORD[col], 0
      jle check_k_updateColP1
      dec DWORD[col]
      jmp end_updateColP1

   check_k_updateColP1:
      cmp BYTE[charac], 'k'
      jne end_updateColP1
      cmp DWORD[col], (DIMMATRIX-1)
      jge end_updateColP1
      inc DWORD[col]

   end_updateColP1:

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Store the read character ['0' - '9'] (charac) in the matrix
; (mSecretPlay) in the row indicated by the variable (state) and
; the column indicated by the variable (col).
; If (state==0) we will change the character read by a '*'
; (charac = '*') for which the secret code we write is not seen.
; Finally, we show the character (charac) on the screen at the position
; where the cursor is by calling the printchP1 subroutine.
; 
; Global variables used:
; (charac)    : Character to show.
; (mSecrePlay): Matrix where we store the secret code and the try.
; (col)       : Column where the cursor is.
; (state)     : State of the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateMatrixBoardP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

      mov eax, DWORD[state]
      imul eax, DIMMATRIX ;We multiply by the size of each row.
      add eax, DWORD[col] ;we add the index of the column.

      mov sil, BYTE[charac]
      mov BYTE[mSecretPlay + eax], sil ;We insert charac at calculated position.

      cmp DWORD[state], 0
      jne end_updateMatrixBoardP1
      mov BYTE[charac], '*'

   end_updateMatrixBoardP1:
      call printchP1

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Read the characters of the secret code or the try.
; While ENTER(10) or ESC(27) is not pressed do the following:
; · Place the cursor on the screen by calling the posCurScreenP1 subroutine,
; according to the value of the variables (col, tries and state).
; · Read a keyboard character by calling the getchP1 subroutine
; which returns to (charac) the ASCII code of the character read.
; - If a 'j' (left) or a 'k' (right) has been read, move the
; cursor through the 5 positions of combination updating
; the value of the variable (col) by calling the updateColP1 subroutine
; depending on the variables (col, tries and state).
; - If a number ['0'-'9'] has been read we store it in the array
; (mSecretPlay) and we display it by calling the updateMatrixBoardP1 subroutine
; depending on the variables (charac, mSecretPlay, col and state).
; If ESC(27) has been pressed, set (state=-1) to indicate that we must exit.
; Pressing ENTER(10) will accept the combination as is.
; NOTE: Please note that if ENTER is pressed without having been assigned
; values in all positions of the combination, there will be positions
; which will be a space (value used to initialise the array).
; 
; Global variables used:
; (charac)     : Character read from the keyboard.
; (col)        : Column where the cursor is.
; (mSecretPlay): Matrix where we store the secret code and the try.
; (state)      : State of the game.
; (tries)      : Remaining tries.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getSecretPlayP1
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

   mov DWORD[col], 0

   ;There is not much to comment, the main challenge is to reproduce
   ;the do while using the comparators that we have used in class.
   do_getSecretPlayP1:
      call posCurScreenP1
      call getchP1

      cmp BYTE[charac], 'j'
      je call_update_col
      cmp BYTE[charac], 'k'
      je call_update_col

      do_check_updateMatrixBoardP1:
         cmp BYTE[charac], '0'
         jl while_condition_getSecretPlayP1
         cmp BYTE[charac], '9'
         jg while_condition_getSecretPlayP1
         call updateMatrixBoardP1

      while_condition_getSecretPlayP1:
         cmp BYTE[charac], 10
         je end_while_getSecretPlayP1
         cmp BYTE[charac], 27
         je end_while_getSecretPlayP1
         jmp do_getSecretPlayP1

      call_update_col:
         call updateColP1
         jmp do_check_updateMatrixBoardP1

   end_while_getSecretPlayP1:
      cmp BYTE[charac], 27
      jne end_getSecretPlayP1
      mov DWORD[state], -1 

   end_getSecretPlayP1:

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Verify that the secret code does not have the initial value (' '),
; or repeated numbers.
; For each element of the row [0] of the matrix (mSecretPlay) check
; that there is no space (' ') and that it is not repeated in the
; (from the next position to the current one until the end).
; To indicate that the secret code is not correct we set (secretError=1).
; If the secret code is incorrect, set (state = 2) to request it again.
; else, the secret code is correct, set (state = 1) to read tries.
;  
; Global variables used:
; (mSecretPlay): Matrix where we store the secret code and the try.
; (state)      : State of the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
checkSecretP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

   mov ecx, 0 ;i Counter
   mov ebx, 0 ;Error

   for_i_checkSecretP1:
      cmp ecx, DIMMATRIX
      jge end_for_i_checkSecretP1
      movzx eax, BYTE[mSecretPlay + ecx] ;Sets the most significant bits corresponding
                                         ;to the bits not occupied by the BTTE in EAX to 0.
      cmp eax, ' '
      jne not_space
      mov ebx, 1

   not_space:
      mov edx, ecx ;j Counter
      inc edx

      for_j_checkSecretP1:
         cmp edx, DIMMATRIX
         jge end_for_j_checkSecretP1
         movzx esi, BYTE[mSecretPlay + ecx] ;mSecretPlay[0][i]
         movzx edi, BYTE[mSecretPlay + edx] ;mSecretPlay[0][j]
         cmp esi, edi
         jne not_repeated
         mov ebx, 1
         
      not_repeated:
         inc edx
         jmp for_j_checkSecretP1

      end_for_j_checkSecretP1:
         inc ecx
         jmp for_i_checkSecretP1

   end_for_i_checkSecretP1:
      cmp ebx, 1
      je set_secret_error
      mov DWORD[state], 1
      jmp end_checkSecretP1

   set_secret_error:
      mov DWORD[state], 2

   end_checkSecretP1:

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show the secret code.
; Show the secret code (row 0 of the mSecretPlay matrix)
; at the top of the board when the game ends.
; To show the values, the gotoxyP1 subroutine must be called to
; place cursor, in row 3 (rowScreen=3) and from
; column 8 (colScreen=8) and printchP1 to display each character.
; Increase the column (colScreen) by 2.
; 
; Global variables used:
; (rowScreen)  : Row of the screen where the cursor is placed.
; (colScreen)  : Column of the screen where the cursor is placed.
; (charac)     : Character to show.
; (mSecretPlay): Matrix where we store the secret code and the try.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printSecretP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

   mov DWORD[rowScreen], 3
   mov DWORD[colScreen], 8

   mov ecx, 0 ;Counter

   for_printSecretP1:
      cmp ecx, DIMMATRIX
      jge end_for_printSecretP1
      call gotoxyP1
      movzx eax, BYTE[mSecretPlay + ecx]
      mov BYTE[charac], al
      call printchP1
      add DWORD[colScreen], 2 ;We use 2 to avoid printing contiguous
                              ;numbers and to follow the template with space between numbers.
      inc ecx
      jmp for_printSecretP1

   end_for_printSecretP1:

   ;restore the register's state that have been saved in the stack.
   
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show the hits in place.
; Place the cursor in the row (rowScreen=9+(DIMMATRIX-tries)*2) and
; column (colScreen=22) (right side of the board) to show
; the hits on the game board.
; Show as many 'X' as there are hits in place (hX).
; To show the hits, place the cursor by calling the gotoxyP1
; subroutine and show the characters by calling the printchP1 subroutine.
; Each time a hit is shown, the column (colScreen) must be increased by 2.
; NOTE: (hX must always be smaller or equal than DIMMATRIX).
; 
; Global variables used:
; (rowScreen): Row of the screen where the cursor is placed.
; (colScreen): Column of the screen where the cursor is placed.
; (charac)   : Character to show.
; (tries)    : Remaining tries.
; (hX)       : Hits in place.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printHitsP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

   mov ecx, DWORD[hX] ;Counter

   mov eax, DIMMATRIX
   sub eax, DWORD[tries] ;The same happens as in the posCurScreenP1 subroutine.
   imul eax, 2
   add eax, 9
   mov DWORD[rowScreen], eax
   mov DWORD[colScreen], 22
   mov BYTE[charac], 'X'

   for_printHitsP1:
      cmp ecx, 0
      jle end_for_printHitsP1
      call gotoxyP1
      call printchP1
      add DWORD[colScreen], 2
      dec ecx
      jmp for_printHitsP1

   end_for_printHitsP1:

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Count hits in place of the try with respect to the secret code.
; Compare each element of the secret code with the element
; in the same position of the try.
; If an element of the secret code (mSecretPlay[0][i]) is equal to
; the element of the same position of the try (mSecretPlay[1][i]) it will be
; a hit in place 'X' and the hits in place must be increased (hX++).
; If all positions in the secret code and the try are equals
; (hX=DIMMATRIX), we have won and the game status must be
; modified to indicate it (state=3),
; else, check if the tries have run out (tries=1) to modify
; the state of the game to indicate it (state=4).
; Show the hits in place in the game board
; calling the printHitsP1 subroutine.
; 
; Global variables used:
; (mSecretPlay): Matrix where we store the secret code and the try.
; (state)      : State of the game.
; (tries)      : Remaining tries.
; (hX)         : Hits in place.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
checkPlayP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.

   mov ecx, 0 ;Counter
   mov WORD[hX], 0 ;Hits counter

   for_checkPlayP1:
      cmp ecx, DIMMATRIX
      jge end_for_checkPlayP1
      mov sil, BYTE[mSecretPlay + ecx] ;mSecretPlay[0][i].
      mov dil, BYTE[mSecretPlay + DIMMATRIX + ecx] ;mSecretPlay[1][i].
      cmp sil, dil
      jne increment_and_back_checkPlayP1
      inc WORD[hX]

   increment_and_back_checkPlayP1:
      inc ecx
      jmp for_checkPlayP1

   end_for_checkPlayP1:
      cmp WORD[hX], DIMMATRIX
      jne check_tries_checkPlayP1
      mov DWORD[state], 3
      jmp end_checkPlayP1

   check_tries_checkPlayP1:
      cmp QWORD[tries], 1
      jne end_checkPlayP1
      mov DWORD[state], 4

   end_checkPlayP1:
      call printHitsP1

   ;restore the register's state that have been saved in the stack.

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show a message at the bottom right of the game board according to
; the value of the variable (state).
; (state) -1: ESC was pressed to exit.
;          0: We are typing the secret code.
;          1: We are typing a tray.
;          2: The secret code has spaces or repeated numbers.
;          3: Won, try = secret code.
;          4: The tries have run out.
; 
; Is expected to press a key to continue.
; Show a message below on the  game board to indicate this,
; and pressing a key, it is deleted.
; 
; Global variables used:
; (rowScreen): Row of the screen where the cursor is placed.
; (colScreen): Column of the screen where the cursor is placed.
; (state)    : State of the game.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printMessageP1:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers state because
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   call printMessageP1_C

   ;restore the register's state that have been saved in the stack.
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main game subroutine.
; Read the secret code and verify that it is correct.
; Then a try is read, compare the try with 
; the secret code to check the hits in place.
; Repeat the process until the secret code is guessed or
; while there aren't tries left. If 'ESC' key is pressed while reading
; the secret code or a try, exit.
; 
; Pseudo-code:
; The player has 5 tries (tries=5) to guess the secret code,
; the initial state of the game is 0 (state=0) and the cursor is set
; to column 0 (col=0).
; Show the game board by calling the printBoardP1_C function.
;  
; While (state == 0) read the secret code or (state == 1) read
; the try:
;   - Show the remaining tries (tries) to guess the secret code,
;     place the cursor in row 21, column 5 calling the gotoxyP1
;     subroutine and show the character associated with the value of the
;     variable (tries) adding '0' and calling the printchP1 subroutine.
;   - Show a message according to the state of the game (state) calling
;     the printMessageP1 subroutine.
;   - Place the cursor on the game board calling the posCurBoardP1 subroutine.
;   - Read the characters of the secret combination or the try
;     and update the game state by calling the getSecretPlayP1 subroutine.
;   - If we are typing the secret code (state==0), verify
;     that is correct by calling the checkSecretP1 subroutine.
;     Else, if we are typing a try (state==1) check
;     hits in place of the try calling the checkPlayP1 subroutine,
;     decrease tries (tries). Initialize the try that we have saved 
;     in row 1 of the array mSecretPlay with spaces (' ')
;     to be able to enter a new try.
; 
; Finally, show the remaining tries (tries) to guess the
; secret code, place the cursor in row 21, column 5 by calling the
; gotoxyP1 subroutine and show the character associated with the
; value of the variable (tries) by adding '0' and calling the
; printchP1 subroutine, show the secret code by calling the
; printSecretP1 subroutine and finally show the message indicating the
; reason calling the printMessageP1 subroutine.
; Game is over.
; 
; Global variables used:
; (col)        : Column where the cursor is placed.
; (state)      : State of the game.
; (tries)      : Remaining tries.
; (rowScreen)  : Row of the screen where the cursor is placed.
; (colScreen)  : Column of the screen where the cursor is placed.
; (charac)     : Character read from the keyboard and to show.
; (mSecretPlay): Matrix where we store the secret code and the try.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
playP1:
   push rbp
   mov  rbp, rsp
   ;We save the processor's registers state that are modified in this
   ;subroutine and that are not use to return values.
   push rcx
   push rdi

   mov DWORD[col], 0
   mov DWORD[state], 0
   mov QWORD[tries], 5

   call printBoardP1_C

   P1_while:
   cmp DWORD[state], 0
   je P1_whileOk
   cmp DWORD[state], 1
   jne P1_endwhile

   P1_whileOk:
      mov DWORD[rowScreen], 21
      mov DWORD[colScreen], 5
      call gotoxyP1
      mov rdi, QWORD[tries]
      add dil, '0'
      mov BYTE[charac], dil ;charac = tries + '0';
      call printchP1
      call printMessageP1
      call posCurScreenP1
      call getSecretPlayP1

   P1_if1:
      cmp DWORD[state], 0
      jne P1_else1
      call checkSecretP1
      jmp P1_endif1

   P1_else1:

      P1_if2:
         cmp DWORD[state], 1
         jne P1_endif2
         call checkPlayP1
         dec QWORD[tries]

      P1_endif2:
         mov rcx, 0

      P1_for:
         cmp rcx, (DIMMATRIX)
         jge P1_endfor
         mov BYTE[mSecretPlay+DIMMATRIX+rcx], ' ' ;mSecretPlay[1][i]=' ';
         inc rcx
         jmp P1_for

      P1_endfor:
   P1_endif1:
     jmp P1_while

   P1_endwhile:
      mov DWORD[rowScreen], 21
      mov DWORD[colScreen], 5
      call gotoxyP1 ;gotoxyP1_C(21,5);
      mov rdi, QWORD[tries]
      add  dil, '0'
      mov BYTE[charac], dil ;charac = tries + '0';
      call printchP1 ;printchP1_C();
      call printSecretP1 ;printSecretP1_C();
      call printMessageP1 ;printMessage_C();
   
   P1_end:
   ;restore the register's state that have been saved in the stack.
   pop rdi
   pop rcx

   mov rsp, rbp
   pop rbp
   ret

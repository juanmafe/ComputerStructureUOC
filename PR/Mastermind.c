/**
 * C-Implementation of the practice, to have a high-level 
 * functional version with all the features you have to implement 
 * in assembly language.
 * From this code calls are made to assembly subroutines. 
 * THIS CODE CANNOT BE MODIFIED AND SHOULD NOT BE DELIVERED. 
 */

#include <stdio.h>
#include <termios.h>    //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>     //STDIN_FILENO

/**
 * Constants.
 */
#define DIMMATRIX 5

/**
 * Global variables definition
 */
extern int developer; //Declared variable in assembly language indicating the program developer name.

char charac;   //Character read from the keyboard and to show.
int  rowScreen;//Row of the screen where the cursor is placed.
int  colScreen;//Column of the screen where the cursor is placed.

char mSecretPlay[2][DIMMATRIX] = { {' ',' ',' ',' ',' '},   //Row 0: Secret Code.
                                   {' ',' ',' ',' ',' '} }; //Row 1: Each try.
int  col;      //Column of the matrix we are accessing.

int state;     //State of the game.
               //-1: ESC was pressed to exit.
               // 0: We are typing the secret code.
               // 1: We are typing a tray.
               // 2: The secret code has spaces or repeated numbers.
               // 3: Won, try = secret code.
               // 4: The tries have run out.

long  tries;   //Remaining tries.
short hX;      //Hits in place.


/**
 * Definition of C functions.
 **/
void clearScreen_C();
void gotoxyP1_C();
void printchP1_C();
void getchP1_C();
void printMenuP1_C();
void printBoardP1_C();

void posCurScreenP1_C();
void updateColP1_C();
void updateMatrixBoardP1_C();
void getSecretPlayP1_C();
void printSecretP1_C();
void checkSecretP1_C();
void printHitsP1_C();
void checkPlayP1_C();
void printMessageP1_C();
void playP1_C();

/**
 * Definition of assembly language subroutines called from C.
 **/
void posCurScreenP1();
void updateColP1();
void updateMatrixBoardP1();
void getSecretPlayP1();
void printSecretP1();
void checkSecretP1();
void printHitsP1();
void checkPlayP1();
void playP1();

/**
 * Clear screen.
 * 
 * Global variables used:	
 * None
 * 
 * This function is not called from assembly code
 * and an equivalent assembly subroutine is not defined.
 */
void clearScreen_C(){
    printf("\x1B[2J");
}


/**
 * Place the cursor at a position on the screen.
 * 
 * Global variables used:
 * (rowScreen) : Row of the screen where the cursor is placed.
 * (colScreen) : Column of the screen where the cursor is placed.
 * 
 * An assembly language subroutine 'gotoxyP1' is defined to be able
 * to call this function saving the status of the processor registers.
 * This is done because C functions do not maintain the status of
 * the processor registers.
 */
void gotoxyP1_C(){
   printf("\x1B[%d;%dH", rowScreen, colScreen);
}


/**
 * Show a character on the screen at the cursor position.
 * 
 * Global variables used:
 * (charac) : Character to show.
 * 
 * An assembly language subroutine 'printchP1' is defined to be able
 * to call this function saving the status of the processor registers.
 * This is done because C functions do not maintain the status of
 * the processor registers.
 */
void printchP1_C(){
   printf("%c",charac);
}


/**
 * Read a character from the keyboard without displaying it
 * on the screen and store it in the variable (charac).
 * 
 * Global variables used:
 * (charac) : Character read from the keyboard.
 * 
 * An assembly language subroutine 'getchP1' is defined to be able
 * to call this function saving the status of the processor registers.
 * This is done because C functions do not maintain the status of
 * the processor registers.
 */
void getchP1_C(){

   static struct termios oldt, newt;

   /*tcgetattr get terminal parameters
   STDIN_FILENO indicates that standard input parameters (STDIN) are written on oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*copy parameters*/
   newt = oldt;

   /* ~ICANON to handle keyboard input character to character, not as an entire line finished with /n
      ~ECHO so that it does not show the character read*/
   newt.c_lflag &= ~(ICANON | ECHO);

   /*Fix new terminal parameters for standard input (STDIN)
   TCSANOW tells tcsetattr to change the parameters immediately.*/
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Read a character*/
   charac=(char)getchar();
    
   /*restore the original settings*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
}


/**
 * Show the game menu on the screen and ask for an option.
 * Only accepts one of the correct menu options ('0'-'9').
 * 
 * Global variables used:
 * (developer) :((char *)&developer):Variable defined in the assembly code.
 * (rowScreen) : Row of the screen where the cursor is placed.
 * (colScreen) : Column of the screen where the cursor is placed.
 * (charac)    : Character read from the keyboard.
 * 
 * This function is not called from the assembly code and
 * an equivalent subroutine has not been defined in assembly language.
 */
void printMenuP1_C(){

   clearScreen_C();
   rowScreen = 1;
   colScreen = 1;
   gotoxyP1_C();
   printf("                              \n");
   printf("       Developed by:          \n");
   printf("     ( %s )   \n",(char *)&developer);
   printf(" _____________________________ \n");
   printf("|                             |\n");
   printf("|    MENU MASTERMIND v1.0     |\n");
   printf("|_____________________________|\n");
   printf("|                             |\n");
   printf("|     1.  PosCurScreen        |\n");
   printf("|     2.  UpdateCol           |\n");
   printf("|     3.  UpdateMatrixBoard   |\n");
   printf("|     4.  getSecretPlay       |\n");
   printf("|     5.  PrintSecret         |\n");
   printf("|     6.  CheckSecret         |\n");
   printf("|     7.  PrintHits           |\n");
   printf("|     8.  CheckPlay           |\n");
   printf("|     9.  Play Game           |\n");
   printf("|     0.  Play Game C         |\n");
   printf("|    ESC. Exit game           |\n");
   printf("|                             |\n");
   printf("|         OPTION:             |\n");
   printf("|_____________________________|\n"); 

   charac=' ';
   while (charac!=27 && (charac < '0' || charac > '9')) {
     rowScreen = 21;
     colScreen = 19;
     gotoxyP1_C();
     getchP1_C();
   }
}


/**
 * Show the game board on the screen. Lines of the board.
 * 
 * Global variables used:
 * (rowScreen): Row of the screen where the cursor is placed.
 * (colScreen): Column of the screen where the cursor is placed.
 * (tries)    : Remaining tries.
 * 
 * This function is not called from the assembly code and
 * an equivalent subroutine has not been defined in assembly language.
 */
void printBoardP1_C(){
   int i;

   clearScreen_C();
   rowScreen = 1;
   colScreen = 1;
   gotoxyP1_C();
   printf(" _______________________________ \n");//1
   printf("|                               |\n");//2
   printf("|      _ _ _ _ _   Secret Code  |\n");//3
   printf("|_______________________________|\n");//4
   printf("|                 |             |\n");//5
   printf("|       Play      |     Hits    |\n");//6
   printf("|_________________|_____________|\n");//7
   for (i=0;i<tries;i++){                        //8-19
     printf("|   |             |             |\n");
     printf("| %d |  _ _ _ _ _  |  _ _ _ _ _  |\n",i+1);
   }
   printf("|___|_____________|_____________|\n");//20
   printf("|       |                       |\n");//21
   printf("| Tries |                       |\n");//22
   printf("|  ___  |                       |\n");//23
   printf("|_______|_______________________|\n");//24
   printf(" (ENTER) next Try       (ESC)Exit \n");//25
   printf(" (0-9) values    (j)Left (k)Right   ");//26
}


/**
 * Place the cursor inside the board according to the position of the
 * cursor (col), the remaining tries (tries) and the game state (state).
 * If we are typing the secret code (state==0) we will place 
 * the cursor in row 3 (rowScreen=3), if we are typing a try (state==1)
 * the row is calculated with the formula: (rowScreen=9+(DIMMATRIX-tries)*2).
 * The column is calculated with the formula (colScreen= 8+(pos*2)).
 * Place the cursor calling the gotoxyP1_C function.
 * 
 * Global variables used:
 * (rowScreen): Row of the screen where the cursor is placed.
 * (colScreen): Column of the screen where the cursor is placed.
 * (state)    : State of the game.
 * (tries)    : Remaining tries.
 * (col)      : Column where the cursor is.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'posCurScreenP1' is defined.
 **/
void posCurScreenP1_C(){

   if (state==0) {
      rowScreen = 3;
   } else {
      rowScreen = 9+(DIMMATRIX-tries)*2;
   }
   colScreen = 8+(col*2);
   gotoxyP1_C();
}

/**
 * Update the column (col) where the cursor is.
 * If we read (charac=='j') move left or (charac=='k') right
 * update cursor position (col +/- 1)
 * checking that it does not leave the array [0..DIMMATRIX-1].
 * 
 * Global variables used:	
 * (charac) : Character read from the keyboard.
 * (col)    : Column where the cursor is.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'updateColP1' is defined.
 **/
void updateColP1_C(){

   if ((charac=='j') && (col>0)){
      col--;
   }
   if ((charac =='k') && (col<DIMMATRIX-1)){
      col++;
   }
}


/**
 * Store the read character ['0' - '9'] (charac) in the matrix
 * (mSecretPlay) in the row indicated by the variable (state) and
 * the column indicated by the variable (col).
 * If (state==0) we will change the character read by a '*'
 * (charac = '*') for which the secret code we write is not seen.
 * Finally, we show the character (charac) on the screen at the position
 * where the cursor is by calling the printchP1_C function.
 * 
 * Global variables used:
 * (charac)    : Character to show.
 * (mSecrePlay): Matrix where we store the secret code and the try.
 * (col)       : Column where the cursor is.
 * (state)     : State of the game.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'updateMatriBoardP1' is defined.
 **/
void updateMatrixBoardP1_C(){

   mSecretPlay[state][col] = charac;
   if (state==0) {
      charac='*';
   }
   printchP1_C();
}


/**
 * Read the characters of the secret code or the try.
 * While ENTER(10) or ESC(27) is not pressed do the following:
 * · Place the cursor on the screen by calling the posCurScreenP1_C function,
 * according to the value of the variables (col, tries and state).
 * · Read a keyboard character by calling the getchP1_C function
 * which returns to (charac) the ASCII code of the character read.
 * - If a 'j' (left) or a 'k' (right) has been read, move the
 * cursor through the 5 positions of combination updating
 * the value of the variable (col) by calling the updateColP1_C function
 * depending on the variables (col, tries and state).
 * - If a number ['0'-'9'] has been read we store it in the array
 * (mSecretPlay) and we display it by calling the updateMatrixBoardP1_C function
 * depending on the variables (charac, mSecretPlay, col and state).
 * If ESC(27) has been pressed, set (state=-1) to indicate that we must exit.
 * Pressing ENTER(10) will accept the combination as is.
 * NOTE: Please note that if ENTER is pressed without having been assigned
 * values in all positions of the combination, there will be positions
 * which will be a space (value used to initialise the array).
 * 
 * Global variables used:
 * (charac)     : Character read from the keyboard.
 * (col)        : Column where the cursor is.
 * (mSecretPlay): Matrix where we store the secret code and the try.
 * (state)      : State of the game.
 * (tries)      : Remaining tries.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'getSecretPlayP1' is defined.
 **/
void getSecretPlayP1_C(){

   col = 0;

   do {
   posCurScreenP1_C();
   getchP1_C();
     if (charac=='j' || charac=='k'){
       updateColP1_C();
     }
     if (charac>='0' && charac<='9'){
       updateMatrixBoardP1_C();
     }
   } while (charac!=10 && charac!=27);

   if (charac == 27) {
     state = -1;
   }
}


/**
 * Verify that the secret code does not have the initial value (' '),
 * or repeated numbers.
 * For each element of the row [0] of the matrix (mSecretPlay) check
 * that there is no space (' ') and that it is not repeated in the
 * (from the next position to the current one until the end).
 * To indicate that the secret code is not correct we set (secretError=1).
 * If the secret code is incorrect, set (state = 2) to request it again.
 * else, the secret code is correct, set (state = 1) to read tries.
 *  
 * Global variables used:
 * (mSecretPlay): Matrix where we store the secret code and the try.
 * (state)      : State of the game.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'checkSecreP1' is defined. 
 */
void checkSecretP1_C() {
   int i,j;
   int secretError = 0;

   for (i=0;i<DIMMATRIX;i++) {
     if (mSecretPlay[0][i]==' ') {
       secretError=1;
     }
     for (j=i+1;j<DIMMATRIX;j++) {
       if (mSecretPlay[0][i]==mSecretPlay[0][j]) {
         secretError=1;
       }
     }
   }

   if (secretError==1) state = 2; 
   else state = 1; 
}


/**
 * Show the secret code.
 * Show the secret code (row 0 of the mSecretPlay matrix)
 * at the top of the board when the game ends.
 * To show the values, the gotoxyP1_C function must be called to
 * place cursor, in row 3 (rowScreen=3) and from
 * column 8 (colScreen=8) and printchP1_C to display each character.
 * Increase the column (colScreen) by 2.
 * 
 * Global variables used:
 * (rowScreen)  : Row of the screen where the cursor is placed.
 * (colScreen)  : Column of the screen where the cursor is placed.
 * (charac)     : Character to show.
 * (mSecretPlay): Matrix where we store the secret code and the try.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'printSecretP1' is defined.
 */
void printSecretP1_C() {

   int i;
   rowScreen = 3;
   colScreen = 8;

   for (i=0; i<DIMMATRIX; i++){
   gotoxyP1_C();
   charac = mSecretPlay[0][i];
     printchP1_C(charac);
     colScreen = colScreen + 2;
   }
}


/**
 * Show the hits in place.
 * Place the cursor in the row (rowScreen=9+(DIMMATRIX-tries)*2) and
 * column (colScreen=22) (right side of the board) to show 
 * the hits on the game board.
 * Show as many 'X' as there are hits in place (hX).
 * To show the hits, place the cursor by calling the gotoxyP1_C
 * function and show the characters by calling the printchP1_C function.
 * Each time a hit is shown, the column (colScreen) must be increased by 2.
 * NOTE: (hX must always be smaller or equal than DIMMATRIX).
 * 
 * Global variables used:
 * (rowScreen): Row of the screen where the cursor is placed.
 * (colScreen): Column of the screen where the cursor is placed.
 * (charac)   : Character to show.
 * (tries)    : Remaining tries.
 * (hX)       : Hits in place.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'printHitsP1' is defined.
 */
void printHitsP1_C() {
   int i;

   rowScreen = 9 + (DIMMATRIX-tries)*2;
   colScreen = 22;
   charac = 'X';

   for(i=hX;i>0;i--) {
     gotoxyP1_C();
     printchP1_C();
     colScreen = colScreen + 2;
   }
}


/**
 * Count hits in place of the try with respect to the secret code.
 * Compare each element of the secret code with the element
 * in the same position of the try.
 * If an element of the secret code (mSecretPlay[0][i]) is equal to
 * the element of the same position of the try (mSecretPlay[1][i]) it will be
 * a hit in place 'X' and the hits in place must be increased (hX++).
 * If all positions in the secret code and the try are equals
 * (hX=DIMMATRIX), we have won and the game status must be
 * modified to indicate it (state=3),
 * else, check if the tries have run out (tries=1) to modify
 * the state of the game to indicate it (state=4).
 * Show the hits in place in the game board
 * calling the printHitsP1_C function.
 * 
 * Global variables used:	
 * (mSecretPlay): Matrix where we store the secret code and the try.
 * (state)      : State of the game.
 * (tries)      : Remaining tries.
 * (hX)         : Hits in place.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'checkPlayP1' is defined.
 */
void checkPlayP1_C(){

   int i;
   hX = 0;
   for (i=0;i<DIMMATRIX;i++) {
   if (mSecretPlay[0][i]==mSecretPlay[1][i]) {
       hX++;
     }
   }
    
   if (hX == DIMMATRIX ) {
     state = 3;
   } else if (tries==1) {
     state = 4;
   }
   printHitsP1_C();
}


/**
 * Show a message at the bottom right of the game board according to
 * the value of the variable (state).
 * (state) -1: ESC was pressed to exit.
 *          0: We are typing the secret code.
 *          1: We are typing a tray.
 *          2: The secret code has spaces or repeated numbers.
 *          3: Won, try = secret code.
 *          4: The tries have run out.
 * 
 * Is expected to press a key to continue.
 * Show a message below on the  game board to indicate this,
 * and pressing a key, it is deleted.
 * 
 * Global variables used:
 * (rowScreen): Row of the screen where the cursor is placed.
 * (colScreen): Column of the screen where the cursor is placed.
 * (state)    : State of the game.
 * 
 * An assembly language subroutine 'printMessageP1' is defined to be able
 * to call this function saving the status of the processor registers.
 * This is done because C functions do not maintain the status of 
 * the processor registers.
 */
void printMessageP1_C(){

rowScreen = 20;
   colScreen = 11;
   gotoxyP1_C();
   switch(state){
     case -1:
       printf(" EXIT: (ESC) PRESSED ");
     break;
     case 0: 
       printf("Write the Secret Code");
     break;
     case 1:
       printf(" Write a combination ");
     break;
     case 2:
       printf("Secret Code ERROR!!! ");
     break;
     case 3:
       printf("YOU WIN: CODE BROKEN!");
     break;
     case 4:
       printf("GAME OVER: No tries! ");
     break;
   }
   rowScreen = 21;
   colScreen = 11;
   gotoxyP1_C(); 
   printf("  Press any key   ");
   getchP1_C();	  
   gotoxyP1_C();  
   printf("                  ");
   
}


/**
 * Main game function
 * Read the secret code and verify that it is correct.
 * Then a try is read, compare the try with
 * the secret code to check the hits in place.
 * Repeat the process until the secret code is guessed or
 * while there aren't tries left. If 'ESC' key is pressed while reading
 * the secret code or a try, exit.
 * 
 * Pseudo-code:
 * The player has 5 tries (tries=5) to guess the secret code,
 * the initial state of the game is 0 (state=0) and the cursor is set
 * to column 0 (col=0).
 * Show the game board by calling the printBoardP1_C function.
 * 
 * While (state == 0) read the secret code or (state == 1) read
 * the try:
 *   - Show the remaining tries (tries) to guess the secret code,
 *     place the cursor in row 21, column 5 calling the gotoxyP1_C
 *     function and show the character associated with the value of the
 *     variable (tries) adding '0' and calling the printchP1_C function.
 *   - Show a message according to the state of the game (state) calling
 *     the  printMessageP1_C function.
 *   - Place the cursor on the game board calling the posCurBoardP1_C function.
 *   - Read the characters of the secret combination or the try
 *     and update the game state by calling the getSecretPlayP1_C function.
 *   - If we are typing the secret code (state==0), verify
 *     that is correct by calling the checkSecretP1_C function.
 *     Else, if we are typing a try (state==1) check
 *     hits in place of the try calling the checkPlayP1_C function,
 *     decrease tries (tries). Initialize the try that we have saved
 *     in row 1 of the array mSecretPlay with spaces (' ')
 *     to be able to enter a new try.
 * 
 * Finally, show the remaining tries (tries) to guess the
 * secret code, place the cursor in row 21, column 5 by calling the
 * gotoxyP1_C function and show the character associated with the
 * value of the variable (tries) by adding '0' and calling the
 * printchP1_C function, show the secret code by calling the
 * printSecretP1_C  function and finally show the message indicating the
 * reason calling the  function printMessageP1_C.
 * Game is over.
 * 
 * Global variables used:
 * (col)        : Column where the cursor is placed.
 * (state)      : State of the game.
 * (tries)      : Remaining tries.
 * (rowScreen)  : Row of the screen where the cursor is placed.
 * (colScreen)  : Column of the screen where the cursor is placed.
 * (charac)     : Character read from the keyboard and to show.
 * (mSecretPlay): Matrix where we store the secret code and the try.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'playP1' is defined. 
 */
void playP1_C() {

   col=0;
   state = 0;
   tries = 5;

   printBoardP1_C();

   int i;

   while (state == 0 || state == 1) {
      rowScreen=21;
        colScreen=5;  
      gotoxyP1_C();
      charac = (char)tries + '0';
        printchP1_C();
        printMessageP1_C();
        posCurScreenP1_C();

      getSecretPlayP1_C();
      if (state==0) {
        checkSecretP1_C();
      } else {
        if (state==1) {
          checkPlayP1_C();
          tries --;
        }
        for (i=0;i<DIMMATRIX;i++) {
          mSecretPlay[1][i]=' ';
        }
      }
   }

   rowScreen=21;
   colScreen=5;
   gotoxyP1_C();
   charac=tries + '0';
   printchP1_C();
   printSecretP1_C();
   printMessageP1_C();
}


/**
 * Main Program
 * 
 * ATTENTION: In each option an assembly subroutine is called.
 * Below them there is a line comment with the equivalent C function
 * that we give you done in case you want to see how it works.
 * For the full game there is an option for the assembler version and
 * an option for the game in C.
 **/
void main(void){
   int i;
   int op=' ';

   while (op!=27) {
     printMenuP1_C();
     op = charac;
     switch(op){
       case 27:
         rowScreen=23;
         colScreen=1;
         gotoxyP1_C(); 
         break;
       case '1':	          //Place the cursor in the game board.
         state=1;
         tries=5;
         col = 0;		
         printBoardP1_C();
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key  ");
         //=======================================================
         posCurScreenP1();
         //posCurScreenP1_C();
         //=======================================================
         getchP1_C();
         break;
       case '2':          //Update cursor column.
         state=1;
         tries=5;
         col = 4;
         printBoardP1_C();
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf(" Press 'j' or 'k' ");
         posCurScreenP1_C();
         getchP1_C();
         if (charac=='j' || charac=='k') {
         //=======================================================
         updateColP1();
         //updateColP1_C();
         //=======================================================
         }
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key  ");
         posCurScreenP1_C();
         getchP1_C();
         break;
       case '3':     //Update array and show it on the game board.
         state=0;
         tries=5;
         col=2;
         printBoardP1_C();
         printSecretP1_C();
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf(" Press (0-9) value ");
         posCurScreenP1_C();
         getchP1_C();
         if (charac>='0' && charac<='9'){
         //=======================================================
         updateMatrixBoardP1();
         //updateMatrixBoardP1_C();
         //=======================================================
         }
         rowScreen=20;
         colScreen=11;
         gotoxyP1_C();
         printf("   To show Secret  ");
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key   ");
         getchP1_C();
         printSecretP1_C();
         rowScreen=20;
         colScreen=11;
         gotoxyP1_C();
         printf("                   ");
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key  ");
         getchP1_C();
         break;
       case '4': 	     //Read the secret code and the try
         state=0;
         tries=5;
         col=0;
         for (i=0;i<DIMMATRIX;i++) {
           mSecretPlay[state][i]=' ';
         }
         printBoardP1_C();
         printMessageP1_C();
         //=======================================================
         getSecretPlayP1();
         //getSecretPlayP1_C();
         //=======================================================
         printSecretP1_C();
         checkSecretP1_C();
         printMessageP1_C();
         break;
       case '5': 	     //Show the secret code
         state=0;
         tries=5;
         col=0;
         printBoardP1_C();
         //=======================================================
         printSecretP1();
         //printSecretP1_C();
         //=======================================================
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key  ");
         getchP1_C();
         break;
       case '6': 	     //Check the secret code
         state=0;
         tries=5;
         col=0;	
         printBoardP1_C();
         //=======================================================
         checkSecretP1();
         //checkSecretP1_C();
         //=======================================================
         printSecretP1_C();
         printMessageP1_C();
         break;
       case '7':     //Show hits.
         state=1;
         tries=5;
         col=0;
         printBoardP1_C();
         hX = 4;
         //=======================================================
         printHitsP1();
         //printHitsP1_C();
         //=======================================================
         rowScreen=21;
         colScreen=11;
         gotoxyP1_C();
         printf("   Press any key  ");
         getchP1_C();
         break;
       case '8': 	     //Check hits in place
         state=0;
         tries=5;
         col=0;
         printBoardP1_C();
         char  msecretplay2[2][DIMMATRIX] = {{'1','2','3','4','5'}, //Secret code
                                             {'1','4','3','1','4'}};//Try
         for (i=0;i<DIMMATRIX;i++) {
           mSecretPlay[0][i]=msecretplay2[0][i];
           mSecretPlay[1][i]=msecretplay2[1][i];
         }
         printSecretP1_C();
         state=1;
         rowScreen = 9+(DIMMATRIX-tries)*2;
         colScreen = 8;
         for (i=0; i<DIMMATRIX; i++){
         gotoxyP1_C();
         charac = mSecretPlay[1][i];
         printchP1_C();
         colScreen = colScreen + 2;
         }
         //=======================================================
         checkPlayP1();
         //checkPlayP1_C();
         //=======================================================
         for (i=0;i<DIMMATRIX;i++) {
           mSecretPlay[0][i]=' ';
           mSecretPlay[1][i]=' ';
         } 
         printMessageP1_C();
         break;
       case '9':      //Complet game in assembly language.
         i=0;
         for (i=0;i<DIMMATRIX;i++) {
           mSecretPlay[0][i]=' ';
           mSecretPlay[1][i]=' ';
         }
         //=======================================================
         playP1();
         //=======================================================
         break;
       case '0':     //Complet game in C.
         i=0;
         for (i=0;i<DIMMATRIX;i++) {
           mSecretPlay[0][i]=' ';
           mSecretPlay[1][i]=' ';
         }
         //=======================================================
         playP1_C();
         //=======================================================
         break;
     }
   }
}

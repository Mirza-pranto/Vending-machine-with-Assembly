.MODEL SMALL
 
.STACK 100H

.DATA
    productList db "mojo   $", "coke   $", "pepsi  $", "fanta  $", "mirinda$"
    productPrices db 25, 40, 35, 35, 40
    
    promptMessage db "Enter a product index (0-4): $"
    invalidIndexMsg db "Invalid index. Please enter a value between 0 and 4.$", 0
    productMsg db "Product: ", 0
    priceMsg db ", Price: $"

.CODE  
      
    ; Macro to print product and price
PRINT_PRODUCT_PRICE MACRO index
    ; Calculate address of the product
    MOV SI, OFFSET productList
    MOV CL, index
    MOV CH, 0
    MOV AX, CX
    SHL AX, 3         ; Multiply index by 8 (each product is 8 bytes)
    ADD SI, AX

    ; Print the product
    MOV AH, 09H
    LEA DX, productMsg
    INT 21H
    MOV DX, SI
    MOV AH, 09H
    INT 21H

    ; Print the price
    MOV SI, OFFSET productPrices
    MOV CL, index
    MOV CH, 0
    ADD SI, CX        ; Move to the corresponding price
    MOV AL, [SI]      ; Load the price
    MOV AH, 00        ; Clear AH
    MOV BX, AX        ; Store price in BX

    ; Convert price to ASCII and print
    LEA DX, priceMsg
    MOV AH, 09H
    INT 21H

    MOV AX, BX
    CALL PRINT_NUMBER ; Print the price as a number
ENDM

; Subroutine to print a number in AX
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX        ; Clear CX (digit count)
    MOV BX, 10        ; Base 10

DIV_LOOP:
    XOR DX, DX        ; Clear DX for DIV
    DIV BX            ; AX = AX / BX, DX = AX % BX
    PUSH DX           ; Push remainder (digit)
    INC CX            ; Increment digit count
    CMP AX, 0
    JNE DIV_LOOP

PRINT_DIGITS:
    POP DX            ; Get digit
    ADD DL, '0'       ; Convert to ASCII
    MOV AH, 02H
    INT 21H           ; Print the digit
    LOOP PRINT_DIGITS

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP
          

MAIN PROC

;iniitialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here

; Prompt the user to enter an index
MOV AH, 09H
LEA DX, promptMessage
INT 21H

; Read user input
MOV AH, 01H
INT 21H
SUB AL, '0'        ; Convert ASCII to integer
MOV BL, AL         ; Store the index in BL

; Check if the index is valid
CMP BL, 0
JL INVALID_INDEX
CMP BL, 4
JG INVALID_INDEX

; Call macro to print product and price
PRINT_PRODUCT_PRICE BL 
jmp exit

; Invalid index handling
INVALID_INDEX:
MOV AH, 09H
LEA DX, invalidIndexMsg
INT 21H
JMP MAIN

exit: 

;exit to DOS
               
MOV AX,4C00H
INT 21H

MAIN ENDP
    END MAIN
.MODEL SMALL
.STACK 100H

.DATA

; ----- ARRAYS -----
item_name      db  "Alooz$", "Curl $", "Lays $", "     $", "     $"  
item_price     db  20, 20, 30, 0, 0
item_quantity  db  1, 20, 30, 0, 0

; ----- VARIABLES -----
item_no        db  99
i              db  0
quantity       db  0

bill           dw  0
cash           dw  0
return_cash    dw  0
total_sell     dw  0

admin_pin      db  "1234", 0

; ----- STRINGS -----
s_menu         db  "Press 1 for Customer Mode, 2 for Admin Mode.$", 0
s_enterPin     db  "Enter Admin 4-digit PIN:$", 0
s_pinWrong     db  "Incorrect PIN. Returning to main menu.$", 0
s_adminWelcome db  "ADMIN MODE:$", 0

; Admin menu & Feature #5
s_adminMenu    db  "Press 1 => Show total sales, 2 => Show low stock items, 3 => Update items, 0 => Main Menu$", 0
s_totalsell    db  "Total Sales Amount: $", 0
s_lowstockHdr  db  "Low-Stock Items (Quantity < 5):$", 0
s_noLowstock   db  "No items are below threshold.$", 0

; Admin update (Feature #6)
s_updatemsg    db  "Enter item # to update (1..3), or 0 to return:$", 0
s_newprice     db  "Enter new price (two digits, e.g. 25):$", 0
s_newquant     db  "Enter new quantity (two digits, e.g. 15):$", 0
s_updatedone   db  "Item updated successfully.$", 0

; Customer strings
s_welc         db  "Welcome$", 0
s_curr         db  "What would you like to purchase? Currently we have these items: $", 0
s_ino          db  "Item No: $", 0
s_iname        db  "| Item name: $", 0
s_iprice       db  "| Item price: $", 0
s_iquant       db  "| Item quantity: $", 0
s_pick         db  "Pick any one item$", 0
s_picknum      db  "For item 1 enter '1' , For item 2 enter '2', For item 3 enter '3', Enter 0 to end process$", 0
s_picked       db  "You have picked item number $", 0
s_quant        db  "Enter the quantity of item (max 3)$", 0
s_stock        db  "Out of stock$", 0
s_bill         db  "Your bill is $", 0
s_thanks       db  "Thank you for purchasing$", 0
s_cash         db  "Enter cash. For now we only take taka 20, 50, 100$", 0
s_picknote     db  "Enter 1 for 20, Enter 2 for 50, Enter 3 for 100$", 0
s_insufficient db  "Insufficient cash. Please enter the correct amount.$", 0
s_retamount    db  "Returned cash amount:$", 0
s_itemhere     db  "Here is your ordered item $", 0

.CODE

; ----------------------------------------
; Subroutine: Print a newline (CR LF)
; ----------------------------------------
NewLine PROC
    MOV AH, 2
    MOV DL, 0DH  ; carriage return
    INT 21H
    MOV DL, 0AH  ; line feed
    INT 21H
    RET
NewLine ENDP

; ----------------------------------------
; Subroutine: Print AX in decimal (up to 9999)
; ----------------------------------------
PrintWordDecimal PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JNE PrintLoop
    ; If AX=0, just print '0'
    MOV DL, '0'
    MOV AH, 2
    INT 21H
    JMP DonePrint

PrintLoop:
    XOR CX, CX
DivideLoop:
    MOV DX, 0
    MOV BX, 10
    DIV BX       ; AX / 10 => quotient in AX, remainder in DX
    PUSH DX      ; push remainder
    INC CX
    CMP AX, 0
    JNE DivideLoop

PrintDigits:
    POP DX
    ADD DL, '0'
    MOV AH, 2
    INT 21H
    LOOP PrintDigits

DonePrint:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PrintWordDecimal ENDP

; ----------------------------------------
; MAIN
; ----------------------------------------
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX

; -------------------------
; ShowMainMenu
; -------------------------
ShowMainMenu:
    LEA DX, s_menu
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h

    CMP AL, 1
    JE Start       
    CMP AL, 2
    JE AdminCheck
    JMP ShowMainMenu

; -------------------------
; AdminCheck: check PIN
; -------------------------
AdminCheck:
    LEA DX, s_enterPin
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV CX, 4
    MOV SI, OFFSET admin_pin  
CheckLoop:
    MOV AH, 1
    INT 21H
    CMP AL, [SI]
    JNE WrongPin
    INC SI
    LOOP CheckLoop

    ; If loop completes, PIN is correct
    JMP AdminMode

WrongPin:
    LEA DX, s_pinWrong
    MOV AH, 9
    INT 21H
    CALL NewLine
    JMP ShowMainMenu

; ----------------------------------------
; AdminMode: Feature #5 & #6
; ----------------------------------------
AdminMode:
    LEA DX, s_adminWelcome
    MOV AH, 9
    INT 21H
    CALL NewLine

AdminMenu:
    ; Press 1 => Show total sales
    ; Press 2 => Show low stock
    ; Press 3 => Update items
    ; Press 0 => Main Menu
    LEA DX, s_adminMenu
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h

    CMP AL, 1
    JE ShowTotalSales
    CMP AL, 2
    JE ShowLowStock
    CMP AL, 3
    JE UpdateItems
    CMP AL, 0
    JE ShowMainMenu

    JMP AdminMenu

; ----------------------------------------
; ShowTotalSales (Feature #5 part 1)
; ----------------------------------------
ShowTotalSales:
    LEA DX, s_totalsell
    MOV AH, 9
    INT 21H

    MOV AX, total_sell
    CALL PrintWordDecimal
    CALL NewLine

    JMP AdminMenu

; ----------------------------------------
; ShowLowStock (Feature #5 part 2)
; ----------------------------------------
ShowLowStock:
    LEA DX, s_lowstockHdr
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV BL, 0    ; foundLowStock = 0
    MOV AL, 0    ; i = 0
    MOV i, AL

CheckItems:
    MOV AL, i
    CMP AL, 5
    JGE DoneCheck
    
    MOV AH, 0
    MOV SI, AX
    MOV CL, item_quantity[SI]
    CMP CL, 5
    JGE SkipItem  ; quantity >= 5 => skip

    ; => quantity < 5 => low stock
    MOV BL, 1

    ; print "Item No: i+1"
    LEA DX, s_ino
    MOV AH, 9
    INT 21H

    MOV DL, i
    ADD DL, 30h
    ADD DL, 1
    MOV AH, 2
    INT 21H
    CALL NewLine
    
    jmp SkipItem

    ; print item name
    LEA DX, s_iname
    MOV AH, 9
    INT 21H

    MOV AH, 9
    ; each name is 6 bytes => offset = i * 6
    MOV AL, i
    CBW
    MOV BL, 6
    MUL BL
    MOV DI, AX
    LEA DX, item_name[DI]
    INT 21H
    CALL NewLine

    ; print item_quantity as two digits
    LEA DX, s_iquant
    MOV AH, 9
    INT 21H

    MOV DL, item_quantity[SI]
    MOV AL, DL
    MOV AH, 0
    MOV CL, 10
    DIV CL
    MOV CL, AL
    MOV CH, AH

    ADD CL, 30h
    MOV DL, CL
    MOV AH, 2
    INT 21H

    ADD CH, 30h
    MOV DL, CH
    MOV AH, 2
    INT 21H
    CALL NewLine

SkipItem:
    INC AL
    MOV i, AL
    JMP CheckItems

DoneCheck:
    CMP BL, 1
    JE PrintDone

    LEA DX, s_noLowstock
    MOV AH, 9
    INT 21H
    CALL NewLine

PrintDone:
    JMP AdminMenu

; ----------------------------------------
; UpdateItems (Feature #6)
; ----------------------------------------
UpdateItems:
    ; We'll let admin pick which item # (1..3), or 0 to exit
    LEA DX, s_updatemsg
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h   ; now AL=0..3
    CMP AL, 0
    JE AdminMenu  ; if 0 => back
    CMP AL, 3
    JG  AdminMenu ; if >3 => invalid => back

    ; AL is item_no => 1..3
    MOV item_no, AL
    ; We'll do item_no-1 => index in arrays
    MOV BL, item_no
    DEC BL
    MOV BH, 0
    MOV SI, BX

    ; Prompt for new price
    LEA DX, s_newprice
    MOV AH, 9
    INT 21H
    CALL NewLine

    ; We'll read 2 digits as ASCII, e.g. '2','5' => 25
    ; Using AH=1 twice
    ; First digit
    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV BH, AL   ; tens
    ; Second digit
    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV BL, AL   ; ones

    ; price = BH*10 + BL
    MOV AL, BH
    mov cl, 10
    MUL cl   ; AL = BH * 10
    ADD AL, BL
    MOV item_price[SI], AL

    ; Prompt for new quantity
    LEA DX, s_newquant
    MOV AH, 9
    INT 21H
    CALL NewLine

    ; read 2 digits => e.g. '1','5' => 15
    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV BH, AL
    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV BL, AL

    ; quantity = BH*10 + BL
    MOV AL, BH
    mov cl, 10
    MUL cl
    ADD AL, BL
    MOV item_quantity[SI], AL

    ; success message
    LEA DX, s_updatedone
    MOV AH, 9
    INT 21H
    CALL NewLine

    JMP AdminMenu

; we need a little constant for '10' in data
tenConst db 10

; ----------------------------------------------------------
; Start: Customer Mode
; ----------------------------------------------------------
Start:
    LEA DX, s_welc
    MOV AH, 9
    INT 21H

    ; new line
    MOV AH, 2 
    MOV DL, 0DH
    INT 21H 
    MOV DL, 0AH
    INT 21H

    LEA DX, s_curr
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV SI, 0
    MOV DI, 0
    MOV i, 0

Print_Items:
    LEA DX, s_ino
    MOV AH, 9
    INT 21H

    MOV DL, i
    ADD DL, 30h
    ADD DL, 1
    MOV AH, 2
    INT 21H

    LEA DX, s_iname
    MOV AH, 9
    INT 21H

    MOV AH, 9
    LEA DX, item_name[DI]
    INT 21H

    LEA DX, s_iprice
    MOV AH, 9
    INT 21H

    MOV DL, item_price[SI]
    MOV AL, DL
    MOV AH, 0
    MOV CL, 10
    DIV CL
    MOV CL, AL
    MOV CH, AH

    ADD CL, 30h
    MOV DL, CL
    MOV AH, 2
    INT 21H

    ADD CH, 30h
    MOV DL, CH
    MOV AH, 2
    INT 21H

    LEA DX, s_iquant
    MOV AH, 9
    INT 21H

    MOV DL, item_quantity[SI]
    MOV AL, DL
    MOV AH, 0
    MOV CL, 10
    DIV CL
    MOV CL, AL
    MOV CH, AH

    ADD CL, 30h
    MOV DL, CL
    MOV AH, 2
    INT 21H

    ADD CH, 30h
    MOV DL, CH
    MOV AH, 2
    INT 21H

    CALL NewLine

Next_item:
    INC SI
    ADD DI, 6
    INC i

Range_check:
    CMP i, 5
    JGE Pick_item   

    MOV BL, item_quantity[SI]
    CMP BL, 0
    JNE Print_Items
    JE Next_item

Pick_item:
    CALL NewLine
    CALL NewLine

    LEA DX, s_pick
    MOV AH, 9
    INT 21H
    CALL NewLine

    LEA DX, s_picknum
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV item_no, AL

    CMP AL, 0
    JE ExitProgram

    CALL NewLine

    LEA DX, s_picked
    MOV AH, 9
    INT 21H

    MOV DL, item_no
    ADD DL, 30h
    MOV AH, 2
    INT 21H
    CALL NewLine

    LEA DX, s_quant
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h
    MOV quantity, AL
    CALL NewLine

    MOV BL, item_no
    DEC BL
    MOV BH, 0
    MOV SI, BX
    MOV CL, item_quantity[SI]
    MOV CH, quantity
    CMP CL, CH
    JGE Calculate_bill

    LEA DX, s_stock
    MOV AH, 9
    INT 21H
    CALL NewLine
    JMP Start

Calculate_bill:
    LEA DX, s_bill
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AL, item_price[SI]
    MOV BL, quantity
    MUL BL
    MOV bill, AX

    MOV AX, bill
    CALL PrintWordDecimal
    CALL NewLine

    MOV AX, 0
    MOV cash, AX

Ask_Cash:
    LEA DX, s_cash
    MOV AH, 9
    INT 21H
    CALL NewLine

    LEA DX, s_picknote
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV AH, 1
    INT 21H
    SUB AL, 30h

    CMP AL, 1
    JE ADD_20
    CMP AL, 2
    JE ADD_50
    CMP AL, 3
    JE ADD_100
    JMP Ask_Cash

ADD_20:
    MOV AX, 20
    ADD cash, AX
    JMP CHECK_BILL

ADD_50:
    MOV AX, 50
    ADD cash, AX
    JMP CHECK_BILL

ADD_100:
    MOV AX, 100
    ADD cash, AX

CHECK_BILL:
    MOV AX, cash
    CMP AX, bill
    JL Ask_Cash

    SUB AX, bill
    MOV return_cash, AX

    CMP AX, 0
    JLE DONE_PAY

    LEA DX, s_retamount
    MOV AH, 9
    INT 21H

    MOV AX, return_cash
    CALL PrintWordDecimal
    CALL NewLine

DONE_PAY:
    LEA DX, s_itemhere
    MOV AH, 9
    INT 21H
    CALL NewLine

    MOV BL, item_no
    DEC BL
    MOV BH, 0
    MOV SI, BX
    MOV AL, item_quantity[SI]
    SUB AL, quantity
    MOV item_quantity[SI], AL

    MOV AX, total_sell
    ADD AX, bill
    MOV total_sell, AX

    ; Return to main menu after purchase
    JMP ShowMainMenu

ExitProgram:
    LEA DX, s_thanks
    MOV AH, 9
    INT 21H

    MOV AX, 4C00H
    INT 21H

MAIN ENDP
END MAIN




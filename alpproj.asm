include 'emu8086.inc'  

org 100h
    mov ax,'$$'                             ; $$ is used to check for stack's fullness
    push ax                                 ;push $$ it into the stack
    xor ax,ax                               ;clearing the ax reigister 
    print 'Enter your expression:'
    mov dx,20h                              ;maximum length of the string
    mov di,offset a+10                      ;storing the value of offset in di
    call get_string                         ;getting the string from user
    printn     
    mov di,offset a+10 
    mov si,offset b                         ;This is used to store the resulting answer
    print '1.Infix->postfix'
    printn
    print '2.Infix->prefix'
    printn
    call scan_num                           ; getting user input
    mov [7000h],cl                          ; storing it
    cmp [7000h],01h                         ; comparing if it is to be converted to postfix expression
    je tadan
    cmp [7000h],02h
    jne nonerror                            ; Checking if the input is either 1 or 2
    call rere                               ; Calling the reverse expression to convert to  prefix
    mov di,offset c                     
    mov si,offset b                         ; Setting si and di after reversing
  
    tadan:
        lop:  
        xor bx,bx                           ;To clear bl
        mov ax,[di]                         ; Storing the value in ax
        mov ah,00h                          ;Clearing ah
        call is_operand                     ;Checking if it is from A-Z or a-z
        cmp bx,1                            ;bx has 1 if it is an operand
        jne brok                            ;Jumps to brok if not
        mov [si], al                        ;Stores the operand if it is valid in si
        inc si                              ;increments si
        jmp nn  

    brok:
        cmp al,'('                          ;Checks if is '('
        jne toto                            ;If not it jmups to toto
        push ax                             ;If it is '(' then it is pushed into the stack
        jmp nn                              
        
    toto:
    cmp al,')'                              ;Checks if it is ')'
    jne nope                                ;If it is not equal then it jumps to nope 
        lolo:                               ;This segment Pops everything until '(' is encountered
            pop bx
            cmp bx,'('                      ;Checks for '('
            jne loko
            jmp nope
            loko:
            cmp bx,')'
            je lq
            mov [si], bl                    ;The poped items are stores in si
            inc si                          ;si is incremented
            lq:
            jmp lolo
    nope:                                    
        call is_operator                    ; Check if [di] operator
        cmp bx,1                            ; bx is set 1 if it is an operator   
        jne nn   
        pop dx                              ;The top of the stack id poped
        call assign_weight1                 ;Function to assign weight
        call assign_weight2                
        cmp cx,bx                           ; The weights of ax and dx are stored bx and cx are compared
        jl njnj
        push ax                             ; If it is greater then it is pushed
        mov [si], dl                        ; The operator is stored in si as result
        inc si
        jmp vroom       
   njnj:  
        push dx                             ;Else both dx and ax are pudhed into the stack
        push ax 
        
  vroom:                                    ;This segment is used when a pop has occured to check the weights of the 
    pop ax                                  ;current stack top and the the item before the poped elements can be 
    pop dx                                  ;be stored in as result
    call assign_weight1
    call assign_weight2  
    cmp bx,cx                               ;The values are compared
    jne n1n                                 ;If the condition satisfies then it is stored
    mov [si], dl
    inc si
    push ax
  jmp vroom
  
  n1n:
    push dx                                 ;If the condition does not satisfy,
    push ax                                 ;ax and dx are pushed back to the stack
  
  nn:
    inc di                                  ;The di now is incremented
    cmp [di],0                              ;Checked if is equal to end of string
    jne lop
    jmp lol; 
    
  lol:                                      ;After the complete iteration of the string the rest of elements in stack are poped
    pop ax                                  ;To check end of '$$'
    cmp ax,'$$'                             
    je lole
    mov [si], al                            
    inc si
    jmp lol                                 
    lole:  
    endd:  
    printn      
    cmp [7000h],01h                         ;To check if it is infix to postfix
    jne fun
    mov si,offset b  
    call print_string                       ;If it is the same then we print the answer
    printn
    jmp exit                                ;Goto the end
 
  fun:                                      ;The below code is for postix,The result which we obtained is reversed in the below part
    mov si,offset b    
    mov di,5000H
    
  loop:                                     ;The  length of the string is calculated
    inc si
    cmp [si],00H
    jne loop
    dec si     
    mov ch,0h
    
  loop1:                                    ;The following segment is used to reverse the r=expression whic we have obtained
    mov al,[si]
    dec si
    mov [di],AL
    inc di
    inc ch
    cmp [si],00H
    jne LOOP1  
    mov cl,0h 
    mov di,5000H
    mov    ah, 0Eh   
   print:
    mov al,[di]    
    int   10h    
    inc di
    inc cl
    cmp cl,ch
    je exit
    jmp print   
    nonerror:
    print 'Invalid option'                  ;This is used as a validation
exit:
 hlt
ret          
define_get_string
define_print_string
define_scan_num

is_operand proc                             ;To check if operand
    cmp ax,'a'
    jl fal
    cmp ax,'z'
    jg fal
    mov bx,1 
    jmp ccrew
    fal:
    cmp ax,'A'
    jl ccrew
    cmp ax,'Z'
    jg ccrew
    mov bx,1                                 ;This code compared from a-z and A-Z  if it is ab operand
    ccrew:
    ret
is_operand endp

is_operator proc                            ;To check if operator
    cmp ax,'+'
    je yep 
    cmp ax,'^'                               ;The +,-,*,/,^,% are used as operators
    je yep   
    cmp ax,'%'
    je yep
    cmp ax,'-'
    je yep
    cmp ax,'*'
    je yep
    cmp ax,'/'
    je yep  
    jmp een
    mov bx,0000h
    yep:
    mov bx,0001h
    een:
    ret
is_operator endp

assign_weight1 proc 
    cmp dx,'+'                      
    jne n1                              ;The weights are assigned to compare the operators that is currently being iterated  to cx
    mov cx,0003h
    n1:
    cmp dx,'-'  
    jne n2
    mov cx,0003h
    n2:
    cmp dx,'*'
    jne n3
    mov cx,0004h
    n3:
    cmp dx,'/'
    jne n4
    mov cx,0004h 
    n4:
    cmp dx,'('
    jne n5
    mov cx,0001h   
    n5:
    cmp dx,')'
    jne n6
    mov cx,0001h 
    n6:
    cmp dx,'$$'
    jne n7
    mov cx,0001h 
    n7:
    cmp dx,'%'
    jne n8
    mov cx,0004h 
    n8:
    cmp dx,'^'
    jne eend
    mov cx,0005h
    eend:
    ret
assign_weight1 endp
 
rere proc                       ;This procedure is used to reverse the string
    mov si,offset c
    LOO:
    inc di
    cmp [di],00h
    jne LOO
    dec di
    mov ch,0h
    LOOP_1:
    mov al,[di]
    dec di
    mov [si],al
    cmp [si],'('               ;While reverding the string the ( are changed to ) and vice versa
    jne denver
    mov [si],')'
    jmp moscow
    denver:
        cmp [si],')'
        jne moscow
        mov [si],'('
    moscow:
        inc si
        inc ch  
        cmp [di],00H
        
    jne LOOP_1 
    mov cl,0h 
    mov si,5000H
    mov    AH, 0Eh    
exitu:
  ret        
rere endp

assign_weight2 proc              ;This assigns weights for elements that are poped from stack to bx
    cmp ax,'+'                   ;The priority value for values are as follow
    jne n11                      ; $$ equals ( equals ) lesser  + equals - lesser / equals *
    mov bx,0003h
    n11:
    cmp ax,'-'  
    jne n22
    mov bx,0003h
    n22:
    cmp ax,'*'
    jne n33
    mov bx,0004h
    n33:
    cmp ax,'/'
    jne n44
    mov bx,0004h 
    n44:
    cmp ax,'('
    jne n55
    mov bx,0001h   
    n55:
    cmp ax,')'
    jne n66
    mov bx,0001h 
    n66:
    cmp ax,'$$'
    jne n77
    mov bx,0001h 
    n77:
    cmp ax,'%'
    jne n88
    mov bx,0004h 
    n88:
    cmp ax,'^'
    jne eendd
    mov bx,0005h
    eendd:
    ret
assign_weight2 endp
 
	hlt
	a dw 100 dup(0)                     ;The declaration of the strings
	b db 100 dup(0) 
	c dw 100 dup(0)
	ret     
   DATA SEGMENT
   num dw 20 ;求到～的阶乘
   n dw 1 
   m dw ? ;用了多少个字来存结果
   c dw ? ;进位
   i dw ? 
   str1 db '! = $'
   DATA ENDS

   CODES SEGMENT
   ASSUME CS:CODES,DS:DATA

   main proc
 START:
        MOV      AX,DATA
        MOV      DS,AX 
        mov cx, [num]
l1: 
   push cx
   call print
   call fractor 
   mov cx,di
   routput: ;循环输出
   push cx 
   mov di,cx 
   call output
   pop cx
   dec cx
   cmp cx,0
   jge routput
   pop cx
   mov dl, 0ah
   mov ah, 2
   int 21h
   inc [n]
   loop l1
 exit:
   mov ah, 4ch
   int 21h 
   
   main endp 

   print proc near
   push ax
   push dx
   mov ax, [n]
   call disp
   mov dx, offset str1
   mov ah, 9
   int 21h
   pop dx
   pop ax
   ret
   print endp

   fractor proc near 
   mov cx,[n] ;n当前要求阶乘的数
   mov ch, 0
   mov [i], 1
   mov [m], 0 
   mov di,0
   mov si, 0
   mov word ptr [si+200h],1
l2: mov [c], 0 
   mov di,0
l3: cmp di,[m] 
   ja cmpc 
  mov si, di
  shl si, 1
   mov ax,[si+200h] 
   mov bx,[i] 
   mul bx 
   add ax,[c] 
   adc dx,0 
   mov bx,10000 
   div bx 
   mov [c],ax 
   mov [si+200h],dx 
   inc di 
   jmp l3 
 cmpc: cmp [c],0 
   jbe next 
   inc [m] 
   mov ax,[c] 
   mov [si+2+200h],ax 
 next: inc i
   cmp cx,0
   jng if0 
   loop l2
 if0: mov di,[m] 
   ret 
   
   fractor endp 

   output proc near 
    
    mov si, di
    shl si, 1
   mov bx,[si+200h] 
   cmp di, [m]
   jne shown
   mov ax, bx
   call disp
   ret
   shown: 
   mov cx,10000 
   mov ax,bx 
   mov dx,0 
   div cx 
   mov bx,dx
   mov cx,1000 
   call ddiv 
   mov cx,100 
   call ddiv 
   mov cx,10 
   call ddiv 
   mov cx,1
   call ddiv 
   ret 
   output endp 

  ddiv proc near
   mov ax,bx 
   mov dx,0 
   div cx 
   mov bx,dx 
   mov dl,al 
   add dl,30h 
   mov ah,02h 
   int 21h 
   ret
   
   ddiv endp 

   disp proc near use ax bx cx dx ;输出函数,将数字(整形，用ax传入)
        push ax
        push bx
        push cx 
        push dx
        mov cx, 0
l4:     
        mov dx, 0
        cmp ax, 10
        jb show
        mov bx, 10
        div bx
        push dx
        inc cx
        jmp l4
show:   
        push ax
        inc cx
show2:  pop dx
        add dl, 30h
        mov ah, 2
        int 21h
        loop show2
        pop dx 
        pop cx 
        pop bx 
        pop ax
        ret
disp endp

   CODES ENDS 
   END START 
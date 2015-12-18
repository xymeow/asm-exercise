data segment
	;支持有符号整型(-32768~32767)加减法
	expr db 100 dup(?), '$'
	expr2 db 100 dup(?), '$'
	showresult db 100 dup(?), '$'
	calcresult dw ? ,'$'
	str1 db 'please input an expression:',0ah,'$'
data ends

stack segment stack
 db 100 dup(?)
stack ends

code segment
assume cs:code, ds:data, ss:stack
start:
		mov ax, data
		mov ds, ax
		mov dx, offset str1
		mov ah, 9
		int 21h
		mov si, 0
		mov ah, 1
		int 21h
		cmp al, '-'
		jne l1
		mov expr[si], '0'
		inc si
l1:		mov expr[si], al
		inc si
l2:	mov ah, 1
		int 21h
		mov expr[si], al
		inc si
		cmp al, 0dh
		jne l2
		mov dl, 10
		mov ah, 2
		int 21h
		call change
		call calc
		mov ax, calcresult
		call disp
next:	mov ah, 4ch
		int 21h


change proc near
		mov ah, 0
		mov dh, 0
		mov si, 0
		mov di, 0
		push di
l3:		mov al, expr[si]
		inc si
		cmp al, '('
		je c1
		cmp al, '+'
		je c2
		cmp al, '-'
		je c3
		cmp al, ')'
		je c4
		cmp al, '0'
		jge c5
		cmp al, 0dh
		je ccc6
		jmp l3
ccc6:	mov cx, offset c6
		jmp cx
c1:		push ax	;处理（
		mov ax, 0
		push ax
		cmp expr[si], '-'
		jne l3
		mov expr2[di], '0'
		inc di
		mov expr2[di], 0
		inc di
c2:		mov bp, sp	;	处理＋
		mov dl, [bp]
		cmp dl, 1
		je cc2
		push ax
		mov dx, 1
		push dx
		jmp l3
cc2:	pop  dx
		pop bx
		mov expr2[di], bl
		inc di
		jmp c2

c3:		mov bp, sp	;处理－
		mov dx, [bp]
		cmp dl, 1
		je cc3
		push ax
		mov dx, 1
		push dx
		jmp l3
cc3:	pop dx
		pop bx
		mov expr2[di], bl
		inc di
		jmp c3

c4:		mov bp, sp	;处理 ）
		cmp byte ptr[bp], 0
		jne cc4
		pop dx
		pop ax
		jmp l3
cc4:	pop dx
		pop bx
		mov expr2[di], bl
		inc di
		jmp c4
c5:		cmp al, '9'	;处理数字
		jbe cc5
ccc5:
		mov cx, offset l3
		jmp cx
cc5:	mov expr2[di], al
		inc di
		cmp expr[si], '0' ;下一个字符
		jge cc52
		mov al, 0
		inc di
		jmp l3
cc52:	cmp expr[si], '9'
		mov al, [si]
		inc si
		jmp cc5
c6:		mov bp, sp
		cmp byte ptr[bp], 0
		jg cc6
		pop ax
		jmp default
cc6:	pop dx
		pop bx
		mov expr2[di], bl
		inc di
		jmp c6
default: mov expr2[di], 10
		ret
change endp

calc proc near
		mov si, 0
		mov di, 0
		mov ah, 0
l4:		mov al, expr2[di]
		inc di
		cmp al, 10
		je nextt
		cmp al, '+'
		je cal1
		cmp al, '-'
		je cal2
		cmp al, '0'
		jge cal3
		jmp l4
cal3:	cmp al, '9'
		jle cal31
		jmp l4
cal31:	mov cx, ax
		and cx, 000fh
		mov bl, 10
		mov ax, 0
cal32:	imul bx
		add ax, cx
		cmp expr2[di], 0
		jne cal33
		push ax
		jmp l4
cal33:	mov cl, expr2[di]
		inc di
		and cx, 000fh
		jmp cal32
cal2:	pop dx
		pop ax
		sub ax, dx
		push ax
		jmp l4
cal1:	pop dx
		pop ax
		add ax, dx
		push ax
		jmp l4
nextt:
		pop ax
		mov calcresult, ax
		ret
calc endp

disp proc near ;输出函数,将数字(整形，用ax传入)
        push ax
        push bx
        push cx 
        push dx
        mov cx, 0
        cmp ax, 0
        jge l5
        push ax
        mov dl, '-'
        mov ah, 2
        int 21h
        pop ax
        neg ax
l5:     
        mov dx, 0
        cmp ax, 10
        jb show
        mov bx, 10
        div bx
        push dx
        inc cx
        jmp l5
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

code ends
end start
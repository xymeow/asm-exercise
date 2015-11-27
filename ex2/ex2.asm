data            segment
file            db    '2.txt' , 0       ;文件名
buf             db   256 dup(0)        ;文件内容暂存区
error_message   db   0ah , 'error !' , '$'    ;出错时的提示
handle          dw  ?                ;保存文件号
sortlist        db   256 dup(0)
temp            db   10 dup(0)
digit           db   ?
resultlist      db    256 dup(0)
len          dw ?
len2         dw ?

smallist db ?
data            ends
code            segment
                assume  cs:code  , ds:data
start:
        mov ax , data
        mov ds , ax
        mov dx , offset file
        mov al , 0
        mov ah , 3dh
        int 21h                  ;打开文件
        jc error                  ;若打开出错，转error
        mov handle , ax           ;保存文件号
        mov bx , ax
        mov cx , 255
        mov dx , offset buf
        mov ah , 3fh
        int 21h                  ;从文件中读255字节→buf
        jc error                  ;若读出错，转error
        mov bx , ax              ;实际读到的字符数送入bx
        mov buf[bx] , '$'          ;在文件结束处放置一“$”符
        ; mov dx , offset buf
        ; mov ah , 9
        ; int 21h                            ;显示文件内容
        mov bx , handle
        mov ah , 3eh
        int 21h                            ;关闭文件
        ;jnc end1             ;若关闭过程无错，转到end1处返回dos
        ;对缓冲区进行处理
        ;mov di, offset sortlist
        jmp next
error:
        mov dx , offset error_message
        mov ah , 9
        int 21h 
        jmp end1

next:   mov dx, 0
        mov si, offset buf
l2:     ;
        mov cx, 10
        mov bx, offset temp
        mov al, 0
clear:  mov [bx], al
        inc bx
        loop clear
        mov di, offset temp
l3:     mov al, [si]
        inc si
        cmp al, 10
        je  b1
        cmp al, 24h
        je  stover
        mov byte ptr[di], al
        inc di
        jmp l3
b1:     mov byte ptr[di], al
        inc di
        call atoi
        ;inc dx
        jmp l2
stover: 
        mov byte ptr[di], al
        inc di
        call atoi
        ;inc dx
        mov cx, [len]
        mov [len2], cx
        mov dx, 0
        ;mov [smallist], 255
       ; mov di, offset resultlist
        sub [len], 1
        sub cx, 1
        mov si, offset sortlist
       ; add si, dx
sort:   mov [len], cx
        mov di, si
        inc di
sort1:  mov ah, byte ptr[si]
        mov al, byte ptr[di]
        cmp ah, al
        jbe small
        mov byte ptr[si], al
        mov byte ptr[di], ah
small:  inc di
        loop sort1
        mov cx, [len]
        inc si
        loop sort
        ;inc si
; s1:     mov al, byte ptr[si]
;         inc si
;         cmp al, [smallist]
;         jb small
;         jae big
; small:  mov [smallist], al
; big:    loop s1
;         mov al, [smallist]
;         mov [di], al
;         inc di
;         inc dx
;         sub [len], 1
;         mov cx, [len]
;         loop sort
        ;
        mov cx, [len2]
        mov si, offset sortlist
print:  mov al, [si]
        inc si
        call disp
        loop print
        jmp end1
                           ;显示错误提示
end1:
        mov ah , 4ch
        int 21h

atoi proc near use ax bx si di
        push ax
        push bx
        push si
        push di 
        mov bx, 0
        mov ax, 0
        mov si, offset temp
        mov di, offset sortlist
        add di, [len]
l1:     mov al, [si]
        inc si
        cmp al, 10
        je  back
        cmp al, 24h
        je back
        sub al, 30h
        mov [digit], al
        mov ax, 10
        mul bx
        mov bx, ax
        add bx, [digit]
        jmp l1
back:   mov ax, bx
        mov [di], ax
        add [len], 1
        pop di
        pop si 
        pop bx 
        pop ax 
        ret
atoi endp

disp proc near use ax bx cx dx
        push ax
        push bx
        push cx 
        push dx
        mov cx, 0
l4:     mov ah, 0
        mov dx, 0
        cmp al, 10
        jb show
        mov bx, 10
        div bx
        push dx
        inc cx
        jmp l4
show:   
        mov bl,al
        mov bh,0
        push bx
        inc cx
show2:  pop dx
        add dl, 30h
        mov ah, 2
        int 21h
        loop show2
        mov dl, 10
        mov ah, 2
        int 21h
        pop dx 
        pop cx 
        pop bx 
        pop ax
        ret
disp endp

code   ends
            end  start

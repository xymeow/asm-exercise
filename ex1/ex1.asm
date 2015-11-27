
data segment
data1 db 36 dup(?)
blank db ' '
output db 2 dup(?),'$'
times db 1
i db 0
data ends

code segment
	assume cs:code, ds:data
start:
	mov ax, data
	mov ds, ax
	mov cx, 36
	mov ax, 1
	mov bx, offset data1
l1:
	mov [bx], ax 
	inc al
	inc bx
	loop l1

	;mov cx, 36
	mov cl, [times]
	mov bx, offset data1
show:
	mov al, [bx]
	call disp
	inc bx
	mov dl, [blank]
	call dispascii
	loop show
	mov dl, 10
	call dispascii
	add [i], 6
	mov bl, [i]
	add bl, offset data1
	add [times], 1
	mov cl, [times]
	cmp cl, 6
	jbe show
	int 21h

disp proc near
	mov ah, 0
	add ax, 0
	call toascii
	cmp ah, 0
	je digit
	add ax, 2000h
digit:	add ax, 1030h
	mov [output], ah
	mov [output+1], al
	mov dx, offset output
	mov ah, 9
	int 21h
	mov ah, 4ch
	ret
disp endp

dispascii proc near
	mov ah, 2
	int 21h
	mov ah, 4ch
	ret
dispascii endp

toascii proc near
	mov ah, 0
l3:	cmp al, 10
	jb complete
	sub al, 10
	add ah, 1
	jmp l3
complete:
	ret
toascii endp

code ends
end start


	


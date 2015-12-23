.386
.387
.model flat, stdcall
option casemap :none   

include	\masm32\include\windows.inc
include	\masm32\include\user32.inc
include	\masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\msvcrt.lib
includelib	\masm32\lib\kernel32.lib
includelib	\masm32\lib\user32.lib

.const
res db 'the result is %lf',0
error db 'Error: x < 0 !',0
scan db '%f%f%f%f',0
inputs db 'please input x, a1, a2, a3',10,0

.data
x dd ?
x2 dd ?
a1 dd ?
a2 dd ?
a3 dd ?
result dq ?
xlge dq ?
temp dq ?
temp2 dq ?
temp3 dq ?

.code
start:
invoke crt_printf, addr inputs
invoke crt_scanf, addr scan, addr x, addr a1, addr a2, addr a3

call compute

invoke	ExitProcess,NULL

compute proc near
	mov eax, x
	mov x2, eax
	fld x
	fldz
	fcompp 
	fnstsw ax
	sahf
	jbe el
err:
		invoke crt_printf, addr error
		ret
el:
		fld x
		fsqrt
		fmul a1
		fstp result
		fld x
		fldz
		fcompp 
		fnstsw ax
		sahf
		jne l1
		fld1
		jmp l2
l1:		
		fldl2e
		fmul x
		fst xlge
		frndint
		fstp temp2
		fld temp2
		fld xlge
		fsub ST(0), ST(1)
		fst temp3
		ftst
		fnstsw ax
		sahf
		jb nega
		;>0, st0 = frac st1 = int
		f2xm1
		fld1
		fadd ST(0), ST(1)
		fstp temp
		fcomp
		fld temp
		fscale 
		fstp temp
		fcomp
		fld temp
		jmp l2
nega:   
		fld1
		fadd ST(0), ST(1);st0 = frac
		fstp temp
		fcomp
		fld1
		fsub ST(1), ST(0)
		fcomp
		fld temp
		f2xm1
		fld1
		fadd ST(0), ST(1)
		fstp temp
		fcomp
		fld temp
		fscale
		fstp temp
		fcomp
		fld temp
l2:
		fmul a2
		fld result
		fadd ST(0), ST(1)
		fstp result
		fcomp
		fld x
		fsin
		fmul a3
		fld result
		fadd ST(0), ST(1)
		fstp result
		fcomp
		invoke crt_printf, addr res, result
		ret
compute endp
end start
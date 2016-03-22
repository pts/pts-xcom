;
; xcom.nasm v2.2
; by pts@fazekas.hu (EP/PSW, Hungary) on 1996-09-10
;
; Compile with: nasm -f bin -o xcom.com xcom.nasm
;
; Usage (on DOS):
;
;   xcom - <original.com >ascii.com
;   xcom -- <original.dat >ascii.dat
;   xcom <ascii.dat >original.dat
;   xcom <ascii.com >original.com
;

	org 100h

%define ide_len 128
%define count byte[80h]
%define offset

; These definitions ensure exact same binary output as of a86.
%define xor_bp_bp db 33h, 0EDh  ; xor bp,bp
%define xor_bx_bx db 33h, 0DBh  ; xor bx,bx
%define add_bp_ax db 03h, 0E8h  ; add bp,ax
%define xor_cx_cx db 33h, 0C9h  ; xor cx,cx
%define xor_dx_dx db 33h, 0D2h  ; xor dx,dx
%define mov_ax_dx db 8Bh, 0C2h  ; mov ax,dx
%define mov_ax_di db 8Bh, 0C7h  ; mov ax,di
%define mov_cx_di db 8Bh, 0CFh  ; mov cx,di
%define mov_dx_ax db 8Bh, 0D0h  ; mov dx,ax
%define mov_dx_cx db 8Bh, 0D1h  ; mov dx,cx
%define mov_si_cx db 8Bh, 0F1h  ; mov si,cx


start:	xor_bp_bp
	mov al, count
	cmp al, 0
	jne starte
	jmp near startb
starte:	cmp al, 2
	je starta			;make .COM file there

	mov word[offset l3], 9090h	;replace "ja l1" by two "nop"s
	jmp l1				;skip header

;-----------------------------------------------------------------------------
; acom.8
; by pts@fazekas.hu (EP/PSW, Hungary) on 1996-09-10
;-----------------------------------------------------------------------------

starta:	mov ah, 40h			;stdout
	mov bx, 1
	mov cx, ide_len		;+CRLF
	mov dx, offset ide
	int 21h
	jc e1

l1:	mov ah, 3Fh
	xor_bx_bx			;stdin
	mov cx, 4000h			;16384
	mov_dx_cx			;[ds:4000h]
	mov si, dx
	int 21h
	jc e1
	mov cx, ax
	jcxz e2				;eof
	add_bp_ax
	mov al, 255
	cmp bp, 42666
l3:	ja e1				;File too long
	mov di, 8000h
	inc cx
	shr cx, 1
		
l2:	lodsw
	mov_dx_ax
	shr ax, 12
	and al, 63
	add al, 63
	call incj
	mov_ax_dx
	shr ax, 6
	and al, 63
	add al, 63
	call incj
	mov_ax_dx
	and al, 63
	add al, 63
	call incj
	loop l2

	mov ah, 40h
	mov bx, 1			;stdout
	mov_cx_di
	mov dx, 8000h
	sub cx, dx
	int 21h
	jc e1
	jmp short l1

incj:	stosb
i2:	mov_ax_di
	and ax, 3FFFh
	mov bh, 80			;Max 16K buffer!
	div bh
	cmp ah, 78
	jne i1
	mov ax, 0A0Dh			;CRLF
	stosw
i1:	ret

;-----------------------------------------------------------------------------
;?com.8 Common Error/Exit routine
;-----------------------------------------------------------------------------

e1:	push ax
	mov al, 7
	int 29h				;Beep
	pop ax
e2:	mov ah, 4Ch
	int 21h				;Exit to OS
	
;-----------------------------------------------------------------------------
; bcom.8
; by pts@fazekas.hu (EP/PSW, Hungary) on 1996-09-10
;-----------------------------------------------------------------------------

startb:	mov count, 3

	mov ah, 7			;read stdin in AL
	int 21h
	cmp al, '&'
	je k2

	mov ax, 4200h			;Ignore first char read
	xor_bx_bx
	xor_cx_cx
	xor_dx_dx
	int 21h
	jmp word k1

k2:	mov ah, 3Fh
	xor_bx_bx			;stdin
	mov cx, ide_len-1
	mov dx, 8000h
	int 21h
	jc e1

k1:	mov ah, 3Fh
	xor_bx_bx			;stdin
	mov cx, 4000h			;16384 (divisible by 3)
	mov_dx_cx
	mov_si_cx
	int 21h
	jc e1
	mov cx, ax
	jcxz e2				;eof
	mov di, 8000h

	mov ah, 0	
k0:     lodsb
        sub al, 63
        jc k0c
	call send
k0c:	loop k0

	mov ah, 40h
	mov bx, 1			;stdout
	mov dx, 8000h
	mov_cx_di
	sub cx, dx
	int 21h
	jc e1
	jmp short k1

send:	shl bp, 6
	add_bp_ax
	dec count
	jnz s1
	mov count, 3
	mov [di], bp
	inc di
	inc di
s1:	ret

;-----------------------------------------------------------------------------
; try.com 128-byte self-decoder routine
; by pts@fazekas.hu (EP/PSW, Hungary) on 1996-09-10
;-----------------------------------------------------------------------------

ide:	db '&XPZ,2P_0E[0E_,pP[,Eu',13,10
	db 'R^!5+1+1CC+1)5GGHu#PWtl6~!ugH"!rE"!~~0B(m"!4r!!Y~!)E~"0~~Cump!!|d',13,10
	db '~E)!~~0B(m"!pq!"G0!!oD!"B~"v_Q"! PSW',13,10

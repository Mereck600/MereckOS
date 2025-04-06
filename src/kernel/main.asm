org 0x7c00 ;this is the address where the bios puts the os 
;Directive give a clue to the assembler that will affect how the program gets compiled
;instruction translated to machine code that the cpu will execute
bits 16 ; emit 16bit code so it can be backwards compatible start on 16 bit and can move up to 64
;refrencing a mem location
;segment:[base +index *scale(num constants only in 32/64 bit modes 1,2,4,8)+displacement(any int const)]
;var; dw 100
; move ax,var ;cpoy offset to ax
; mov ax, [var] ;copy memory contents

;;array 3rd elm
;array: dw 100,200,300
; mov bx, array ;copy offset to ax
; mov si,2*2 ;array[2], words are 2 bytes wide
; mov ax, [bx+si] ; copy memory contents

%define ENDL 0x0D,0x0A ;setting macro for endline 

start:
	jmp main ;since func above main we need to jump to main

;prints a string to the screen
; Params:
;	- ds:si points to a string prints until a null char

puts:
	;save registers we will modify
	push si
	push ax

.loop:
	lodsb 		 ;loads the next character in al
	or al,al ;verify if next char is null 
	jz .done
	

	mov ah,0x0e ; moves from source to destination
	mov bh,0
	int 0x10
	jmp .loop	
; interupts are a signal wich makes the processor stop to handle sig
; can be triggerd by exception
; or hardware
;or software 0-255 using INT 10h --video 


.done:
	pop ax
	pop si
	ret ;return



main:

	;setup data segments
	mov ax, 0
	mov ds, ax
	mov es,ax

	;setup stack
	mov ss, ax
	mov sp, 0x7c00 ;stack grows downwards in memory fifo push pop sp=stackpointe


	;print message
	mov si,msg_hello
	call puts
	
	hlt
.halt:
	JMP .halt ;so that we dont hit infinite loop 

msg_hello: db  'Hello World!',ENDL,0
times 510-($-$$) db 0
dw 0AA55h

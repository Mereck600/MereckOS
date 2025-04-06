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



#
# FAT12 header
#
jmp short start
no op

bdb_oem:	db 'MSWIN4.1' ;8 bytes
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count:	db 2
bdb_dir_entries_count: dw 0E0h 
bdb_total_sectors: dw 2880  ; 288-*512 =1.44mb
bdb_media_descriptor_type: db 0F0h ; F0 = 3.5*floppy disk
bdb_sectors_per_fat: dw 9 ;9 sectors/fat
bdb_heads: 	dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

# extended boot sector
ebr_drive_number: 	db 0
					db 0 ;reserved
ebr_signature: 		db 29h 
ebr_volume_id:		db 12h, 34h, 56h, 78h ;serial num
ebr_volume_label: 	db 'MERECK OS O' ;;11 bytes padded with spaces



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

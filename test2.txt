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



;
; FAT12 header
;
jmp short start
nop

bdb_oem:	db 'MSWIN4.1' ;8 bytes
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_fat_count:	db 2
bdb_dir_entries_count: dw 0E0h 
bdb_total_sectors: dw 2880  ; 288-*512 =1.44mb
bdb_media_descriptor_type: db 0F0h ; F0 = 3.5*floppy disk
bdb_sectors_per_fat: dw 9 ;9 sectors/fat
bdb_sectors_per_track: dw 18
bdb_heads: 	dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

; extended boot sector
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


	;read something from floppy disk
	; BIOS SHOULD SET drive number to dl
	mov [ebr_drive_number],dl
	mov ax,1 ;lba=1 second sector from disk
	mov cl,1 ; 1 sector to read
	mov bx,0x7E00 ; data should be after the bootloader
	call disk_read


	;print message
	mov si,msg_hello
	call puts
	
	cli
	hlt
;.halt:
;	JMP .halt ;so that we dont hit infinite loop 



;
;Disk routines
;
;
; converts an LBA address to a CHS address
; parameters:
; -ax: LBA address
; returns
;	- cx (bits 0-55): sectors number
;	- cx (bits 6-15): cylinder
;	- dh: head


;
;Error handlers
;
floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot
	

wait_key_and_reboot:
	mov ah, 0
	int 16h ;wait for key press
	jmp 0FFFFh:0 ;jump to begining of BIOS, should reboot 
		
.halt:
	cli ;disable interupts so we cant get out of halt state
	hlt ; hope this works 

lba_to_chs:
	push ax
	push dx
	xor dx,dx ;dx =0
	div word [bdb_sectors_per_track] ; ax = lba /sectorspertrack
									; dx = lba % sectorsPerTrack

	inc dx ; dx = lba % sectors per track +1 = sector 
	xor dx,dx ;dx=0
	div word [bdb_heads] ; ax = [lba /sectorsPerTrack ]/heas = cylinders
							; dx =[lba/sectorspertrack]%heads = headv
	mov dh,dl ; dh=head
	mov ch,al ; ch = cylinder (lower 8 bits)
	shl ah, 6 
	or cl,ah ;put upper 2 bits of cylinder in cl

	pop ax
	mov dl, al
	pop ax
	ret


;
;reads form a disk
;
; parameters:
; ax: lba address
; cl: number of sectors to read up to 128
; dl: drive number
; es:bx memory address where to store read data

disk_read:
	push ax ;save registers we will modify
	push bx
	push cx
	push di

	push cx ; temp save cl number of secotrs to read
	call lba_to_chs
	pop ax
	
	mov ah, 02h
	mov di, 3

; in real life need to loop 3 times cus floppys are ass

.retry:
	pusha ; save all regs we dont know what bios modifies
	stc ;set carry flag some bios dont set it 
	int 13h ; carry flag cleared = success
	jnc .done ; jump if carry not set 

	;read failed
	popa
	call disk_reset

	dec di
	test di,di
	jnz .retry

.fail:
	; all attempsts failes
	jmp floppy_error

.done:
	popa

	pop di ;restoe registers we will modify
	pop dx
	pop cx
	pop bx
	pop ax
	ret 

;
;resets disk controller
;parametersL
;	dl :drive number
;
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa
	ret

	







msg_hello: db  'Hello World!',ENDL,0
msg_read_failed: db 'Read from disk failed!', ENDL, 0
times 510-($-$$) db 0
dw 0AA55h

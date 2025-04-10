bits 16

section _TEXT class=CODE
;CDECL calling convention
; Arguments: passed through stack, pushed from right to left, caller removes parameters from stack
; return:integers, pointers:EAX, floatingpoint:ST0, 
; registers: EAX,ECX, EDX saved by caller, all others saved by callee
; Name mangling: C functions are prepended with a _
; look at wikipedia if confused 

;
;int 10h ah =0Eh
;args: character, page
;

global x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    ; make nrew cal frame
    push bp ;save old call fram
    mov bp,sp ;init new call frame

    ;save bx
    push bx


    ;[bp+0] - return address (small memory model => 2bytes)
    ; [bp+2] - first argument (character) bytes are converted to words(cant push a single byte onto stack)
    ; [bp+4] - second argumet (page)
    ; again note bytes are converted to words (cant push a byte)
    mov ah,0Eh
    mov al, [bp+2]
    mov bh, [bp+4]

    int 10h
    ; restore bx
    pop bx

    ;Restore the old call frame
    mov sp,bp
    pop bp
    ret


    



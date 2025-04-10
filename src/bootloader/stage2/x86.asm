bits 16

section _TEXT class=CODE

global x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
;CDECL calling convention
; Arguments: passed through stack, pushed from right to left, caller removes parameters from stack
; return:integers, pointers:EAX, floatingpoint:ST0, 
; registers: EAX,ECX, EDX saved by caller, all others saved by callee
; Name mangling: C functions are prepended with a _
; look at wikipedia if confused 


; =========================================================
; Program 1: Vector add without ADDV
; Computes: a[i] = a[i] + b[i], for i = 1 ... n
;
; Assumed input registers:
;   R1 = base address of a
;   R2 = base address of b
;   R3 = n
;
; Register usage:
;   R4 = loop counter
;   R5 = a[i]
;   R6 = b[i]
;   R7 = sum
; =========================================================

        INC   R4, R3, 0        ; R4 = n

LOOP:
        BRZ   R4               ; if R4 == 0, go to DONE

        LD    R5, R1           ; R5 = M[R1] = a[i]
        LD    R6, R2           ; R6 = M[R2] = b[i]
        ADD   R7, R5, R6       ; R7 = a[i] + b[i]
        ST    R7, R1           ; M[R1] = R7

        INC   R1, R1, 1        ; move to next a element
        INC   R2, R2, 1        ; move to next b element
        INC   R4, R4, -1       ; counter--

        J     LOOP

DONE:
        NOP
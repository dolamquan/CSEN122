; =========================================================
; Program 2: Vector add with ADDV
; Computes: a[i] = a[i] + b[i], for i = 1 ... n
;
; Assumed input registers:
;   R1 = base address of a
;   R2 = base address of b
;   R3 = n
;
; Register usage:
;   R4 = n - 1
; =========================================================

        INC   R4, R3, -1       ; R4 = n - 1
        ADDV  R4, R1, R2       ; vector add
        NOP
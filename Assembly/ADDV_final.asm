; =========================================================
; Vector Addition Loop (Without ADDV)
; =========================================================
; Register usage:
;   R4  = Loop counter (starts at -n, increments to 0)
;   R5  = a[i] (temporary load)
;   R6  = b[i] (temporary load)
;   R7  = sum (a[i] + b[i])
;   R10 = Loop target PC address
; =========================================================
        NEG   R4, R3           ; R4 = -n (loop counter, counting up to 0)
        SVPC  R10, 1           ; R10 = PC + 1 = 2 (address of LOOP)
LOOP:
        LD    R5, R1           ; R5 = M[R1] = a[i]
        LD    R6, R2           ; R6 = M[R2] = b[i]
        NOP                    ; Load-use hazard delay slot for R6
        ADD   R7, R5, R6       ; R7 = a[i] + b[i]
        ST    R7, R1           ; M[R1] = R7 (a[i] = R7)
        INC   R1, R1, 1        ; Move to next element in array a
        INC   R2, R2, 1        ; Move to next element in array b
        INC   R4, R4, 1        ; Increment loop counter
        NOP                    ; Branch flag hazard delay slot 1
        NOP                    ; Branch flag hazard delay slot 2
        BRN   R10              ; Branch to LOOP (R10) if R4 < 0
DONE:
        NOP                    ; Program ends

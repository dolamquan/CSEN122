# ============================================================
# Vector Addition without ADDV
# a[i] = a[i] + b[i], for i = 0 to n - 1
# ============================================================
#
# Assumptions:
#   x0  = 0
#   x1  = base address of array a
#   x2  = base address of array b
#   x3  = n
#   x4  = LOOP address
#   x5  = DONE address
#   x6  = temporary a[i]
#   x7  = temporary b[i]
#   x8  = sum
#   x9  = loop counter
#   x10 = temporary for unconditional branch
# ============================================================

        ADD     x9, x3, x0          # x9 = n

        SVPC    x4, LOOP_OFFSET     # x4 = LOOP address
        SVPC    x5, DONE_OFFSET     # x5 = DONE address

LOOP:
        LD      x6, x1              # x6 = Mem[x1] = a[i]
        NOP
        NOP

        LD      x7, x2              # x7 = Mem[x2] = b[i]
        NOP
        NOP

        ADD     x8, x6, x7          # x8 = a[i] + b[i]
        NOP
        NOP

        ST      x8, x1              # Mem[x1] = x8

        INC     x1, x1, 1           # x1 = x1 + 1, next a element
        INC     x2, x2, 1           # x2 = x2 + 1, next b element
        INC     x9, x9, -1          # x9 = x9 - 1

        NOP
        NOP

        BRZ     x5                  # if x9 == 0, branch to DONE

        INC     x10, x0, 1          # x10 = 1
        NEG     x10, x10            # x10 = -1, sets Negative flag

        NOP
        NOP

        BRN     x4                  # unconditional branch to LOOP

DONE:
        NOP
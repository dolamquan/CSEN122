# ============================================================
# Demo assembly for current working testbench
# ============================================================

# Label addresses:
# LABEL1 = 15
# SKIP1  = 21
# LABEL2 = 31
# SKIP2  = 37

# Since SVPC does:
# xrd = PC + immediate
#
# These offsets are used:
# PC 1: x10 = 1 + 14 = 15
# PC 2: x11 = 2 + 29 = 31
# PC 3: x12 = 3 + 18 = 21
# PC 4: x13 = 4 + 33 = 37

0:  SVPC x1, 100        # x1 = 100
1:  SVPC x10, 14        # x10 = LABEL1 = 15
2:  SVPC x11, 29        # x11 = LABEL2 = 31
3:  SVPC x12, 18        # x12 = SKIP1  = 21
4:  SVPC x13, 33        # x13 = SKIP2  = 37

5:  NOP
6:  NOP

7:  INC x2, x1, 4       # x2 = x1 + 4 = 104
8:  NEG x3, x1          # x3 = -x1 = -100

9:  NOP
10: NOP

11: BRN x10             # branch to LABEL1 because previous Neg = 1
12: NOP
13: NOP
14: INC x2, x2, 17      # should not execute

LABEL1:
15: ADD x4, x1, x2      # x4 = 100 + 104 = 204

16: NOP
17: NOP

18: BRN x12             # should not branch because previous Neg = 0
19: NOP
20: INC x4, x4, 6       # x4 = 210

SKIP1:
21: ST x1, x1           # Mem[x1] = x1, so Mem[100] = 100
22: NOP

23: LD x5, x1           # x5 = Mem[x1] = Mem[100] = 100
24: NOP
25: NOP

26: ADD x6, x1, x2      # x6 = 100 + 104 = 204
27: SUB x7, x5, x1      # x7 = 100 - 100 = 0

28: NOP
29: NOP

30: BRZ x11             # branch to LABEL2 because previous Zero = 1

LABEL2:
31: ADD x8, x1, x2      # x8 = 100 + 104 = 204

32: NOP
33: NOP

34: BRZ x13             # should not branch because previous Zero = 0
35: NOP
36: INC x8, x8, 10      # x8 = 204 + 10 = 214

SKIP2:
37: INC x9, x1, -5      # x9 = 100 - 5 = 95
38: NOP
39: NOP

40: JM x1               # PC = Mem[x1] = Mem[100] = 100

# At instruction memory address 100:
100: JM x1              # keeps jumping to address stored in Mem[100]
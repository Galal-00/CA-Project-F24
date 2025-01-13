
.ORG 0  #this is the reset address
200

.ORG 1  #this is the address of the empty stack exception handler
400

.ORG 2  #this is the address of the invalid memory address exception handler
600

# for those who are implementing the bonus (dynamic vector table):
.ORG 3  #this is the address of INT0
800

.ORG 4  #this is the address of INT1
0A00

# for those who are implementing the bonus (dynamic vector table):
# .ORG 3
# 100
# .ORG 100
# 800
# 0A00

# Empty Stack Exception Handler
.ORG 400
    LDM R0,FFFF
    JMP R0          # Causes Invalid Memory Address Exception
    HLT             # Should not be executed

# Invalid Memory Address Exception Handler
.ORG 600
    LDM R0,ABCD
    HLT             # Should be executed, End of testcase :)

# INT0
.ORG 800
    LDM R0,2
    LDM R1,0
    SUB R1,R1,R0
    LDM R2,809      # Address of the JZ
    LDM R3,80C      # Address of the RTI
    JZ R3           # For loop that should execute 2 times
    INC R1,R1
    JMP R2
    RTI

# INT1
.ORG 0A00
    LDM R0,1
    LDM R1,2
    LDM R2,0A08      # Address of the JN
    LDM R3,0A0B      # Address of the RTI
    JN R3            # For loop that should execute 3 times
    SUB R1,R1,R0
    JMP R2
    RTI

# Main loop
.ORG 200
    LDM R0,300
    CALL R0
    SETC            # Should be preserved
    INT 0
    INT 1
    LDM R0,300
    JC R0           # Should be executed and succeed
    HLT             # Should not be executed
	
# Function
.ORG 300
    LDM R5,313      # RET address
    LDM R6,300      # Start of function address
    LDM R0,5        # Some Value
    PUSH R0
    LDM R1,A0
    LDM R4,A5
    POP R2
    STD R2,5(R1)    # Load-use here
    LDD R3,0(R4)
    SUB R0,R0,R3    # Should be zero
    JZ R5           # Should be executed and succeed
    JMP R6          # Should not be executed
    RET             # Executes normally first time, then causes empty stack exception the second time

import re
import os
from enum import Enum

opcode_dict = {
        'NOP': '00000', 'HLT': '00001', 'SETC': '00010', 'NOT': '00011', 'INC': '00100', 'OUT': '00101', 'IN': '00110',
        'MOV': '00111', 'ADD': '01000', 'SUB': '01001', 'AND': '01010', 'IADD': '01011',
        'PUSH': '01100', 'POP': '01101', 'LDM': '01110', 'LDD': '01111', 'STD': '10000',
        'JZ': '10001', 'JN': '10010', 'JC': '10011', 'JMP': '10100', 'CALL': '10101', 'RET': '10110', 'INT': '10111', 'RTI': '11000'
    }

class InstructionFormat(Enum):
        OPCODE = 0
        RSRC1 = 1
        RSRC2 = 2
        RDST = 3
        IMMEDIATE = 4
        INDEX = 5

class Instruction:
    def __init__(self, opcode, operands):
        self.opcode = opcode
        self.operands = operands
        
    def __str__(self):
        return f"{self.opcode} {', '.join(self.operands)}"
    
    def __repr__(self):
        return str(self)
    

ISA = {
    # Zero-operand instructions
    'NOP': Instruction(opcode_dict['NOP'], []),
    'HLT': Instruction(opcode_dict['HLT'], []),
    'SETC': Instruction(opcode_dict['SETC'], []),
    'RET': Instruction(opcode_dict['RET'], []),
    'INT': Instruction(opcode_dict['INT'], [InstructionFormat.INDEX]),
    'RTI': Instruction(opcode_dict['RTI'], []),

    # One-operand instructions
    'OUT': Instruction(opcode_dict['OUT'], [InstructionFormat.RSRC1]),
    'IN': Instruction(opcode_dict['IN'], [InstructionFormat.RDST]),
    'PUSH': Instruction(opcode_dict['PUSH'], [InstructionFormat.RSRC1]),
    'POP': Instruction(opcode_dict['POP'], [InstructionFormat.RDST]),
    'JZ': Instruction(opcode_dict['JZ'], [InstructionFormat.RSRC1]),
    'JN': Instruction(opcode_dict['JN'], [InstructionFormat.RSRC1]),
    'JC': Instruction(opcode_dict['JC'], [InstructionFormat.RSRC1]),
    'JMP': Instruction(opcode_dict['JMP'], [InstructionFormat.RSRC1]),
    'CALL': Instruction(opcode_dict['CALL'], [InstructionFormat.RSRC1]),

    # Two-operand instructions
    'NOT': Instruction(opcode_dict['NOT'], [InstructionFormat.RDST, InstructionFormat.RSRC1]),
    'INC': Instruction(opcode_dict['INC'], [InstructionFormat.RDST, InstructionFormat.RSRC1]),
    'MOV': Instruction(opcode_dict['MOV'], [InstructionFormat.RDST, InstructionFormat.RSRC1]),

    # Three-operand instructions
    'ADD': Instruction(opcode_dict['ADD'], [InstructionFormat.RDST, InstructionFormat.RSRC1, InstructionFormat.RSRC2]),
    'SUB': Instruction(opcode_dict['SUB'], [InstructionFormat.RDST, InstructionFormat.RSRC1, InstructionFormat.RSRC2]),
    'AND': Instruction(opcode_dict['AND'], [InstructionFormat.RDST, InstructionFormat.RSRC1, InstructionFormat.RSRC2]),

    # Immediate instructions
    'IADD': Instruction(opcode_dict['IADD'], [InstructionFormat.RDST, InstructionFormat.RSRC1, InstructionFormat.IMMEDIATE]),
    'LDM': Instruction(opcode_dict['LDM'], [InstructionFormat.RDST, InstructionFormat.IMMEDIATE]),
    'LDD': Instruction(opcode_dict['LDD'], [InstructionFormat.RDST, InstructionFormat.IMMEDIATE, InstructionFormat.RSRC1]),
    'STD': Instruction(opcode_dict['STD'], [InstructionFormat.RSRC1, InstructionFormat.IMMEDIATE, InstructionFormat.RSRC2]),

    }
       

def parse_line(line):
    """Parse a single line and return its type and content."""
    line = line.split('#')[0].strip()  # Remove comments and whitespace and indentation
    if not line:
        return None, None  # Ignore empty lines
    if line.startswith('.ORG'):
        return 'ORG', int(line.split()[1], 16)  # Extract address
    return 'INSTRUCTION', line


def parse_file(file):
    """Parse a file and return a list of tuples with the type and content of each line."""
    with open(file) as f:
        return [parse_line(line) for line in f if parse_line(line)[0] is not None] 

# Function to convert instruction to opcode
def instruction_to_opcode(content):
    instruction = content.split()[0]
    return opcode_dict.get(instruction, 'UNKNOWN')

def operand_to_binary(operand):
    if operand.startswith('R'):
        operand = re.sub(r'[\,\(\)]', '', operand)
        return format(int(operand[1:]), '03b')
    return format(int(operand, 16), '016b')

ORG = 0
def assemble(parsed_line):
    """
    Assemble a parsed line into machine code.
    Returns a tuple of (is_immediate, machine_code) where:
    - is_immediate: boolean indicating if this instruction has an immediate value
    - memory: 16-bit or 32-bit binary string depending on instruction type
    """
    line_type, content = parsed_line
    global ORG
    if line_type == 'ORG':
        ORG = content
        return False, None
    
    # Split instruction into parts
    parts = content.split()
    instruction = parts[0]
    if re.match(r'^[0-9][0-9A-F]*$', instruction, re.IGNORECASE):
        machine_code =  f"{int(ORG)}: {format(int(instruction, 16), '016b')}"
        ORG += 1
        return False, machine_code
    operands = parts[1:]
    operands = re.split('[,()]', ' '.join(operands)) if operands else []
    operands = [op.strip() for op in operands if op.strip()]
    
    # Get instruction format from ISA
    if instruction not in ISA:
        raise ValueError(f"Unknown instruction: {instruction}")
    
    inst_format = ISA[instruction]
    opcode = inst_format.opcode
    
    # Initialize register fields with zeros
    rsrc1 = '000'
    rsrc2 = '000'
    rdst = '000'
    extra = '00'
    
    # Convert operands based on instruction format
    has_immediate = False
    immediate = ''
    
    for i, format_type in enumerate(inst_format.operands):
        if i >= len(operands):
            break
            
        if format_type == InstructionFormat.RSRC1:
            rsrc1 = operand_to_binary(operands[i])
        elif format_type == InstructionFormat.RSRC2:
            rsrc2 = operand_to_binary(operands[i])
        elif format_type == InstructionFormat.RDST:
            rdst = operand_to_binary(operands[i])
        elif format_type == InstructionFormat.INDEX:
            extra = format(int(operands[i]), '02b')
        elif format_type == InstructionFormat.IMMEDIATE:
            has_immediate = True
            immediate = operand_to_binary(operands[i])
    
    # Construct the machine code
    machine_code = str(ORG) + ': ' + opcode + rsrc1 + rsrc2 + rdst + extra
    ORG += 1
    if has_immediate:
        # For instructions with immediate values, return 32-bit instruction
        machine_code += ',' + str(ORG) + ': '+ immediate
        ORG += 1
        return True, machine_code
    else:
        # For regular instructions, return 16-bit instruction
        return False, machine_code

def output_to_file(file_path, machine_code):
    header = """// memory data file (do not edit the following line - required for mem load use)
// instance=/dm/memory
// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1
"""
    with open(file_path, 'w') as f:
        f.write(header + '\n')
        memory = ['0' * 16] * 4096  # Initialize memory with zeros
        for line in machine_code.split('\n'):
            if line:
                address, code = line.split(': ')
                memory[int(address)] = code
        for i, line in enumerate(memory):
            f.write(f"{i:4}: {line}\n")

if __name__ == '__main__':
    # print debug

    file_path = 'Assembler/asm_example.asm'
    if os.path.exists(file_path):
        parsed_lines = parse_file(file_path)
        
        # for line_type, content in parsed_lines:
        #     if line_type is not None and content is not None:
        #         print(line_type, content)
        
        # Print the opcode for each instruction
        # for line_type, content in parsed_lines:
        #     if line_type == 'INSTRUCTION':
        #         parts = content.split()
                
        #         instruction = parts[0]
        #         opcode = instruction_to_opcode(content)

        #         operands = parts[1:]
        #         operands = re.split('[,()]', ' '.join(operands)) if operands else []
        #         operands = [op.strip() for op in operands if op.strip()]
        #         if operands:
        #             operands = [operand_to_binary(operand) for operand in operands]
        #         print(f"instruction: {instruction}, opcode: {opcode}, operands: {operands}")
        #     elif line_type == 'ORG':
        #         print(f"ORG: {content}")
        # Print the assembled machine code
        output_list = []
        for parsed_line in parsed_lines:
            is_immediate, machine_code = assemble(parsed_line)
            line_type, content = parsed_line
            if line_type == 'INSTRUCTION':
                parts = content.split()
                instruction = parts[0]
                print(f"{line_type}: {content}")
            else:
                print(f"{line_type}: {content}")
            if (machine_code):
                if is_immediate:
                    parts = machine_code.split(',')
                    for part in parts:
                        print(f"{part.strip()}")
                        output_list.append(part.strip())
                else:
                    print(f"{machine_code}")
                    output_list.append(machine_code)
        output_to_file('Assembler/asm_example.mem', '\n'.join(output_list))


    else:
        print(f"Error: The file '{file_path}' does not exist.")
        # Define the opcode dictionary

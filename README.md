# Algol-C Compiler
This is a basic compiler for a simple Algol-C language created in a compiler class in the Fall of 2025. 
The compiler reads Algol-C source code from a `.al` file and produces MIPS code in a `.asm` file.
## What it Does
This is a list of the compiler's capabilities. These are all tested in the provided `test.al`.
- Local and global variables
- Assignment statements
- Variable and arithmetic expressions
- If/Else statements
- While loops
- Function Calls

## Project Structure
- `Makefile` - Build rules
- `compiler.l` - Lexer to tokenize the input
- `compiler.y` - Parser used for syntax directed semantic action
- `ast.*` - Abstract Syntax Tree used as the intermediate representation of the code. Can be printed using `-d` for debugging
- `symtable.*` - Symbol table data structure
- `emit.*` - MIPS code generation
- `test.al` - Sample Algol-C program
- `test.asm` - Generated assembly code from `test.al`

## Running the compiler
### Requirements
- A Unix/Linux based system (not tested on Windows)
- [MARS MIPS simulator](https://computerscience.missouristate.edu/mars-mips-simulator.htm) (tested with version 4.5)

### 1. Clone the Repository
```bash
git clone https://github.com/VSanchez33/Algol-C-Compiler.git
```

### 2. Build the Compiler
```bash
make
```

### 3. Compile an Algol-C Program
```bash
./compiler -o <destination_name> < <input_file.al>
```
> **Note**: Replace <output_file> with the desired .asm output name and <input_file.al> with the Algol-C source file.

### 4. Run the Generated Assembly Code
```bash
java -jar Mars4_5.jar sm <created_asm_file>
```

## Example
```bash
make
./compiler -o test < test.al
java -jar Mars4_5.jar sm test.asm
```

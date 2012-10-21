divert(`-1')
# Forth Macros

This is a set of macros for developing Forth code for the DCPU-16.

## Register Usage

The forth interpreter reserves the use of a couple of registers.
I is the instruction pointer for the Forth VM,
J serves as the Return Stack Pointer, and
Z is the working register.

As an optimization, Top of Stack is kept in Y to simplify some commands.

## DEF* Functions

DEFWORD, DEFCODE, DEFVAR are for defining Forth primitives.
DEFWORD and DEFCODE take three arguments:

* name  
  This gets converted to uppercase.
* flags  
  A bitmap of F_IMMED and F_HIDDEN.
* label  
  This is optional and defaults to name. Used when name contains/is
  a symbol, like +1 or >>. In this case, label could be INCR or
  SHIFTR.

## Pseudo-Instructions

NEXT sets up the CPU to interpret another Forth word. This is called
at the end of every Forth word.
PUSHRSP pushes some value to the return stack.
POPRSP pops a value from the return stack.

## Variables

F_IMMMED, F_HIDDEN, and F_LENMASK are used for DEFWORD and DEFCODE.

link is a pointer to the last Forth word defined. Starts at 0x0000.

----

# Helper Functions
define(`LQ',`changequote(<,>)`dnl'
changequote`'')
define(`RQ',`changequote(<,>)dnl`
'changequote`'')
define(`ASCIIHEX', `syscmd(`printf "%x" "'RQ`$1'RQ`"')')
define(`PACKSTR', `ifelse($1,,,`ifelse(len($1),1,`dat 0x`'ASCIIHEX($1)`'00',`dat 0x`'ASCIIHEX(substr($1,0,1))`'ASCIIHEX(substr($1,1,1))
	PACKSTR(substr($1,2))')')')
define(`NAME_LABEL', `translit(translit(ifelse($1,,$2,$1),`-',`_'),`a-z',`A-Z')')
# Variables
define(`F_IMMED', `0x80')
define(`F_HIDDEN', `0x20')
define(`F_LENMASK', `0x1F')
define(`link', `0')

# Pseudo-instructions

Sets up the CPU to interpret the next word.
Expects I to be untouched, and overwrites Z.
define(`NEXT', `set z, [i]		; Get address of next word
	set pc, [z]		; Indirect threading!')
define(`PUSHRSP', `sub j, 1		; Push $1 to the return stack
	set [j], $1')
define(`POPRSP', `set $1, [j]		; Pop from the return stack to $1
	add j, 1')

# DEF* Functions
DEFWORD(name, flags=0, label=name)
define(`DEFWORD', `
:name_`'NAME_LABEL($2,$1)
	dat link  		; Link to previous command.
define(`link', name_`'NAME_LABEL($2,$1))dnl
	dat eval($3+len($1))			; Flags have the higher 3 bits, then len gets the rest.
	PACKSTR($1)		; This is the packed version of "$1"
:`'NAME_LABEL($2,$1)
	dat DOCOL`'dnl
')

define(`DEFCODE', `
:name_`'NAME_LABEL($2,$1)
	dat link		; Link to previous command.
define(`link', name_`'NAME_LABEL($2,$1))dnl
	dat eval($3+len($1))			; Flags have the higher 3 bits, then len gets the rest.
	PACKSTR($1)		; This is the packed version of "$1"
:`'NAME_LABEL($2,$1)
	dat code_`'NAME_LABEL($2,$1)
:code_`'NAME_LABEL($2,$1)`'dnl
')

define(`DEFVAR', `
	DEFCODE($1, $2, $3)
	set push, var_`'NAME_LABEL($2,$1)
:var_'`NAME_LABEL($2,$1)
	dat ifelse($4,,0,$4)`'dnl
')

divert(`0')dnl
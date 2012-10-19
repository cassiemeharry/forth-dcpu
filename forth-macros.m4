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

# Variables
define(`F_IMMED', `0x80')
define(`F_HIDDEN', `0x20')
define(`F_LENMASK', `0x1F')
define(`link', `0')

# Pseudo-instructions

Sets up the CPU to interpret the next word.
Expects I to be untouched, and overwrites Z.
define(`NEXT', `
	SET Z, [I]
	ADD I, 1
	SET PC, [Z]
')
define(`PUSHRSP', `
	SUB J, 1
	SET [J], $1
')
define(`POPRSP', `
	SET $1, [J]
	ADD J, 1
')

# DEF* Functions
DEFWORD(name, flags=0, label=name)
define(`DEFWORD', `
define(`$name', $1)dnl
define(`$flags', ifelse($2, `', 0, $2))dnl
define(`label', ifelse($3, `', $3, $name))dnl
:name_$3
	dat link  	; Link to previous command.
	define(`link', name_`'label)
	dat eval($flags+len($name))	; Flags have the higher 3 bits, then len gets the rest.
	dat "$name"	; The string name of the command.
:`'label
	dat DOCOL
')

define(`DEFCODE', `dnl
:name_`'ifelse($3, `', $1, $3)
	dat link	; Link to previous command.
define(`link', name_`'ifelse($3, `', $1, $3))dnl
	dat eval($2+len($1))		; Flags have the higher 3 bits, then len gets the rest.
	dat "$1"	; The string name of the command
:`'ifelse($3, `', $1, $3)
	dat code_`'ifelse($3, `', $1, $3)
:code_`'ifelse($3, `', $1, $3)`'dnl
')

define(`DEFVAR', `
define(`$name', $1)dnl
define(`$flags', ifelse($2, `', 0, $2))dnl
define(`$label', ifdef($3, $3, $name))dnl
define(`$initial', ifdef($4, $4, 0))dnl
	DEFCODE($name, $flags, $label)
	set push, var_$label
:var_$label_
	dat $initial
')

divert(`0')dnl
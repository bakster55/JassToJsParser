/*
 * Copyright (c) 2013 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
grammar Jass;

// program         := file+
/*
Note that I did not include `program` since `file` matches an empty 
string, causing the `program` rule to take up a lot of time on large 
input files.
*/

// file     ::= newline? ( declr newline )* func*
file
 : NEWLINE? (declr NEWLINE)* func*
 ;

// declr    ::= typedef
//            | globals
//            | native_func
declr
 : typedef
 | globals
 | native_func
 ;

// typedef  ::= 'type' id 'extends' ( 'handle' | id )
typedef
 : K_TYPE ID K_EXTENDS (K_HANDLE | ID)
 ;

// globals  ::= 'globals' newline global_var_list 'endglobals'
globals
 : K_GLOBALS NEWLINE global_var_list NEWLINE K_ENDGLOBALS
 ;

// global_var_list
//          ::= ( 'constant' type id '=' expr newline | var_declr newline )*
global_var_list
 : ((K_CONSTANT type ID ASSIGN expr NEWLINE) | (var_declr NEWLINE))*
 ;

// native_func
//          ::= 'constant'? 'native' func_declr
native_func
 : K_CONSTANT? K_NATIVE func_declr
 ;

// func_declr
//          ::= id 'takes' ( 'nothing' | param_list ) 'returns' ( type | 'nothing' )
func_declr
 : ID K_TAKES (K_NOTHING | param_list) K_RETURNS (type | K_NOTHING)
 ;

// param_list
//          ::= type id ( ',' type id )*
param_list
 : type ID (COMMA type ID)*
 ;

// func     ::= 'constant'? 'function' func_declr newline local_var_list statement_list 'endfunction' newline
func
 : K_CONSTANT? K_FUNCTION func_declr NEWLINE local_var_list statement_list K_ENDFUNCTION NEWLINE
 ;

// local_var_list
//          ::= ( 'local' var_declr newline )*
local_var_list
 : (K_LOCAL var_declr NEWLINE)*
 ;

// var_declr
//          ::= type id ( '=' expr )?
//            | type 'array' id
var_declr
 : type ID (ASSIGN expr)?
 | type K_ARRAY ID
 ;

// statement_list
//          ::= ( statement newline )*
statement_list
 : (statement NEWLINE)*
 ;

// statement
//          ::= set
//            | call
//            | ifthenelse
//            | loop
//            | exitwhen
//            | return
//            | debug
statement
 : set
 | call
 | ifthenelse
 | loop
 | exitwhen
 | return_stat
 | debug
 ;

// set      ::= 'set' id '=' expr
//            | 'set' id '[' expr ']' '=' expr
set
 : K_SET ID ASSIGN expr
 | K_SET ID O_BRACK expr C_BRACK ASSIGN expr
 ;

// call     ::= 'call' id '(' args? ')'
call
 : K_CALL ID O_PAR args? C_PAR
 ;

// args     ::= expr ( ',' expr )*
args
 : expr (COMMA expr)*
 ;

// ifthenelse
//          ::= 'if' expr 'then' newline statement_list else_clause? 'endif'
ifthenelse
 : K_IF expr K_THEN NEWLINE statement_list else_clause? K_ENDIF
 ;

// else_clause
//          ::= 'else' newline statement_list
//            | 'elseif' expr 'then' newline statement_list else_clause?
else_clause
 : K_ELSE NEWLINE statement_list
 | K_ELSEIF expr K_THEN NEWLINE statement_list else_clause?
 ;

// loop     ::= 'loop' newline statement_list 'endloop'
loop
 : K_LOOP NEWLINE statement_list K_ENDLOOP
 ;

// exitwhen ::= 'exitwhen' expr
exitwhen
 : K_EXITWHEN expr
 ;

// return   ::= 'return' expr?
return_stat
 : K_RETURN expr?
 ;

// debug    ::= 'debug' ( set | call | ifthenelse | loop )
debug
 : K_DEBUG (set | call | ifthenelse | loop)
 ;

// expr     ::= binary_op
//            | unary_op
//            | func_call
//            | array_ref
//            | func_ref
//            | id
//            | const
//            | parens
//
// binary_op
//          ::= expr ( [+-*/><] | '==' | '!=' | '>=' | '<=' | 'and' | 'or' ) expr
//
// unary_op ::= ( '+' | '-' | 'not' ) expr
expr
 : ADD expr
 | SUB expr
 | K_NOT expr
 | expr (MULT | DIV) expr
 | expr (ADD | SUB) expr
 | expr (GT | LT | GTEQ | LTEQ) expr
 | expr (EQ | NEQ) expr
 | expr (K_AND | K_OR) expr
 | func_call
 | array_ref
 | func_ref
 | ID
 | constant
 | parens
 ;

// func_call
//          ::= id '(' args? ')'
func_call
 : ID O_PAR args? C_PAR
 ;

// array_ref
//          ::= id '[' expr ']'
array_ref
 : ID O_BRACK expr C_BRACK
 ;

// func_ref ::= 'function' id
func_ref
 : K_FUNCTION ID
 ;

// const    ::= int_const
//            | real_const
//            | bool_const
//            | string_const
//            | 'null'
constant
 : int_const
 | REAL_CONST
 | bool_const
 | STRING_CONST
 | K_NULL
 ;

// int_const
//          ::= decimal
//            | octal
//            | hex
//            | fourcc
int_const
 : DECIMAL
 | OCTAL
 | HEX
 | FOURCC
 ;

// parens   ::= '(' expr ')'
parens
 : O_PAR expr C_PAR
 ;

// bool_const
//          ::= 'true'
//            | 'false'
bool_const
 : K_TRUE
 | K_FALSE
 ;

// type     ::= id
//            | 'code'
//            | 'handle'
//            | 'integer'
//            | 'real'
//            | 'boolean'
//            | 'string'
type
 : ID
 | K_CODE
 | K_HANDLE
 | K_INTEGER
 | K_REAL
 | K_BOOLEAN
 | K_STRING
 ;

// keywords
K_CODE : 'code';
K_HANDLE : 'handle';
K_INTEGER : 'integer';
K_REAL : 'real';
K_BOOLEAN : 'boolean';
K_STRING : 'string';
K_TRUE : 'true';
K_FALSE : 'false';
K_NULL : 'null';
K_NOT : 'not';
K_AND : 'and';
K_OR : 'or';
K_FUNCTION : 'function';
K_RETURN : 'return';
K_RETURNS : 'returns';
K_EXITWHEN : 'exitwhen';
K_LOOP : 'loop';
K_ENDLOOP : 'endloop';
K_ELSEIF : 'elseif';
K_ELSE : 'else';
K_CALL : 'call';
K_IF : 'if';
K_THEN : 'then';
K_ENDIF : 'endif';
K_DEBUG : 'debug';
K_SET : 'set';
K_TYPE : 'type';
K_EXTENDS : 'extends';
K_GLOBALS : 'globals';
K_ENDGLOBALS : 'endglobals';
K_CONSTANT : 'constant';
K_NATIVE : 'native';
K_TAKES : 'takes';
K_NOTHING : 'nothing';
K_ENDFUNCTION : 'endfunction';
K_LOCAL : 'local';
K_ARRAY : 'array';

// special chars
ADD : '+';
SUB : '-';
MULT : '*';
DIV : '/';
GT : '>';
LT : '<';
EQ : '==';
NEQ : '!=';
GTEQ : '>=';
LTEQ : '<=';
O_BRACK : '[';
C_BRACK : ']';
O_PAR : '(';
C_PAR : ')';
COMMA : ',';
ASSIGN : '=';

// decimal  ::= [1-9] [0-9]*
DECIMAL
 : [1-9] [0-9]*
 ;

// octal    ::= '0' [0-7]*
OCTAL
 : '0' [0-7]*
 ;

// hex      ::= '$' [0-9a-fA-F]+
//            | '0' [xX] [0-9a-fA-F]+
HEX
 : '$' [0-9a-fA-F]+
 | '0' [xX] [0-9a-fA-F]+
 ;

// fourcc   ::= '' ' .{4} ' ''
FOURCC : ['] . . . . ['];

// real_const
//          ::= [0-9]+ '.' [0-9]*
//            | '.' [0-9]+
REAL_CONST
 : [0-9]+ '.' [0-9]*
 | '.' [0-9]+
 ;

// string_const
//          ::= '"' .* '"'
STRING_CONST
 : '"' .*? '"'
 ;

// id       ::= [a-zA-Z] ( [a-zA-Z0-9_]* [a-zA-Z0-9] )?
ID
 : [a-zA-Z] ([a-zA-Z0-9_]* [a-zA-Z0-9])?
 ;

// newline  ::= '\n'+
NEWLINE
 : [\r\n]+
 ;

SPACE
 : [ \t] -> skip
 ;

COMMENT
 : '//' ~[\r\n] -> skip
 ;
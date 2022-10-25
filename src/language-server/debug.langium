grammar Mediator

entry Program:
    (Expression ':' Type ';')*;

Expression:
    name=ID
    | value=(INT | REAL | CHAR | BOOL | NULL)
    | '[' values+=Expression (',' values+=Expression)? ']';

Type infers Type:
    (PrimitiveType | BracketType)
    ({infer ListType} '[' (capacity=Expression)? ']')*
;

BracketType infers Type:
    '(' Type ({infer TupleType.types+=current} ',' types+=Type)* ')';

interface PrimitiveType {
    name: 'int' | 'real' | 'char' | 'bool' | string;
}

interface BoundedIntType extends PrimitiveType {
    lbound: Expression;
    ubound: Expression;
}

PrimitiveType returns PrimitiveType:
    {BoundedIntType} BoundedIntType |
    name=('int' | 'real' | 'char' | 'bool' | NULL);

BoundedIntType returns BoundedIntType:
    name='int' lbound=Expression '..' ubound=Expression;


// Lexical rules
terminal REAL returns number: DECFRAC EXPONENT? | DECSEQ EXPONENT;
terminal INT returns number: /[1-9]\d*|0/;

// terminal fragment BINSEQ: /0[bB][01]+/;
// terminal fragment OCTSEQ: /0[oO][0-7]+/;
// terminal fragment HEXSEQ: /0[xX][\da-fA-F]+/;
terminal fragment DECFRAC: /(([1-9]\d*|0)?\.\d+)/;
terminal fragment DECSEQ: /[1-9]\d*|0/;
terminal fragment EXPONENT: /[eE][+-]?\d+/;

terminal CHAR returns string: /'[^'\\\s]'|'\\[abtnvfr0e\\']'|' '/;

terminal BOOL returns boolean: 'true' | 'false';

terminal NULL returns string: 'null';

terminal ID returns string: /[a-zA-Z_]\w*/;

// hidden terminal rules
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

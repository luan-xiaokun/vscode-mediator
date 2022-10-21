grammar Mediator

entry Program:
    (expr+=Term)*;

// ##### Type #####
Type:
    PrimitiveType ({infer InitType} 'init')?;

ParameterType infers ParameterType:
    'type' |
    'func' '('arg_types+=Type (',' arg_types+=Type)* ')' ':' return_type=Type |
    'interface' '(' (ports+=PortTyping (',' ports+=PortTyping)*)? ')';

PortTyping infers PortTyping:
    direction=('in' | 'out') vtype=Type;

PrimitiveType infers PrimitiveType:
    {infer IntType} 'int' |
    {infer BoundedIntType} 'int' lbound=Term '..' ubound=Term |
    {infer RealType} 'real' |
    {infer CharType} 'char' |
    {infer BoolType} 'bool' |
    {infer NullType} 'NULL' |
    {infer EnumType} 'enum' '{' members+=ID (',' members+=ID)* '}' |
    {infer StructType} 'struct' '{' (fields+=ID ':' types+=Type ';')+ '}';

// ##### Term #####
Term:
    Literal |
    ScopedId ({infer PortVar.port=current} '.' field=PORTFIELD)? |
    StructTerm |
    BracketTerm;

BracketTerm infers Term:
    '(' Term ({infer TupleTerm.members+=current} (',' members+=Term)) ')';

fragment Terms:
    Term (',' Term)+;

StructTerm infers StructTerm:
    'struct' '{' (fields+=ID '=' values+=Term (',' fields+=ID '=' values+=Term)*)? '}';

// ##### Literal #####
Literal infers Literal:
    IntLiteral | RealLiteral | CharLiteral | BoolLiteral | NullLiteral;

ScopedId infers ScopedId:
    (scope+=ID '.')* identifier=ID;

// parse rules
interface LiteralType {
}

IntLiteral infers IntLiteral:
    value=INT;

RealLiteral infers RealLiteral:
    value=REAL;

CharLiteral infers CharLiteral:
    value=CHAR;

BoolLiteral infers BoolLiteral:
    value=BOOL;

NullLiteral infers NullLiteral:
    value='null';

// Lexical rules
terminal INT returns number: BINSEQ | OCTSEQ | HEXSEQ | DECSEQ;
terminal REAL returns number: DECFRAC EXPONENT? | DECSEQ EXPONENT;
terminal fragment BINSEQ: /0[bB][01]+/;
terminal fragment OCTSEQ: /0[oO][0-7]+/;
terminal fragment HEXSEQ: /0[xX][\da-fA-F]+/;
terminal fragment DECFRAC: /(([1-9]\d*|0)?\.\d+)/;
terminal fragment DECSEQ: /[1-9]\d*|0/;
terminal fragment EXPONENT: /[eE][+-]?\d+/;

terminal CHAR returns string: /'[^'\\\s]'|'\\[abtnvfr0e\\']'|' '/;

terminal BOOL returns boolean: 'true' | 'false';

terminal PORTFIELD returns string: 'value' | 'reqRead' | 'reqWrite';

terminal ID returns string: /[a-zA-Z_]\w*/;

// hidden terminal rules
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

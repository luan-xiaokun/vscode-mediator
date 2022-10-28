grammar Mediator

entry Program:
    (typedefs+=TypeDef | constdefs+=ConstDef | vars+=VariableTyping ';')*;


// ##### Type Definition
TypeDef infers TypeDef:
    'typedef' type=Type 'as' name=ID ';';

// ##### Constant Definition
ConstDef infers ConstDef:
    'const' expr=Expression 'as' name=ID ';';

interface VariableTyping {
    name: string;
    typing: Type;
}

VariableTyping returns VariableTyping:
    name=ID ':' typing=Type;

// ##### Expression #####
type Expression = 
    ConditionalExpression | BinaryExpression | PrefixExpression
    | IndexingExpression | FunctionCallExpression | Literal 
    | NamedElement | StructExpression | ListExpression | TupleExpression;

Expression returns Expression:
    LogicalOrExpression ({ConditionalExpression} '?' Expression ':' Expression)?;

// ##### Expression ##### - interface
interface ConditionalExpression {
    condition: Expression;
    then: Expression;
    else: Expression;
}

interface BinaryExpression {
    left: Expression;
    operator: string;
    right: Expression;
}

interface PrefixExpression {
    operator: string;
    operand: Expression;
}

interface IndexingExpression {
    base: Expression;
    index: Expression;
}

interface AttributeExpression {
    previous: Expression;
    field: @NamedElement | string;
}

interface FunctionCallExpression {
    name?: @NamedElement;
    typetemplates?: Type[];
    exprtemplates?: Expression[];
    arguments: Expression[];
}

interface NamedExpression {
    element: @NamedElement;
}

interface StructExpression {
    fields: string[];
    values: Expression[];
}

interface IterableExpression {
    values: Expression[];
}

interface ListExpression extends IterableExpression {}

interface TupleExpression extends IterableExpression {}

// ##### Expression ##### - parse rules
LogicalOrExpression returns Expression:
    LogicalAndExpression ({BinaryExpression.left=current} operator='||' right=LogicalAndExpression)*;

LogicalAndExpression returns Expression:
    LogicalNotExpression ({BinaryExpression.left=current} operator='&&' right=LogicalNotExpression)*;

LogicalNotExpression returns Expression:
    ({PrefixExpression} operator='!' operand=LogicalNotExpression) | ComparisonExpression;

ComparisonExpression returns Expression:
    EqualityExpression ({BinaryExpression.left=current} operator=('<'|'>'|'<='|'>=') right=EqualityExpression)*;

EqualityExpression returns Expression:
    AdditiveExpression ({BinaryExpression.left=current} operator=('=='|'!=') right=AdditiveExpression)*;

AdditiveExpression returns Expression:
    MultiplicativeExpression ({BinaryExpression.left=current} operator=('+'|'-') right=MultiplicativeExpression)*;

MultiplicativeExpression returns Expression:
    PrefixExpression ({BinaryExpression.left=current} oeprator=('*'|'/'|'%') right=PrefixExpression)*;

PrefixExpression returns Expression:
    ({PrefixExpression} operator=('+'|'-') operand=PrefixExpression) | ExponentExpression;

ExponentExpression returns Expression:
    PostfixExpression ({BinaryExpression.left=current} operator='**' right=PostfixExpression)*;

PostfixExpression returns Expression:
    PrimaryExpression (
        ({IndexingExpression.base=current} '[' index=Expression ']')
        | ({AttributeExpression.previous=current} '.' field=[NamedElement:ID])
        | ({FunctionCallExpression} '(' ArgumentSequence? ')')
    )*;

PrimaryExpression returns Expression:
    Literal
    | FunctionCallExpression
    | StructExpression
    | ListExpression
    | BracketExpression;

FunctionCallExpression returns FunctionCallExpression:
    ({NamedExpression} element=[NamedElement:ID])
    ({FunctionCallExpression.name=current} '(' ArgumentSequence? ')')?;

fragment ArgumentSequence:
    arguments+=Expression (',' arguments+=Expression)*;

StructExpression returns StructExpression:
    'struct' '{' fields+=ID '=' values+=Expression (',' fields+=ID '=' values+=Expression)* '}';

ListExpression returns ListExpression:
    '[' (values+=Expression (',' values+=Expression)* ','?)? ']';

BracketExpression returns Expression:
    '(' Expression ({TupleExpression.values+=current} ',' values+=Expression)* ','? ')';

// ##### NamedElement
type NamedElement = VariableTyping | ConstDef | EnumMember | StructType;

// ##### Literal #####
type Literal = IntLiteral | RealLiteral | CharLiteral | BoolLiteral | NullLiteral;

Literal returns Literal:
    ({IntLiteral} value=INT) | ({RealLiteral} value=REAL) | ({CharLiteral} value=CHAR)
    | ({BoolLiteral} value=BOOL) | ({NullLiteral} value='null');

interface IntLiteral {
    value: number;
}
interface RealLiteral {
    value: number;
}
interface CharLiteral {
    value: string;
}
interface BoolLiteral {
    value: boolean
}
interface NullLiteral {
    value: string;
}

// ##### Type #####
type Type = PrimitiveType | EnumType | StructType | NamedType | ListType | TupleType | UnionType;

Type returns Type:
    (PrimitiveType | EnumType | StructType | NamedType | BracketType)
    // the precedence of list is higher than union
    ({ListType.base=current} '[' (capacity=Expression)? ']')*
    ({UnionType.types+=current} '|' types+=Type)*
;

// ##### Type ##### - interface
interface PrimitiveType {
    name: 'int' | 'real' | 'char' | 'bool' | 'null';
}

interface EnumType {
    members: EnumMember[];
}

interface EnumMember {
    name: string;
}

interface StructType {
    fields: Field[];
    types: Type[];
}

interface Field {
    name: string;
}

interface NamedType {
    alias: @TypeDef;
}

interface ListType {
    base: Type;
    capacity?: Expression;
}

interface TupleType {
    types: Type[];
}

interface UnionType {
    types: Type[];
}

// ##### Type ##### - parse rules
PrimitiveType returns PrimitiveType:
    name=('int' | 'real' | 'char' | 'bool' | 'null');

EnumType returns EnumType:
    'enum' '{' members+=EnumMember (',' members+=EnumMember)* '}';

EnumMember returns EnumMember:
    name=ID;

StructType returns StructType:
    'struct' '{' fields+=Field ':' types+=Type (',' fields+=Field ':' types+=Type)* '}';

Field returns Field:
    name=ID;

NamedType returns NamedType:
    alias=[TypeDef:ID];

BracketType returns Type:
    '(' Type ({TupleType.types+=current} ',' types+=Type)*')';

// Lexical rules
terminal REAL returns number: DECFRAC EXPONENT? | DECSEQ EXPONENT;
terminal INT returns number: BINSEQ | OCTSEQ | HEXSEQ | DECSEQ;

terminal fragment BINSEQ: /0[bB][01]+/;
terminal fragment OCTSEQ: /0[oO][0-7]+/;
terminal fragment HEXSEQ: /0[xX][\da-fA-F]+/;
terminal fragment DECFRAC: /(([1-9]\d*|0)?\.\d+)/;
terminal fragment DECSEQ: /[1-9]\d*|0/;
terminal fragment EXPONENT: /[eE][+-]?\d+/;

terminal CHAR returns string: /'[^'\\\s]'|'\\[abtnvfr0e\\']'|' '/;

terminal BOOL returns boolean: 'true' | 'false';

terminal ID returns string: /[a-zA-Z_]\w*/;

// hidden terminal rules
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

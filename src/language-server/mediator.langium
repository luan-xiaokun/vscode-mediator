grammar Mediator

entry Program:
    (typedefs+=TypeDef | constdefs+=ConstDef | functions+=FunctionDefinition | automatons+=AutomatonDefinition | systems+=SystemDefinition)*;


// ##### Type Definition
TypeDef infers TypeDef:
    'typedef' type=Type 'as' alias=ID ';';


// ##### Constant Definition
ConstDef infers ConstDef:
    'const' expr=Expression 'as' alias=ID ';';


// ##### System
interface System {
    name: string;
    templates: SystemTemplateTyping[];
    ports: PortTyping[];
    internals: string[];
    components: ComponentTyping[];
    connections: Connection[];
}

SystemDefinition returns System:
    'system' ('<' SystemTemplateList '>')? name=ID
    '(' (ports+=PortTyping (',' ports+=PortTyping)*)? ')'
    '{'
        ('internals' internals+=ID (',' internals+=ID)* ';')?
        ('components' '{' (components+=ComponentTyping ';')+ '}')?
        'connections' '{' (connections+=Connection ';')+ '}'
    '}'
;


// ##### Connection
type Connection = InstantiationConnection | PortConnection;

Connection returns Connection:
    InstantiationConnection | PortConnection;

interface InstantiationConnection {
    entity: ComponentInstantiation;
    ports: ScopedId[];
}

InstantiationConnection returns InstantiationConnection:
    entity=ComponentInstantiation '(' ports+=ScopedId (',' ports+=ScopedId)* ')';

interface PortConnection {
    from: ScopedId[];
    to: ScopedId[];
    options?: PortConnectionOption;
}

PortConnection returns PortConnection:
    (from+=ScopedId | '(' from+=ScopedId (',' from+=ScopedId)* ')')
    ('->' | '-(' options=PortConnectionOption ')->')
    (to+=ScopedId | '(' to+=ScopedId (',' to+=ScopedId)* ')')
;

interface PortConnectionOption {
    sync: 'sync' | 'async';
    cast: 'broadcast' | 'unicast';
    capacity?: Expression;
}

PortConnectionOption returns PortConnectionOption:
    sync=('sync' | 'async') ',' cast=('broadcast' | 'unicast') (',' 'capacity' '=' capacity=Expression)?;


// ##### Automaton
interface Automaton {
    name: string;
    templates: NonSystemTemplateTyping[];
    ports: PortTyping[];
    localvars: MultiVariableTyping[];
    initial: Statement[];
    transitions: Transition[];
}

AutomatonDefinition returns Automaton:
    'automaton' ('<' NonSystemTemplateList '>')? name=ID
    '(' (ports+=PortTyping (',' ports+=PortTyping)*)? ')'
    '{'
        ('variables' '{' (localvars+=MultiVariableTyping ';')+ '}')?
        ('initial' '{' (initial+=Statement)+ '}')?
        'transitions' 
        '{'
            (transitions+=Transition)+
        '}'
    '}'
;

// ##### Transition
type Transition = SingleTransition | GroupTransition;

Transition returns Transition:
    SingleTransition | GroupTransition;

interface SingleTransition {
// urgent?: boolean;
    guard: Expression;
    statements: StatementOrSynchronization[];
}

interface GroupTransition {
// urgent?: boolean;
    transitions: SingleTransition[];
}

SingleTransition returns SingleTransition:
    // (urgent?='urgent')?
    guard=Expression '->' (statements+=StatementOrSynchronization | '{' (statements+=StatementOrSynchronization)+ '}');

GroupTransition returns GroupTransition:
    // (urgent?='urgent')?
    'group' '{' (transitions+=SingleTransition)+ '}';


type StatementOrSynchronization = Statement | Synchronization;

StatementOrSynchronization returns StatementOrSynchronization:
    Statement | Synchronization;


// ##### Function
interface Function {
    name: string;
    templates: NonSystemTemplateTyping[];
    arguments: VariableTyping[];
    returntype: Type;
    localvars: MultiVariableTyping[];
    statements: FunctionStatement[];
}

FunctionDefinition returns Function:
    'function' ('<' NonSystemTemplateList '>')? name=ID
    '(' (arguments+=VariableTyping (',' arguments+=VariableTyping)*)? ')' ':' returntype=Type
    '{' 
        ('variables' '{' (localvars+=MultiVariableTyping ';')+ '}')?
        'statements' '{' (statements+=FunctionStatement)+ '}'
    '}'
;


// ##### Template
NonSystemTemplateType:
    Type | NonInterfaceParameterType;

interface NonSystemTemplateTyping {
    name: string;
    typing: NonSystemTemplateType;
}

NonSystemTemplateTyping returns NonSystemTemplateTyping:
    name=ID ':' typing=NonSystemTemplateType;

fragment NonSystemTemplateList:
    templates+=NonSystemTemplateTyping (',' templates+=NonSystemTemplateTyping)*;

SystemTemplateType:
    Type | ParameterType;

interface SystemTemplateTyping {
    name: string;
    typing: SystemTemplateType;
}

SystemTemplateTyping returns SystemTemplateTyping:
    name=ID ':' typing=SystemTemplateType;

fragment SystemTemplateList:
    templates+=SystemTemplateTyping (',' templates+=SystemTemplateTyping)*;


// ##### Statement
type Statement=Assignment | Conditional | Loop | ';';

Statement returns Statement:
    ';' | AssignmentStatement | ConditionalStatement | LoopStatement;

interface Assignment {
    left: Expression;
    assign: '=' | '+=' | '-=' | '*=' | '/=' | '%=';
    right: Expression;
}

interface Conditional {
    condition: Expression;
    then: Statement[];
    else: Statement[];
}

interface Loop {
    declaration: AssignmentUpdate;
    condition: Expression;
    update: AssignmentUpdate;
    body: Statement[];
}

AssignmentStatement returns Assignment:
    left=Expression assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') right=Expression ';'
;

AssignmentUpdate:
    left=ID assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') right=Expression;

ConditionalStatement returns Conditional:
    'if' '(' condition=Expression ')'
    (then+=Statement | '{' (then+=Statement)+ '}')
    ('else' (else+=Statement | '{' (else+=Statement)+ '}'))?
;

LoopStatement returns Loop:
    'for' '(' 'let' declaration=AssignmentUpdate ';' condition=LogicalOrExpression ';' update=AssignmentUpdate ')'
    (body+=Statement | '{' (body+=Statement)+ '}')
;


// ##### Function Statement
type FunctionStatement = Assignment | FunctionReturn | FunctionConditional | FunctionLoop | ';';

FunctionStatement returns FunctionStatement:
    ';' | AssignmentStatement | FunctionReturnStatement | FunctionConditionalStatement | FunctionLoopStatement;

interface FunctionReturn {
    value: Expression;
}

interface FunctionConditional {
    condition: Expression;
    then: FunctionStatement[];
    else: FunctionStatement[]
}

interface FunctionLoop {
    declaration: AssignmentUpdate;
    condition: Expression;
    update: AssignmentUpdate;
    body: FunctionStatement[];
}

FunctionReturnStatement returns FunctionReturn:
    'return' value=Expression;

FunctionConditionalStatement returns FunctionConditional:
    'if' '(' condition=Expression ')'
    (then+=FunctionStatement | '{' (then+=FunctionStatement)+ '}')
    ('else' (else+=FunctionStatement | '{' (else+=FunctionStatement)+ '}'))?
;

FunctionLoopStatement returns FunctionLoop:
    'for' '(' 'let' declaration=AssignmentUpdate ';' condition=LogicalOrExpression ';' update=AssignmentUpdate ')'
    (body+=FunctionStatement | '{' (body+=FunctionStatement)+ '}')
;

// ##### Synchronization
interface Synchronization {
    ports: string[];
}

Synchronization returns Synchronization:
    'sync' ports+=ID (',' ports+=ID)* ';';


// ##### Typing Declaration #####
interface VariableTyping {
    name: string;
    typing: Type;
}

VariableTyping returns VariableTyping:
    name=ID ':' typing=Type;

interface MultiVariableTyping {
    names: string[];
    typing: Type;
}

MultiVariableTyping returns MultiVariableTyping:
    names+=ID (',' names+=ID)* ':' typing=Type;

interface PortTyping {
    name: string;
    typing: PortType;
}

PortTyping returns PortTyping:
    name=ID ':' typing=PortType;

interface TemplateParameterTyping {
    name: string;
    typing: ParameterType;
}

interface ComponentInstantiation {
    name: string;
    templates: Expression[];
}

ComponentInstantiation returns ComponentInstantiation:
    name=ID ('<' templates+=AdditiveExpression (',' templates+=AdditiveExpression)* '>')?;

interface ComponentTyping {
    names: string[];
    typing: ComponentInstantiation
}

ComponentTyping returns ComponentTyping:
    names+=ID (',' names+=ID)* ':' typing=ComponentInstantiation;


// ##### Expression #####
type Expression = 
    ConditionalExpression | BinaryExpression | PrefixExpression
    | IndexingExpression | FunctionCallExpression | Literal 
    | ScopedId | StructExpression | ListExpression | TupleExpression;

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

interface FunctionCallExpression {
    name: ScopedId;
    typetemplates?: Type[];
    exprtemplates?: Expression[];
    arguments: Expression[];
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
    IndexingExpression ({BinaryExpression.left=current} operator='**' right=IndexingExpression)*;

IndexingExpression returns Expression:
    PrimaryExpression ({IndexingExpression.base=current} '[' index=Expression ']')*;

PrimaryExpression returns Expression:
    Literal
    | ScopedId (
    // TODO: type parameters
    // TODO: support function call with templates
        {FunctionCallExpression.name=current} /*('<' ExprTemplates? '>')?*/ '(' ArgumentSequence? ')'
    )?
    | StructExpression
    | ListExpression
    | BracketExpression;

// fragment TypeExprTemplates:
//     TypeTemplates (',' ExprTemplates)? | ExprTemplates;

// fragment TypeTemplates:
//     typetemplates+=Type (',' typetemplates+=Type)*;

// fragment ExprTemplates:
//     exprtemplates+=Expression (',' exprtemplates+=Expression)*;

fragment ArgumentSequence:
    arguments+=Expression (',' arguments+=Expression)*;

StructExpression returns StructExpression:
    'struct' '{' fields+=ID '=' values+=Expression (',' fields+=ID '=' values+=Expression)* '}';

ListExpression returns ListExpression:
    '[' (values+=Expression (',' values+=Expression)* ','?)? ']';

BracketExpression returns Expression:
    '(' Expression ({TupleExpression.values+=current} ',' values+=Expression)* ','? ')';


// ##### Literal #####
type Literal = IntLiteral | RealLiteral | CharLiteral | BoolLiteral | NullLiteral;

Literal returns Literal:
    ({IntLiteral} value=INT) | ({RealLiteral} value=REAL) | ({CharLiteral} value=CHAR)
    | ({BoolLiteral} value=BOOL) | ({NullLiteral} value=NULL);

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


// ##### ScopedId #####
interface ScopedId {
    scope?: string[];
    identifier: string;
}

ScopedId returns ScopedId:
    (scope+=ID '.')* identifier=ID;

// ##### Type #####
type Type = PrimitiveType | EnumType | StructType | ListType | TupleType | UnionType | ScopedId;

Type returns Type:
    (PrimitiveType | EnumType | StructType | BracketType | ScopedId)
    // the precedence of list is higher than union
    // TODO: parentheses check for array of bounded integer whose upper bound has something like `a[1]`
    // FIXME: currently int[3] is parsed as int lbound and report missing '..' errors
    ({ListType.base=current} '[' (capacity=Expression)? ']')*
    ({UnionType.types+=current} '|' types+=Type)*
;

// ##### Type ##### - interface
interface PrimitiveType {
    name: 'int' | 'real' | 'char' | 'bool' | string;
}

interface BoundedIntType extends PrimitiveType {
    lbound: Expression;
    ubound: Expression;
}

interface EnumType {
    members: string[];
}

interface StructType {
    fields: string[];
    types: Type[];
}

interface ListType {
    base: Type;
    capacity?: Expression;
}

interface MultiType {
    types: Type[];
}

interface TupleType extends MultiType {}

interface UnionType extends MultiType {}


// ##### Type ##### - parse rules
PrimitiveType returns PrimitiveType:
    {BoundedIntType} BoundedIntType
    | name=('int' | 'real' | 'char' | 'bool' | NULL);

BoundedIntType returns BoundedIntType:
    name='int' lbound=Expression '..' ubound=Expression;

EnumType returns EnumType:
    'enum' '{' members+=ID (',' members+=ID)* '}';

StructType returns StructType:
    'struct' '{' fields+=ID ':' types+=Type (',' fields+=ID ':' types+=Type)* '}';

BracketType returns Type:
    '(' Type ({TupleType.types+=current} ',' types+=Type)*')';


// ##### Port Type
interface PortType {
    direction: 'in' | 'out';
    typing: Type;
}

PortType returns PortType:
    direction=('in' | 'out') typing=Type;


// ##### Parameter Type
type ParameterType = AbstractType | FunctionType | InterfaceType;

type NonInterfaceParameterType = AbstractType | FunctionType;

ParameterType returns ParameterType:
    AbstractType | FunctionType | InterfaceType;

NonInterfaceParameterType returns NonInterfaceParameterType:
    AbstractType | FunctionType;

AbstractType returns string:
    'type';

interface FunctionType {
    returntype: Type;
    argtypes: Type[];
}

interface InterfaceType {
    porttypes: PortType[];
}

FunctionType returns FunctionType:
    'func' '(' (argtypes+=Type (',' argtypes+=Type)*)? ')' ':' returntype=Type;

InterfaceType returns InterfaceType:
    'interface' '(' (porttypes+=PortType (',' porttypes+=PortType)*)? ')';

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

terminal NULL returns string: 'null';

terminal ID returns string: /[a-zA-Z_]\w*/;

// hidden terminal rules
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;

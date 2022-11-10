grammar Mediator

entry Program:
    (typedefs+=TypeDefinition | constdefs+=ConstDefinition | functions+=FunctionDefinition | automatons+=AutomatonDefinition | systems+=SystemDefinition)*;

// Type Definition
TypeDefinition infers TypeDef:
    'typedef' type=Type 'as' name=FeatureID ';';

// Constant Definition
ConstDefinition infers ConstDef:
    'const' expr=Expression 'as' name=FeatureID ';';

// System Definition
SystemDefinition infers System:
    'system' ('<' SystemTemplateList '>')? name=FeatureID
    '(' (ports+=PortTyping (',' ports+=PortTyping)*)? ')'
    '{'
        ('internals' internals+=InternalPort (',' internals+=InternalPort)* ';')?
        ('components' '{' (components+=ComponentTyping ';')+ '}')?
        'connections' '{' (connections+=Connection ';')+ '}'
    '}';

// Automaton Definition
AutomatonDefinition infers Automaton:
    'automaton' ('<' NonSystemTemplateList '>')? name=FeatureID
    '(' (ports+=PortTyping (',' ports+=PortTyping)*)? ')'
    '{'
        ('variables' '{' (localvars+=MultipleVariableTyping ';')+ '}')?
        ('initial' '{' (initial+=Statement)+ '}')?
        'transitions' 
        '{'
            (transitions+=Transition)+
        '}'
        ('invariants' '{' (invariants+=Expression ';')+ '}')?
    '}'
;

// Function Definition
FunctionDefinition infers FunctionDef:
    'function' ('<' NonSystemTemplateList '>')? name=FeatureID
    '(' (arguments+=VariableTyping (',' arguments+=VariableTyping)*)? ')' ':' returntype=Type
    '{' 
        ('variables' '{' (localvars+=MultipleVariableTyping ';')* '}')?
        'statements' '{' (statements+=FunctionStatement)* '}'
    '}';

// Named Identifiers
type NamedElement = VariableName | ConstDef | EnumMember | StructField | PortTyping | LoopVariableDeclaration | TemplateTyping | FunctionDef;

type NamedAutomaton = ComponentName | Automaton;

type NamedType = TypeDef | TemplateTyping;

// Connection
Connection infers Connection:
    InstantiationConnection | PortConnection;

InstantiationConnection infers InstantiationConnection:
    entity=ComponentInstantiation '(' ports+=AutomatonPort (',' ports+=AutomatonPort)* ')';

PortConnection infers PortConnection:
    (from+=AutomatonPort | '(' from+=AutomatonPort (',' from+=AutomatonPort)* ')')
    ('->' | '-(' options=PortConnectionOption ')->')
    (to+=AutomatonPort | '(' to+=AutomatonPort (',' to+=AutomatonPort)* ')');

AutomatonPort infers AutomatonPort:
    automaton=[NamedAutomaton:FeatureID] '.' port=[PortTyping:FeatureID] | port=[InternalPort:ID];

PortConnectionOption infers PortConnectionOption:
    (sync='sync' ',' cast=('broadcast' | 'unicast'))
    | (sync='async' ',' cast=('broadcast' | 'unicast') ',' 'capacity' '=' capacity=Expression);

InternalPort infers InternalPort:
    name=FeatureID;

// Transition
Transition infers Transition:
    SingleTransition | GroupTransition;

SingleTransition infers SingleTransition:
    // (urgent?='urgent')?
    guard=Expression '->' (statements+=(Statement | Synchronization) | '{' (statements+=(Statement | Synchronization))+ '}');

GroupTransition infers GroupTransition:
    // (urgent?='urgent')?
    'group' '{' (transitions+=SingleTransition)+ '}';

// Statement
Statement infers Statement:
    ';' | AssignmentStatement | ConditionalStatement | LoopStatement;

AssignmentStatement infers AssignmentStatement:
    left=Expression assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') right=Expression ';';

ConditionalStatement infers ConditionalStatement:
    'if' '(' condition=Expression ')'
    (then+=Statement | '{' (then+=Statement)* '}')
    ('else' (else+=Statement | '{' (else+=Statement)* '}'))?;

LoopStatement infers LoopStatement:
    'for'
    '(' declaration=LoopVariableDeclaration ';' condition=Expression ';' update=LoopVariableUpdate ')'
    (body+=Statement | '{' (body+=Statement)* '}');

LoopVariableDeclaration infers LoopVariableDeclaration:
    'let' name=FeatureID ':' type=Type '=' value=Expression;

LoopVariableUpdate infers LoopVariableUpdate:
    var=[LoopVariableDeclaration:FeatureID] assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') expr=Expression;

// Synchronization
Synchronization infers Synchronization:
    'sync' ports+=[PortTyping:FeatureID] (',' ports+=[PortTyping:FeatureID])* ';';

// Function Statement
FunctionStatement infers FunctionStatement:
    ';' | AssignmentStatement | ReturnStatement | FunctionConditionalStatement | FunctionLoopStatement;

ReturnStatement infers ReturnStatement:
    'return' value=Expression;

FunctionConditionalStatement infers FunctionConditionalStatement:
    'if' '(' condition=Expression ')'
    (then+=FunctionStatement | '{' (then+=FunctionStatement)* '}')
    ('else' (else+=FunctionStatement | '{' (else+=FunctionStatement)* '}'))?;

FunctionLoopStatement infers FunctionLoopStatement:
    'for'
    '(' declaration=LoopVariableDeclaration ';' condition=Expression ';' update=LoopVariableUpdate ')'
    (body+=FunctionStatement | '{' (body+=FunctionStatement)* '}');

// Variable Typing
VariableTyping infers VariableTyping:
    var=VariableName ':' type=Type;

MultipleVariableTyping infers MultipleVariableTyping:
    vars+=VariableName (',' vars+=VariableName)* ':' type=Type;

VariableName infers VariableName:
    name=FeatureID;

// Port Typing
PortTyping infers PortTyping:
    name=FeatureID ':' type=PortType;

// Component Typing
ComponentTyping infers ComponentTyping:
    components+=ComponentName (',' components+=ComponentName)* ':' type=ComponentInstantiation;

ComponentName infers ComponentName:
    name=FeatureID;

ComponentInstantiation infers ComponentInstantiation:
    component=[NamedAutomaton:FeatureID] ('<' templates+=TypeOrExpression (',' templates+=TypeOrExpression)* '>')?;

// Template Typing
SystemTemplateTyping infers TemplateTyping:
    name=FeatureID ':' type=(Type | ParameterType);

NonSystemTemplateTyping infers TemplateTyping:
    name=FeatureID ':' type=(Type | NonInterfaceParameterType);

fragment SystemTemplateList:
    templates+=SystemTemplateTyping (',' templates+=SystemTemplateTyping)*;

fragment NonSystemTemplateList:
    templates+=NonSystemTemplateTyping (',' templates+=NonSystemTemplateTyping)*;

// Type Or Expression
TypeOrExpression infers TypeOrExpression:
    (PrimitiveType | EnumType | StructType | EqualityExpression)
    ({infer ListTypeOrExpression.base=current} '[' (capacity=Expression)? ']')*
    ({infer UnionTypeOrExpression.types+=current} '|' types+=TypeOrExpression)*;

// Expression
Expression infers Expression:
    LogicalOrExpression ({infer ConditionalExpression.condition=current} '?' then=Expression ':' else=Expression)?;

LogicalOrExpression infers Expression:
    LogicalAndExpression ({infer BinaryExpression.left=current} operator='||' right=LogicalAndExpression)*;

LogicalAndExpression infers Expression:
    LogicalNotExpression ({infer BinaryExpression.left=current} operator='&&' right=LogicalNotExpression)*;

LogicalNotExpression infers Expression:
    ({infer PrefixExpression} operator='!' operand=LogicalNotExpression) | ComparisonExpression;

ComparisonExpression infers Expression:
    EqualityExpression ({infer BinaryExpression.left=current} operator=('<'|'>'|'<='|'>=') right=EqualityExpression)*;

EqualityExpression infers Expression:
    AdditiveExpression ({infer BinaryExpression.left=current} operator=('=='|'!=') right=AdditiveExpression)*;

AdditiveExpression infers Expression:
    MultiplicativeExpression ({infer BinaryExpression.left=current} operator=('+'|'-') right=MultiplicativeExpression)*;

MultiplicativeExpression infers Expression:
    PrefixExpression ({infer BinaryExpression.left=current} oeprator=('*'|'/'|'%') right=PrefixExpression)*;

PrefixExpression infers Expression:
    ({infer PrefixExpression} operator=('+'|'-') operand=PrefixExpression) | ExponentExpression;

ExponentExpression infers Expression:
    PostfixExpression ({infer BinaryExpression.left=current} operator='**' right=ExponentExpression)?;

PostfixExpression infers Expression:
    PrimaryExpression (
        ({infer IndexingExpression.base=current} '[' index=Expression ']')
        | ({infer AttributeExpression.previous=current} '.' (field=[StructField:ID] | portField=('value' | 'reqRead' | 'reqWrite')))
    )*;

PrimaryExpression infers Expression:
    IntLiteral | RealLiteral | CharLiteral | BoolLiteral | NullLiteral
    | FunctionCallExpression
    | StructExpression
    | ListExpression
    | BracketExpression;

FunctionCallExpression infers FunctionCallExpression:
    ({infer NamedExpression} element=[NamedElement:FeatureID])
    ({infer FunctionCallExpression.name=current} ('<' templates+=TypeOrExpression (',' templates+=TypeOrExpression)* '>')? '(' ArgumentSequence? ')')?;

fragment ArgumentSequence:
    arguments+=Expression (',' arguments+=Expression)*;

StructExpression infers StructExpression:
    'struct' '{' fields+=FeatureID '=' values+=Expression (',' fields+=FeatureID '=' values+=Expression)* '}';

ListExpression infers ListExpression:
    '[' (values+=Expression (',' values+=Expression)* ','?)? ']';

BracketExpression infers Expression:
    '(' Expression ({infer TupleExpression.values+=current} ',' values+=Expression)* ','? ')';

// Literal
IntLiteral:
    value=INT;

RealLiteral:
    value=REAL;

CharLiteral:
    value=CHAR;

BoolLiteral:
    value=BOOL;

NullLiteral:
    value=NULL;

// Type
Type infers Type:
    ListType
    ({infer UnionType.subtypes+=current} '|' subtypes+=Type)*;

ListType infers Type:
    (PrimitiveType | EnumType | StructType | AliasType | BracketType)
    // the precedence of list is higher than union
    ({infer ListType.base=current} '[' (capacity=Expression)? ']')*;

PrimitiveType infers PrimitiveType:
    name=('int' | 'real' | 'char' | 'bool' | 'Null');

EnumType infers EnumType:
    'enum' '{' members+=EnumMember (',' members+=EnumMember)* '}';

EnumMember infers EnumMember:
    name=FeatureID;

StructType infers StructType:
    'struct' '{' fields+=FieldName ':' types+=Type (',' fields+=FieldName ':' types+=Type)* '}';

FieldName infers StructField:
    name=FeatureID;

AliasType infers AliasType:
    alias=[NamedType:FeatureID];

BracketType infers Type:
    '(' Type ({infer TupleType.types+=current} ',' types+=Type)*')';

// Port Type
PortType infers PortType:
    direction=('in' | 'out') type=Type;

// Parameter Type
ParameterType infers ParameterType:
    'type' | FunctionType | InterfaceType;

NonInterfaceParameterType infers NonInterfaceParameterType:
    'type' | FunctionType;

FunctionType infers FunctionType:
    'func' '(' (argtypes+=Type (',' argtypes+=Type)*)? ')' ':' returntype=Type;

InterfaceType infers InterfaceType:
    'interface' '(' (porttypes+=PortType (',' porttypes+=PortType)*)? ')';

// Datatype rule
FeatureID returns string:
    'value' | 'reqRead' | 'reqWrite' | ID;

BOOL returns string:
    'true' | 'false';

NULL returns string:
    'null';

// Lexical rules
terminal REAL returns number: DECFRAC EXPONENT? | DECSEQ EXPONENT;
terminal INT returns number: BINSEQ | OCTSEQ | HEXSEQ | DECSEQ;
terminal CHAR returns string: /'[^'\\\s]'|'\\[abtnvfr0e\\']'|' '/;
terminal ID returns string: /[a-zA-Z_]\w*/;

terminal fragment BINSEQ: /0[bB][01]+/;
terminal fragment OCTSEQ: /0[oO][0-7]+/;
terminal fragment HEXSEQ: /0[xX][\da-fA-F]+/;
terminal fragment DECFRAC: /(([1-9]\d*|0)?\.\d+)/;
terminal fragment DECSEQ: /[1-9]\d*|0/;
terminal fragment EXPONENT: /[eE][+-]?\d+/;

// hidden terminal rules
hidden terminal WS: /\s+/;
hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;
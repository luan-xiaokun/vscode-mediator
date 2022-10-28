grammar Mediator

import './expression'
import './interface'
import './statement'
import './type'
import './typing'

entry Program:
    (typedefs+=TypeDefinition | constdefs+=ConstDefinition | functions+=FunctionDefinition | automatons+=AutomatonDefinition | systems+=SystemDefinition)*;

// Type Definition
TypeDefinition returns TypeDef:
    'typedef' type=TypeRule 'as' name=FeatureID ';';

// Constant Definition
ConstDefinition returns ConstDef:
    'const' expr=Expression 'as' name=FeatureID ';';

// System Definition
SystemDefinition returns System:
    'system' ('<' SystemTemplateList '>')? name=FeatureID
    '(' (ports+=PortTypingRule (',' ports+=PortTypingRule)*)? ')'
    '{'
        ('internals' internals+=InternalPort (',' internals+=InternalPort)* ';')?
        ('components' '{' (components+=ComponentTypingRule ';')+ '}')?
        'connections' '{' (connections+=Connection ';')+ '}'
    '}';

// Automaton Definition
AutomatonDefinition returns Automaton:
    'automaton' ('<' NonSystemTemplateList '>')? name=FeatureID
    '(' (ports+=PortTypingRule (',' ports+=PortTypingRule)*)? ')'
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
FunctionDefinition returns Function:
    'function' ('<' NonSystemTemplateList '>')? name=FeatureID
    '(' (arguments+=VariableTypingRule (',' arguments+=VariableTypingRule)*)? ')' ':' returntype=TypeRule
    '{' 
        ('variables' '{' (localvars+=MultipleVariableTyping ';')* '}')?
        'statements' '{' (statements+=FunctionStatement)* '}'
    '}';

// Named Identifiers
type NamedElement = VariableName | ConstDef | EnumMember | StructField | PortTyping | LoopVariableDeclaration | TemplateTyping | Function;

type NamedAutomaton = ComponentName | Automaton;

type NamedType = TypeDef | TemplateTyping;

// Connection
Connection returns Connection:
    InstantiationConnection | PortConnection;

InstantiationConnection returns InstantiationConnection:
    entity=ComponentInstantiation '(' ports+=AutomatonPort (',' ports+=AutomatonPort)* ')';

PortConnection returns PortConnection:
    (from+=AutomatonPort | '(' from+=AutomatonPort (',' from+=AutomatonPort)* ')')
    ('->' | '-(' options=PortConnectionOption ')->')
    (to+=AutomatonPort | '(' to+=AutomatonPort (',' to+=AutomatonPort)* ')');

AutomatonPort returns AutomatonPort:
    automaton=[NamedAutomaton:FeatureID] '.' port=[PortTyping:FeatureID];

PortConnectionOption returns PortConnectionOption:
    (sync='sync' ',' cast=('broadcast' | 'unicast'))
    | (sync='async' ',' cast=('broadcast' | 'unicast') ',' 'capacity' '=' capacity=Expression);

InternalPort returns InternalPort:
    name=FeatureID;

// Transition
Transition returns Transition:
    SingleTransition | GroupTransition;

SingleTransition returns SingleTransition:
    // (urgent?='urgent')?
    guard=Expression '->' (statements+=StatementOrSynchronization | '{' (statements+=StatementOrSynchronization)+ '}');

GroupTransition returns GroupTransition:
    // (urgent?='urgent')?
    'group' '{' (transitions+=SingleTransition)+ '}';

StatementOrSynchronization returns StatementOrSynchronization:
    Statement | Synchronization;

FeatureID returns string:
    'value' | 'reqRead' | 'reqWrite' | ID;

// Lexical rules
terminal REAL returns number: DECFRAC EXPONENT? | DECSEQ EXPONENT;
terminal INT returns number: BINSEQ | OCTSEQ | HEXSEQ | DECSEQ;
terminal CHAR returns string: /'[^'\\\s]'|'\\[abtnvfr0e\\']'|' '/;
terminal BOOL returns boolean: 'true' | 'false';
terminal NULL returns string: 'nil';
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
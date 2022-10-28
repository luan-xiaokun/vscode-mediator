import './mediator'

// Statement
Statement returns Statement:
    ';' | AssignmentStatement | ConditionalStatement | LoopStatement;

AssignmentStatement returns AssignmentStatement:
    left=Expression assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') right=Expression ';';

ConditionalStatement returns ConditionalStatement:
    'if' '(' condition=Expression ')'
    (then+=Statement | '{' (then+=Statement)* '}')
    ('else' (else+=Statement | '{' (else+=Statement)* '}'))?;

LoopStatement returns LoopStatement:
    'for'
    '(' declaration=LoopVariableDeclarationRule ';' condition=Expression ';' update=LoopVariableUpdate ')'
    (body+=Statement | '{' (body+=Statement)* '}');

LoopVariableDeclarationRule returns LoopVariableDeclaration:
    'let' name=FeatureID ':' type=TypeRule '=' value=Expression;

LoopVariableUpdate returns LoopVariableUpdate:
    var=[LoopVariableDeclaration:FeatureID] assign=('=' | '+=' | '-=' | '*=' | '/=' | '%=') expr=Expression;

// Synchronization
Synchronization returns Synchronization:
    'sync' ports+=[PortTyping:FeatureID] (',' ports+=[PortTyping:FeatureID])* ';';

// Function Statement
FunctionStatement returns FunctionStatement:
    ';' | AssignmentStatement | ReturnStatement | FunctionConditionalStatement | FunctionLoopStatement;

ReturnStatement returns ReturnStatement:
    'return' value=Expression;

FunctionConditionalStatement returns FunctionConditionalStatement:
    'if' '(' condition=Expression ')'
    (then+=FunctionStatement | '{' (then+=FunctionStatement)* '}')
    ('else' (else+=FunctionStatement | '{' (else+=FunctionStatement)* '}'))?;

FunctionLoopStatement returns FunctionLoopStatement:
    'for'
    '(' declaration=LoopVariableDeclarationRule ';' condition=Expression ';' update=LoopVariableUpdate ')'
    (body+=FunctionStatement | '{' (body+=FunctionStatement)* '}');

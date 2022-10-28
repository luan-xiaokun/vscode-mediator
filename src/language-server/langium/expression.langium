import './mediator'

// Expression
Expression returns Expression:
    LogicalOrExpression ({ConditionalExpression} '?' Expression ':' Expression)?;

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
        | ({AttributeExpression.previous=current} '.' field=([StructField:ID] | 'value' | 'reqRead' | 'reqWrite'))
    )*;

PrimaryExpression returns Expression:
    Literal
    | FunctionCallExpression
    | StructExpression
    | ListExpression
    | BracketExpression;

FunctionCallExpression returns FunctionCallExpression:
    ({NamedExpression} element=[NamedElement:FeatureID])
    ({FunctionCallExpression.name=current} '(' ArgumentSequence? ')')?;

fragment ArgumentSequence:
    arguments+=Expression (',' arguments+=Expression)*;

StructExpression returns StructExpression:
    'struct' '{' fields+=FeatureID '=' values+=Expression (',' fields+=FeatureID '=' values+=Expression)* '}';

ListExpression returns ListExpression:
    '[' (values+=Expression (',' values+=Expression)* ','?)? ']';

BracketExpression returns Expression:
    '(' Expression ({TupleExpression.values+=current} ',' values+=Expression)* ','? ')';

// Literal
Literal returns Literal:
    ({IntLiteral} value=INT) | ({RealLiteral} value=REAL) | ({CharLiteral} value=CHAR)
    | ({BoolLiteral} value=BOOL) | ({NullLiteral} value=NULL);
import './mediator'

TypeOrExpressionRule returns TypeOrExpression:
    (PrimitiveType | EnumType | StructTypeRule | EqualityExpression)
    ({ListType.base=current} '[' (capacity=Expression)? ']')*
    ({UnionType.types+=current} '|' types+=TypeOrExpressionRule)*;
import './mediator'

// Type
TypeRule returns Type:
    (PrimitiveType | EnumType | StructTypeRule | AliasType | BracketType)
    // the precedence of list is higher than union
    ({ListType.base=current} '[' (capacity=Expression)? ']')*
    ({UnionType.types+=current} '|' types+=TypeRule)*;

PrimitiveType returns PrimitiveType:
    name=('int' | 'real' | 'char' | 'bool' | 'null');

EnumType returns EnumType:
    'enum' '{' members+=EnumMemberRule (',' members+=EnumMemberRule)* '}';

EnumMemberRule returns EnumMember:
    name=FeatureID;

StructTypeRule returns StructType:
    'struct' '{' fields+=FieldName ':' types+=TypeRule (',' fields+=FieldName ':' types+=TypeRule)* '}';

FieldName returns StructField:
    name=FeatureID;

AliasType returns AliasType:
    alias=[NamedType:FeatureID];

BracketType returns Type:
    '(' TypeRule ({TupleType.types+=current} ',' types+=TypeRule)*')';

// Port Type
PortType returns PortType:
    direction=('in' | 'out') type=TypeRule;

// Parameter Type
ParameterType returns ParameterType:
    AbstractType | FunctionType | InterfaceType;

NonInterfaceParameterType returns NonInterfaceParameterType:
    AbstractType | FunctionType;

FunctionType returns FunctionType:
    'func' '(' (argtypes+=TypeRule (',' argtypes+=TypeRule)*)? ')' ':' returntype=TypeRule;

InterfaceType returns InterfaceType:
    'interface' '(' (porttypes+=PortType (',' porttypes+=PortType)*)? ')';

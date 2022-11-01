// // TypeDef
// interface TypeDef {
//     ^type: Type;
//     name: string;
// }

// // ConstDef
// interface ConstDef {
//     expr: Expression;
//     name: string;
// }

// // System
// interface System {
//     name: string;
//     templates: TemplateTyping[];
//     ports: PortTyping[];
//     internals: InternalPort[];
//     components: ComponentTyping[];
//     connections: Connection[];
// }

// // Automaton
// interface Automaton {
//     name: string;
//     templates: TemplateTyping[];
//     ports: PortTyping[];
//     localvars: MultipleVariableTyping[];
//     initial: Statement[];
//     transitions: Transition[];
//     invariants: Expression[];
// }

// // Function
// interface Function {
//     name: string;
//     templates: TemplateTyping[];
//     arguments: VariableTyping[];
//     returntype: Type;
//     localvars: MultipleVariableTyping[];
//     statements: FunctionStatement[];
// }

// // TypeOrExpression
// type TypeOrExpression =
//     PrimitiveType | EnumType | StructType | Expression
//     | ListType | UnionType;

// // Connection
// type Connection = InstantiationConnection | PortConnection;

// interface InstantiationConnection {
//     entity: ComponentInstantiation;
//     ports: AutomatonPort[];
// }

// interface PortConnection {
//     from: AutomatonPort[];
//     to: AutomatonPort[];
//     options?: PortConnectionOption;
// }

// interface AutomatonPort {
//     automaton: @NamedAutomaton;
//     port: @PortTyping;
// }

// interface ScopedAutomaton {
//     previous?: @NamedAutomaton;
//     automaton: @NamedAutomaton;
// }

// interface PortConnectionOption {
//     sync: 'sync' | 'async';
//     cast: 'broadcast' | 'unicast';
//     capacity?: Expression;
// }

// interface InternalPort {
//     name: string;
// }

// // Transition
// type Transition = SingleTransition | GroupTransition;

// interface SingleTransition {
// // urgent?: boolean;
//     guard: Expression;
//     statements: StatementOrSynchronization[];
// }

// interface GroupTransition {
// //urgent?: boolean;
//     transitions: SingleTransition[];
// }

// type StatementOrSynchronization = Statement | Synchronization;

// // Statement
// type Statement = AssignmentStatement | ConditionalStatement;

// interface AssignmentStatement {
//     left: Expression;
//     assign: '=' | '+=' | '-=' | '*=' | '/=' | '%=';
//     right: Expression;
// }

// interface ConditionalStatement {
//     condition: Expression;
//     then: Statement[];
//     else: Statement[];
// }

// interface LoopStatement {
//     declaration: LoopVariableDeclaration;
//     condition: Expression;
//     update: LoopVariableUpdate;
//     body: Statement[];
// }

// interface LoopVariableDeclaration {
//     name: string;
//     ^type: Type;
//     value: Expression;
// }

// interface LoopVariableUpdate {
//     var: @LoopVariableDeclaration;
//     assign: '=' | '+=' | '-=' | '*=' | '/=' | '%=';
//     expr: Expression;
// }

// // Synchronization
// interface Synchronization {
//     ports: @PortTyping[];
// }

// // Function Statement
// type FunctionStatement =
//     AssignmentStatement | ReturnStatement | FunctionConditionalStatement | FunctionLoopStatement;

// interface ReturnStatement {
//     value: Expression;
// }

// interface FunctionConditionalStatement {
//     condition: Expression;
//     then: FunctionStatement[];
//     else: FunctionStatement[];
// }

// interface FunctionLoopStatement {
//     declaration: LoopVariableDeclaration;
//     condition: Expression;
//     update: LoopVariableUpdate;
//     body: FunctionStatement[];
// }

// // Variable Typing
// interface VariableTyping {
//     var: VariableName;
//     ^type: Type;
// }

// interface MultipleVariableTyping {
//     vars: VariableName[];
//     ^type: Type;
// }

// interface VariableName {
//     name: string;
// }

// // Port Typing
// interface PortTyping {
//     name: string;
//     ^type: PortType;
// }

// // Component Typing
// interface ComponentTyping {
//     components: ComponentName[];
//     ^type: ComponentInstantiation;
// }

// interface ComponentName {
//     name: string;
// }

// interface ComponentInstantiation {
//     component: @NamedAutomaton;
//     templates: TypeOrExpression[];
// }

// // Template Typing
// interface TemplateTyping {
//     name: string;
//     ^type: ParameterType | Type;
// }

// // Expression
// type Expression = 
//     ConditionalExpression | BinaryExpression | PrefixExpression
//     | IndexingExpression | AttributeExpression | FunctionCallExpression
//     | NamedExpression | StructExpression | ListExpression | TupleExpression
//     | Literal;

// interface ConditionalExpression {
//     condition: Expression;
//     then: Expression;
//     else: Expression;
// }

// interface BinaryExpression {
//     left: Expression;
//     operator: string;
//     right: Expression;
// }

// interface PrefixExpression {
//     operator: string;
//     operand: Expression;
// }

// interface IndexingExpression {
//     base: Expression;
//     index: Expression;
// }

// interface AttributeExpression {
//     previous: Expression;
//     field: @NamedElement | string;
// }

// interface FunctionCallExpression {
//     name?: @NamedElement;
//     templates: TypeOrExpression[];
//     arguments: Expression[];
// }

// interface NamedExpression {
//     element: @NamedElement;
// }

// interface StructExpression {
//     fields: string[];
//     values: Expression[];
// }

// interface IterableExpression {
//     values: Expression[];
// }

// interface ListExpression extends IterableExpression {}

// interface TupleExpression extends IterableExpression {}

// // Literal
// type Literal = IntLiteral | RealLiteral | CharLiteral | BoolLiteral | NullLiteral;

// interface IntLiteral {
//     value: number;
// }
// interface RealLiteral {
//     value: number;
// }
// interface CharLiteral {
//     value: string;
// }
// interface BoolLiteral {
//     value: boolean
// }
// interface NullLiteral {
//     value: string;
// }

// // Type
// type Type =
//     PrimitiveType | EnumType | StructType | AliasType
//     | ListType | TupleType | UnionType;

// interface PrimitiveType {
//     name: 'int' | 'real' | 'char' | 'bool' | 'null';
// }

// interface EnumType {
//     members: EnumMember[];
// }

// interface EnumMember {
//     name: string;
// }

// interface StructType {
//     fields: StructField[];
//     types: Type[];
// }

// interface StructField {
//     name: string;
// }

// interface AliasType {
//     alias: @NamedType;
// }

// interface ListType {
//     base: Type;
//     capacity?: Expression;
// }

// interface IterableType {
//     types: Type[];
// }

// interface TupleType extends IterableType {}

// interface UnionType extends IterableType {}

// // Port Type
// interface PortType {
//     direction: 'in' | 'out';
//     ^type: Type;
// }

// // Parameter Type
// type ParameterType = AbstractType | FunctionType | InterfaceType;

// type NonInterfaceParameterType = AbstractType | FunctionType;

// AbstractType returns string:
//     'type';

// interface FunctionType {
//     returntype: Type;
//     argtypes: Type[];
// }

// interface InterfaceType {
//     porttypes: PortType[];
// }
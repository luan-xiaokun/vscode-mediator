import { AstNode } from "langium";
import { BoolLiteral, CharLiteral, Expression, IntLiteral, RealLiteral } from "../generated/ast";

export type TypeDescription =
    // nothing except type can be of abstract type
    AbstractTypeDescription
    | NullTypeDescription
    | IntTypeDescription
    | RealTypeDescription
    | CharTypeDescription
    | BoolTypeDescription
    | EnumTypeDescription
    | StructTypeDescription
    | ListTypeDescription
    | TupleTypeDescription
    | UnionTypeDescription
    // port is used in both expression (p.value) and component&connection
    | PortTypeDescription
    // function is used in expression, but any variable cannot be of function type
    | FunctionTypeDescription
    // automaton is only used in component&connection
    | AutomatonTypeDescription
    | ErrorType
    ;

export interface AbstractTypeDescription {
    readonly $type: "type";
}

export function createAbstractType(): AbstractTypeDescription {
    return {
        $type: "type"
    };
}

export function isAbstractType(item: TypeDescription): item is AbstractTypeDescription {
    return item.$type == "type";
}

export interface NullTypeDescription {
    readonly $type: "null";
}

export function createNullType(): NullTypeDescription {
    return {
        $type: "null"
    };
}

export function isNullType(item: TypeDescription): item is NullTypeDescription {
    return item.$type == "null";
}

export interface IntTypeDescription {
    readonly $type: "int";
    readonly literal?: IntLiteral;
}

export function createIntType(literal?: IntLiteral): IntTypeDescription {
    return {
        $type: "int",
        literal
    };
}

export function isIntType(item: TypeDescription): item is IntTypeDescription {
    return item.$type == "int";
}

export interface RealTypeDescription {
    readonly $type: "real";
    readonly literal?: RealLiteral;
}

export function createRealType(literal?: RealLiteral): RealTypeDescription {
    return {
        $type: "real",
        literal
    }
}

export function isRealType(item: TypeDescription): item is RealTypeDescription {
    return item.$type == "real";
}

export interface CharTypeDescription {
    readonly $type: "char";
    readonly literal?: CharLiteral;
}

export function createCharType(literal?: CharLiteral): CharTypeDescription {
    return {
        $type: "char",
        literal
    }
}

export function isCharType(item: TypeDescription): item is CharTypeDescription {
    return item.$type == "char";
}

export interface BoolTypeDescription {
    readonly $type: "bool";
    readonly literal?: BoolLiteral;
}

export function createBoolType(literal?: BoolLiteral): BoolTypeDescription {
    return {
        $type: "bool",
        literal
    }
}

export function isBoolType(item: TypeDescription): item is BoolTypeDescription {
    return item.$type == "bool";
}


export interface EnumTypeDescription {
    readonly $type: "enum";
    readonly members: string[];
}

export function createEnumType(members: string[]): EnumTypeDescription {
    return {
        $type: "enum",
        members
    }
}

export function isEnumType(item: TypeDescription): item is EnumTypeDescription {
    return item.$type == "enum";
}

export interface StructTypeDescription {
    readonly $type: "struct";
    readonly fields: string[];
    readonly fieldTypes: TypeDescription[];
}

export function createStructType(fields: string[], fieldTypes: TypeDescription[]): StructTypeDescription {
    return {
        $type: "struct",
        fields,
        fieldTypes
    };
}

export function isStructType(item: TypeDescription): item is StructTypeDescription {
    return item.$type == "struct";
}

export interface ListTypeDescription {
    readonly $type: "list";
    readonly base: TypeDescription;
    readonly capacity?: Expression;
}

export function createListType(base: TypeDescription, capacity?: Expression): ListTypeDescription {
    return {
        $type: "list",
        base,
        capacity
    }
}

export function isListType(item: TypeDescription): item is ListTypeDescription {
    return item.$type == "list";
}

export interface TupleTypeDescription {
    readonly $type: "tuple";
    readonly types: TypeDescription[];
}

export function createTupleType(types: TypeDescription[]): TupleTypeDescription {
    return {
        $type: "tuple",
        types
    }
}

export function isTupleType(item: TypeDescription): item is TupleTypeDescription {
    return item.$type == "tuple";
}

export interface UnionTypeDescription {
    readonly $type: "union";
    readonly types: TypeDescription[];
}

export function createUnionType(types: TypeDescription[]): UnionTypeDescription {
    return {
        $type: "union",
        types
    };
}

export function isUnionType(item: TypeDescription): item is UnionTypeDescription {
    return item.$type == "union";
}

export interface PortTypeDescription {
    readonly $type: "port";
    readonly direction: "in" | "out";
    readonly valueType: TypeDescription;
}

export function createPortType(direction: "in" | "out", valueType: TypeDescription): PortTypeDescription {
    return {
        $type: "port",
        direction,
        valueType: valueType
    };
}

export function isPortType(item: TypeDescription): item is PortTypeDescription {
    return item.$type == "port";
}

export interface FunctionTypeDescription {
    readonly $type: "function";
    readonly returnType: TypeDescription;
    readonly paramsType: TypeDescription[];
}

export function createFunctionType(returnType: TypeDescription, paramsType: TypeDescription[]): FunctionTypeDescription {
    return {
        $type: "function",
        returnType,
        paramsType
    };
}

export function isFunctionType(item: TypeDescription): item is FunctionTypeDescription {
    return item.$type == "function";
}

export interface AutomatonTypeDescription {
    readonly $type: "automaton";
    readonly ports: PortTypeDescription[];
}

export function createAutomatonType(ports: PortTypeDescription[]): AutomatonTypeDescription {
    return {
        $type: "automaton",
        ports
    };
}

export function isAutomatonType(item: TypeDescription): item is AutomatonTypeDescription {
    return item.$type == "automaton";
}

export interface ErrorType {
    readonly $type: "error";
    readonly source?: AstNode;
    readonly message: string;
}

export function createErrorType(message: string, source?: AstNode): ErrorType {
    return {
        $type: "error",
        message,
        source
    };
}

export function isErrorType(item: TypeDescription): item is ErrorType {
    return item.$type === "error";
}

export function typeToString(item: TypeDescription): string {
    return item.$type;
}

export function isNumber(item: TypeDescription): boolean {
    if (["int", "real", "bool"].includes(item.$type)) {
        return true;
    } else if (item.$type == "union") {
        return item.types.every(isNumber);
    }
    return false;
}
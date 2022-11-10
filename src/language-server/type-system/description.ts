import { AstNode } from "langium";
import { BoolLiteral, CharLiteral, EnumMember, Expression, IntLiteral, RealLiteral } from "../generated/ast";

export type TypeDescription =
    NullTypeDescription
    | IntTypeDescription
    | RealTypeDescription
    | CharTypeDescription
    | BoolTypeDescription
    | AbstractTypeDescription
    | EnumTypeDescription
    | StructTypeDescription
    | ListTypeDescription
    | TupleTypeDescription
    | UnionTypeDescription
    | FunctionTypeDescription
    | InterfaceTypeDescription
    | PortTypeDescription
    | LoopVariableTypeDescription
    | ErrorTypeDescription
    ;

export interface NullTypeDescription {
    readonly $type: "null";
}

export function createNullType(): NullTypeDescription {
    return {
        $type: "null"
    };
}

export function isNullType(item: TypeDescription): item is NullTypeDescription {
    return item.$type === "null";
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
    return item.$type === "int";
}

export interface RealTypeDescription {
    readonly $type: "real";
    readonly literal?: RealLiteral;
}

export function createRealType(literal?: RealLiteral): RealTypeDescription {
    return {
        $type: "real",
        literal
    };
}

export function isRealType(item: TypeDescription): item is RealTypeDescription {
    return item.$type === "real";
}

export interface CharTypeDescription {
    readonly $type: "char";
    readonly literal?: CharLiteral;
}

export function createCharType(literal?: CharLiteral): CharTypeDescription {
    return {
        $type: "char",
        literal
    };
}

export function isCharType(item: TypeDescription): item is CharTypeDescription {
    return item.$type === "char";
}

export interface BoolTypeDescription {
    readonly $type: "bool";
    readonly literal?: BoolLiteral;
}

export function createBoolType(literal?: BoolLiteral): BoolTypeDescription {
    return {
        $type: "bool",
        literal
    };
}

export function isBoolType(item: TypeDescription): item is BoolTypeDescription {
    return item.$type === "bool";
}

export interface AbstractTypeDescription {
    readonly $type: "type";
    readonly concreteType?: TypeDescription;
}

export function createAbstractType(concreteType?: TypeDescription): AbstractTypeDescription {
    return {
        $type: "type",
        concreteType
    };
}

export function isAbstractType(item: TypeDescription): item is AbstractTypeDescription {
    return item.$type === "type";
}

export interface EnumTypeDescription {
    readonly $type: "enum";
    readonly members: EnumMember[];
}

export function createEnumType(members: EnumMember[]): EnumTypeDescription {
    return {
        $type: "enum",
        members
    };
}

export function isEnumType(item: TypeDescription): item is EnumTypeDescription {
    return item.$type === "enum";
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
    return item.$type === "struct";
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
    };
}

export function isListType(item: TypeDescription): item is ListTypeDescription {
    return item.$type === "list";
}

export interface TupleTypeDescription {
    readonly $type: "tuple";
    readonly types: TypeDescription[];
}

export function createTupleType(types: TypeDescription[]): TupleTypeDescription {
    return {
        $type: "tuple",
        types
    };
}

export function isTupleType(item: TypeDescription): item is TupleTypeDescription {
    return item.$type === "tuple";
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
    return item.$type === "union";
}

export interface FunctionTypeDescription {
    readonly $type: "func";
    readonly returnType: TypeDescription;
    readonly argumentTypes: TypeDescription[];
}

export function createFunctionType(returnType: TypeDescription, argumentTypes: TypeDescription[]): FunctionTypeDescription {
    return {
        $type: "func",
        returnType,
        argumentTypes
    };
}

export function isFunctionType(item: TypeDescription): item is FunctionTypeDescription {
    return item.$type === "func";
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
        valueType
    };
}

export function isPortType(item: TypeDescription): item is PortTypeDescription {
    return item.$type === "port";
}

export interface InterfaceTypeDescription {
    readonly $type: "interface";
    readonly portTypes: PortTypeDescription[];
}

export function createInterfaceType(portTypes: PortTypeDescription[]): InterfaceTypeDescription {
    return {
        $type: "interface",
        portTypes
    };
}

export function isInterfaceType(item: TypeDescription): item is InterfaceTypeDescription {
    return item.$type === "interface";
}

export interface LoopVariableTypeDescription {
    readonly $type: "loop-var";
    readonly type: TypeDescription;
}

export function createLoopVariableType(type: TypeDescription): LoopVariableTypeDescription {
    return {
        $type: "loop-var",
        type
    };
}

export function isLoopVariableType(item: TypeDescription): item is LoopVariableTypeDescription {
    return item.$type === "loop-var";
}

export interface ErrorTypeDescription {
    readonly $type: "error";
    readonly message: string;
    readonly source?: AstNode;
}

export function createErrorType(message: string, source?: AstNode): ErrorTypeDescription {
    return {
        $type: "error",
        message,
        source
    };
}

export function isErrorType(item: TypeDescription): item is ErrorTypeDescription {
    return item.$type === "error";
}

export function isPrimitiveType(item: TypeDescription):
    item is IntTypeDescription | RealTypeDescription | CharTypeDescription | BoolTypeDescription | NullTypeDescription {
    return ["int", "real", "char", "bool", "null"].includes(item.$type);
}

export function isParameterType(item: TypeDescription):
    item is AbstractTypeDescription | FunctionTypeDescription | InterfaceTypeDescription {
    return ["type", "func", "interface"].includes(item.$type);
}

export function isExpressionType(item: TypeDescription):
    item is IntTypeDescription | RealTypeDescription | CharTypeDescription | BoolTypeDescription | NullTypeDescription | EnumTypeDescription | StructTypeDescription | ListTypeDescription | TupleTypeDescription | UnionTypeDescription | PortTypeDescription {
    return ["int", "real", "char", "bool", "null", "enum", "struct", "list", "tuple", "union", "port"].includes(item.$type);
}

export function typeToString(item: TypeDescription): string {
    if (isPrimitiveType(item)) {
        const suffix = (item.$type !== "null" && item.literal) ? ` ${item.literal}` : "";
        return `${item.$type}` + suffix;
    } else if (item.$type === "enum") {
        const members = item.members.map(e => e.name).join(", ");
        return `enum {${members}}`;
    } else if (item.$type === "struct") {
        const structs = item.fields.map((value, index) => {
            `${value}: ${typeToString(item.fieldTypes[index])}`
        }).join(", ");
        return `struct {${structs}}`
    } else if (item.$type === "list") {
        return typeToString(item.base) + `[${item.capacity ? "n" : ""}]`;
    } else if (item.$type === "tuple") {
        const types = item.types.map(e => typeToString(e)).join(", ");
        return `(${types})`;
    } else if (item.$type === "union") {
        return item.types.map(e => typeToString(e)).join(" | ");
    } else if (item.$type === "type") {
        const suffix = item.concreteType ? ` (${item.concreteType})` : "";
        return "type" + suffix;
    } else if (item.$type === "func") {
        const params = item.argumentTypes.map(e => `${typeToString(e)}`).join(", ");
        return `func (${params}): ${typeToString(item.returnType)}`;
    } else if (item.$type === "interface") {
        const ports = item.portTypes.map(e => e.direction + ` ${typeToString(e.valueType)}`).join(", ");
        return `interface (${ports})`;
    } else if (item.$type === "port") {
        return item.direction + ` ${typeToString(item.valueType)}`;
    } else if (item.$type === "loop-var") {
        return `loop-var ${typeToString(item.type)}`;
    } else {
        const suffix = item.source ? ` from ${item.source}` : "";
        return `error: '${item.message}'` + suffix;
    }
}
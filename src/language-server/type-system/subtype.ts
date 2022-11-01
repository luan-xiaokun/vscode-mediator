import { isIntLiteral } from "../generated/ast";
import { isAbstractType, isAutomatonType, isBoolType, isCharType, isEnumType, isFunctionType, isIntType, isListType, isNullType, isPortType, isRealType, isStructType, isTupleType, isUnionType, TypeDescription } from "./descriptions";

export function isSubtypeOf(from: TypeDescription, to: TypeDescription): boolean {
    // structural recursion on `to`
    if (isNullType(to)) {
        return from.$type === "null";
    } else if (isCharType(to)) {
        return from.$type === "char";
    } else if (isIntType(to)) {
        return from.$type === "int" || from.$type === "bool";
    } else if (isBoolType(to) || isRealType(to)) {
        return ["int", "real", "char", "bool"].includes(from.$type);
    }
    if (isEnumType(to)) {
        // for enum type, members of `from` must be contained in `to`
        return from.$type === "enum" && from.members.length <= to.members.length
            && arrayContainedIn(from.members, to.members);
    } else if (isStructType(to)) {
        // for struct type, fields of `to` must be contained in `from`, whose types are supertype of those of `from`
        return from.$type === "struct" && from.fields.length >= to.fields.length
            && arrayContainedIn(to.fields, from.fields)
            && to.fields.every((value, index) => {
                return isSubtypeOf(from.fieldTypes[from.fields.indexOf(value)], to.fieldTypes[index])
            });
    } else if (isListType(to)) {
        // for list type
        if (from.$type === "list") {
            // `to` must also be of list type
            if (!to.capacity) {
                // if `to` is unbounded, `from` should also be unbounded with proper base type
                return !from.capacity && isSubtypeOf(from.base, to.base);
            } else {
                // otherwise, `from` should have larger capacity with proper base type
                if (!from.capacity) {
                    return isSubtypeOf(from.base, to.base);
                }
                // TODO: finer capacity check
                if (isIntLiteral(from.capacity) && isIntLiteral(to.capacity)) {
                    return from.capacity.value >= to.capacity.value
                        && isSubtypeOf(from.base, to.base);
                }
                return isSubtypeOf(from.base, to.base);
            }
        }
        return false;
    } else if (isTupleType(to)) {
        // for tuple type, `from` must be of the same length and have proper sub-types
        return from.$type === "tuple" && from.types.length === to.types.length
            && from.types.every((value, index) => { return isSubtypeOf(value, to.types[index]) });
    } else if (isUnionType(to)) {
        // for union type, `from` should be subtype of at least one of those types
        if (from.$type === "union") {
            // when `from` is also a union type, each sub-type of `from` should be also subtype of `to`
            return from.types.every((value) => { return isSubtypeOf(value, to) });
        } else {
            return to.types.some((value) => { return isSubtypeOf(from, value) });
        }
    } else if (isAbstractType(to)) {
        // for type type, only abstract type can be subtype of abstract type
        return from.$type === "type";
    } else if (isPortType(to)) {
        // for port type, its subtype port has same direction and proper value type
        return from.$type === "port" && from.direction === to.direction && isSubtypeOf(from.valueType, to.valueType);
    } else if (isFunctionType(to)) {
        // for function type, `from` should have matching parameters with same length and proper types
        // return type of `from` should also be subtype of that of `to`
        return from.$type === "function" && from.paramsType.length === to.paramsType.length
            && isSubtypeOf(from.returnType, to.returnType)
            && from.paramsType.every((value, index) => { return isSubtypeOf(value, to.paramsType[index]) });
    } else if (isAutomatonType(to)) {
        // for automaton type, the ports of `from` should be subtype of those of `to`
        // they should have same number of ports, but this does not seem to be called ever
        if (from.$type === "automaton" && from.ports.length === to.ports.length) {
            // this is more difficult than I expected :(
            // it seems like a maximum matching problem :)
            // TODO: implement this
            return true;
        }
        return false;
    }
    // leaving error type
    return from.$type === to.$type;
}

function arrayContainedIn<T>(array1: Array<T>, array2: Array<T>): boolean {
    return array1.every((value) => { return array2.includes(value) });
}
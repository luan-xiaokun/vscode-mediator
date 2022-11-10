import { TypeDescription, UnionTypeDescription } from "./description";

export function isLegalOperation(operator: string, left: TypeDescription, right?: TypeDescription, third?: TypeDescription): boolean {
    if (operator === "+" || operator === "-") {
        if (!right) {
            return isSubsetOf(left, ["int", "real", "bool"]);
        }
        return isSubsetOf(left, ["int", "real", "bool"])
            && isSubsetOf(right, ["int", "real", "bool"]);
    } else if (["**", "*", "/", "%"].includes(operator)) {
        if (!right) return false;
        return isSubsetOf(left, ["int", "real", "bool"])
            && isSubsetOf(right, ["int", "real", "bool"]);
    } else if (["==", "!=", "&&", "||"].includes(operator)) {
        if (!right) return false;
        return isSubsetOf(left, ["int", "real", "bool", "char", "null", "enum", "list", "tuple"])
            && isSubsetOf(right, ["int", "real", "bool", "char", "null", "enum", "list", "tuple"]);
    } else if (["<", ">", "<=", "<="].includes(operator)) {
        if (!right) return false;
        return isSubsetOf(left, ["int", "real", "bool"])
            && isSubsetOf(right, ["int", "real", "bool"])
            || left.$type === "char" && right.$type === "char";
    } else if (operator === "!") {
        if (right) return false;
        return isSubsetOf(left, ["int", "real", "bool", "char", "null", "enum", "list", "tuple"]);
    }
    return false;
}

export function isUnionSubsetOf(union: UnionTypeDescription, items: string[]): boolean {
    if (items.length === 0) return false;
    return union.types.every(subtype => {
        (subtype.$type !== "union") && items.includes(subtype.$type)
            || (subtype.$type === "union") && isUnionSubsetOf(subtype, items)
    });
}

export function isSubsetOf(type: TypeDescription, items: string[]): boolean {
    return items.includes(type.$type) || type.$type === "union" && isUnionSubsetOf(type, items);
}
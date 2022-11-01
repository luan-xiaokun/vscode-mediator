import { TypeDescription, isNumber } from "./descriptions";

export function isLegalOperation(operator: string, left: TypeDescription, right?: TypeDescription, last?: TypeDescription): boolean {
    if (["+", "-", "*", "/", "%", "**"].includes(operator)) {
        if (!right) {
            return isNumber(left);
        }
        return isNumber(left) && isNumber(right);
    } else if (["!", "==", "!=", "&&", "||"].includes(operator)) {
        if (!right) {
            return isNumber(left) || left.$type === "char" || left.$type === "null";
        }
        return (isNumber(left) || left.$type === "char" || left.$type === "null")
            && (isNumber(right) || right.$type === "char" || right.$type === "null");
    } else if (right && ["<", ">", "<=", ">="].includes(operator)) {
        return (isNumber(left) && isNumber(right)) || (left.$type === "char" && right.$type === "char");
    } else if (operator === "?") {  // condition ? then : else
        return isNumber(left) && right?.$type === last?.$type;
    }
    return false;
}
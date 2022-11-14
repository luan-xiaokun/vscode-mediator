import { AstNode } from "langium";
import { Expression, IntLiteral, isAbstractType, isAliasType, isAttributeExpression, isAutomaton, isBinaryExpression, isBoolLiteral, isCharLiteral, isComponentInstantiation, isConditionalExpression, isConstDef, isEnumMember, isEnumType, isExpression, isFunctionCallExpression, isFunctionDef, isFunctionType, isIndexingExpression, isIntLiteral, isListExpression, isListType, isNamedExpression, isNullLiteral, isParameterType, isPortType, isPortTyping, isPrefixExpression, isPrimitiveType, isRealLiteral, isStructExpression, isStructField, isStructType, isTemplateTyping, isTupleExpression, isTupleType, isType, isTypeDef, isUnionType, isVariableName, StructField, Type } from "../generated/ast";
import { createAbstractType, createAnyType, createBoolType, createCharType, createEnumType, createErrorType, createFunctionType, createInterfaceType, createIntType, createListType, createNullType, createPortType, createRealType, createStructType, createTupleType, createUnionType, TypeDescription } from "./description";
import { isSubtypeOf } from "./subtype";

export function inferType(node: AstNode | undefined, cache: Map<AstNode, TypeDescription>): TypeDescription {
    let type: TypeDescription | undefined;
    if (!node) {
        return createErrorType("Could not infer type for undefined", node);
    }
    const existing = cache.get(node);
    if (existing) {
        return existing;
    }
    // prevent recursive inference errors
    cache.set(node, createErrorType("Recursive definition", node));
    if (isExpression(node)) {
        type = inferExpression(node, cache);
    } else if (isType(node)) {
        type = inferTypeRef(node, cache);
    } else if (isParameterType(node)) {
        if (isAbstractType(node)) {
            type = createAbstractType();
        } else if (isFunctionType(node)) {
            type = createFunctionType(
                inferTypeRef(node.returntype, cache),
                node.argtypes.map(value => inferTypeRef(value, cache))
            );
        } else {
            type = createInterfaceType(
                node.porttypes.map(value => inferType(value, cache))
            );
        }
    } else if (isPortType(node)) {
        type = createPortType(node.direction, inferTypeRef(node.type, cache));
    } else if (isComponentInstantiation(node)) {
        if (node.component.ref) {
            const ref = node.component.ref;
            if (isAutomaton(ref)) {
                type = createInterfaceType(
                    ref.ports.map(value => inferType(value.type, cache))
                );
            } else {
                type = inferType(ref.$container.type, cache);
            }
        }
    } else if (isTypeDef(node)) {
        type = inferTypeRef(node.type, cache);
    } else if (isConstDef(node)) {
        type = inferExpression(node.expr, cache);
    }

    if (!type) {
        type = createErrorType("Could not infer type for " + node.$type, node);
    }

    cache.set(node, type);

    return type;
}

export function inferExpression(node: Expression, cache: Map<AstNode, TypeDescription>): TypeDescription {
    const existing = cache.get(node);
    if (existing) {
        return existing;
    }
    let type: TypeDescription;
    if (isIntLiteral(node)) {
        type = createIntType(node);
    } else if (isRealLiteral(node)) {
        type = createRealType(node);
    } else if (isCharLiteral(node)) {
        type = createCharType(node);
    } else if (isBoolLiteral(node)) {
        type = createBoolType(node);
    } else if (isNullLiteral(node)) {
        type = createNullType();
    } else if (isListExpression(node)) {
        const capacity = node.values.length > 0 ? { $type: "IntLiteral", value: node.values.length } as IntLiteral : undefined;
        if (!capacity) {
            type = createListType(createAnyType(), capacity, true);
        } else {
            const baseType = computeLeastUpperBound(cache, ...node.values);
            type = createListType(baseType, capacity);
        }
    } else if (isTupleExpression(node)) {
        type = createTupleType(node.values.map(e => inferExpression(e, cache)));
    } else if (isStructExpression(node)) {
        type = createStructType(node.fields.map(value => { return { $type: "StructField", name: value } as StructField }), node.values.map(e => inferExpression(e, cache)));
    } else if (isNamedExpression(node)) {
        const ref = node.element.ref;
        if (ref) {
            if (isVariableName(ref)) {
                type = inferTypeRef(ref.$container.type, cache);
            } else if (isConstDef(ref)) {
                type = inferExpression(ref.expr, cache);
            } else if (isEnumMember(ref)) {
                type = createEnumType(ref.$container.members);
            } else if (isFunctionDef(ref)) {
                type = createFunctionType(
                    inferTypeRef(ref.returntype, cache),
                    ref.arguments.map(value => inferTypeRef(value.type, cache))
                );
            } else if (isPortTyping(ref)) {
                type = createPortType(ref.type.direction, inferTypeRef(ref.type.type, cache));
            } else if (isStructField(ref)) {
                type = createStructType(
                    ref.$container.fields,
                    ref.$container.types.map(value => inferTypeRef(value, cache))
                );
            } else if (isTemplateTyping(ref)) {
                if (isType(ref.type)) {
                    type = inferTypeRef(ref.type, cache);
                } else if (isAbstractType(ref.type)) {
                    type = createAbstractType();
                } else if (isFunctionType(ref.type)) {
                    type = createFunctionType(
                        inferTypeRef(ref.type.returntype, cache),
                        ref.type.argtypes.map(value => inferTypeRef(value, cache))
                    );
                } else {
                    type = createInterfaceType(
                        ref.type.porttypes.map(value => inferType(value, cache))
                    );
                }
            } else {
                type = createErrorType("Could not infer reference for this node", node);
            }
        } else {
            type = createErrorType("Reference cannot be resolved", node);
        }
    } else if (isIndexingExpression(node)) {
        const baseType = inferExpression(node.base, cache);
        const indexType = inferExpression(node.index, cache);
        if (!['bool', 'char', 'int'].includes(indexType.$type)) {
            type = createErrorType("Index expression inferred as " + indexType.$type, node);
        } else {
            type = baseType;
        }
    } else if (isAttributeExpression(node)) {
        const previousType = inferExpression(node.previous, cache);
        if (previousType.$type === "struct") {
            const field = node.field && node.field.ref ? node.field.ref.name : node.portField;
            type = createErrorType("Field name '" + field + "'not found", node);
            if (field) {
                const index = previousType.fields.map(value => value.name).indexOf(field);
                if (index >= 0) {
                    type = previousType.fieldTypes[index];
                }
            }
        } else if (previousType.$type === "port") {
            if (node.portField === "value") {
                type = previousType.valueType;
            } else if (node.portField) {
                // 'reqRead' or 'reqWrite'
                type = createBoolType();
            } else {
                type = createErrorType("Unexpected field '" + node.field + "' found in port", node);
            }
        } else {
            type = createErrorType("Type '" + previousType.$type + "' does not have attribute", node);
        }
    } else if (isPrefixExpression(node)) {
        const operandType = inferExpression(node.operand, cache);
        switch (node.operator) {
            case "!": {
                const coerced = boolCoercion(operandType);
                if (coerced !== undefined) {
                    type = createBoolType();
                } else {
                    type = createErrorType("Type '" + operandType.$type + "; cannot be converted to bool type", node);
                }
                break;
            }
            case "+": {
                if (["char", "int", "real"].includes(operandType.$type)) {
                    type = operandType;
                } else {
                    type = createErrorType("Unary plus cannot be applied to type " + operandType.$type);
                }
                break;
            }
            case "-": {
                if (operandType.$type === "int" || operandType.$type === "real") {
                    type = operandType;
                } else if (operandType.$type === "char") {
                    // TODO: convert ascii to integer literal
                    type = createIntType();
                } else {
                    type = createErrorType("Unary minus cannot be applied to type " + operandType.$type);
                }
                break;
            }
            default: {
                type = createErrorType("UnknowUnexpectedn unary operator", node);
            }
        }
    } else if (isBinaryExpression(node)) {
        const leftType = inferExpression(node.left, cache);
        const rightType = inferExpression(node.right, cache);
        switch (node.operator) {
            case "&&":
            case "||": {
                const leftCoerced = boolCoercion(leftType);
                const rightCoerced = boolCoercion(rightType);
                if (leftCoerced && rightCoerced) {
                    type = createBoolType();
                } else {
                    type = createErrorType("Expression cannot be converted to bool type", node);
                }
                break;
            }
            case "<":
            case ">":
            case "<=":
            case ">=": {
                if (["bool", "char", "int", "real"].includes(leftType.$type)
                    && ["bool", "char", "int", "real"].includes(rightType.$type)) {
                    type = createBoolType();
                } else {
                    type = createErrorType(
                        `Type '${leftType.$type}' and type '${rightType.$type}' cannot be compared`,
                        node
                    );
                }
                break;
            }
            case "==":
            case "!=": {
                if (["bool", "char", "int", "real"].includes(leftType.$type) &&
                    ["bool", "char", "int", "real"].includes(rightType.$type)) {
                    type = createBoolType();
                    if ((leftType.$type === "bool" && rightType.$type === "char") ||
                        (leftType.$type === "char" && rightType.$type === "bool")) {
                        type = createErrorType("Bool and char cannot be checked for equality");
                    }
                } else if (leftType.$type === rightType.$type &&
                    ["null", "enum", "struct", "list"].includes(leftType.$type)) {
                    type = createBoolType();
                    if (leftType.$type === "list" && rightType.$type === "list") {
                        if ((leftType.capacity && !rightType.capacity) ||
                            (!leftType.capacity && rightType.capacity)) {
                            type = createErrorType("Dynamic list cannot be compared with fixed length array", node);
                        }
                    }
                } else {
                    type = createErrorType(
                        `Type '${leftType.$type}' and type '${rightType.$type}' cannot be checked for equality`,
                        node
                    );
                }
                break;
            }
            case '%': {
                if (["bool", "char", "int"].includes(leftType.$type)
                    && ["bool", "char", "int"].includes(rightType.$type)) {
                    type = createIntType();
                } else {
                    type = createErrorType(
                        `Modulo is not supported for type '${leftType.$type}' and type '${rightType.$type}'`,
                        node
                    );
                }
                break;
            }
            case '*':
            case '**':
            case '+':
            case '-':
            case '/': {
                if (["bool", "char", "int", "real"].includes(leftType.$type) &&
                    ["bool", "char", "int", "real"].includes(rightType.$type)) {
                    if (leftType.$type === "real" || rightType.$type === "real") {
                        type = createRealType();
                    } else {
                        type = createIntType();
                    }
                } else {
                    type = createErrorType(
                        `Arithmetic operator is not supported for type '${leftType.$type}' and type '${rightType.$type}'`,
                        node
                    );
                }
                break;
            }
            default: {
                type = createErrorType("Unknown binary operator", node);
                break;
            }
        }
    } else if (isConditionalExpression(node)) {
        // TODO: should we check bool coercion of condition?
        const thenType = inferExpression(node.then, cache);
        const elseType = inferExpression(node.else, cache);
        if (isSubtypeOf(thenType, elseType)) {
            type = elseType;
        } else if (isSubtypeOf(elseType, thenType)) {
            type = thenType;
        } else {
            type = createUnionType([thenType, elseType]);
        }
    } else if (isFunctionCallExpression(node)) {
        // TODO: check function template
        const argTypes = node.arguments.map(value => inferExpression(value, cache));
        const functionType = inferExpression(node.name, cache);
        if (functionType.$type === "func") {
            if (argTypes.every((value, index) => isSubtypeOf(value, functionType.argumentTypes[index]))) {
                type = functionType.returnType;
            } else {
                type = createErrorType("Function signature mismatch", node);
            }
        } else {
            type = createErrorType("Referenced function is not defined", node);
        }
    } else {
        type = createErrorType("Could not infer type for this expression", node)
    }
    cache.set(node, type);

    return type;
}

export function inferTypeRef(node: Type, cache: Map<AstNode, TypeDescription>): TypeDescription {
    let type: TypeDescription;
    const existing = cache.get(node);
    if (existing) {
        return existing;
    }
    if (isPrimitiveType(node)) {
        switch (node.name) {
            case "int": {
                type = createIntType();
                break;
            }
            case "real": {
                type = createRealType();
                break;
            }
            case "char": {
                type = createCharType();
                break;
            }
            case "bool": {
                type = createBoolType();
                break;
            }
            case "Null": {
                type = createNullType();
                break;
            }
            default: {
                type = createErrorType("Cannot infer type for this primitive type", node);
            }
        }
    } else if (isEnumType(node)) {
        type = createEnumType(node.members);
    } else if (isStructType(node)) {
        type = createStructType(
            node.fields,
            node.types.map(e => inferTypeRef(e, cache))
        );
    } else if (isAliasType(node)) {
        type = createErrorType("Cannot infer type for this parameter type", node);
        if (node.alias.ref) {
            if (isTypeDef(node.alias.ref)) {
                type = inferTypeRef(node.alias.ref.type, cache);
            } else if (isType(node.alias.ref.type)) {
                type = inferTypeRef(node.alias.ref.type, cache);
            } else if (isParameterType(node.alias.ref.type)) {
                type = inferType(node.alias.ref.type, cache);
            }
        }
    } else if (isListType(node)) {
        type = createListType(inferTypeRef(node.base, cache), node.capacity);
    } else if (isUnionType(node)) {
        type = createUnionType(node.subtypes.map(e => inferTypeRef(e, cache)));
    } else if (isTupleType(node)) {
        type = createTupleType(node.types.map(e => inferTypeRef(e, cache)));
    } else {
        type = createErrorType("Could not infer type for this type reference", node);
    }

    cache.set(node, type);
    return type;
}

export function computeLeastUpperBound(cache: Map<AstNode, TypeDescription>, ...items: Expression[]): TypeDescription {
    // TODO: implement lub computation
    const inferredTypes = items.map(value => inferExpression(value, cache));
    if (items.length > 0) {
        let candidate = inferredTypes[0];
        for (const type of inferredTypes.slice(1)) {
            if (isSubtypeOf(candidate, type)) {
                candidate = type;
            } else if (isSubtypeOf(type, candidate)) {
                continue
            } else {
                return createAnyType();
            }
        }
        return candidate;
    }
    return createAnyType();
}

export enum coercedBool {
    true,
    false,
    unknown
}

export function boolCoercion(item: TypeDescription): coercedBool | undefined {
    if (item.$type === 'null') {
        return coercedBool.false;
    } else if (item.$type === 'bool') {
        if (item.literal) {
            return item.literal.value === 'true' ? coercedBool.true : coercedBool.false;
        }
        return coercedBool.unknown;
    } else if (item.$type === 'char') {
        if (item.literal) {
            return item.literal.value === '\0' ? coercedBool.false : coercedBool.true;
        }
        return coercedBool.unknown;
    } else if (item.$type === 'int') {
        if (item.literal) {
            return item.literal.value === 0 ? coercedBool.false : coercedBool.true;
        }
        return coercedBool.unknown;
    } else if (item.$type === 'real') {
        if (item.literal) {
            return item.literal.value === 0 ? coercedBool.false : coercedBool.true;
        }
        return coercedBool.unknown;
    } else if (item.$type === 'list') {
        return item.empty ? coercedBool.false : coercedBool.true;
    }

    return undefined;
}
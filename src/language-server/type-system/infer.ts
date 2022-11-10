import { AstNode } from "langium";
import { Expression, isAliasType, isAttributeExpression, isBinaryExpression, isBoolLiteral, isCharLiteral, isComponentInstantiation, isComponentTyping, isConditionalExpression, isConstDef, isEnumType, isExpression, isFunctionCallExpression, isFunctionStatement, isIndexingExpression, isIntLiteral, isListExpression, isListType, isLoopVariableDeclaration, isLoopVariableUpdate, isMultipleVariableTyping, isNamedExpression, isNonInterfaceParameterType, isNullLiteral, isParameterType, isPortType, isPortTyping, isPrefixExpression, isPrimitiveType, isRealLiteral, isStatement, isStructExpression, isStructType, isSynchronization, isTemplateTyping, isTupleExpression, isTupleType, isType, isTypeDef, isUnionType, isVariableName, isVariableTyping, Type } from "../generated/ast";
import { createBoolType, createCharType, createEnumType, createErrorType, createIntType, createListType, createNullType, createPortType, createRealType, createStructType, createTupleType, createUnionType, TypeDescription } from "./description";

export function inferType(node: AstNode | undefined, cache: Map<AstNode, TypeDescription>): TypeDescription {
    let type: TypeDescription | undefined;
    if (!node) {
        return createErrorType("Cound not infer type for undefined", node);
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
        // TODO
    } else if (isStatement(node)) {
        // TODO
    } else if (isFunctionStatement(node)) {
        // TODO
    } else if (isSynchronization(node)) {
        // TODO
    } else if (isNonInterfaceParameterType(node)) {
        // TODO
    } else if (isParameterType(node)) {
        // TODO
    } else if (isPortType(node)) {
        type = createPortType(node.direction, inferTypeRef(node.type, cache));
    } else if (isTemplateTyping(node)) {
        // TODO
    } else if (isComponentTyping(node)) {
        // TODO
    } else if (isComponentInstantiation(node)) {
        // TODO
    } else if (isPortTyping(node)) {
        // TODO
    } else if (isVariableTyping(node)) {
        // TODO
    } else if (isMultipleVariableTyping(node)) {
        // TODO
    } else if (isLoopVariableDeclaration(node)) {
        // TODO
    } else if (isLoopVariableUpdate(node)) {
        // TODO
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
    let type: TypeDescription;
    const existing = cache.get(node);
    if (existing) {
        return existing;
    }
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
        // type = createListType();
        // we may need Any type
    } else if (isTupleExpression(node)) {
        type = createTupleType(node.values.map(e => inferType(e, cache)));
    } else if (isStructExpression(node)) {
        type = createStructType(node.fields, node.values.map(e => inferType(e, cache)));
        return type;
    } else if (isNamedExpression(node)) {
        // TODO
        const ref = node.element.ref;
        if (ref) {
            if (isVariableName(ref)) {
                ref.name;
            }
        }
    } else if (isIndexingExpression(node)) {
        // TODO
    } else if (isAttributeExpression(node)) {
        // TODO
    } else if (isPrefixExpression(node)) {
        // TODO
    } else if (isBinaryExpression(node)) {
        // TODO
    } else if (isConditionalExpression(node)) {
        // TODO
    } else if (isFunctionCallExpression(node)) {
        // TODO
    }

    return createErrorType("Could not infer type for this expression", node);
}

export function inferTypeRef(node: Type, cache: Map<AstNode, TypeDescription>): TypeDescription {
    const existing = cache.get(node);
    if (existing) {
        return existing;
    }

    if (isPrimitiveType(node)) {
        switch (node.name) {
            case "int": {
                return createIntType();
            }
            case "real": {
                return createRealType();
            }
            case "char": {
                return createCharType();
            }
            case "bool": {
                return createBoolType();
            }
            case "Null": {
                return createNullType();
            }
            default: {
                return createErrorType("Cannot infer type for this primitive type", node);
            }
        }
    } else if (isEnumType(node)) {
        return createEnumType(node.members);
    } else if (isStructType(node)) {
        return createStructType(
            node.fields.map(e => e.name),
            node.types.map(e => inferTypeRef(e, cache))
        );
    } else if (isAliasType(node)) {
        // TODO
    } else if (isListType(node)) {
        return createListType(inferTypeRef(node.base, cache), node.capacity);
    } else if (isUnionType(node)) {
        return createUnionType(node.subtypes.map(e => inferTypeRef(e, cache)));
    } else if (isTupleType(node)) {
        return createTupleType(node.types.map(e => inferTypeRef(e, cache)));
    }
    return createErrorType("Could not infer type for this type reference", node);
}

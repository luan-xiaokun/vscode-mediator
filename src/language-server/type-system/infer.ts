// import { AstNode } from "langium";
// import { isAliasType, isEnumType, isFunctionType, isInterfaceType, isListType, isPrimitiveType, isStructType, isTupleType, isType, isUnionType, ListType, TupleType, Type, UnionType } from "../generated/ast";
// import { createAbstractType, createAutomatonType, createBoolType, createCharType, createEnumType, createErrorType, createFunctionType, createIntType, createListType, createNullType, createPortType, createRealType, createStructType, createTupleType, PortTypeDescription, TypeDescription } from "./descriptions";

// function inferTypeReference(node: Type | ListType | TupleType | UnionType, cache: Map<AstNode, TypeDescription>): TypeDescription {
//     if (isAliasType(node)) {
//         if (node.alias.ref) {
//             const alias = node.alias.ref.type;
//             if (isType(alias)) {
//                 return inferTypeReference(alias, cache);
//             } else if (isFunctionType(alias)) {
//                 const returnType = inferTypeReference(alias.returntype, cache);
//                 const paramsType: TypeDescription[] = [];
//                 for (const param of alias.argtypes) {
//                     paramsType.push(inferTypeReference(param, cache));
//                 }
//                 return createFunctionType(returnType, paramsType);
//             } else if (isInterfaceType(alias)) {
//                 const ports: PortTypeDescription[] = [];
//                 for (const port of alias.porttypes) {
//                     ports.push(createPortType(
//                         port.direction, inferTypeReference(port.type, cache)
//                     ));
//                 }
//                 return createAutomatonType(ports);
//             } else if (typeof alias === "string") {
//                 return createAbstractType();
//             }
//         }
//     } else if (isEnumType(node)) {
//         const members: string[] = [];
//         for (const mem of node.members) {
//             members.push(mem.name);
//         }
//         return createEnumType(members);
//     } else if (isStructType(node)) {
//         const fields: string[] = [];
//         const fieldTypes: TypeDescription[] = [];
//         for (let i = 0; i < node.fields.length; ++i) {
//             fields.push(node.fields[i].name);
//             fieldTypes.push(inferTypeReference(node.types[i], cache));
//         }
//         return createStructType(fields, fieldTypes);
//     } else if (isPrimitiveType(node)) {
//         switch (node.name) {
//             case "int": {
//                 return createIntType();
//             }
//             case "real": {
//                 return createRealType();
//             }
//             case "char": {
//                 return createCharType();
//             }
//             case "bool": {
//                 return createBoolType();
//             }
//             case "null": {
//                 return createNullType();
//             }
//             default:
//                 return createErrorType("Uncaught primitive type", node);
//         }
//     } else if (isListType(node)) {
//         return createListType(inferTypeReference(node.base, cache), node.capacity);
//     } else if (isTupleType(node) || isUnionType(node)) {
//         const types: TypeDescription[] = [];
//         for (const type of node.types) {
//             types.push(inferTypeReference(type, cache));
//         }
//         return createTupleType(types);
//     }
//     return createErrorType("Uncaught type", node);
// }
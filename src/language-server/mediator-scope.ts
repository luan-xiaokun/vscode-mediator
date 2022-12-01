import { AstNode, AstNodeDescription, DefaultScopeComputation, DefaultScopeProvider, interruptAndCheck, LangiumDocument, LangiumServices, MultiMap, PrecomputedScopes, ReferenceInfo, Scope, streamAllContents } from "langium";
import { CancellationToken } from "vscode-jsonrpc";
import { isEnumType, isTypeDef, Type, isComponentName, ComponentTyping, isVariableName, VariableTyping, MultipleVariableTyping, isEnumMember, isFunctionDef, isAutomaton, isSystem, isTupleType, isUnionType, AttributeExpression, AutomatonPort, isInternalPort } from "./generated/ast";
import { StructTypeDescription, TypeDescription } from "./type-system/description";
import { inferExpression } from "./type-system/infer";

export class MediatorScopeComputation extends DefaultScopeComputation {
    constructor(services: LangiumServices) {
        super(services)
    }

    async computeLocalScopes(document: LangiumDocument, cancelToken = CancellationToken.None): Promise<PrecomputedScopes> {
        const rootNode = document.parseResult.value;
        const scopes = new MultiMap<AstNode, AstNodeDescription>();
        // Here we navigate the full AST - local scopes shall be available in the whole document
        for (const node of streamAllContents(rootNode)) {
            await interruptAndCheck(cancelToken);
            this.processNode(node, document, scopes);
        }
        return scopes;
    }

    protected processNode(node: AstNode, document: LangiumDocument<AstNode>, scopes: PrecomputedScopes): void {
        const container = node.$container;
        if (container) {
            const name = this.nameProvider.getName(node);
            if (name) {
                scopes.add(container, this.descriptions.createDescription(node, name, document));
                if (isComponentName(node)) {
                    scopes.add((container as ComponentTyping).$container, this.descriptions.createDescription(node, name, document));
                } else if (isInternalPort(node)) {
                    scopes.add(container, this.descriptions.createDescription(node, name, document))
                }
                else if (isVariableName(node))
                    scopes.add((container as VariableTyping | MultipleVariableTyping).$container, this.descriptions.createDescription(node, name, document));
                else if (isEnumMember(node)) {
                    let parent = container;
                    const isCorrectScope = (n: unknown) => {
                        return isTypeDef(n) || isFunctionDef(n) || isAutomaton(n) || isSystem(n)
                    };
                    while (parent.$container && !isCorrectScope(parent.$container)) {
                        parent = parent.$container;
                    }
                    if (parent.$container) {
                        parent = parent.$container;
                        if (isTypeDef(parent)) parent = parent.$container;
                        scopes.add(parent, this.descriptions.createDescription(node, name, document));
                    }
                }
            }
        }
    }

    protected processEnumTypeDef(node: Type, container: AstNode, document: LangiumDocument<AstNode>, scopes: PrecomputedScopes): void {
        if (isEnumType(node)) {
            for (const member of node.members) {
                const name = this.nameProvider.getName(member);
                if (name) scopes.add(container, this.descriptions.createDescription(member, name, document));
            }
        } else if (isTupleType(node)) {
            for (const subnode of node.types) {
                this.processEnumTypeDef(subnode, container, document, scopes);
            }
        } else if (isUnionType(node)) {
            for (const subnode of node.subtypes) {
                this.processEnumTypeDef(subnode, container, document, scopes);
            }
        }
    }
}

export class MediatorScopeProvider extends DefaultScopeProvider {
    constructor(services: LangiumServices) {
        super(services);
    }

    override getScope(context: ReferenceInfo): Scope {
        if (context.property === "field" || context.property === "portField") {
            const fieldAccess = context.container as AttributeExpression;
            const previousType = inferExpression(fieldAccess.previous, new Map());
            // struct supports field access, we should consider:
            // 1. plain struct type
            // 2. union struct type, in which case only intersection fields can be accessed
            if (previousType.$type === "struct") {
                return this.createScopeForNodes(previousType.fields);
            } else if (previousType.$type === "union") {
                let allStruct: boolean = true;
                const structTypeDescriptions: StructTypeDescription[] = [];
                const stack: TypeDescription[] = previousType.types;

                while (stack.length > 0) {
                    const tailType = stack.pop();
                    if (tailType?.$type === "struct") {
                        structTypeDescriptions.push(tailType);
                    } else if (tailType?.$type === "union") {
                        stack.push(...tailType.types);
                    } else {
                        allStruct = false;
                        break;
                    }
                }

                if (allStruct) {
                    const commonFields = structTypeDescriptions.reduce(
                        (previousFields, currentType) =>
                            previousFields.filter(field => currentType.fields.some(value => value.name === field.name)),
                        structTypeDescriptions[0].fields);
                    return this.createScopeForNodes(commonFields);
                }
            }
        } else if (context.property === "port") {
            const automatonPort = context.container as AutomatonPort;
            if (automatonPort.automaton) {
                // reference to port typing
                let automaton = automatonPort.automaton.ref;
                while (automaton) {
                    if (isAutomaton(automaton) || isSystem(automaton)) {
                        return this.createScopeForNodes(automaton.ports);
                    } else {
                        automaton = automaton.$container.type.component.ref
                    }
                }
            }
        }
        return super.getScope(context);
    }
}
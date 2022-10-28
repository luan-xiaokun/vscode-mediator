import { AstNode, AstNodeDescription, DefaultScopeComputation, DefaultScopeProvider, interruptAndCheck, LangiumDocument, LangiumServices, MultiMap, PrecomputedScopes, ReferenceInfo, Scope, streamAllContents } from "langium";
import { CancellationToken } from "vscode-jsonrpc";
import { isEnumType, isIterableType, isTypeDef, Type, isComponentName, ComponentTyping, isVariableName, VariableTyping, MultipleVariableTyping, isEnumMember, isFunction, isAutomaton, isSystem, isLoopStatement, isFunctionLoopStatement } from "./generated/ast";

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
                if (isComponentName(node))
                    scopes.add((container as ComponentTyping).$container, this.descriptions.createDescription(node, name, document));
                else if (isVariableName(node))
                    scopes.add((container as VariableTyping | MultipleVariableTyping).$container, this.descriptions.createDescription(node, name, document));
                else if (isEnumMember(node)) {
                    let parent = container;
                    const isCorrectScope = (n: unknown) => {
                        return isTypeDef(n) || isFunction(n) || isAutomaton(n) || isSystem(n) || isLoopStatement(n) || isFunctionLoopStatement(n)
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
        } else if (isIterableType(node)) {
            for (const subnode of node.types) {
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
        return super.getScope(context);
    }
}
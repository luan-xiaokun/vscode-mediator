import { AstNode, DefaultScopeComputation, LangiumDocument, LangiumServices, PrecomputedScopes } from "langium";
// import { CancellationToken } from "vscode-jsonrpc";
import { isEnumType, isProgram, isTupleType, isTypeDef, isUnionType, Program, Type } from "./generated/ast";

export class MediatorScopeComputation extends DefaultScopeComputation {
    constructor(services: LangiumServices) {
        super(services)
    }

    protected processNode(node: AstNode, document: LangiumDocument<AstNode>, scopes: PrecomputedScopes): void {
        const container = node.$container;
        if (container) {
            const name = this.nameProvider.getName(node);
            if (name) {
                scopes.add(container, this.descriptions.createDescription(node, name, document));
            }
        }
        // add the enum members in typedef to the root scope
        if (isTypeDef(node) && isProgram(container)) {
            this.processEnumTypeDef(node.type, container, document, scopes);
        }
    }

    protected processEnumTypeDef(node: Type, container: Program, document: LangiumDocument<AstNode>, scopes: PrecomputedScopes): void {
        if (isEnumType(node)) {
            for (const member of node.members) {
                const name = this.nameProvider.getName(member);
                if (name) {
                    scopes.add(container, this.descriptions.createDescription(member, name, document))
                }
            }
        } else if (isTupleType(node) || isUnionType(node)) {
            for (const subnode of node.types) {
                this.processEnumTypeDef(subnode, container, document, scopes);
            }
        }
    }
}
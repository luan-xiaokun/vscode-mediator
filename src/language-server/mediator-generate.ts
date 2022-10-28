// import { OutputChannel, window } from 'vscode';
import { AstNode, LangiumParser } from "langium";
import { MediatorServices } from "./mediator-module";
import { isProgram, Program } from './generated/ast';

export interface Generator {
    generate(program: string | AstNode): string | undefined;
}

/**
 * Generate nuXmv model from Mediator program
 */
export class MediatorGenerator implements Generator {
    private readonly parser: LangiumParser;

    constructor(services: MediatorServices) {
        this.parser = services.parser.LangiumParser;
    }

    generate(program: string | AstNode): string | undefined {
        const astNode = (typeof (program) == 'string' ? this.parser.parse(program).value : program);
        if (isProgram(astNode)) {
            this.walkProgram(astNode);
        } else {
            console.log(astNode.$type);
        }
        return astNode.$type;
    }

    walkProgram(program: Program): void {
        // a program contains: type aliases, const definitions, functions, automatons, systems
        for (let typedef of program.typedefs) {
            console.log("type alias: " + typedef.name);
        }
        for (let constdef of program.constdefs) {
            console.log("type alias: " + constdef.name);
        }
        // for (let func of program.functions) {
        //     console.log("function name: " + func.name);
        // }
        // for (let automaton of program.automatons) {
        //     console.log("automaton name: " + automaton.name);
        // }
        // for (let system of program.systems) {
        //     console.log("system name: " + system.name);
        // }
    }
}
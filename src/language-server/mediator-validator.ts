// import { ValidationAcceptor, ValidationChecks, ValidationRegistry } from 'langium';
// import { MediatorAstType, Person } from './generated/ast';
// import type { MediatorServices } from './mediator-module';

/**
 * Registry for validation checks.
 */
// export class MediatorValidationRegistry extends ValidationRegistry {
//     constructor(services: MediatorServices) {
//         super(services);
//         const validator = services.validation.MediatorValidator;
//         const checks: ValidationChecks<MediatorAstType> = {
//             Person: validator.checkPersonStartsWithCapital
//         };
//         this.register(checks, validator);
//     }
// }

/**
 * Implementation of custom validations.
 */
export class MediatorValidator {

    // checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
    //     if (person.name) {
    //         const firstChar = person.name.substring(0, 1);
    //         if (firstChar.toUpperCase() !== firstChar) {
    //             accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
    //         }
    //     }
    // }

}

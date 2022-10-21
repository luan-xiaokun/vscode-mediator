import {
    createDefaultModule, createDefaultSharedModule, DefaultSharedModuleContext, inject,
    LangiumServices, LangiumSharedServices
} from 'langium';
import { MediatorGeneratedModule, MediatorGeneratedSharedModule } from './generated/module';

/**
 * Declaration of custom services - add your own service classes here.
 */
// export type MediatorAddedServices = {
//     validation: {
//         MediatorValidator: MediatorValidator
//     }
// }

/**
 * Union of Langium default services and your custom services - use this as constructor parameter
 * of custom service classes.
 */
export type MediatorServices = LangiumServices
// export type MediatorServices = LangiumServices & MediatorAddedServices

/**
 * Dependency injection module that overrides Langium default services and contributes the
 * declared custom services. The Langium defaults can be partially specified to override only
 * selected services, while the custom services must be fully specified.
 */
// export const MediatorModule: Module<MediatorServices, PartialLangiumServices & MediatorAddedServices> = {
//     validation: {
//         // ValidationRegistry: (services) => new MediatorValidationRegistry(services),
//         MediatorValidator: () => new MediatorValidator()
//     }
// };

/**
 * Create the full set of services required by Langium.
 *
 * First inject the shared services by merging two modules:
 *  - Langium default shared services
 *  - Services generated by langium-cli
 *
 * Then inject the language-specific services by merging three modules:
 *  - Langium default language-specific services
 *  - Services generated by langium-cli
 *  - Services specified in this file
 *
 * @param context Optional module context with the LSP connection
 * @returns An object wrapping the shared services and the language-specific services
 */
export function createMediatorServices(context: DefaultSharedModuleContext): {
    shared: LangiumSharedServices,
    Mediator: MediatorServices
} {
    const shared = inject(
        createDefaultSharedModule(context),
        MediatorGeneratedSharedModule
    );
    const Mediator = inject(
        createDefaultModule({ shared }),
        MediatorGeneratedModule,
        // MediatorModule
    );
    shared.ServiceRegistry.register(Mediator);
    return { shared, Mediator };
}

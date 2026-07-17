import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DDComponentMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PresenterStateMacro.self,
    ]
}
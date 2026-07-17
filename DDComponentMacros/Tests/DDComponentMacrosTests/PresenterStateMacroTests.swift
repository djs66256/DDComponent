import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Import the macro implementation target
#if canImport(DDComponentMacros)
import DDComponentMacros

let testMacros: [String: Macro.Type] = [
    "PresenterState": PresenterStateMacro.self,
]
#endif

final class PresenterStateMacroTests: XCTestCase {

    // MARK: - Basic expansion

    func testBasicExpansion() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            var count: Int = 0
            """,
            expandedSource: """
            var count: Int {
                get {
                    $count
                }
                set {
                    setState {
                        $count = newValue
                    }
                }
            }

            var $count: Int = 0

            func setCount(_ newValue: Int, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $count = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - willSet/didSet preservation

    func testWithWillSetDidSet() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            var count: Int = 0 {
                willSet {
                    print("will", newValue)
                }
                didSet {
                    print("did", oldValue)
                }
            }
            """,
            expandedSource: """
            var count: Int {
                willSet {
                    print("will", newValue)
                }
                didSet {
                    print("did", oldValue)
                }
                get {
                    $count
                }

                set {
                    setState {
                        $count = newValue
                    }
                }
            }

            var $count: Int = 0  {
                {
                willSet {
                    print("will", newValue)
                }
                didSet {
                    print("did", oldValue)
                }
                }
            }

            func setCount(_ newValue: Int, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $count = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Access level preservation

    func testPrivateAccessLevel() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            private var count: Int = 0
            """,
            expandedSource: """
            private var count: Int {
                get {
                    $count
                }
                set {
                    setState {
                        $count = newValue
                    }
                }
            }

            private var $count: Int = 0

            private func setCount(_ newValue: Int, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $count = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Without initial value

    func testWithoutInitialValue() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            var name: String
            """,
            expandedSource: """
            var name: String {
                get {
                    $name
                }
                set {
                    setState {
                        $name = newValue
                    }
                }
            }

            var $name: String

            func setName(_ newValue: String, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $name = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Optional type

    func testOptionalType() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            var title: String? = nil
            """,
            expandedSource: """
            var title: String? {
                get {
                    $title
                }
                set {
                    setState {
                        $title = newValue
                    }
                }
            }

            var $title: String? = nil

            func setTitle(_ newValue: String?, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $title = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }

    // MARK: - Multiple properties

    func testMultipleProperties() {
        #if canImport(DDComponentMacros)
        assertMacroExpansion(
            """
            @PresenterState
            var count: Int = 0
            @PresenterState
            var name: String = ""
            """,
            expandedSource: """
            var count: Int {
                get {
                    $count
                }
                set {
                    setState {
                        $count = newValue
                    }
                }
            }

            var $count: Int = 0

            func setCount(_ newValue: Int, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $count = newValue
                    }, context: context, completion: completion)
            }
            var name: String {
                get {
                    $name
                }
                set {
                    setState {
                        $name = newValue
                    }
                }
            }

            var $name: String = ""

            func setName(_ newValue: String, context: (inout ViewUpdateContext) -> Void = { _ in
                }, completion: (() -> Void)? = nil) {
                setState(updater: {
                        $name = newValue
                    }, context: context, completion: completion)
            }
            """,
            macros: testMacros
        )
        #endif
    }
}
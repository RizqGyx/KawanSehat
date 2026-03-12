import SwiftUI

// MARK: - Keyboard Helpers
enum KeyboardState {
    case hidden
    case visible
}

// MARK: - Focus Management Extension
#if canImport(UIKit)
extension View {
    /// Dismiss keyboard when tapping outside text fields
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
    
    /// Add a return key handler to TextField for keyboard dismissal
    func addKeyboardDismissal() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Toolbar Keyboard Dismissal
struct KeyboardDismissalModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                }
            }
    }
}

extension View {
    func keyboardDismissalButton() -> some View {
        modifier(KeyboardDismissalModifier())
    }
}

// MARK: - Combine Gesture and Keyboard Dismissal
struct NumberPadDismissalModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
    }
}

extension TextField {
    func numberPadDismissal() -> some View {
        modifier(NumberPadDismissalModifier())
    }
}
#endif

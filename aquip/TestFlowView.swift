import SwiftUI

enum TestFlowStep {
    case typeSelection
    case poolInstructions
    case poolDataCollection
}

struct TestFlowView: View {
    @State private var step: TestFlowStep = .typeSelection
    @State private var navigatingForward = true

    // Single transition that flips direction based on nav direction
    private var transition: AnyTransition {
        navigatingForward
            ? .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              )
            : .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
              )
    }

    private func navigate(to newStep: TestFlowStep, forward: Bool) {
        navigatingForward = forward
        withAnimation(.easeInOut(duration: 0.3)) {
            step = newStep
        }
    }

    var body: some View {
        ZStack {
            switch step {
            case .typeSelection:
                TestTypeSelectionView(onSelect: { type in
                    if type == "pool" {
                        navigate(to: .poolInstructions, forward: true)
                    }
                })
                .transition(transition)

            case .poolInstructions:
                PoolTestIntroView(
                    onContinue: { navigate(to: .poolDataCollection, forward: true) },
                    onBack:     { navigate(to: .typeSelection,       forward: false) }
                )
                .transition(transition)

            case .poolDataCollection:
                PoolTestFormView(
                    onCancel:   { navigate(to: .typeSelection,   forward: false) },
                    onComplete: { _ in /* results wired up later */ }
                )
                .transition(transition)
            }
        }
    }
}

import SwiftUI

enum WaterTestType {
    case pool
    case spa
}

enum TestFlowStep {
    case typeSelection
    case poolInstructions
    case poolDataCollection
    case spaInstructions
    case spaDataCollection
}

struct TestFlowView: View {
    @Binding var isInQuestionnaire: Bool
    @Binding var shouldReset: Bool

    @State private var step: TestFlowStep = .typeSelection
    @State private var navigatingForward = true

    private var transition: AnyTransition {
        navigatingForward
            ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
            : .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }

    private func navigate(to newStep: TestFlowStep, forward: Bool) {
        navigatingForward = forward
        withAnimation(.easeInOut(duration: 0.3)) {
            step = newStep
        }
        let inForm = (newStep == .poolDataCollection || newStep == .spaDataCollection)
        isInQuestionnaire = inForm
    }

    var body: some View {
        ZStack {
            switch step {
            case .typeSelection:
                TestTypeSelectionView(onSelect: { type in
                    if type == "pool" {
                        navigate(to: .poolInstructions, forward: true)
                    } else if type == "spa" {
                        navigate(to: .spaInstructions, forward: true)
                    }
                })
                .transition(transition)

            case .poolInstructions:
                PoolTestIntroView(
                    testType: .pool,
                    onContinue: { navigate(to: .poolDataCollection, forward: true) },
                    onBack:     { navigate(to: .typeSelection, forward: false) }
                )
                .transition(transition)

            case .poolDataCollection:
                PoolTestFormView(
                    testType: .pool,
                    onCancel:   { navigate(to: .typeSelection, forward: false) },
                    onComplete: { _ in /* results wired up later */ }
                )
                .transition(transition)

            case .spaInstructions:
                PoolTestIntroView(
                    testType: .spa,
                    onContinue: { navigate(to: .spaDataCollection, forward: true) },
                    onBack:     { navigate(to: .typeSelection, forward: false) }
                )
                .transition(transition)

            case .spaDataCollection:
                PoolTestFormView(
                    testType: .spa,
                    onCancel:   { navigate(to: .typeSelection, forward: false) },
                    onComplete: { _ in /* results wired up later */ }
                )
                .transition(transition)
            }
        }
        .onChange(of: shouldReset) { _, newValue in
            if newValue {
                navigate(to: .typeSelection, forward: false)
                shouldReset = false
            }
        }
        .onAppear {
            // Safety net: if a tab-bar exit happened while this view was off-screen,
            // ensure we're back at the type selection screen.
            if shouldReset {
                navigate(to: .typeSelection, forward: false)
                shouldReset = false
            }
        }
    }
}

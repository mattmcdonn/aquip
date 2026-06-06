import SwiftUI

enum WaterTestType {
    case pool
    case spa
}

enum TestFlowStep {
    case typeSelection
    case poolInstructions
    case poolDataCollection
    case poolResults
    case spaInstructions
    case spaDataCollection
    case spaResults
}

struct TestFlowView: View {
    @Binding var isInQuestionnaire: Bool
    @Binding var shouldReset: Bool

    @Environment(TestHistoryStore.self) private var historyStore
    @Environment(WaterBodyStore.self) private var waterBodyStore

    @State private var step: TestFlowStep = .typeSelection
    @State private var navigatingForward = true
    @State private var poolFormData: PoolFormData? = nil

    // History limit flow
    @State private var pendingRecord: TestHistoryRecord? = nil
    @State private var showHistoryLimitPopup = false
    @State private var selectedReplaceID: UUID? = nil

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
        let inForm = (newStep == .poolDataCollection || newStep == .spaDataCollection
                      || newStep == .poolResults || newStep == .spaResults)
        isInQuestionnaire = inForm
    }

    private func resolvedPoolName(for formData: PoolFormData, testType: WaterTestType) -> String {
        if formData.savedPool != "none", !formData.savedPool.isEmpty,
           let uuid = UUID(uuidString: formData.savedPool),
           let body = waterBodyStore.bodies.first(where: { $0.id == uuid }) {
            return body.name
        }
        return testType == .spa ? "Custom Spa" : "Custom Pool"
    }

    private func saveOrPrompt(_ record: TestHistoryRecord) {
        if historyStore.isFull {
            pendingRecord = record
            selectedReplaceID = historyStore.records.last?.id
            withAnimation(.easeOut(duration: 0.2)) { showHistoryLimitPopup = true }
        } else {
            historyStore.add(record)
        }
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
                    onCancel: { navigate(to: .typeSelection, forward: false) },
                    onComplete: { data in
                        poolFormData = data
                        let analysis = PoolChemistryEngine.analyze(data)
                        let record = TestHistoryRecord(
                            testType: "pool",
                            poolName: resolvedPoolName(for: data, testType: .pool),
                            formData: data,
                            issueCount: analysis.totalIssueCount
                        )
                        navigate(to: .poolResults, forward: true)
                        saveOrPrompt(record)
                    }
                )
                .transition(transition)

            case .poolResults:
                if let data = poolFormData {
                    PoolTestResultsView(
                        formData: data,
                        onDone: { navigate(to: .typeSelection, forward: false) }
                    )
                    .transition(transition)
                }

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
                    onComplete: { data in
                        poolFormData = data
                        let analysis = SpaChemistryEngine.analyze(data)
                        let record = TestHistoryRecord(
                            testType: "spa",
                            poolName: resolvedPoolName(for: data, testType: .spa),
                            formData: data,
                            issueCount: analysis.totalIssueCount
                        )
                        navigate(to: .spaResults, forward: true)
                        saveOrPrompt(record)
                    }
                )
                .transition(transition)

            case .spaResults:
                if let data = poolFormData {
                    SpaTestResultsView(
                        formData: data,
                        onDone: { navigate(to: .typeSelection, forward: false) }
                    )
                    .transition(transition)
                }
            }

            // History limit popup — shown after navigating to results when store is full
            if showHistoryLimitPopup, let pending = pendingRecord {
                HistoryLimitPopup(
                    records: historyStore.records,
                    selectedReplaceID: $selectedReplaceID,
                    onReplace: { replaceID in
                        historyStore.replace(deleteID: replaceID, with: pending)
                        pendingRecord = nil
                        withAnimation(.easeIn(duration: 0.18)) { showHistoryLimitPopup = false }
                    },
                    onCancel: {
                        pendingRecord = nil
                        withAnimation(.easeIn(duration: 0.18)) { showHistoryLimitPopup = false }
                    }
                )
                .zIndex(10)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: showHistoryLimitPopup)
        .onChange(of: shouldReset) { _, newValue in
            if newValue {
                navigate(to: .typeSelection, forward: false)
                shouldReset = false
            }
        }
        .onAppear {
            if shouldReset {
                navigate(to: .typeSelection, forward: false)
                shouldReset = false
            }
        }
    }
}

// MARK: - History limit popup

private struct HistoryLimitPopup: View {
    let records: [TestHistoryRecord]
    @Binding var selectedReplaceID: UUID?
    var onReplace: (UUID) -> Void
    var onCancel: () -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(red: 255/255, green: 237/255, blue: 213/255))
                        .frame(width: 64, height: 64)
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(red: 234/255, green: 88/255, blue: 12/255))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Test History Full")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.bottom, 10)

                Text("You've reached the \(testHistoryLimit)-test limit. Select an existing test to replace with this new one, or tap Cancel to discard the new test.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Dropdown / picker
                Menu {
                    ForEach(records) { record in
                        Button {
                            selectedReplaceID = record.id
                        } label: {
                            Text("\(record.poolName)  –  \(Self.dateFormatter.string(from: record.date))")
                        }
                    }
                } label: {
                    HStack {
                        if let id = selectedReplaceID,
                           let rec = records.first(where: { $0.id == id }) {
                            Text("\(rec.poolName)  –  \(Self.dateFormatter.string(from: rec.date))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                        } else {
                            Text("Select a test to replace")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 156/255, green: 163/255, blue: 175/255))
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 229/255, green: 231/255, blue: 235/255), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                Divider()

                HStack(spacing: 0) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)

                    Divider().frame(height: 52)

                    Button {
                        if let id = selectedReplaceID {
                            onReplace(id)
                        }
                    } label: {
                        Text("Replace")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                selectedReplaceID != nil
                                    ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                    : Color(red: 156/255, green: 163/255, blue: 175/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedReplaceID == nil)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 32)
        }
    }
}


import SwiftUI

// MARK: - Form data model

private enum PoolFormStep {
    case savedConfig
    case details
    case sanitizer
    case waterTemperature
    case maintenance
    case recentlyShocked
    case waterAppearance
    case algae
    case higherUsage
    case directSunlight
    case circulation
    case chemicalReadings
}

struct PoolFormData: Codable, Hashable {
    var savedPool: String = "none"
    var volumeUnit: String = "gallons"
    var volume: String = ""
    var hasHeater: String = ""
    var waterSource: String = ""
    var sanitizer: String = ""
    var waterTemp: String = ""
    var tempUnit: String = "fahrenheit"
    var recentlyOpened: String = ""
    var waterChangeAge: String = ""
    var recentlyShocked: String = ""
    var waterColor: String = ""
    var algaeType: String = ""
    var higherUsage: String = ""
    var directSunlight: String = ""
    var hasCirculation: String = ""
    var pumpRunFrequency: String = ""
    var hasLowSaltGenerator: String = ""
    var freeChlorine: String = ""
    var totalChlorine: String = ""
    var saltLevel: String = ""
    var pH: String = ""
    var alkalinity: String = ""
    var cyanuricAcid: String = ""
    var calciumHardness: String = ""
    var phosphates: String = ""
    var copper: String = ""
    var iron: String = ""
    var magnesium: String = ""
}

// MARK: - Reusable form components

struct FormSectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
    }
}

struct FormMenuPicker: View {
    let label: String
    let placeholder: String
    @Binding var selection: String
    let options: [(value: String, label: String)]

    private var displayLabel: String {
        options.first { $0.value == selection }?.label ?? placeholder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            FormSectionLabel(text: label)
            Menu {
                ForEach(options, id: \.value) { option in
                    Button(option.label) { selection = option.value }
                }
            } label: {
                HStack {
                    Text(displayLabel)
                        .font(.system(size: 16))
                        .foregroundStyle(
                            selection.isEmpty
                            ? Color(red: 156/255, green: 163/255, blue: 175/255)
                            : Color(red: 17/255, green: 24/255, blue: 39/255)
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .padding(.trailing, 4)
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .padding(.vertical, 14)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct FormNumberInput: View {
    let label: String
    let placeholder: String
    let unit: String?
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            FormSectionLabel(text: label)
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                if let unit {
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Exit confirmation popup

struct ExitTestConfirmPopup: View {
    var onCancel: () -> Void
    var onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(red: 254/255, green: 226/255, blue: 226/255))
                        .frame(width: 64, height: 64)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(red: 239/255, green: 68/255, blue: 68/255))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Exit Test?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.bottom, 10)

                Text("Are you sure you want to exit? Your progress will not be saved.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .multilineTextAlignment(.center)
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

                    Divider()
                        .frame(height: 52)

                    Button(action: onExit) {
                        Text("Exit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 239/255, green: 68/255, blue: 68/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Save pool/spa popup

struct SavePoolPopup: View {
    let testType: WaterTestType
    let store: WaterBodyStore
    var onSaveNew: (String) -> Void
    var onReplace: (UUID, String) -> Void
    var onDismiss: () -> Void

    @State private var showReplaceSelection = false
    @State private var selectedReplaceID = ""
    @State private var newWaterBodyName = ""

    private var isAtLimit: Bool { store.bodies.count >= 5 }
    private var typeLabel: String { testType == .spa ? "spa" : "pool" }
    private var typeLabelCap: String { testType == .spa ? "Spa" : "Pool" }

    private var replaceOptions: [(value: String, label: String)] {
        store.bodies.map { (value: $0.id.uuidString, label: $0.name) }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            if showReplaceSelection {
                replaceSelectionView
            } else if isAtLimit {
                atLimitView
            } else {
                underLimitView
            }
        }
    }

    // MARK: Under limit — Yes / No

    private var underLimitView: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(red: 219/255, green: 234/255, blue: 254/255))
                    .frame(width: 64, height: 64)
                Image(systemName: testType == .spa ? "drop.fill" : "water.waves")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
            }
            .padding(.top, 28)
            .padding(.bottom, 16)

            Text("Save \(typeLabelCap)?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                .padding(.bottom, 10)

            Text("Would you like to save this \(typeLabel) configuration for future test sessions?")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            // Name input
            TextField("\(typeLabelCap) name (e.g. Backyard \(typeLabelCap))", text: $newWaterBodyName)
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            Divider()

            HStack(spacing: 0) {
                Button(action: onDismiss) {
                    Text("No")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                Divider().frame(height: 52)

                Button { onSaveNew(newWaterBodyName.trimmingCharacters(in: .whitespaces)) } label: {
                    Text("Yes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            newWaterBodyName.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color(red: 156/255, green: 163/255, blue: 175/255)
                            : Color(red: 37/255, green: 99/255, blue: 235/255)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .disabled(newWaterBodyName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 40)
    }

    // MARK: At limit — Replace / Cancel

    private var atLimitView: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color(red: 254/255, green: 243/255, blue: 199/255))
                    .frame(width: 64, height: 64)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 217/255, green: 119/255, blue: 6/255))
            }
            .padding(.top, 28)
            .padding(.bottom, 16)

            Text("Limit Reached")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                .padding(.bottom, 10)

            Text("You've hit your limit of 5 combined pools/spas. Would you like to replace one of your existing entries with this new \(typeLabel)?")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            Divider()

            HStack(spacing: 0) {
                Button(action: onDismiss) {
                    Text("No")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                Divider().frame(height: 52)

                Button { showReplaceSelection = true } label: {
                    Text("Replace")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 40)
    }

    // MARK: Replace selection — dropdown + OK / Cancel

    private var replaceSelectionView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("Choose a Pool/Spa to Replace")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                Text("Select an existing entry to remove and replace with your new \(typeLabel).")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Dropdown
                Menu {
                    ForEach(replaceOptions, id: \.value) { option in
                        Button(option.label) { selectedReplaceID = option.value }
                    }
                } label: {
                    HStack {
                        Text(replaceOptions.first { $0.value == selectedReplaceID }?.label ?? "Select a pool or spa")
                            .font(.system(size: 16))
                            .foregroundStyle(
                                selectedReplaceID.isEmpty
                                ? Color(red: 156/255, green: 163/255, blue: 175/255)
                                : Color(red: 17/255, green: 24/255, blue: 39/255)
                            )
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                // Name for the new pool/spa
                TextField("\(typeLabelCap) name (e.g. Backyard \(typeLabelCap))", text: $newWaterBodyName)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            Divider()

            HStack(spacing: 0) {
                Button { showReplaceSelection = false } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                Divider().frame(height: 52)

                Button {
                    guard !selectedReplaceID.isEmpty,
                          let uuid = UUID(uuidString: selectedReplaceID) else { return }
                    onReplace(uuid, newWaterBodyName.trimmingCharacters(in: .whitespaces))
                } label: {
                    Text("OK")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            (selectedReplaceID.isEmpty || newWaterBodyName.trimmingCharacters(in: .whitespaces).isEmpty)
                            ? Color(red: 156/255, green: 163/255, blue: 175/255)
                            : Color(red: 37/255, green: 99/255, blue: 235/255)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .disabled(selectedReplaceID.isEmpty || newWaterBodyName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 40)
    }
}

// MARK: - Main form view

struct PoolTestFormView: View {
    var testType: WaterTestType
    var onCancel: () -> Void
    var onComplete: (PoolFormData) -> Void

    @Environment(WaterBodyStore.self) private var store

    @State private var currentStep = 1
    @State private var formData = PoolFormData()
    @State private var stepForward = true
    @State private var showVolumeCalc = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showSavePopup = false
    @State private var showExitConfirm = false

    // Saved pools/spas from the store, filtered by type
    private var savedPools: [(value: String, label: String)] {
        store.bodies
            .filter { $0.type == (testType == .spa ? "spa" : "pool") }
            .map { (value: $0.id.uuidString, label: $0.name) }
    }

    private var activeSteps: [PoolFormStep] {
        if testType == .pool {
            return [
                .savedConfig,
                .details,
                .sanitizer,
                .waterTemperature,
                .maintenance,
                .recentlyShocked,
                .waterAppearance,
                .algae,
                .higherUsage,
                .directSunlight,
                .circulation,
                .chemicalReadings
            ]
        }

        return [
            .savedConfig,
            .details,
            .sanitizer,
            .waterTemperature,
            .maintenance,
            .recentlyShocked,
            .waterAppearance,
            .higherUsage,
            .directSunlight,
            .chemicalReadings
        ]
    }

    private var totalSteps: Int { activeSteps.count }

    private var currentFormStep: PoolFormStep {
        activeSteps[currentStep - 1]
    }

    private var progress: Double { Double(currentStep) / Double(totalSteps) }

    private var canContinue: Bool {
        switch currentFormStep {
        case .savedConfig:
            return !formData.savedPool.isEmpty
        case .details:
            let base = !formData.volumeUnit.isEmpty && !formData.volume.isEmpty
                && !formData.waterSource.isEmpty
            return testType == .spa ? base : base && !formData.hasHeater.isEmpty
        case .sanitizer:
            guard !formData.sanitizer.isEmpty else { return false }
            if formData.sanitizer == "salt" {
                return !formData.hasLowSaltGenerator.isEmpty
            }
            return true
        case .waterTemperature:
            return !formData.waterTemp.isEmpty
        case .maintenance:
            return testType == .spa
                ? !formData.waterChangeAge.isEmpty
                : !formData.recentlyOpened.isEmpty
        case .recentlyShocked:
            return !formData.recentlyShocked.isEmpty
        case .waterAppearance:
            return !formData.waterColor.isEmpty
        case .algae:
            return !formData.algaeType.isEmpty
        case .higherUsage:
            return !formData.higherUsage.isEmpty
        case .directSunlight:
            return !formData.directSunlight.isEmpty
        case .circulation:
            guard !formData.hasCirculation.isEmpty else { return false }
            if formData.hasCirculation == "no" {
                return true
            }
            return !formData.pumpRunFrequency.isEmpty && formData.pumpRunFrequency != "not_applicable"
        case .chemicalReadings:
            return !formData.freeChlorine.isEmpty && !formData.totalChlorine.isEmpty
                && !formData.pH.isEmpty && !formData.alkalinity.isEmpty
                && !formData.cyanuricAcid.isEmpty && !formData.calciumHardness.isEmpty
                && !formData.phosphates.isEmpty && !formData.copper.isEmpty
                && !formData.iron.isEmpty && !formData.magnesium.isEmpty
        }
    }

    private var continueLabel: String {
        currentStep == totalSteps ? "Get Results" : "Continue"
    }

    // MARK: - Volume / save helpers

    private var computedVolumeLiters: Double {
        let val = Double(formData.volume) ?? 0
        return formData.volumeUnit == "liters" ? val : val * 3.78541
    }

    private func saveNewWaterBody(name: String) {
        let body = UserWaterBody(
            name: name,
            type: testType == .spa ? "spa" : "pool",
            volumeLiters: computedVolumeLiters,
            volumeUnit: formData.volumeUnit,
            hasHeater: formData.hasHeater == "yes",
            waterSource: formData.waterSource,
            sanitizer: formData.sanitizer
        )
        store.add(body)
    }

    private func replaceWaterBody(id: UUID, name: String) {
        store.delete(id: id)
        saveNewWaterBody(name: name)
    }

    // MARK: - Navigation

    private func handleContinue() {
        if currentStep == totalSteps {
            onComplete(formData)
            return
        }
        // After sanitizer selection, offer to save for new configurations.
        if currentFormStep == .sanitizer && formData.savedPool == "none" {
            showSavePopup = true
            return
        }
        advanceStep()
    }

    private func advanceStep() {
        stepForward = true
        withAnimation(.easeInOut(duration: 0.28)) {
            if currentFormStep == .savedConfig && formData.savedPool != "none" {
                if let jumpIndex = activeSteps.firstIndex(of: .waterTemperature) {
                    currentStep = jumpIndex + 1
                }
            } else {
                currentStep += 1
            }
        }
    }

    private func handleBack() {
        stepForward = false
        withAnimation(.easeInOut(duration: 0.28)) {
            if currentFormStep == .waterTemperature && formData.savedPool != "none" {
                currentStep = 1
            } else {
                currentStep -= 1
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if currentStep > 1 {
                            Button(action: handleBack) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 15))
                                }
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        Button(action: { showExitConfirm = true }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 12)

                    Text(testType == .spa ? "Spa Configuration" : "Pool Configuration")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    // Progress bar
                    VStack(spacing: 4) {
                        HStack {
                            Text("Step \(currentStep) of \(totalSteps)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 191/255, green: 219/255, blue: 254/255))
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 191/255, green: 219/255, blue: 254/255))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * progress, height: 8)
                                    .animation(.easeInOut(duration: 0.28), value: progress)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 72)
                .padding(.bottom, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 37/255, green: 99/255, blue: 235/255),
                            Color(red: 6/255, green: 182/255, blue: 212/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                // Step content, scrollable
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        stepContent(for: currentFormStep)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 180 : 180)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = frame.height }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation(.easeOut(duration: 0.15)) { keyboardHeight = 0 }
                }
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))

            // Fixed continue button above tab bar
            VStack(spacing: 0) {
                Button(action: handleContinue) {
                    Text(continueLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canContinue ? .white : Color(red: 156/255, green: 163/255, blue: 175/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if canContinue {
                                    LinearGradient(
                                        colors: [
                                            Color(red: 37/255, green: 99/255, blue: 235/255),
                                            Color(red: 6/255, green: 182/255, blue: 212/255)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [
                                            Color(red: 229/255, green: 231/255, blue: 235/255),
                                            Color(red: 229/255, green: 231/255, blue: 235/255)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.15), value: canContinue)
                }
                .disabled(!canContinue)
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }
            .background(Color.white)

            // Save pool/spa popup (shown after step 3 in new pool/spa flow)
            if showSavePopup {
                SavePoolPopup(
                    testType: testType,
                    store: store,
                    onSaveNew: { name in
                        saveNewWaterBody(name: name)
                        withAnimation(.easeIn(duration: 0.18)) { showSavePopup = false }
                        advanceStep()
                    },
                    onReplace: { uuid, name in
                        replaceWaterBody(id: uuid, name: name)
                        withAnimation(.easeIn(duration: 0.18)) { showSavePopup = false }
                        advanceStep()
                    },
                    onDismiss: {
                        withAnimation(.easeIn(duration: 0.18)) { showSavePopup = false }
                        advanceStep()
                    }
                )
                .zIndex(3)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            // Exit confirmation popup
            if showExitConfirm {
                ExitTestConfirmPopup(
                    onCancel: {
                        withAnimation(.easeIn(duration: 0.18)) { showExitConfirm = false }
                    },
                    onExit: {
                        withAnimation(.easeIn(duration: 0.18)) { showExitConfirm = false }
                        onCancel()
                    }
                )
                .zIndex(3)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: showSavePopup)
        .animation(.easeOut(duration: 0.2), value: showExitConfirm)
        .fullScreenCover(isPresented: $showVolumeCalc) {
            PoolVolumeCalculatorCover(
                isPresented: $showVolumeCalc,
                onApply: { volume, unit in
                    formData.volume = volume
                    formData.volumeUnit = unit
                }
            )
            .presentationBackground(.clear)
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private func stepContent(for step: PoolFormStep) -> some View {
        switch step {
        case .savedConfig: stepSavedConfig
        case .details: stepDetails
        case .sanitizer: stepSanitizer
        case .waterTemperature: stepWaterTemperature
        case .maintenance: stepMaintenance
        case .recentlyShocked: stepRecentlyShocked
        case .waterAppearance: stepWaterAppearance
        case .algae: stepAlgae
        case .higherUsage: stepHigherUsage
        case .directSunlight: stepDirectSunlight
        case .circulation: stepCirculation
        case .chemicalReadings: stepChemicalReadings
        }
    }

    // Step 1: Saved pool / spa
    @ViewBuilder private var stepSavedConfig: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(testType == .spa ? "Select Your Spa Configuration" : "Select Your Pool Configuration")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            let newLabel = testType == .spa ? "None — Set up new spa" : "None — Set up new pool"

            FormMenuPicker(
                label: "Saved \(testType == .spa ? "Spas" : "Pools")",
                placeholder: testType == .spa ? "Select a spa" : "Select a pool",
                selection: $formData.savedPool,
                options: [(value: "none", label: newLabel)] + savedPools
            )
        }
    }

    // Step 2: Pool / spa details
    @ViewBuilder private var stepDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text(testType == .spa ? "Spa Details" : "Pool Details")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                Spacer()
                Button("Volume Calculator") {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { showVolumeCalc = true }
                }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                    .clipShape(Capsule())
            }

            FormMenuPicker(
                label: "Volume Unit",
                placeholder: "Select unit",
                selection: $formData.volumeUnit,
                options: [
                    ("gallons", "Gallons"),
                    ("liters", "Liters")
                ]
            )

            FormNumberInput(
                label: testType == .spa ? "Spa Volume" : "Pool Volume",
                placeholder: testType == .spa ? "Enter spa volume" : "Enter pool volume",
                unit: formData.volumeUnit == "liters" ? "L" : "gal",
                value: $formData.volume
            )

            if testType == .pool {
                FormMenuPicker(
                    label: "Pool Heater",
                    placeholder: "Select option",
                    selection: $formData.hasHeater,
                    options: [
                        ("yes", "Yes"),
                        ("no", "No")
                    ]
                )
            }

            FormMenuPicker(
                label: "Water Source",
                placeholder: "Select water source",
                selection: $formData.waterSource,
                options: [
                    ("freshwater", "Freshwater"),
                    ("well", "Well Water")
                ]
            )
        }
    }

    // Step 3: Sanitizer
    @ViewBuilder private var stepSanitizer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Sanitizer")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text("Select your sanitizer type")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))

            VStack(spacing: 12) {
                ForEach([
                    ("chlorine", "Chlorine", "drop.fill",
                     Color(red: 37/255, green: 99/255, blue: 235/255),
                     Color(red: 219/255, green: 234/255, blue: 254/255)),
                    ("salt", "Salt", "waveform",
                     Color(red: 8/255, green: 145/255, blue: 178/255),
                     Color(red: 207/255, green: 250/255, blue: 254/255)),
                    ("bromine", "Bromine", "flame.fill",
                     Color(red: 217/255, green: 119/255, blue: 6/255),
                     Color(red: 254/255, green: 243/255, blue: 199/255))
                ], id: \.0) { value, label, icon, accent, bg in
                    let isSelected = formData.sanitizer == value
                    Button {
                        formData.sanitizer = value
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: icon)
                                .font(.system(size: 22))
                                .foregroundStyle(accent)
                                .frame(width: 48, height: 48)
                                .background(bg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            Text(label)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(isSelected ? accent : Color(red: 209/255, green: 213/255, blue: 219/255))
                        }
                        .padding(16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? accent : Color(red: 229/255, green: 231/255, blue: 235/255),
                                        lineWidth: isSelected ? 2 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            if formData.sanitizer == "salt" {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()
                        .padding(.vertical, 4)

                    Text("Salt Generator Type")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

                    Text("Do you have a low-salt generator?")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))

                    HStack(spacing: 12) {
                        ForEach([("yes", "Yes"), ("no", "No — Standard")], id: \.0) { value, label in
                            let isSelected = formData.hasLowSaltGenerator == value
                            Button {
                                formData.hasLowSaltGenerator = value
                            } label: {
                                Text(label)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(
                                        isSelected
                                            ? Color(red: 8/255, green: 145/255, blue: 178/255)
                                            : Color(red: 55/255, green: 65/255, blue: 81/255)
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        isSelected
                                            ? Color(red: 207/255, green: 250/255, blue: 254/255)
                                            : Color.white
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                isSelected
                                                    ? Color(red: 8/255, green: 145/255, blue: 178/255)
                                                    : Color(red: 229/255, green: 231/255, blue: 235/255),
                                                lineWidth: isSelected ? 2 : 1
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                            .animation(.easeInOut(duration: 0.15), value: isSelected)
                        }
                    }
                }
            }
        }
    }

    // Step 4: Water temperature
    @ViewBuilder private var stepWaterTemperature: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Temperature")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            // °F / °C toggle
            HStack(spacing: 0) {
                ForEach([("fahrenheit", "°F  Fahrenheit"), ("celsius", "°C  Celsius")], id: \.0) { value, label in
                    Button { formData.tempUnit = value } label: {
                        Text(label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(
                                formData.tempUnit == value
                                ? .white
                                : Color(red: 107/255, green: 114/255, blue: 128/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                Group {
                                    if formData.tempUnit == value {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 37/255, green: 99/255, blue: 235/255),
                                                Color(red: 6/255, green: 182/255, blue: 212/255)
                                            ],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: formData.tempUnit)
                }
            }
            .padding(4)
            .background(Color(red: 243/255, green: 244/255, blue: 246/255))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            FormNumberInput(
                label: "Current Water Temperature",
                placeholder: "Best guess if unsure",
                unit: formData.tempUnit == "celsius" ? "°C" : "°F",
                value: $formData.waterTemp
            )

            Text("Enter your best estimate if you don't have an exact reading.")
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
        }
    }

    // Step 5: Pool status / spa maintenance
    @ViewBuilder private var stepMaintenance: some View {
        if testType == .spa {
            VStack(alignment: .leading, spacing: 20) {
                Text("Spa Maintenance")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

                FormMenuPicker(
                    label: "When did you last change your spa water?",
                    placeholder: "Select timeframe",
                    selection: $formData.waterChangeAge,
                    options: [
                        ("< 1 month",  "Less than 1 month"),
                        ("< 2 months", "Less than 2 months"),
                        ("< 4 months", "Less than 4 months"),
                        ("> 4 months", "More than 4 months")
                    ]
                )
            }
        } else {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pool Status")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

                Text("Was your pool recently opened?")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

                HStack(spacing: 12) {
                    ForEach([("yes", "Yes"), ("no", "No")], id: \.0) { value, label in
                        let isSelected = formData.recentlyOpened == value
                        Button {
                            formData.recentlyOpened = value
                        } label: {
                            Text(label)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(
                                    isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                               : Color(red: 55/255, green: 65/255, blue: 81/255)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    isSelected
                                    ? Color(red: 239/255, green: 246/255, blue: 255/255)
                                    : Color.white
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            isSelected
                                            ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                            : Color(red: 229/255, green: 231/255, blue: 235/255),
                                            lineWidth: isSelected ? 2 : 1
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                    }
                }
            }
        }
    }

    // Step: Recently shocked
    @ViewBuilder private var stepRecentlyShocked: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recent Shocking")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text(testType == .spa
                 ? "Have you shocked your spa within the last 24 hours?"
                 : "Have you shocked your pool within the last 24 hours?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            HStack(spacing: 12) {
                ForEach([("yes", "Yes"), ("no", "No")], id: \.0) { value, label in
                    let isSelected = formData.recentlyShocked == value
                    Button {
                        formData.recentlyShocked = value
                    } label: {
                        Text(label)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                : Color(red: 55/255, green: 65/255, blue: 81/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                isSelected ? Color(red: 239/255, green: 246/255, blue: 255/255) : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                        : Color(red: 229/255, green: 231/255, blue: 235/255),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
        }
    }

    // Step 6: Water color
    @ViewBuilder private var stepWaterAppearance: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Appearance")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text(testType == .spa ? "What colour is your spa water?" : "What colour is your pool water?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            let colorOptions: [(value: String, label: String, color: Color)] = [
                ("green",  "Green (algae)",     Color(red: 34/255, green: 197/255, blue: 94/255)),
                ("cloudy", "Blue (cloudy)",     Color(red: 96/255, green: 165/255, blue: 250/255)),
                ("clear",  "Clear",             Color(red: 125/255, green: 211/255, blue: 252/255)),
                ("brown",  "Brown",             Color(red: 180/255, green: 83/255, blue: 9/255)),
                ("black",  "Black",             Color(red: 31/255, green: 41/255, blue: 55/255)),
                ("purple", "Purple",            Color(red: 168/255, green: 85/255, blue: 247/255))
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colorOptions, id: \.value) { option in
                    let isSelected = formData.waterColor == option.value
                    Button {
                        formData.waterColor = option.value
                    } label: {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(option.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                                )
                                .shadow(color: option.color.opacity(0.4), radius: 4, x: 0, y: 2)

                            Text(option.label)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(
                                    isSelected ? option.color
                                               : Color(red: 55/255, green: 65/255, blue: 81/255)
                                )
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isSelected ? option.color.opacity(0.1) : Color.white
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isSelected ? option.color : Color(red: 229/255, green: 231/255, blue: 235/255),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
        }
    }

    // Step 7 (pool only): Algae type
    @ViewBuilder private var stepAlgae: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Algae Check")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text("Do you notice any algae in the pool?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            let algaeOptions: [(value: String, label: String, color: Color)] = [
                ("green",     "Green Algae",    Color(red: 34/255,  green: 197/255, blue: 94/255)),
                ("mustard",   "Mustard Algae",  Color(red: 234/255, green: 179/255, blue: 8/255)),
                ("black",     "Black Algae",    Color(red: 31/255,  green: 41/255,  blue: 55/255)),
                ("pink",      "Pink Algae",     Color(red: 244/255, green: 114/255, blue: 182/255)),
                ("white",     "White Algae",    Color(red: 180/255, green: 180/255, blue: 190/255)),
                ("invisible", "Invisible /\nChlorine Demand", Color(red: 147/255, green: 197/255, blue: 253/255))
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(algaeOptions, id: \.value) { option in
                    let isSelected = formData.algaeType == option.value
                    Button {
                        formData.algaeType = option.value
                    } label: {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(option.color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                                )
                                .shadow(color: option.color.opacity(0.4), radius: 4, x: 0, y: 2)

                            Text(option.label)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(
                                    isSelected ? option.color
                                               : Color(red: 55/255, green: 65/255, blue: 81/255)
                                )
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isSelected ? option.color.opacity(0.1) : Color.white
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isSelected ? option.color
                                               : Color(red: 229/255, green: 231/255, blue: 235/255),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            // No algae — full-width option at the bottom
            let noSelected = formData.algaeType == "none"
            Button {
                formData.algaeType = "none"
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 220/255, green: 252/255, blue: 231/255))
                            .frame(width: 40, height: 40)
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 22/255, green: 163/255, blue: 74/255))
                    }
                    Text("No Algae")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            noSelected ? Color(red: 22/255, green: 163/255, blue: 74/255)
                                       : Color(red: 55/255, green: 65/255, blue: 81/255)
                        )
                    Spacer()
                    if noSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 22/255, green: 163/255, blue: 74/255))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    noSelected ? Color(red: 220/255, green: 252/255, blue: 231/255).opacity(0.5) : Color.white
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            noSelected ? Color(red: 22/255, green: 163/255, blue: 74/255)
                                       : Color(red: 229/255, green: 231/255, blue: 235/255),
                            lineWidth: noSelected ? 2 : 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.15), value: noSelected)
        }
    }

    // Step 8: Higher usage
    @ViewBuilder private var stepHigherUsage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Usage Check")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text(testType == .spa ? "Has there been higher spa usage recently?" : "Has there been higher pool usage recently?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            HStack(spacing: 12) {
                ForEach([("yes", "Yes"), ("no", "No")], id: \.0) { value, label in
                    let isSelected = formData.higherUsage == value
                    Button {
                        formData.higherUsage = value
                    } label: {
                        Text(label)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                : Color(red: 55/255, green: 65/255, blue: 81/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                isSelected ? Color(red: 239/255, green: 246/255, blue: 255/255) : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                        : Color(red: 229/255, green: 231/255, blue: 235/255),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
        }
    }

    // Step 9: Direct sunlight
    @ViewBuilder private var stepDirectSunlight: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sunlight Exposure")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text(testType == .spa ? "Does your spa get direct sunlight throughout the day?" : "Does your pool get direct sunlight throughout the day?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            HStack(spacing: 12) {
                ForEach([("yes", "Yes"), ("no", "No")], id: \.0) { value, label in
                    let isSelected = formData.directSunlight == value
                    Button {
                        formData.directSunlight = value
                    } label: {
                        Text(label)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                : Color(red: 55/255, green: 65/255, blue: 81/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                isSelected ? Color(red: 239/255, green: 246/255, blue: 255/255) : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                        : Color(red: 229/255, green: 231/255, blue: 235/255),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
        }
    }

    // Step 10 (pool only): Circulation and pump runtime
    @ViewBuilder private var stepCirculation: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Circulation")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text("Does your pool get circulation with jets and a pump?")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

            HStack(spacing: 12) {
                ForEach([("yes", "Yes"), ("no", "No")], id: \.0) { value, label in
                    let isSelected = formData.hasCirculation == value
                    Button {
                        formData.hasCirculation = value
                        if value == "no" {
                            formData.pumpRunFrequency = "not_applicable"
                        } else if formData.pumpRunFrequency == "not_applicable" {
                            formData.pumpRunFrequency = ""
                        }
                    } label: {
                        Text(label)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                : Color(red: 55/255, green: 65/255, blue: 81/255)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                isSelected ? Color(red: 239/255, green: 246/255, blue: 255/255) : Color.white
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isSelected ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                        : Color(red: 229/255, green: 231/255, blue: 235/255),
                                        lineWidth: isSelected ? 2 : 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            if formData.hasCirculation == "yes" {
                FormMenuPicker(
                    label: "How often does the pump run?",
                    placeholder: "Select runtime",
                    selection: $formData.pumpRunFrequency,
                    options: [
                        ("24_hours", "24 hours/day"),
                        ("12_plus", "12+ hours/day"),
                        ("8_12", "8-12 hours/day"),
                        ("4_8", "4-8 hours/day"),
                        ("under_4", "Less than 4 hours/day"),
                        ("rarely", "Rarely / only when needed")
                    ]
                )
            }
        }
    }

    // Final step: Chemical readings
    @ViewBuilder private var stepChemicalReadings: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Enter Test Strip Readings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            FormNumberInput(label: "Free Chlorine", placeholder: "0.0", unit: "ppm", value: $formData.freeChlorine)
            FormNumberInput(label: "Total Chlorine", placeholder: "0.0", unit: "ppm", value: $formData.totalChlorine)

            if formData.sanitizer == "salt" {
                FormNumberInput(label: "Salt Level", placeholder: "0", unit: "ppm", value: $formData.saltLevel)
            }

            FormNumberInput(label: "pH", placeholder: "0.0", unit: nil, value: $formData.pH)
            FormNumberInput(label: "Total Alkalinity", placeholder: "0", unit: "ppm", value: $formData.alkalinity)
            FormNumberInput(label: "Cyanuric Acid / Stabilizer", placeholder: "0", unit: "ppm", value: $formData.cyanuricAcid)
            FormNumberInput(label: "Calcium Hardness", placeholder: "0", unit: "ppm", value: $formData.calciumHardness)
            FormNumberInput(label: "Phosphates", placeholder: "0", unit: "ppb", value: $formData.phosphates)
            FormNumberInput(label: "Copper", placeholder: "0.0", unit: "ppm", value: $formData.copper)
            FormNumberInput(label: "Iron", placeholder: "0.0", unit: "ppm", value: $formData.iron)
            FormNumberInput(label: "Magnesium", placeholder: "0.0", unit: "ppm", value: $formData.magnesium)
        }
    }
}

import SwiftUI

// MARK: - Form data model

struct PoolFormData {
    var savedPool: String = "none"
    var volumeUnit: String = "gallons"
    var volume: String = ""
    var hasHeater: String = ""
    var waterSource: String = ""
    var sanitizer: String = ""
    var waterTemp: String = ""
    var recentlyOpened: String = ""
    var waterColor: String = ""
    var freeChlorine: String = ""
    var totalChlorine: String = ""
    var saltLevel: String = ""
    var pH: String = ""
    var alkalinity: String = ""
    var cyanuricAcid: String = ""
    var calciumHardness: String = ""
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

// MARK: - Main form view

struct PoolTestFormView: View {
    var onCancel: () -> Void
    var onComplete: (PoolFormData) -> Void

    @State private var currentStep = 1
    @State private var formData = PoolFormData()
    @State private var stepForward = true  // tracks animation direction

    // Mock saved pools (empty until persistence is added)
    private let savedPools: [(value: String, label: String)] = []

    private var totalSteps: Int { formData.savedPool != "none" ? 5 : 7 }

    private var progress: Double { Double(currentStep) / Double(totalSteps) }

    private var canContinue: Bool {
        switch currentStep {
        case 1: return !formData.savedPool.isEmpty
        case 2: return !formData.volumeUnit.isEmpty && !formData.volume.isEmpty
                     && !formData.hasHeater.isEmpty && !formData.waterSource.isEmpty
        case 3: return !formData.sanitizer.isEmpty
        case 4: return !formData.waterTemp.isEmpty
        case 5: return !formData.recentlyOpened.isEmpty
        case 6: return !formData.waterColor.isEmpty
        case 7: return !formData.freeChlorine.isEmpty && !formData.totalChlorine.isEmpty
                     && !formData.pH.isEmpty && !formData.alkalinity.isEmpty
                     && !formData.cyanuricAcid.isEmpty && !formData.calciumHardness.isEmpty
        default: return false
        }
    }

    private var continueLabel: String {
        currentStep == totalSteps ? "Get Results" : "Continue"
    }

    private func handleContinue() {
        if currentStep == totalSteps {
            onComplete(formData)
            return
        }
        stepForward = true
        withAnimation(.easeInOut(duration: 0.28)) {
            if currentStep == 1 && formData.savedPool != "none" {
                currentStep = 4
            } else {
                currentStep += 1
            }
        }
    }

    private func handleBack() {
        stepForward = false
        withAnimation(.easeInOut(duration: 0.28)) {
            // If we jumped from 1 to 4, go back to 1
            if currentStep == 4 && formData.savedPool != "none" {
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
                // Header row: back on left (steps 2+), X on right (all steps)
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

                        Button(action: onCancel) {
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

                    Text("Pool Configuration")
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
                        stepContent(for: currentStep)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .padding(.bottom, 120)
                }
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
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
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private func stepContent(for step: Int) -> some View {
        switch step {
        case 1: step1
        case 2: step2
        case 3: step3
        case 4: step4
        case 5: step5
        case 6: step6
        case 7: step7
        default: EmptyView()
        }
    }

    // Step 1: Saved pool
    @ViewBuilder private var step1: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Your Pool Configuration")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            var allOptions: [(value: String, label: String)] {
                [("none", "None — Set up new pool")] + savedPools
            }

            FormMenuPicker(
                label: "Saved Pools",
                placeholder: "Select a pool",
                selection: $formData.savedPool,
                options: [("none", "None — Set up new pool")] + savedPools
            )
        }
    }

    // Step 2: Pool details
    @ViewBuilder private var step2: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text("Pool Details")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                Spacer()
                Button("How to estimate volume") { /* wired up later */ }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
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
                label: "Pool Volume",
                placeholder: "Enter pool volume",
                unit: formData.volumeUnit == "liters" ? "L" : "gal",
                value: $formData.volume
            )

            FormMenuPicker(
                label: "Pool Heater",
                placeholder: "Select option",
                selection: $formData.hasHeater,
                options: [
                    ("yes", "Yes"),
                    ("no", "No")
                ]
            )

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
    @ViewBuilder private var step3: some View {
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
        }
    }

    // Step 4: Water temperature
    @ViewBuilder private var step4: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Temperature")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            FormNumberInput(
                label: "Current Water Temperature",
                placeholder: "Best guess if unsure",
                unit: "°F",
                value: $formData.waterTemp
            )

            Text("Enter your best estimate if you don't have an exact reading.")
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
        }
    }

    // Step 5: Recently opened
    @ViewBuilder private var step5: some View {
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

    // Step 6: Water color
    @ViewBuilder private var step6: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Appearance")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

            Text("What colour is your pool water?")
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

    // Step 7: Chemical readings
    @ViewBuilder private var step7: some View {
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
        }
    }
}

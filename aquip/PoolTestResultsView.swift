import SwiftUI

// MARK: - Summary card

private struct SummaryCard: View {
    let analysis: PoolAnalysis

    private var issueCount: Int { analysis.totalIssueCount }
    @State private var pulseScale = false
    @State private var pulseOpacity = false

    private func schedulePulse() {
        // Fade in opacity first, then expand scale simultaneously
        withAnimation(.easeOut(duration: 1.0)) {
            pulseScale   = true
            pulseOpacity = true
        }
        // At peak, fade opacity out — scale continues outward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.75)) {
                pulseOpacity = false
            }
        }
        // Reset scale instantly (invisible so no snap visible)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { pulseScale = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                schedulePulse()
            }
        }
    }

    var body: some View {
        let allClear = issueCount == 0
        let iconColor: Color = allClear
            ? Color(red: 22/255, green: 163/255, blue: 74/255)
            : Color(red: 217/255, green: 119/255, blue: 6/255)
        let iconBg: Color = allClear
            ? Color(red: 220/255, green: 252/255, blue: 231/255)
            : Color(red: 254/255, green: 243/255, blue: 199/255)
        let titleColor: Color = allClear
            ? Color(red: 20/255, green: 83/255, blue: 45/255)
            : Color(red: 120/255, green: 53/255, blue: 15/255)
        let bodyColor: Color = allClear
            ? Color(red: 22/255, green: 101/255, blue: 52/255)
            : Color(red: 146/255, green: 64/255, blue: 14/255)
        let cardBg: Color = allClear
            ? Color(red: 240/255, green: 253/255, blue: 244/255)
            : Color(red: 255/255, green: 251/255, blue: 235/255)
        let cardBorder: Color = allClear
            ? Color(red: 134/255, green: 239/255, blue: 172/255)
            : Color(red: 252/255, green: 211/255, blue: 77/255)

        HStack(spacing: 14) {
            // Pulsing icon
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(iconColor.opacity(pulseOpacity ? 0.28 : 0), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulseScale ? 1.45 : 1.0)
                        .animation(.easeOut(duration: 1.0).delay(Double(i) * 0.18), value: pulseScale)
                        .animation(.easeOut(duration: 0.75).delay(Double(i) * 0.18), value: pulseOpacity)
                }
                Image(systemName: allClear ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconBg)
                    .clipShape(Circle())
            }
            .onAppear { schedulePulse() }

            VStack(alignment: .leading, spacing: 4) {
                Text(allClear ? "Water Looks Good" : "\(issueCount) Issue\(issueCount == 1 ? "" : "s") Found")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(titleColor)
                Text(allClear
                    ? "All levels are good."
                    : "One or more parameters need attention.")
                    .font(.system(size: 13))
                    .foregroundStyle(bodyColor)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(cardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorder, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Animated column bar

private struct ColumnBar: View {
    let level: ChemistryLevel
    let chartHeight: CGFloat
    let idealFraction: CGFloat
    let delay: Double

    private let iconAreaHeight: CGFloat = 26
    @State private var animated = false

    private var targetFraction: CGFloat {
        switch level {
        case .low:  return idealFraction * 0.50
        case .ok:   return idealFraction
        case .high: return idealFraction + (1 - idealFraction) * 0.78
        }
    }

    private var barColor: Color {
        switch level {
        case .low:  return Color(red: 59/255,  green: 130/255, blue: 246/255)
        case .ok:   return Color(red: 22/255,  green: 163/255, blue: 74/255)
        case .high: return Color(red: 234/255, green: 88/255,  blue: 12/255)
        }
    }

    private var iconCircleFill: Color {
        switch level {
        case .low:  return Color(red: 219/255, green: 234/255, blue: 254/255)
        case .ok:   return Color(red: 220/255, green: 252/255, blue: 231/255)
        case .high: return Color(red: 255/255, green: 237/255, blue: 213/255)
        }
    }

    private var iconName: String {
        switch level {
        case .low:  return "chevron.down"
        case .ok:   return "checkmark"
        case .high: return "chevron.up"
        }
    }

    var body: some View {
        VStack(spacing: 3) {
            Spacer(minLength: 0)
            ZStack {
                Circle()
                    .fill(iconCircleFill)
                    .frame(width: 18, height: 18)
                Image(systemName: iconName)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(barColor)
            }
            RoundedRectangle(cornerRadius: 6)
                .fill(barColor.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(barColor, lineWidth: 2)
                )
                .frame(height: chartHeight * (animated ? targetFraction : 0))
        }
        .frame(maxWidth: .infinity, maxHeight: chartHeight + iconAreaHeight)
        .animation(
            .spring(response: 0.65, dampingFraction: 0.72).delay(delay),
            value: animated
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animated = true
            }
        }
    }
}

// MARK: - Parameter column chart

private struct ParameterColumnChart: View {

    struct Entry {
        let abbrev: String
        let level: ChemistryLevel
        let delay: Double
    }

    let title: String
    let entries: [Entry]
    let columnSlots: Int
    private let chartHeight: CGFloat = 90
    private let idealFraction: CGFloat = 0.54
    private let iconAreaHeight: CGFloat = 26

    var body: some View {
        let extraSlots = columnSlots - entries.count
        let leadingSlots = extraSlots / 2
        let trailingSlots = extraSlots - leadingSlots

        VStack(alignment: .leading, spacing: 0) {

            // ── Title row with pill legend ──
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                Spacer()
                // Pill legend
                HStack(spacing: 8) {
                    legendItem(color: Color(red: 22/255,  green: 163/255, blue: 74/255),  label: "Ideal")
                    legendItem(color: Color(red: 59/255,  green: 130/255, blue: 246/255), label: "Low")
                    legendItem(color: Color(red: 234/255, green: 88/255,  blue: 12/255),  label: "High")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // ── Bars (icon floats just above each bar inside ColumnBar) ──
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(0..<leadingSlots, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity)
                }
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    ColumnBar(
                        level: entry.level,
                        chartHeight: chartHeight,
                        idealFraction: idealFraction,
                        delay: entry.delay
                    )
                }
                ForEach(0..<trailingSlots, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: chartHeight + iconAreaHeight)

            // ── X-axis ──
            Rectangle()
                .fill(Color(red: 229/255, green: 231/255, blue: 235/255))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // ── Abbreviated labels ──
            HStack(spacing: 0) {
                ForEach(0..<leadingSlots, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity)
                }
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    Text(entry.abbrev)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                ForEach(0..<trailingSlots, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 5)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
        }
    }
}

// MARK: - Pool info card

private struct PoolInfoCard: View {
    let formData: PoolFormData
    let analysis: PoolAnalysis
    @Environment(WaterBodyStore.self) private var store

    private var poolName: String {
        guard formData.savedPool != "none",
              let body = store.bodies.first(where: { $0.id.uuidString == formData.savedPool })
        else { return "None" }
        return body.name
    }

    private var volumeDisplay: String {
        guard !formData.volume.isEmpty else { return "—" }
        let unit = formData.volumeUnit == "liters" ? "L" : "gal"
        return "\(formData.volume) \(unit)"
    }

    private var sanitizerInfo: (label: String, icon: String, color: Color) {
        switch formData.sanitizer {
        case "salt":    return ("Salt",    "waveform",   Color(red: 8/255,   green: 145/255, blue: 178/255))
        case "bromine": return ("Bromine", "flame.fill", Color(red: 217/255, green: 119/255, blue: 6/255))
        default:        return ("Chlorine","drop.fill",  Color(red: 37/255,  green: 99/255,  blue: 235/255))
        }
    }

    private var waterTempDisplay: String {
        guard !formData.waterTemp.isEmpty else { return "—" }
        let unit = formData.tempUnit == "celsius" ? "°C" : "°F"
        return "\(formData.waterTemp) \(unit)"
    }

    private var combinedChlorineDisplay: String {
        if let total = Double(formData.totalChlorine), let free = Double(formData.freeChlorine) {
            return String(format: "%.1f ppm", max(0, total - free))
        }
        return "—"
    }

    private struct ParamRow {
        let name: String
        let value: String
        let idealRange: String
        let level: ChemistryLevel
    }

    private var parameters: [ParamRow] {
        let salt = formData.sanitizer == "salt"
        return [
            .init(name: "Free Chlorine",     value: val(formData.freeChlorine, "ppm"),
                  idealRange: salt ? "2–4 ppm" : "1–3 ppm",   level: analysis.freeChlorine.level),
            .init(name: "Combined Chlorine", value: combinedChlorineDisplay,
                  idealRange: "< 0.2 ppm",                     level: analysis.combinedChlorine.level),
            .init(name: "pH",                value: val(formData.pH, ""),
                  idealRange: "7.2–7.6",                       level: analysis.pH.level),
            .init(name: "Alkalinity",        value: val(formData.alkalinity, "ppm"),
                  idealRange: "80–120 ppm",                    level: analysis.alkalinity.level),
            .init(name: "CYA",               value: val(formData.cyanuricAcid, "ppm"),
                  idealRange: salt ? "60–90 ppm" : "30–70 ppm",level: analysis.stabilizer.level),
            .init(name: "Calcium Hardness",  value: val(formData.calciumHardness, "ppm"),
                  idealRange: "200–500 ppm",                   level: analysis.calcium.level),
            .init(name: "Phosphates",        value: val(formData.phosphates, "ppb"),
                  idealRange: "< 100 ppb",                     level: analysis.phosphates.level),
            .init(name: "Copper",            value: val(formData.copper, "ppm"),
                  idealRange: "≤ 0.2 ppm",                     level: analysis.copper.level),
            .init(name: "Iron",              value: val(formData.iron, "ppm"),
                  idealRange: "≤ 0.1 ppm",                     level: analysis.iron.level),
            .init(name: "Magnesium",         value: val(formData.magnesium, "ppm"),
                  idealRange: "≤ 50 ppm",                      level: analysis.magnesium.level),
        ]
    }

    private func val(_ raw: String, _ unit: String) -> String {
        guard !raw.isEmpty else { return "—" }
        return unit.isEmpty ? raw : "\(raw) \(unit)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Card header ──
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                Text("Pool Overview")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            // ── Info rows ──
            VStack(spacing: 0) {
                infoRow(label: "Pool Name",  value: poolName)
                Divider().padding(.leading, 16)
                infoRow(label: "Volume",     value: volumeDisplay)
                Divider().padding(.leading, 16)
                HStack {
                    Text("Sanitizer")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: sanitizerInfo.icon)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(sanitizerInfo.color)
                        Text(sanitizerInfo.label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                Divider().padding(.leading, 16)
                infoRow(label: "Water Temp", value: waterTempDisplay)
                if formData.sanitizer == "salt" {
                    Divider().padding(.leading, 16)
                    infoRow(label: "Salt Level", value: val(formData.saltLevel, "ppm"))
                }
            }

            Divider()

            // ── Parameter readings header ──
            Text("Parameter Readings")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 6)

            // ── Parameter rows ──
            VStack(spacing: 0) {
                ForEach(Array(parameters.enumerated()), id: \.offset) { i, row in
                    if i > 0 { Divider().padding(.leading, 56) }
                    paramRow(row)
                }
            }
            .padding(.bottom, 6)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func paramRow(_ row: ParamRow) -> some View {
        HStack(spacing: 12) {
            levelBadge(row.level)
            Text(row.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(row.value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                Text("Ideal: \(row.idealRange)")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func levelBadge(_ level: ChemistryLevel) -> some View {
        switch level {
        case .ok:
            ZStack {
                Circle().fill(Color(red: 220/255, green: 252/255, blue: 231/255)).frame(width: 28, height: 28)
                Image(systemName: "checkmark").font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 22/255, green: 163/255, blue: 74/255))
            }
        case .low:
            ZStack {
                Circle().fill(Color(red: 219/255, green: 234/255, blue: 254/255)).frame(width: 28, height: 28)
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 59/255, green: 130/255, blue: 246/255))
            }
        case .high:
            ZStack {
                Circle().fill(Color(red: 255/255, green: 237/255, blue: 213/255)).frame(width: 28, height: 28)
                Image(systemName: "chevron.up").font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 234/255, green: 88/255, blue: 12/255))
            }
        }
    }
}

// MARK: - Next steps card

private struct NextStepsCard: View {

    private struct Step {
        let number: Int
        let title: String
        let product: String?
        let description: String
    }

    private let steps: [Step] = [
        Step(number: 1,
             title: "Add alkalinity increaser (sodium bicarbonate)",
             product: "Sodium Bicarbonate / Alkalinity Up",
             description: "Stabilizes pH levels and prevents rapid pH fluctuations"),
        Step(number: 2,
             title: "Wait 4–6 hours and retest pH and alkalinity",
             product: nil,
             description: "Allow chemicals to circulate and stabilize before proceeding"),
        Step(number: 3,
             title: "Add calcium chloride",
             product: "Calcium Chloride",
             description: "Raises calcium hardness to prevent corrosive water and equipment damage"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // ── Gradient header ──
            HStack(spacing: 10) {
                Image(systemName: "list.number")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Next Steps Action Plan")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                             Color(red: 6/255, green: 182/255, blue: 212/255)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 16, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 16
            ))

            // ── Body ──
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Follow these steps in order:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    Text("Complete each step before moving to the next")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 12)

                Divider()

                ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                    if i > 0 { Divider().padding(.leading, 58) }
                    stepRow(step)
                }
            }
            .background(Color.white)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0, bottomLeadingRadius: 16,
                bottomTrailingRadius: 16, topTrailingRadius: 0
            ))
        }
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func stepRow(_ step: Step) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 59/255, green: 130/255, blue: 246/255),
                                     Color(red: 37/255, green: 99/255, blue: 235/255)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 30, height: 30)
                Text("\(step.number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                if let product = step.product {
                    Text(product)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                        .clipShape(Capsule())
                }
                Text(step.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Results view

struct PoolTestResultsView: View {
    let formData: PoolFormData
    let onDone: () -> Void

    private var analysis: PoolAnalysis {
        PoolChemistryEngine.analyze(formData)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text("Test Results")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDone) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Done")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                }

                Text("Pool Water Analysis")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 191/255, green: 219/255, blue: 254/255))
                    .padding(.top, 2)


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

            // MARK: Cards
            ScrollView {
                VStack(spacing: 0) {

                    // ── Summary + section label (inset) ──
                    VStack(spacing: 16) {
                        SummaryCard(analysis: analysis)

                        Text("Parameter Results")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)

                    // ── Horizontally scrolling chart cards ──
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ParameterColumnChart(
                                title: "Balance",
                                entries: [
                                    .init(abbrev: "FC",   level: analysis.freeChlorine.level,     delay: 0.05),
                                    .init(abbrev: "CC",   level: analysis.combinedChlorine.level, delay: 0.10),
                                    .init(abbrev: "pH",   level: analysis.pH.level,               delay: 0.15),
                                    .init(abbrev: "ALK",  level: analysis.alkalinity.level,       delay: 0.20),
                                    .init(abbrev: "CYA",  level: analysis.stabilizer.level,       delay: 0.25),
                                    .init(abbrev: "CH",   level: analysis.calcium.level,          delay: 0.30),
                                    .init(abbrev: "PHOS", level: analysis.phosphates.level,       delay: 0.35),
                                ],
                                columnSlots: 7
                            )
                            .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                            ParameterColumnChart(
                                title: "Metals",
                                entries: [
                                    .init(abbrev: "Cu", level: analysis.copper.level,    delay: 0.05),
                                    .init(abbrev: "Fe", level: analysis.iron.level,      delay: 0.12),
                                    .init(abbrev: "Mg", level: analysis.magnesium.level, delay: 0.19),
                                ],
                                columnSlots: 7
                            )
                            .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 20, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .padding(.bottom, 20)

                    // ── Pool info + parameter readings ──
                    PoolInfoCard(formData: formData, analysis: analysis)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // ── Next steps ──
                    NextStepsCard()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 48)
                }
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }
}

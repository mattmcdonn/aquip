import SwiftUI

// MARK: - Colour palette helpers (scoped to this file)

private extension ChemistryLevel {
    var cardBg: Color {
        switch self {
        case .ok:   return Color(red: 240/255, green: 253/255, blue: 244/255)
        case .low:  return Color(red: 255/255, green: 251/255, blue: 235/255)
        case .high: return Color(red: 255/255, green: 241/255, blue: 242/255)
        }
    }
    var cardBorder: Color {
        switch self {
        case .ok:   return Color(red: 134/255, green: 239/255, blue: 172/255)
        case .low:  return Color(red: 252/255, green: 211/255, blue: 77/255)
        case .high: return Color(red: 252/255, green: 165/255, blue: 165/255)
        }
    }
    var titleColor: Color {
        switch self {
        case .ok:   return Color(red: 20/255, green: 83/255, blue: 45/255)
        case .low:  return Color(red: 120/255, green: 53/255, blue: 15/255)
        case .high: return Color(red: 127/255, green: 29/255, blue: 29/255)
        }
    }
    var bodyColor: Color {
        switch self {
        case .ok:   return Color(red: 22/255, green: 101/255, blue: 52/255)
        case .low:  return Color(red: 146/255, green: 64/255, blue: 14/255)
        case .high: return Color(red: 153/255, green: 27/255, blue: 27/255)
        }
    }
    var pillBg: Color {
        switch self {
        case .ok:   return Color(red: 220/255, green: 252/255, blue: 231/255)
        case .low:  return Color(red: 254/255, green: 243/255, blue: 199/255)
        case .high: return Color(red: 254/255, green: 226/255, blue: 226/255)
        }
    }
    var pillText: Color {
        switch self {
        case .ok:   return Color(red: 22/255, green: 101/255, blue: 52/255)
        case .low:  return Color(red: 120/255, green: 53/255, blue: 15/255)
        case .high: return Color(red: 153/255, green: 27/255, blue: 27/255)
        }
    }
    var statusLabel: String {
        switch self {
        case .ok:   return "OK"
        case .low:  return "LOW"
        case .high: return "HIGH"
        }
    }
}

// MARK: - Summary card

private struct SummaryCard: View {
    let analysis: PoolAnalysis

    private var issueCount: Int { analysis.totalIssueCount }
    @State private var pulse = false

    private func schedulePulse() {
        withAnimation(.easeOut(duration: 1.0)) { pulse = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { pulse = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                schedulePulse()
            }
        }
    }

    var body: some View {
        let level: ChemistryLevel = issueCount == 0 ? .ok : .low
        let iconColor: Color = issueCount == 0
            ? Color(red: 22/255, green: 163/255, blue: 74/255)
            : Color(red: 217/255, green: 119/255, blue: 6/255)

        HStack(spacing: 14) {
            // Pulsing icon
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(iconColor.opacity(pulse ? 0 : 0.28), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulse ? 1.45 : 1.0)
                        .animation(.easeOut(duration: 1.0).delay(Double(i) * 0.15), value: pulse)
                }
                Image(systemName: issueCount == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(level.pillBg)
                    .clipShape(Circle())
            }
            .onAppear { schedulePulse() }

            VStack(alignment: .leading, spacing: 4) {
                Text(issueCount == 0 ? "Water Looks Good" : "\(issueCount) Issue\(issueCount == 1 ? "" : "s") Found")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(level.titleColor)
                Text(issueCount == 0
                    ? "All checked parameters are within the acceptable range."
                    : "One or more parameters need attention. Review the details below.")
                    .font(.system(size: 13))
                    .foregroundStyle(level.bodyColor)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(level.cardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(level.cardBorder, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Issue pill

private struct IssuePill: View {
    let issue: ChemistryIssue
    let accentColor: Color
    let pillBg: Color
    let pillText: Color

    var body: some View {
        Text(issue.label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(pillText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(pillBg)
            .overlay(
                Capsule()
                    .stroke(accentColor, lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - Pill flow layout (Layout protocol — self-sizes correctly)

private struct PillFlowLayout: Layout {
    var hSpacing: CGFloat = 8
    var vSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(availableWidth: proposal.width ?? .infinity, subviews: subviews)
        guard !rows.isEmpty else { return .zero }
        let totalHeight = rows.reduce(0.0) { acc, row in
            acc + (row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0)
        } + CGFloat(rows.count - 1) * vSpacing
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(availableWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowH = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let sz = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(sz))
                x += sz.width + hSpacing
            }
            y += rowH + vSpacing
        }
    }

    private func computeRows(availableWidth: CGFloat, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        for subview in subviews {
            let w = subview.sizeThatFits(.unspecified).width
            if !rows[rows.count - 1].isEmpty && rowWidth + hSpacing + w > availableWidth {
                rows.append([subview])
                rowWidth = w
            } else {
                rows[rows.count - 1].append(subview)
                rowWidth += (rows[rows.count - 1].count == 1 ? 0 : hSpacing) + w
            }
        }
        return rows.filter { !$0.isEmpty }
    }
}

// MARK: - Individual parameter card

private struct ChemistryResultCard: View {
    let parameterName: String
    let unitLabel: String
    let enteredValue: String
    let result: ParameterResult

    @State private var isExpanded = false

    private func bodyText() -> String {
        switch result.level {
        case .ok:
            switch parameterName {
            case "Free Chlorine":
                return "Free chlorine is within the ideal range of 1.0–5.0 ppm."
            case "Combined Chlorine":
                return "Combined chlorine is within the acceptable range (≤0.5 ppm). Your water is well sanitised."
            case "pH":
                return "pH is within the ideal range of 7.2–7.8."
            case "Stabilizer (CYA)":
                return "Stabilizer (cyanuric acid) is within the ideal range."
            case "Phosphates":
                return "Phosphate levels are within the acceptable range (0–500 ppb)."
            case "Calcium Hardness":
                return "Calcium hardness is within the ideal range of 200–500 ppm."
            case "Copper":
                return "Copper levels are within the acceptable range (≤0.2 ppm)."
            case "Iron":
                return "Iron levels are within the acceptable range (≤0.1 ppm)."
            case "Magnesium":
                return "Magnesium levels are within the acceptable range (≤50 ppm)."
            default:
                return "\(parameterName) is within the acceptable range."
            }
        case .low:
            switch parameterName {
            case "Free Chlorine":
                return "Chlorine levels are low. Address the potential causes below to bring them back into range."
            case "pH":
                return "pH is low (below 7.2). Low pH can corrode pool equipment and irritate swimmers. Review the potential causes below."
            case "Alkalinity":
                return "Total alkalinity is low (below 80 ppm). Low alkalinity causes pH to fluctuate wildly. Review the potential causes below."
            case "Stabilizer (CYA)":
                return "Stabilizer is low. Low CYA means chlorine is consumed too quickly by sunlight. Review the potential causes below."
            case "Calcium Hardness":
                return "Calcium hardness is low (below 200 ppm). Low calcium can cause corrosion of pool surfaces and equipment. Review the potential causes below."
            default:
                return "\(parameterName) is below the recommended range."
            }
        case .high:
            switch parameterName {
            case "Free Chlorine":
                return "Chlorine levels are high. Review the potential causes below."
            case "Combined Chlorine":
                return "Combined chlorine is above 0.5 ppm, indicating chloramines are present. These reduce sanitisation effectiveness and cause irritation. Shocking the pool is the primary remedy. Review the potential causes below."
            case "pH":
                return "pH is high (above 7.8). High pH reduces chlorine effectiveness and can cause scale buildup. Review the potential causes below."
            case "Alkalinity":
                return "Total alkalinity is high (above 120 ppm). High alkalinity makes it difficult to adjust pH. Review the potential causes below."
            case "Stabilizer (CYA)":
                return "Stabilizer is high. Excess CYA causes \"chlorine lock\" reducing sanitisation effectiveness. Review the potential causes below."
            case "Phosphates":
                return "Phosphate levels are high (above 500 ppb). Phosphates feed algae growth and reduce chlorine efficiency. Review the potential causes below."
            case "Calcium Hardness":
                return "Calcium hardness is high (above 500 ppm). High calcium leads to cloudy water and scale buildup. Review the potential causes below."
            case "Copper":
                return "Copper levels are elevated (above 0.2 ppm). High copper can stain pool surfaces and turn hair green. Review the potential causes below."
            case "Iron":
                return "Iron levels are elevated (above 0.1 ppm). High iron causes brown or rust-coloured staining. Review the potential causes below."
            case "Magnesium":
                return "Magnesium levels are elevated (above 50 ppm). This can cause water cloudiness and scale. Review the potential causes below."
            default:
                return "\(parameterName) is above the recommended range."
            }
        }
    }

    var body: some View {
        let level = result.level
        VStack(alignment: .leading, spacing: 0) {
            // ── Always-visible header row ──
            HStack(spacing: 10) {
                Text(parameterName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(level.titleColor)

                Spacer()

                // Value badge
                Text("\(enteredValue) \(unitLabel)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(level.bodyColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.7))
                    .overlay(Capsule().stroke(level.cardBorder, lineWidth: 1))
                    .clipShape(Capsule())

                // Status pill
                Text(level.statusLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(level.pillText)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(level.pillBg)
                    .clipShape(Capsule())

                // Expand chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(level.titleColor.opacity(0.7))
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
            }

            // ── Expandable body ──
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.top, 12)

                    Text(bodyText())
                        .font(.system(size: 13))
                        .foregroundStyle(level.bodyColor)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if !result.issues.isEmpty {
                        Text("Potential Causes")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(level.titleColor)

                        PillFlowLayout(hSpacing: 8, vSpacing: 8) {
                            ForEach(result.issues) { issue in
                                IssuePill(issue: issue,
                                          accentColor: level.cardBorder,
                                          pillBg: level.pillBg,
                                          pillText: level.pillText)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(level.cardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(level.cardBorder, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
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
                HStack {
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
                .padding(.bottom, 12)

                Text("Test Results")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                Text("Pool Water Analysis")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 191/255, green: 219/255, blue: 254/255))
                    .padding(.top, 2)

                // Issue summary badge
                HStack(spacing: 6) {
                    let count = analysis.totalIssueCount
                    Image(systemName: count == 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text(count == 0 ? "All clear" : "\(count) issue\(count == 1 ? "" : "s") detected")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
                .padding(.top, 10)
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
                VStack(spacing: 16) {
                    SummaryCard(analysis: analysis)

                    Text("Parameter Results")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ChemistryResultCard(
                        parameterName: "Free Chlorine",
                        unitLabel: "ppm",
                        enteredValue: formData.freeChlorine,
                        result: analysis.freeChlorine
                    )

                    let fc = Double(formData.freeChlorine) ?? 0
                    let tc = Double(formData.totalChlorine) ?? 0
                    let cc = max(tc - fc, 0)
                    let ccString = String(format: cc.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f", cc)

                    ChemistryResultCard(
                        parameterName: "Combined Chlorine",
                        unitLabel: "ppm",
                        enteredValue: ccString,
                        result: analysis.combinedChlorine
                    )

                    ChemistryResultCard(
                        parameterName: "pH",
                        unitLabel: "",
                        enteredValue: formData.pH,
                        result: analysis.pH
                    )

                    ChemistryResultCard(
                        parameterName: "Alkalinity",
                        unitLabel: "ppm",
                        enteredValue: formData.alkalinity,
                        result: analysis.alkalinity
                    )

                    ChemistryResultCard(
                        parameterName: "Stabilizer (CYA)",
                        unitLabel: "ppm",
                        enteredValue: formData.cyanuricAcid,
                        result: analysis.stabilizer
                    )

                    ChemistryResultCard(
                        parameterName: "Phosphates",
                        unitLabel: "ppb",
                        enteredValue: formData.phosphates,
                        result: analysis.phosphates
                    )

                    ChemistryResultCard(
                        parameterName: "Calcium Hardness",
                        unitLabel: "ppm",
                        enteredValue: formData.calciumHardness,
                        result: analysis.calcium
                    )

                    ChemistryResultCard(
                        parameterName: "Copper",
                        unitLabel: "ppm",
                        enteredValue: formData.copper,
                        result: analysis.copper
                    )

                    ChemistryResultCard(
                        parameterName: "Iron",
                        unitLabel: "ppm",
                        enteredValue: formData.iron,
                        result: analysis.iron
                    )

                    ChemistryResultCard(
                        parameterName: "Magnesium",
                        unitLabel: "ppm",
                        enteredValue: formData.magnesium,
                        result: analysis.magnesium
                    )
                }
                .padding(24)
                .padding(.bottom, 40)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }
}

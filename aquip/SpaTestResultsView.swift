import SwiftUI

// MARK: - Spa results view

struct SpaTestResultsView: View {
    let formData: PoolFormData
    var onDone: (() -> Void)? = nil
    var backAction: (() -> Void)? = nil
    var recordID: UUID? = nil
    // Larger default clears the status bar in the test flow (which ignores the
    // top safe area); History presents this inside a NavigationStack and passes
    // a smaller value so the header isn't double-padded.
    var headerTopPadding: CGFloat = 60

    @Environment(AppSettings.self) private var settings
    @Environment(TestHistoryStore.self) private var historyStore

    private let theme = FlowTheme.spa

    private var analysis: SpaAnalysis {
        SpaChemistryEngine.analyze(formData)
    }

    @State private var scrolledChartID: Int? = 0
    @State private var showDoneConfirm = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: Header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if let back = backAction {
                            Button(action: back) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        if backAction != nil && recordID != nil {
                            Button(action: { showDeleteConfirm = true }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.22))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        } else if backAction == nil {
                            Button(action: { showDoneConfirm = true }) {
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
                    }
                    .padding(.bottom, 14)

                    Text("Test Results")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Spa Water Analysis")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 254/255, green: 226/255, blue: 197/255))
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, headerTopPadding)
                .padding(.bottom, 20)
                .background(
                    theme.linearGradient
                        .ignoresSafeArea(edges: .top)
                )

                // MARK: Cards
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Quick info + section label + alert ──
                        VStack(spacing: 12) {
                            SpaQuickInfoCard(formData: formData)

                            Text("Parameter Results")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            SummaryCard(issueCount: analysis.totalIssueCount)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                        // ── Horizontally scrolling chart cards ──
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ParameterColumnChart(
                                    title: "Balance",
                                    entries: balanceEntries,
                                    columnSlots: 7,
                                    isVisible: scrolledChartID == 0
                                )
                                .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                                .id(0)
                                WaterTempCard(
                                    tempString: formData.waterTemp,
                                    tempUnit: formData.tempUnit,
                                    isVisible: scrolledChartID == 1,
                                    testType: .spa
                                )
                                .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                                .id(1)
                                ParameterColumnChart(
                                    title: "Metals",
                                    entries: [
                                        .init(abbrev: "Cu", level: analysis.copper.level,    delay: 0.05),
                                        .init(abbrev: "Fe", level: analysis.iron.level,      delay: 0.12),
                                        .init(abbrev: "Mg", level: analysis.magnesium.level, delay: 0.19),
                                    ],
                                    columnSlots: 7,
                                    isVisible: scrolledChartID == 2
                                )
                                .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                                .id(2)
                            }
                            .scrollTargetLayout()
                        }
                        .contentMargins(.horizontal, 28, for: .scrollContent)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $scrolledChartID)
                        .padding(.bottom, 20)

                        // ── Spa info + parameter readings ──
                        SpaInfoCard(formData: formData, analysis: analysis)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        // ── Next steps ──
                        let treatmentSteps = SpaTreatmentPlanner.steps(formData: formData, analysis: analysis)
                        if !treatmentSteps.isEmpty {
                            NextStepsCard(
                                steps: treatmentSteps,
                                headerGradient: theme.gradient,
                                badgeGradient: theme.badgeGradient,
                                accent: theme.accent,
                                accentSoft: theme.accentSoft
                            )
                            .padding(.horizontal, 20)
                        }
                        Color.clear.frame(height: 120)
                    }
                }
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
            } // end VStack
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))

            // Delete confirm popup (from history view)
            if showDeleteConfirm {
                DeleteTestRecordPopup(
                    onCancel: {
                        withAnimation(.easeIn(duration: 0.18)) { showDeleteConfirm = false }
                    },
                    onDelete: {
                        withAnimation(.easeIn(duration: 0.18)) { showDeleteConfirm = false }
                        if let id = recordID {
                            historyStore.delete(id: id)
                        }
                        backAction?()
                    }
                )
                .zIndex(10)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }

            // Done confirm popup
            if showDoneConfirm {
                DoneViewingConfirmPopup(
                    onCancel: {
                        withAnimation(.easeIn(duration: 0.18)) { showDoneConfirm = false }
                    },
                    onConfirm: {
                        withAnimation(.easeIn(duration: 0.18)) { showDoneConfirm = false }
                        onDone?()
                    }
                )
                .zIndex(10)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        } // end ZStack
        .animation(.easeOut(duration: 0.2), value: showDoneConfirm)
        .animation(.easeOut(duration: 0.2), value: showDeleteConfirm)
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        .navigationBarHidden(true)
    }

    private var balanceEntries: [ParameterColumnChart.Entry] {
        var entries: [ParameterColumnChart.Entry] = [
            .init(abbrev: analysis.sanitizerAbbrev, level: analysis.sanitizerResidual.level, delay: 0.05)
        ]
        var delay = 0.10
        if analysis.showCombinedChlorine {
            entries.append(.init(abbrev: "CC", level: analysis.combinedChlorine.level, delay: delay))
            delay += 0.05
        }
        entries.append(.init(abbrev: "pH",  level: analysis.pH.level,         delay: delay)); delay += 0.05
        entries.append(.init(abbrev: "ALK", level: analysis.alkalinity.level, delay: delay)); delay += 0.05
        if analysis.cyaRelevant {
            entries.append(.init(abbrev: "CYA", level: analysis.stabilizer.level, delay: delay)); delay += 0.05
        }
        entries.append(.init(abbrev: "CH",   level: analysis.calcium.level,    delay: delay)); delay += 0.05
        entries.append(.init(abbrev: "PHOS", level: analysis.phosphates.level, delay: delay))
        return entries
    }
}

// MARK: - Spa quick info card

private struct SpaQuickInfoCard: View {
    let formData: PoolFormData
    @Environment(WaterBodyStore.self) private var store
    @Environment(AppSettings.self) private var settings

    private var spaName: String {
        guard formData.savedPool != "none",
              let body = store.bodies.first(where: { $0.id.uuidString == formData.savedPool })
        else { return "None" }
        return body.name
    }

    private var volumeDisplay: String {
        if !formData.volume.isEmpty, let rawVal = Double(formData.volume) {
            // formData.volume is stored in the unit it was entered in.
            let litres = formData.volumeUnit == "gallons" ? rawVal * 3.78541 : rawVal
            return settings.displayVolume(litres: litres)
        }
        // Saved spa selected without a manually entered volume: use its stored volume.
        if formData.savedPool != "none",
           let body = store.bodies.first(where: { $0.id.uuidString == formData.savedPool }) {
            return settings.displayVolume(litres: body.volumeLiters)
        }
        return "—"
    }

    private var sanitizer: (label: String, icon: String, color: Color) {
        switch formData.sanitizer {
        case "salt":    return ("Salt",    "waveform",   Color(red: 8/255,   green: 145/255, blue: 178/255))
        case "bromine": return ("Bromine", "flame.fill", Color(red: 217/255, green: 119/255, blue: 6/255))
        case "enzyme":  return ("Enzyme",  "leaf.fill",  Color(red: 22/255,  green: 163/255, blue: 74/255))
        default:        return ("Chlorine","drop.fill",  Color(red: 37/255,  green: 99/255,  blue: 235/255))
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "Name",   value: spaName)
            vDivider()
            statItem(label: "Volume", value: volumeDisplay)
            vDivider()
            HStack(spacing: 7) {
                Image(systemName: sanitizer.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(sanitizer.color)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Sanitizer")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(red: 156/255, green: 163/255, blue: 175/255))
                    Text(sanitizer.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
    }

    @ViewBuilder
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(red: 156/255, green: 163/255, blue: 175/255))
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func vDivider() -> some View {
        Rectangle()
            .fill(Color(red: 229/255, green: 231/255, blue: 235/255))
            .frame(width: 1, height: 38)
    }
}

// MARK: - Spa info card

private struct SpaInfoCard: View {
    let formData: PoolFormData
    let analysis: SpaAnalysis
    @Environment(AppSettings.self) private var settings

    private var waterTempDisplay: String {
        guard !formData.waterTemp.isEmpty, let rawTemp = Double(formData.waterTemp) else { return "—" }
        let celsius = formData.tempUnit == "celsius" ? rawTemp : (rawTemp - 32) * 5 / 9
        if settings.temperatureUnit == "fahrenheit" {
            return "\(Int((celsius * 9/5 + 32).rounded()))°F"
        } else {
            return "\(Int(celsius.rounded()))°C"
        }
    }

    private var combinedChlorineDisplay: String {
        if let cc = analysis.combinedChlorineValue {
            return String(format: "%.1f ppm", cc)
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
        var rows: [ParamRow] = [
            .init(name: analysis.sanitizerLabel,
                  value: val(analysis.usesBromineReading ? formData.bromine : formData.freeChlorine, "ppm"),
                  idealRange: "3–5 ppm", level: analysis.sanitizerResidual.level)
        ]
        if analysis.showCombinedChlorine {
            rows.append(.init(name: "Combined Chlorine", value: combinedChlorineDisplay,
                              idealRange: "< 0.2 ppm", level: analysis.combinedChlorine.level))
        }
        rows.append(.init(name: "pH", value: val(formData.pH, ""),
                          idealRange: "7.2–7.8", level: analysis.pH.level))
        rows.append(.init(name: "Alkalinity", value: val(formData.alkalinity, "ppm"),
                          idealRange: "80–120 ppm", level: analysis.alkalinity.level))
        if analysis.cyaRelevant {
            rows.append(.init(name: "CYA", value: val(formData.cyanuricAcid, "ppm"),
                              idealRange: "20–30 ppm", level: analysis.stabilizer.level))
        }
        rows.append(.init(name: "Calcium Hardness", value: val(formData.calciumHardness, "ppm"),
                          idealRange: "150–250 ppm", level: analysis.calcium.level))
        rows.append(.init(name: "Phosphates", value: val(formData.phosphates, "ppb"),
                          idealRange: "< 100 ppb", level: analysis.phosphates.level))
        rows.append(.init(name: "Copper", value: val(formData.copper, "ppm"),
                          idealRange: "≤ 0.2 ppm", level: analysis.copper.level))
        rows.append(.init(name: "Iron", value: val(formData.iron, "ppm"),
                          idealRange: "≤ 0.1 ppm", level: analysis.iron.level))
        rows.append(.init(name: "Magnesium", value: val(formData.magnesium, "ppm"),
                          idealRange: "≤ 50 ppm", level: analysis.magnesium.level))
        return rows
    }

    private func val(_ raw: String, _ unit: String) -> String {
        guard !raw.isEmpty else { return "—" }
        return unit.isEmpty ? raw : "\(raw) \(unit)"
    }

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Parameter Readings")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                VStack(spacing: 0) {
                    ForEach(Array(parameters.enumerated()), id: \.offset) { i, row in
                        if i > 0 { Divider().padding(.leading, 56) }
                        paramRow(row)
                    }
                }

                Divider()

                tempInfoRow()
                if formData.sanitizer == "salt" {
                    Divider().padding(.leading, 16)
                    infoRow(label: "Salt Level",       value: val(formData.saltLevel, "ppm"))
                    Divider().padding(.leading, 16)
                    infoRow(label: "Salt Cell Output", value: val(formData.saltCellOutput, "%"))
                    Divider().padding(.leading, 16)
                    infoRow(label: "Salt Cell Runtime", value: val(formData.saltCellRuntime, "hrs/day"))
                }
                if formData.sanitizer == "enzyme" {
                    Divider().padding(.leading, 16)
                    infoRow(label: "Enzyme Sanitizer", value: enzymeBackingLabel)
                }
                Spacer().frame(height: 6)
            }
        }
        .clipped()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var enzymeBackingLabel: String {
        switch formData.sanitizerBackingType {
        case "chlorine": return "Chlorine"
        case "bromine":  return "Bromine"
        case "unknown":  return "Unknown"
        default:         return "—"
        }
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
    private func tempInfoRow() -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tempBadgeColor(formData.waterTemp, formData.tempUnit).opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(tempBadgeColor(formData.waterTemp, formData.tempUnit))
            }
            Text("Water Temperature")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
            Spacer()
            Text(waterTempDisplay)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func tempBadgeColor(_ tempStr: String, _ unit: String) -> Color {
        guard let t = Double(tempStr) else {
            return Color(red: 156/255, green: 163/255, blue: 175/255)
        }
        let f = unit == "celsius" ? t * 9/5 + 32 : t
        // Spa: safe up to 104°F; above is unsafe (red).
        switch f {
        case ..<100:    return Color(red: 234/255, green: 88/255,  blue: 12/255)
        case 100...104: return Color(red: 22/255,  green: 163/255, blue: 74/255)
        default:        return Color(red: 220/255, green: 38/255,  blue: 38/255)
        }
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

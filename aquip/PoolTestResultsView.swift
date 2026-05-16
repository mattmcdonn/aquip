import SwiftUI

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
                        .stroke(iconColor.opacity(pulse ? 0 : 0.28), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulse ? 1.45 : 1.0)
                        .animation(.easeOut(duration: 1.0).delay(Double(i) * 0.15), value: pulse)
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
                    ? "All checked parameters are within the acceptable range."
                    : "One or more parameters need attention. Review the details below.")
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

    @State private var animated = false

    private var targetFraction: CGFloat {
        switch level {
        case .low:  return idealFraction * 0.50
        case .ok:   return idealFraction
        case .high: return idealFraction + (1 - idealFraction) * 0.78
        }
    }

    private var barGradient: LinearGradient {
        level == .ok
            ? LinearGradient(
                colors: [Color(red: 74/255,  green: 222/255, blue: 128/255),
                         Color(red: 22/255,  green: 163/255, blue: 74/255)],
                startPoint: .top, endPoint: .bottom
              )
            : LinearGradient(
                colors: [Color(red: 253/255, green: 224/255, blue: 71/255),
                         Color(red: 245/255, green: 158/255, blue: 11/255)],
                startPoint: .top, endPoint: .bottom
              )
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 5)
                .fill(barGradient)
                .frame(height: chartHeight * (animated ? targetFraction : 0))
                .animation(
                    .spring(response: 0.65, dampingFraction: 0.72).delay(delay),
                    value: animated
                )
        }
        .frame(maxWidth: .infinity, maxHeight: chartHeight)
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
        let shortName: String
        let level: ChemistryLevel
        let delay: Double
    }

    let entries: [Entry]
    private let chartHeight: CGFloat = 144
    private let idealFraction: CGFloat = 0.54

    var body: some View {
        VStack(spacing: 0) {

            // ── Legend ──
            HStack(spacing: 5) {
                Spacer()
                Text("Ideal")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(red: 22/255, green: 163/255, blue: 74/255))
                // Dashed swatch made from small capsules
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Capsule()
                            .fill(Color(red: 22/255, green: 163/255, blue: 74/255).opacity(0.55))
                            .frame(width: 4, height: 1.5)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 10)

            // ── Bars with ideal dashed line overlaid ──
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    ColumnBar(
                        level: entry.level,
                        chartHeight: chartHeight,
                        idealFraction: idealFraction,
                        delay: entry.delay
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(height: chartHeight)
            .overlay {
                // Canvas sees the same frame as the padded HStack
                Canvas { ctx, size in
                    let y = size.height * (1 - idealFraction)
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    ctx.stroke(
                        path,
                        with: .color(Color(red: 22/255, green: 163/255, blue: 74/255).opacity(0.50)),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                    )
                }
            }

            // ── X-axis line ──
            Rectangle()
                .fill(Color(red: 209/255, green: 213/255, blue: 219/255))
                .frame(height: 1.5)
                .padding(.horizontal, 20)

            // ── Angled parameter labels ──
            HStack(spacing: 8) {
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    Text(entry.shortName)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .rotationEffect(.degrees(-35))
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
            .padding(.top, 4)
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

                    // ── Column chart ──
                    ParameterColumnChart(entries: [
                        .init(shortName: "Free Cl",    level: analysis.freeChlorine.level,     delay: 0.05),
                        .init(shortName: "Comb. Cl",   level: analysis.combinedChlorine.level, delay: 0.13),
                        .init(shortName: "pH",         level: analysis.pH.level,               delay: 0.21),
                        .init(shortName: "Alkalinity",  level: analysis.alkalinity.level,       delay: 0.29),
                        .init(shortName: "CYA",        level: analysis.stabilizer.level,       delay: 0.37),
                        .init(shortName: "Phosphates",  level: analysis.phosphates.level,       delay: 0.45),
                        .init(shortName: "Calcium",    level: analysis.calcium.level,          delay: 0.53),
                    ])
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 48)
                }
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }
}

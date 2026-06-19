import SwiftUI

// MARK: - Summary card

struct SummaryCard: View {
    let issueCount: Int

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
        let textColor: Color = allClear
            ? Color(red: 22/255, green: 101/255, blue: 52/255)
            : Color(red: 120/255, green: 53/255, blue: 15/255)
        let cardBg: Color = allClear
            ? Color(red: 240/255, green: 253/255, blue: 244/255)
            : Color(red: 255/255, green: 251/255, blue: 235/255)
        let cardBorder: Color = allClear
            ? Color(red: 134/255, green: 239/255, blue: 172/255)
            : Color(red: 252/255, green: 211/255, blue: 77/255)
        let boldPart: Text = allClear
            ? Text("All levels are good,").bold()
            : Text(verbatim: "\(issueCount) issue\(issueCount == 1 ? "" : "s") found,").bold()
        let label: Text = allClear
            ? Text("\(boldPart) continue maintaining water")
            : Text("\(boldPart) review next steps")

        HStack(spacing: 10) {
            ZStack {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(iconColor.opacity(pulseOpacity ? 0.28 : 0), lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                        .scaleEffect(pulseScale ? 1.45 : 1.0)
                        .animation(.easeOut(duration: 1.0).delay(Double(i) * 0.18), value: pulseScale)
                        .animation(.easeOut(duration: 0.75).delay(Double(i) * 0.18), value: pulseOpacity)
                }
                Image(systemName: allClear ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
                    .frame(width: 28, height: 28)
                    .background(iconBg)
                    .clipShape(Circle())
            }
            .onAppear { schedulePulse() }

            label
                .font(.system(size: 13))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(cardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorder, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}



// MARK: - Weather impact alert card

struct WeatherImpactAlertCard: View {
    let impact: WeatherImpactResult
    let snapshot: WeatherSnapshot?

    private var isHot: Bool { snapshot?.isHot == true }
    private var isSunny: Bool { snapshot?.isSunny == true }
    private var isRaining: Bool { snapshot?.isRaining == true }

    // Match the same visual language used by the Weather sheet cards.
    // Priority: rain > sunny > hot. Rain gets priority because it affects test reliability.
    private var iconName: String {
        if isRaining { return "cloud.rain.fill" }
        if isSunny { return "sun.max.fill" }
        if isHot { return "thermometer.medium" }
        return "cloud.fill"
    }

    private var iconColor: Color {
        if isRaining { return Color(red: 59/255, green: 130/255, blue: 246/255) }
        if isSunny { return Color(red: 245/255, green: 158/255, blue: 11/255) }
        if isHot { return Color(red: 37/255, green: 99/255, blue: 235/255) }
        return Color(.systemGray)
    }

    private var iconBackground: Color {
        if isRaining { return Color(red: 219/255, green: 234/255, blue: 254/255) }
        if isSunny { return Color(red: 254/255, green: 243/255, blue: 199/255) }
        if isHot { return Color(red: 219/255, green: 234/255, blue: 254/255) }
        return Color(red: 243/255, green: 244/255, blue: 246/255)
    }

    private var cardBackground: Color {
        if isRaining { return Color(red: 239/255, green: 246/255, blue: 255/255) }
        if isSunny { return Color(red: 255/255, green: 251/255, blue: 235/255) }
        if isHot { return Color(red: 239/255, green: 246/255, blue: 255/255) }
        return Color(red: 249/255, green: 250/255, blue: 251/255)
    }

    private var cardBorder: Color {
        if isRaining { return Color(red: 191/255, green: 219/255, blue: 254/255) }
        if isSunny { return Color(red: 252/255, green: 211/255, blue: 77/255) }
        if isHot { return Color(red: 191/255, green: 219/255, blue: 254/255) }
        return Color(red: 229/255, green: 231/255, blue: 235/255)
    }

    private var textColor: Color {
        if isRaining { return Color(red: 30/255, green: 64/255, blue: 175/255) }
        if isSunny { return Color(red: 120/255, green: 53/255, blue: 15/255) }
        if isHot { return Color(red: 30/255, green: 64/255, blue: 175/255) }
        return Color(red: 55/255, green: 65/255, blue: 81/255)
    }

    private var inlineText: Text {
        Text("Weather Alert, ").bold() + Text(impact.message)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(iconBackground)
                .clipShape(Circle())

            inlineText
                .font(.system(size: 13))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorder, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Animated column bar

struct ColumnBar: View {
    let level: ChemistryLevel
    let chartHeight: CGFloat
    let idealFraction: CGFloat
    let delay: Double
    let isVisible: Bool

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
            guard isVisible else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animated = true
            }
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                animated = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animated = true
                }
            } else {
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) { animated = false }
            }
        }
    }
}

// MARK: - Parameter column chart

struct ParameterColumnChart: View {

    struct Entry {
        let abbrev: String
        let level: ChemistryLevel
        let delay: Double
    }

    let title: String
    let entries: [Entry]
    let columnSlots: Int
    let isVisible: Bool
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
                        delay: entry.delay,
                        isVisible: isVisible
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

// MARK: - Water temperature ring card

struct WaterTempCard: View {
    let tempString: String
    let tempUnit: String
    let isVisible: Bool
    var testType: WaterTestType = .pool
    @Environment(AppSettings.self) private var settings

    // Always resolve celsius internally for ring/category logic.
    private var tempCelsius: Double? {
        guard let t = Double(tempString) else { return nil }
        return tempUnit == "celsius" ? t : (t - 32) * 5 / 9
    }

    private var tempFahrenheit: Double? {
        guard let c = tempCelsius else { return nil }
        return c * 9 / 5 + 32
    }

    private var tempCategory: (label: String, color: Color) {
        guard let f = tempFahrenheit else {
            return ("—", Color(red: 156/255, green: 163/255, blue: 175/255))
        }
        if testType == .spa {
            // Spa: safe soaking range is 100–104°F; above 104°F is unsafe.
            switch f {
            case ..<100:    return ("Too Cool", Color(red: 59/255,  green: 130/255, blue: 246/255))
            case 100...104: return ("Ideal",    Color(red: 22/255,  green: 163/255, blue: 74/255))
            default:        return ("Unsafe",   Color(red: 220/255, green: 38/255,  blue: 38/255))
            }
        }
        switch f {
        case ..<60:   return ("Cold",         Color(red: 59/255,  green: 130/255, blue: 246/255))
        case 60..<70: return ("Transitional",  Color(red: 125/255, green: 211/255, blue: 252/255))
        case 70..<85: return ("Ideal",         Color(red: 22/255,  green: 163/255, blue: 74/255))
        case 85..<90: return ("Warm",          Color(red: 234/255, green: 88/255,  blue: 12/255))
        default:      return ("Hot",           Color(red: 220/255, green: 38/255,  blue: 38/255))
        }
    }

    // Fraction of the ring to fill (0–1).
    private var ringFraction: Double {
        guard let f = tempFahrenheit else { return 0 }
        if testType == .spa {
            // Map 80–110°F so the 100–104°F ideal band sits near the top of the ring.
            let clamped = min(max(f, 80), 110)
            return (clamped - 80) / (110 - 80)
        }
        let clamped = min(max(f, 32), 110)
        return (clamped - 32) / (110 - 32)
    }

    @State private var animatedFraction: Double = 0

    var body: some View {
        let color = tempCategory.color
        let label = tempCategory.label
        // Display temperature in the user's preferred unit
        let displayTemp: String = {
            if tempString.isEmpty { return "—" }
            if let c = tempCelsius {
                if settings.temperatureUnit == "fahrenheit" {
                    return String(Int((c * 9/5 + 32).rounded()))
                } else {
                    return String(Int(c.rounded()))
                }
            }
            return tempString
        }()
        let unit = settings.temperatureUnit == "fahrenheit" ? "°F" : "°C"

        VStack(alignment: .leading, spacing: 0) {
            // Title row
            HStack(alignment: .center) {
                Text("Temperature")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                Spacer()
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Ring
            ZStack {
                // Track
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 18)
                // Fill
                Circle()
                    .trim(from: 0, to: animatedFraction)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.1), value: animatedFraction)
                // Label
                VStack(spacing: 2) {
                    Text(displayTemp)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
            }
            .frame(width: 100, height: 100)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 16)
            .onAppear {
                guard isVisible else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animatedFraction = ringFraction
                }
            }
            .onChange(of: isVisible) { _, visible in
                if visible {
                    animatedFraction = 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        animatedFraction = ringFraction
                    }
                } else {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { animatedFraction = 0 }
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Pool quick info card

private struct PoolQuickInfoCard: View {
    let formData: PoolFormData
    @Environment(WaterBodyStore.self) private var store
    @Environment(AppSettings.self) private var settings

    private var poolName: String {
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
        // Saved pool selected without a manually entered volume: use its stored volume.
        if formData.savedPool != "none",
           let body = store.bodies.first(where: { $0.id.uuidString == formData.savedPool }) {
            return settings.displayVolume(litres: body.volumeLiters)
        }
        return "—"
    }

    private var sanitizerIcon: String {
        switch formData.sanitizer {
        case "salt":    return "waveform"
        case "bromine": return "flame.fill"
        default:        return "drop.fill"
        }
    }

    private var sanitizerLabel: String {
        switch formData.sanitizer {
        case "salt":    return "Salt"
        case "bromine": return "Bromine"
        default:        return "Chlorine"
        }
    }

    private var sanitizerColor: Color {
        switch formData.sanitizer {
        case "salt":    return Color(red: 8/255,   green: 145/255, blue: 178/255)
        case "bromine": return Color(red: 217/255, green: 119/255, blue: 6/255)
        default:        return Color(red: 37/255,  green: 99/255,  blue: 235/255)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            statItem(label: "Name",   value: poolName)
            vDivider()
            statItem(label: "Volume", value: volumeDisplay)
            vDivider()
            HStack(spacing: 7) {
                Image(systemName: sanitizerIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(sanitizerColor)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Sanitizer")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(red: 156/255, green: 163/255, blue: 175/255))
                    Text(sanitizerLabel)
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

// MARK: - Pool info card

private struct PoolInfoCard: View {
    let formData: PoolFormData
    let analysis: PoolAnalysis
    @Environment(WaterBodyStore.self) private var store
    @Environment(AppSettings.self) private var settings

    private var poolName: String {
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
        // Saved pool selected without a manually entered volume: use its stored volume.
        if formData.savedPool != "none",
           let body = store.bodies.first(where: { $0.id.uuidString == formData.savedPool }) {
            return settings.displayVolume(litres: body.volumeLiters)
        }
        return "—"
    }

    private var sanitizerInfo: (label: String, icon: String, color: Color) {
        switch formData.sanitizer {
        case "salt":    return ("Salt",    "waveform",   Color(red: 8/255,   green: 145/255, blue: 178/255))
        case "bromine": return ("Bromine", "flame.fill", Color(red: 217/255, green: 119/255, blue: 6/255))
        default:        return ("Chlorine","drop.fill",  Color(red: 37/255,  green: 99/255,  blue: 235/255))
        }
    }

    private var waterTempDisplay: String {
        guard !formData.waterTemp.isEmpty, let rawTemp = Double(formData.waterTemp) else { return "—" }
        // Always stored as celsius after migration; legacy may be fahrenheit
        let celsius = formData.tempUnit == "celsius" ? rawTemp : (rawTemp - 32) * 5 / 9
        if settings.temperatureUnit == "fahrenheit" {
            return "\(Int((celsius * 9/5 + 32).rounded()))°F"
        } else {
            return "\(Int(celsius.rounded()))°C"
        }
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

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Card header ──
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

                // ── Parameter rows ──
                VStack(spacing: 0) {
                    ForEach(Array(parameters.enumerated()), id: \.offset) { i, row in
                        if i > 0 { Divider().padding(.leading, 56) }
                        paramRow(row)
                    }
                }

                Divider()

                // ── Conditions ──
                tempInfoRow()
                if formData.sanitizer == "salt" {
                    Divider().padding(.leading, 16)
                    infoRow(label: "Salt Level", value: val(formData.saltLevel, "ppm"))
                }
                Spacer().frame(height: 6)
            }
        }
        .clipped()
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
        switch f {
        case ..<60:   return Color(red: 59/255,  green: 130/255, blue: 246/255)
        case 60..<70: return Color(red: 125/255, green: 211/255, blue: 252/255)
        case 70..<85: return Color(red: 22/255,  green: 163/255, blue: 74/255)
        case 85..<90: return Color(red: 234/255, green: 88/255,  blue: 12/255)
        default:      return Color(red: 220/255, green: 38/255,  blue: 38/255)
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

// MARK: - Next steps card

struct NextStepsCard: View {

    let steps: [TreatmentStep]
    var headerGradient: [Color] = [Color(red: 37/255, green: 99/255, blue: 235/255),
                                   Color(red: 6/255, green: 182/255, blue: 212/255)]
    var badgeGradient: [Color] = [Color(red: 59/255, green: 130/255, blue: 246/255),
                                  Color(red: 37/255, green: 99/255, blue: 235/255)]
    var accent: Color = Color(red: 37/255, green: 99/255, blue: 235/255)
    var accentSoft: Color = Color(red: 219/255, green: 234/255, blue: 254/255)

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Gradient header (tappable) ──
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "list.number")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Next Steps Action Plan")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: headerGradient,
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: isExpanded ? 0 : 16,
                    bottomTrailingRadius: isExpanded ? 0 : 16,
                    topTrailingRadius: 16
                ))
            }
            .buttonStyle(.plain)

            // ── Body ──
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Follow these steps in order:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                        Text("Complete each step before moving to the next. Never add multiple chemicals at the same time.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .lineSpacing(2)
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
        }
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    @ViewBuilder
    private func stepRow(_ step: TreatmentStep) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: badgeGradient,
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 30, height: 30)
                Text("\(step.id)")
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
                        .foregroundStyle(accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accentSoft)
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

// MARK: - Delete test record popup

struct DeleteTestRecordPopup: View {
    var onCancel: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(red: 254/255, green: 226/255, blue: 226/255))
                        .frame(width: 64, height: 64)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(red: 220/255, green: 38/255, blue: 38/255))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Delete Test Result?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.bottom, 10)

                Text("Are you sure you want to delete this test result? This action cannot be undone.")
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
                            .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)

                    Divider().frame(height: 52)

                    Button(action: onDelete) {
                        Text("Yes, Delete")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 220/255, green: 38/255, blue: 38/255))
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

// MARK: - Results view

struct PoolTestResultsView: View {
    let formData: PoolFormData
    var weatherSnapshot: WeatherSnapshot? = nil
    var onDone: (() -> Void)? = nil
    var backAction: (() -> Void)? = nil
    var recordID: UUID? = nil
    // Larger default clears the status bar in the test flow (which ignores the
    // top safe area); History presents this inside a NavigationStack and passes
    // a smaller value so the header isn't double-padded.
    var headerTopPadding: CGFloat = 60

    @Environment(AppSettings.self) private var settings
    @Environment(TestHistoryStore.self) private var historyStore

    private var analysis: PoolAnalysis {
        PoolChemistryEngine.analyze(formData)
    }

    private var weatherImpact: WeatherImpactResult? {
        WeatherService.weatherImpact(
            from: weatherSnapshot,
            testType: "pool",
            sanitizer: formData.sanitizer
        )
    }

    @State private var scrolledChartID: Int? = 0
    @State private var showDoneConfirm = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
            // MARK: Header
            VStack(alignment: .leading, spacing: 0) {
                // Top row: back button (left) + delete/done button (right)
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
                        // Delete button when viewing from history
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
                        // Done button when viewing fresh results
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

                Text("Pool Water Analysis")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 191/255, green: 219/255, blue: 254/255))
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, headerTopPadding)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 37/255, green: 99/255, blue: 235/255),
                        Color(red: 6/255, green: 182/255, blue: 212/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .ignoresSafeArea(edges: .top)
            )

            // MARK: Cards
            ScrollView {
                VStack(spacing: 0) {

                    // ── Quick info + section label + alert ──
                    VStack(spacing: 12) {
                        PoolQuickInfoCard(formData: formData)

                        Text("Parameter Results")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SummaryCard(issueCount: analysis.totalIssueCount)

                        if let weatherImpact {
                            WeatherImpactAlertCard(impact: weatherImpact, snapshot: weatherSnapshot)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)

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
                                columnSlots: 7,
                                isVisible: scrolledChartID == 0
                            )
                            .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                            .id(0)
                            WaterTempCard(
                                tempString: formData.waterTemp,
                                tempUnit: formData.tempUnit,
                                isVisible: scrolledChartID == 1
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

                    // ── Pool info + parameter readings ──
                    PoolInfoCard(formData: formData, analysis: analysis)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // ── Next steps ──
                    let treatmentSteps = PoolTreatmentPlanner.steps(
                        formData: formData,
                        analysis: analysis,
                        weatherSnapshot: weatherSnapshot
                    )
                    if !treatmentSteps.isEmpty {
                        NextStepsCard(steps: treatmentSteps)
                            .padding(.horizontal, 20)
                    }

                    // Bottom spacer so content clears the tab bar
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
}

// MARK: - Done viewing confirm popup

struct DoneViewingConfirmPopup: View {
    var onCancel: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(red: 219/255, green: 234/255, blue: 254/255))
                        .frame(width: 64, height: 64)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Done Viewing?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.bottom, 10)

                Text("Are you sure you're done viewing your test results? You can always find them again in your test history.")
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

                    Button(action: onConfirm) {
                        Text("Done")
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
    }
}

// MARK: - My Products section

struct MyProductsSection: View {
    var onSelect: (PoolProductType) -> Void
    @Environment(PoolProductStore.self) private var productStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("My Products")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(PoolProductType.allCases) { type in
                    MyProductCard(type: type, product: productStore.product(for: type)) {
                        onSelect(type)
                    }
                }
            }
        }
    }
}

// MARK: - My product card

private struct MyProductCard: View {
    let type: PoolProductType
    let product: PoolProduct
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(type.iconColor)
                    .frame(width: 48, height: 48)
                    .background(type.iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(type.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    if product.isConfigured {
                        Text(product.name)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .lineLimit(1)
                    } else {
                        Text("Not configured")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 156/255, green: 163/255, blue: 175/255))
                            .italic()
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 209/255, green: 213/255, blue: 219/255))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Product info row

private struct ProductInfoRow: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 46, height: 46)
                .background(iconBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Product config view

struct ProductConfigView: View {
    let type: PoolProductType
    var onBack: () -> Void
    @Environment(PoolProductStore.self) private var productStore
    @Environment(AppSettings.self) private var settings

    @State private var showingEdit = false

    private var product: PoolProduct { productStore.product(for: type) }

    private let gradient = LinearGradient(
        colors: [
            Color(red: 37/255, green: 99/255, blue: 235/255),
            Color(red: 6/255, green: 182/255, blue: 212/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            detailContent

            if showingEdit {
                ProductEditView(
                    type: type,
                    onDone: {
                        withAnimation(.easeInOut(duration: 0.3)) { showingEdit = false }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingEdit)
    }

    private var detailContent: some View {
        VStack(spacing: 0) {
            // Gradient header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { showingEdit = true }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Edit")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)

                HStack(spacing: 16) {
                    Image(systemName: type.icon)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(type.displayName)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text(type.subtitle)
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .background(gradient)

            // Info rows
            ScrollView {
                VStack(spacing: 12) {
                    ProductInfoRow(
                        icon: "tag.fill",
                        iconColor: type.iconColor,
                        iconBg: type.iconBackground,
                        label: "Product Name",
                        value: product.isConfigured ? product.name : "Not configured"
                    )
                    ProductInfoRow(
                        icon: "scalemass.fill",
                        iconColor: Color(red: 5/255, green: 150/255, blue: 105/255),
                        iconBg: Color(red: 209/255, green: 250/255, blue: 229/255),
                        label: "Amount",
                        value: amountDisplayValue
                    )
                    ProductInfoRow(
                        icon: "drop.fill",
                        iconColor: Color(red: 37/255, green: 99/255, blue: 235/255),
                        iconBg: Color(red: 219/255, green: 234/255, blue: 254/255),
                        label: "Per Volume",
                        value: perVolumeDisplayValue
                    )
                    ProductInfoRow(
                        icon: "arrow.up.arrow.down",
                        iconColor: Color(red: 217/255, green: 119/255, blue: 6/255),
                        iconBg: Color(red: 254/255, green: 243/255, blue: 199/255),
                        label: "\(type.direction.capitalized) \(type.parameterName) by",
                        value: changeByDisplayValue
                    )
                }
                .padding(24)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }

    private var amountDisplayValue: String {
        guard product.amountGrams > 0 else { return "—" }
        let val = settings.productWeightUnit == "imperial" ? product.amountGrams / 28.3495 : product.amountGrams
        return "\(formatNum(val)) \(settings.productWeightUnitLabel)"
    }

    private var perVolumeDisplayValue: String {
        guard product.perLiters > 0 else { return "—" }
        let val = settings.volumeUnit == "gallons" ? product.perLiters / 3.78541 : product.perLiters
        return "\(formatNum(val)) \(settings.volumeUnitLabel)"
    }

    private var changeByDisplayValue: String {
        guard product.toChangeBy > 0 else { return "—" }
        return "\(formatNum(product.toChangeBy)) \(type.changeUnit)"
    }

    private func formatNum(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : String(format: "%.2f", v)
    }
}

// MARK: - Product edit view

struct ProductEditView: View {
    let type: PoolProductType
    var onDone: () -> Void
    @Environment(PoolProductStore.self) private var productStore
    @Environment(AppSettings.self) private var settings

    @State private var name = ""
    @State private var amountText = ""
    @State private var perVolumeText = ""
    @State private var changeByText = ""
    @State private var keyboardHeight: CGFloat = 0

    private var weightUnit: String { settings.productWeightUnitLabel }
    private var volumeUnit: String { settings.volumeUnitLabel }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Gradient header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: onDone) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 15))
                            }
                            .foregroundStyle(.white.opacity(0.9))
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding(.bottom, 14)

                    Text("Edit \(type.displayName)")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Update your product details")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 72)
                .padding(.bottom, 28)
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

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            FormSectionLabel(text: "Product Name")
                            TextField("e.g. BioGuard Balance Pak", text: $name)
                                .font(.system(size: 16))
                                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            FormSectionLabel(text: "Dosage Formula")
                            VStack(spacing: 14) {
                                dosageRow(
                                    label: "Amount of product",
                                    text: $amountText,
                                    unit: weightUnit
                                )
                                dosageRow(
                                    label: "Per volume of water",
                                    text: $perVolumeText,
                                    unit: volumeUnit
                                )
                                dosageRow(
                                    label: "To \(type.direction) \(type.parameterName) by",
                                    text: $changeByText,
                                    unit: type.changeUnit
                                )
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                        }
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

            // Save button
            VStack(spacing: 0) {
                Button {
                    save()
                    onDone()
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }
            .background(Color.white)
        }
        .onAppear { loadExisting() }
    }

    @ViewBuilder
    private func dosageRow(label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            HStack(spacing: 6) {
                TextField("0", text: text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 15, weight: .medium))
                    .frame(width: 80)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 229/255, green: 231/255, blue: 235/255), lineWidth: 1)
                    )
                Text(unit)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .frame(minWidth: 40, alignment: .leading)
            }
        }
    }

    private func loadExisting() {
        let p = productStore.product(for: type)
        name = p.name
        if p.amountGrams > 0 {
            let val = settings.productWeightUnit == "imperial" ? p.amountGrams / 28.3495 : p.amountGrams
            amountText = formatNum(val)
        }
        if p.perLiters > 0 {
            let val = settings.volumeUnit == "gallons" ? p.perLiters / 3.78541 : p.perLiters
            perVolumeText = formatNum(val)
        }
        if p.toChangeBy > 0 {
            changeByText = formatNum(p.toChangeBy)
        }
    }

    private func save() {
        let amountVal   = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let perVol      = Double(perVolumeText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let changeBy    = Double(changeByText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let amountGrams = settings.productWeightUnit == "imperial" ? amountVal * 28.3495 : amountVal
        let perLiters   = settings.volumeUnit == "gallons" ? perVol * 3.78541 : perVol
        productStore.setProduct(
            PoolProduct(
                name: name.trimmingCharacters(in: .whitespaces),
                amountGrams: amountGrams,
                perLiters: perLiters,
                toChangeBy: changeBy
            ),
            for: type
        )
    }

    private func formatNum(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : String(format: "%.2f", v)
    }
}

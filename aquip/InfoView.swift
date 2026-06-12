import SwiftUI

// MARK: - Models

private enum InfoDestination: Hashable {
    case poolChemistry
    case spaChemistry
    case howToTest
    case poolMaintenance
    case spaMaintenance
}

private struct InfoHomeCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let destination: InfoDestination
}

private struct InfoSection: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let idealRange: String?
    let overview: String
    let bullets: [String]
    let lowHigh: [String]
    let weather: [WeatherInfoNote]
}

private struct InfoArticleSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let bullets: [String]
}

private struct WeatherInfoNote: Identifiable, Hashable {
    let id = UUID()
    let kind: WeatherInfoKind
    let message: String
}

private enum WeatherInfoKind: Hashable {
    case hot
    case sunny
    case rain

    var icon: String {
        switch self {
        case .hot: return "thermometer.medium"
        case .sunny: return "sun.max.fill"
        case .rain: return "cloud.rain.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .hot: return Color(red: 37/255, green: 99/255, blue: 235/255)
        case .sunny: return Color(red: 245/255, green: 158/255, blue: 11/255)
        case .rain: return Color(red: 59/255, green: 130/255, blue: 246/255)
        }
    }

    var iconBackground: Color {
        switch self {
        case .hot, .rain: return Color(red: 219/255, green: 234/255, blue: 254/255)
        case .sunny: return Color(red: 254/255, green: 243/255, blue: 199/255)
        }
    }

    var cardBackground: Color {
        switch self {
        case .hot, .rain: return Color(red: 239/255, green: 246/255, blue: 255/255)
        case .sunny: return Color(red: 255/255, green: 251/255, blue: 235/255)
        }
    }

    var border: Color {
        switch self {
        case .hot, .rain: return Color(red: 191/255, green: 219/255, blue: 254/255)
        case .sunny: return Color(red: 252/255, green: 211/255, blue: 77/255)
        }
    }

    var textColor: Color {
        switch self {
        case .hot, .rain: return Color(red: 30/255, green: 64/255, blue: 175/255)
        case .sunny: return Color(red: 120/255, green: 53/255, blue: 15/255)
        }
    }
}

private enum InfoTheme {
    case pool
    case spa
    case testing

    var gradient: [Color] {
        switch self {
        case .pool, .testing:
            return [
                Color(red: 37/255, green: 99/255, blue: 235/255),
                Color(red: 6/255, green: 182/255, blue: 212/255)
            ]
        case .spa:
            return [
                Color(red: 234/255, green: 88/255, blue: 12/255),
                Color(red: 245/255, green: 158/255, blue: 11/255)
            ]
        }
    }

    var accent: Color {
        switch self {
        case .pool, .testing: return Color(red: 37/255, green: 99/255, blue: 235/255)
        case .spa: return Color(red: 234/255, green: 88/255, blue: 12/255)
        }
    }

    var accentSoft: Color {
        switch self {
        case .pool, .testing: return Color(red: 219/255, green: 234/255, blue: 254/255)
        case .spa: return Color(red: 255/255, green: 237/255, blue: 213/255)
        }
    }

    var subtitle: Color {
        switch self {
        case .pool, .testing: return Color(red: 219/255, green: 234/255, blue: 254/255)
        case .spa: return Color(red: 254/255, green: 226/255, blue: 197/255)
        }
    }
}

// MARK: - Home data

private let infoHomeCards: [InfoHomeCard] = [
    InfoHomeCard(
        title: "Pool Chemistry",
        subtitle: "Ideal ranges, sanitizer types, weather effects, and what low/high readings mean",
        icon: "water.waves",
        destination: .poolChemistry
    ),
    InfoHomeCard(
        title: "Spa Chemistry",
        subtitle: "Hot tub sanitizer, balance, water age, optional readings, and safety basics",
        icon: "drop.fill",
        destination: .spaChemistry
    ),
    InfoHomeCard(
        title: "How to Test",
        subtitle: "Best practices for accurate water test strip readings",
        icon: "checklist",
        destination: .howToTest
    ),
    InfoHomeCard(
        title: "Pool Maintenance",
        subtitle: "Filters, pumps, jets, chlorinators, heaters, and circulation basics",
        icon: "gearshape.2.fill",
        destination: .poolMaintenance
    ),
    InfoHomeCard(
        title: "Spa Maintenance",
        subtitle: "Spa filters, jets, floaters, covers, water changes, and routine cleaning",
        icon: "sparkles",
        destination: .spaMaintenance
    )
]

// MARK: - InfoView

struct InfoView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                InfoHomeHeader()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(infoHomeCards) { card in
                            NavigationLink(value: card.destination) {
                                InfoHomeCardRow(card: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 100)
                }
                .background(InfoColors.pageBackground)
            }
            .background(InfoColors.pageBackground)
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: InfoDestination.self) { destination in
                switch destination {
                case .poolChemistry:
                    InfoSectionPage(
                        title: "Pool Chemistry",
                        subtitle: "Learn what each reading means and how to keep it balanced",
                        theme: .pool,
                        sections: poolChemistrySections
                    )
                case .spaChemistry:
                    InfoSectionPage(
                        title: "Spa Chemistry",
                        subtitle: "Hot tub balance, sanitizer, optional readings, and water age",
                        theme: .spa,
                        sections: spaChemistrySections
                    )
                case .howToTest:
                    InfoArticlePage(
                        title: "How to Test",
                        subtitle: "How to get reliable test strip readings",
                        theme: .testing,
                        sections: howToTestSections
                    )
                case .poolMaintenance:
                    InfoSectionPage(
                        title: "Pool Maintenance",
                        subtitle: "Equipment basics that keep water moving and clean",
                        theme: .pool,
                        sections: poolMaintenanceSections
                    )
                case .spaMaintenance:
                    InfoSectionPage(
                        title: "Spa Maintenance",
                        subtitle: "Filters, jets, floaters, covers, and water changes",
                        theme: .spa,
                        sections: spaMaintenanceSections
                    )
                }
            }
        }
    }
}

// MARK: - Shared colors

private enum InfoColors {
    static let pageBackground = Color(red: 249/255, green: 250/255, blue: 251/255)
    static let primaryText = Color(red: 17/255, green: 24/255, blue: 39/255)
    static let secondaryText = Color(red: 107/255, green: 114/255, blue: 128/255)
    static let cardBorder = Color(red: 229/255, green: 231/255, blue: 235/255)
    static let greenBg = Color(red: 240/255, green: 253/255, blue: 244/255)
    static let greenBorder = Color(red: 134/255, green: 239/255, blue: 172/255)
    static let greenText = Color(red: 22/255, green: 101/255, blue: 52/255)
    static let greenIcon = Color(red: 22/255, green: 163/255, blue: 74/255)
}

// MARK: - Home components

private struct InfoHomeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Water Care Info")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            Text("Learn about your water chemistry")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 32)
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
    }
}

private struct InfoHomeCardRow: View {
    let card: InfoHomeCard

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: card.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                .frame(width: 46, height: 46)
                .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(card.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(InfoColors.primaryText)
                Text(card.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(InfoColors.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 209/255, green: 213/255, blue: 219/255))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Section page

private struct InfoSectionPage: View {
    let title: String
    let subtitle: String
    let theme: InfoTheme
    let sections: [InfoSection]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String

    init(title: String, subtitle: String, theme: InfoTheme, sections: [InfoSection]) {
        self.title = title
        self.subtitle = subtitle
        self.theme = theme
        self.sections = sections
        _selectedID = State(initialValue: sections.first?.id ?? "")
    }

    private var selectedSection: InfoSection? {
        sections.first { $0.id == selectedID } ?? sections.first
    }

    var body: some View {
        VStack(spacing: 0) {
            CompactInfoHeader(title: title, subtitle: subtitle, theme: theme, onBack: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    horizontalPills

                    if let section = selectedSection {
                        InfoSectionContent(section: section, theme: theme)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(InfoColors.pageBackground)
        }
        .background(InfoColors.pageBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }

    private var horizontalPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sections) { section in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedID = section.id
                        }
                    } label: {
                        Text(section.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedID == section.id ? .white : theme.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(selectedID == section.id ? theme.accent : theme.accentSoft)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct InfoSectionContent: View {
    let section: InfoSection
    let theme: InfoTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 44, height: 44)
                    .background(theme.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(InfoColors.primaryText)
                    Text("What it means and how to manage it")
                        .font(.system(size: 13))
                        .foregroundStyle(InfoColors.secondaryText)
                }
            }

            if let ideal = section.idealRange {
                IdealRangeCard(text: ideal)
            }

            InfoWhiteCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Overview")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(InfoColors.primaryText)
                    Text(section.overview)
                        .font(.system(size: 14))
                        .foregroundStyle(InfoColors.secondaryText)
                        .lineSpacing(3)
                }
            }

            if !section.bullets.isEmpty {
                InfoBulletCard(title: "How to Keep It in Range", bullets: section.bullets)
            }

            if !section.lowHigh.isEmpty {
                InfoBulletCard(title: "When It Is Low or High", bullets: section.lowHigh)
            }

            if !section.weather.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weather & Temperature Impact")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(InfoColors.primaryText)

                    ForEach(section.weather) { note in
                        WeatherInfoAlert(note: note)
                    }
                }
            }
        }
    }
}

// MARK: - Article page

private struct InfoArticlePage: View {
    let title: String
    let subtitle: String
    let theme: InfoTheme
    let sections: [InfoArticleSection]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            CompactInfoHeader(title: title, subtitle: subtitle, theme: theme, onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sections) { section in
                        InfoWhiteCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: section.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(theme.accent)
                                        .frame(width: 38, height: 38)
                                        .background(theme.accentSoft)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    Text(section.title)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(InfoColors.primaryText)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(section.bullets, id: \.self) { bullet in
                                        InfoBulletRow(text: bullet)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(InfoColors.pageBackground)
        }
        .background(InfoColors.pageBackground)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Shared components

private struct CompactInfoHeader: View {
    let title: String
    let subtitle: String
    let theme: InfoTheme
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.92))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(theme.subtitle)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 28)
        .background(
            LinearGradient(colors: theme.gradient, startPoint: .leading, endPoint: .trailing)
        )
    }
}

private struct IdealRangeCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(InfoColors.greenIcon)
                .frame(width: 28, height: 28)
                .background(Color(red: 220/255, green: 252/255, blue: 231/255))
                .clipShape(Circle())

            (Text("Ideal Range, ").bold() + Text(text))
                .font(.system(size: 13))
                .foregroundStyle(InfoColors.greenText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(InfoColors.greenBg)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(InfoColors.greenBorder, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct WeatherInfoAlert: View {
    let note: WeatherInfoNote

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: note.kind.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(note.kind.iconColor)
                .frame(width: 28, height: 28)
                .background(note.kind.iconBackground)
                .clipShape(Circle())

            (Text("Weather Impact, ").bold() + Text(note.message))
                .font(.system(size: 13))
                .foregroundStyle(note.kind.textColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(note.kind.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(note.kind.border, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct InfoWhiteCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(InfoColors.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.035), radius: 4, x: 0, y: 2)
    }
}

private struct InfoBulletCard: View {
    let title: String
    let bullets: [String]

    var body: some View {
        InfoWhiteCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(InfoColors.primaryText)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(bullets, id: \.self) { bullet in
                        InfoBulletRow(text: bullet)
                    }
                }
            }
        }
    }
}

private struct InfoBulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(red: 156/255, green: 163/255, blue: 175/255))
                .frame(width: 5, height: 5)
                .padding(.top, 7)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(InfoColors.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Pool chemistry data

private let poolChemistrySections: [InfoSection] = [
    InfoSection(
        id: "free_chlorine",
        title: "Free Chlorine",
        icon: "drop.fill",
        idealRange: "1–3 ppm for chlorine/bromine pools and 2–4 ppm for salt pools.",
        overview: "Free chlorine is the active sanitizer available to kill bacteria, algae, and organic contamination. It is one of the most important safety readings in pool care.",
        bullets: [
            "Keep pH and alkalinity balanced so chlorine works effectively.",
            "For salt pools, check salt-cell output/runtime if chlorine keeps dropping.",
            "Avoid stabilized chlorine if CYA is already high."
        ],
        lowHigh: [
            "Low: raise chlorine after pH/alkalinity are safe. If algae or cloudiness is present, treat that sanitizer demand first.",
            "High: stop adding chlorine, remove tablets if applicable, and let sunlight/time lower the level before swimming."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Heat can increase chlorine demand and make levels drop faster."),
            WeatherInfoNote(kind: .sunny, message: "Sunlight burns off chlorine faster, especially when CYA/stabilizer is low."),
            WeatherInfoNote(kind: .rain, message: "Rain can dilute chlorine and make surface test-strip readings unreliable until the pump mixes the water.")
        ]
    ),
    InfoSection(
        id: "total_chlorine",
        title: "Total Chlorine",
        icon: "sum",
        idealRange: "Total chlorine should be close to free chlorine. Combined chlorine should stay below 0.2 ppm.",
        overview: "Total chlorine is free chlorine plus combined chlorine. The difference between total and free chlorine shows how much used-up chlorine is in the water.",
        bullets: [
            "Calculate combined chlorine as total chlorine minus free chlorine.",
            "Keep filters clean and sanitizer steady to avoid buildup.",
            "High combined chlorine usually means the water needs oxidation/shocking."
        ],
        lowHigh: [
            "Low total chlorine usually means free chlorine is low too, so sanitizer needs to be raised.",
            "High combined chlorine means contaminants are using up chlorine. Balance pH first, then oxidize/shock if metals are not suspected."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Hot weather and heavy use can increase organic load, which can raise combined chlorine."),
            WeatherInfoNote(kind: .rain, message: "Rain can add organics and debris that increase sanitizer demand.")
        ]
    ),
    InfoSection(
        id: "ph",
        title: "pH",
        icon: "dial.medium.fill",
        idealRange: "7.2–7.6 for pools.",
        overview: "pH tells you how acidic or basic the water is. It affects swimmer comfort, chlorine strength, scale, corrosion, and metal staining risk.",
        bullets: [
            "Fix alkalinity first when alkalinity is also out of range.",
            "Use acid to lower pH and pH increaser/soda ash to raise pH, following label dosage.",
            "Retest after circulation before adding more."
        ],
        lowHigh: [
            "Low: water can become corrosive and irritating. Raise alkalinity first if alkalinity is also low.",
            "High: chlorine becomes less effective and scaling/staining risk increases. Lower with acid, especially before shocking."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rainwater can shift pH and cause temporary surface readings until the pump mixes the pool."),
            WeatherInfoNote(kind: .hot, message: "Evaporation and heavy use during hot weather can make pH drift more often.")
        ]
    ),
    InfoSection(
        id: "alkalinity",
        title: "Alkalinity",
        icon: "chart.bar.fill",
        idealRange: "80–120 ppm.",
        overview: "Total alkalinity buffers pH and helps keep it stable. If alkalinity is off, pH can bounce around and become harder to control.",
        bullets: [
            "Raise low alkalinity with alkalinity increaser/sodium bicarbonate.",
            "Lower high alkalinity with acid and aeration cycles.",
            "Retest pH after changing alkalinity because they affect each other."
        ],
        lowHigh: [
            "Low: raise alkalinity first, then adjust pH if needed.",
            "High: pH may drift high and scaling risk increases. Use acid carefully, then aerate to raise pH without raising alkalinity."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain can dilute or shift alkalinity, so retest after circulation rather than reacting to unmixed surface water.")
        ]
    ),
    InfoSection(
        id: "cya",
        title: "Stabilizer / CYA",
        icon: "sun.max.fill",
        idealRange: "30–70 ppm for chlorine/bromine pools; 60–90 ppm for salt pools.",
        overview: "CYA protects chlorine from sunlight. Too little CYA lets chlorine burn off quickly; too much CYA can make chlorine less effective.",
        bullets: [
            "Add stabilizer only after pH/alkalinity are stable and active algae is controlled.",
            "For salt pools, a higher range is usually used because the cell produces chlorine gradually.",
            "Lowering high CYA usually requires partial drain/refill."
        ],
        lowHigh: [
            "Low: chlorine may disappear quickly in sun. Add stabilizer carefully and avoid overshooting.",
            "High: avoid stabilized chlorine and consider dilution. Do not keep adding tablets that raise CYA."
        ],
        weather: [
            WeatherInfoNote(kind: .sunny, message: "Sunlight is the main reason CYA matters; low CYA can cause fast chlorine loss."),
            WeatherInfoNote(kind: .rain, message: "Heavy rain/refill can dilute CYA. Retest after the water has circulated.")
        ]
    ),
    InfoSection(
        id: "calcium",
        title: "Calcium Hardness",
        icon: "hexagon.fill",
        idealRange: "200–500 ppm.",
        overview: "Calcium hardness affects scaling and corrosion. Too low can make water aggressive; too high can cause scale, cloudy water, and heater/equipment buildup.",
        bullets: [
            "Raise low calcium with calcium hardness increaser.",
            "High calcium usually requires dilution or careful scale management.",
            "Avoid cal-hypo shock when calcium is already high."
        ],
        lowHigh: [
            "Low: add calcium hardness increaser in stages.",
            "High: avoid calcium-adding products, control pH/alkalinity, and consider partial drain/refill."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Hot weather and evaporation can concentrate hardness minerals and increase scale risk."),
            WeatherInfoNote(kind: .rain, message: "Rain can dilute calcium readings after enough water replacement, so retest after circulation.")
        ]
    ),
    InfoSection(
        id: "phosphates",
        title: "Phosphates",
        icon: "leaf.fill",
        idealRange: "Below 100 ppb.",
        overview: "Phosphates are algae food. They are not the first thing to fix, but high phosphates can make algae prevention harder once sanitizer and balance are corrected.",
        bullets: [
            "Treat phosphates after pH, alkalinity, sanitizer, algae, and filtration are under control.",
            "Use phosphate remover by label and clean/backwash the filter afterward if directed.",
            "Do not use phosphate remover as a substitute for chlorine."
        ],
        lowHigh: [
            "Low/normal: no treatment needed.",
            "High: treat last after core chemistry and sanitizer are stable."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain can wash pollen, soil, fertilizer, and debris into the pool, increasing phosphate load.")
        ]
    ),
    InfoSection(
        id: "metals",
        title: "Metals",
        icon: "atom",
        idealRange: "Copper ≤ 0.2 ppm, iron ≤ 0.1 ppm, magnesium ≤ 50 ppm.",
        overview: "Copper, iron, and magnesium can cause staining, discoloration, or cloudy water. Brown, purple, black, or clear green water after shocking can point toward metals.",
        bullets: [
            "Treat high copper/iron with a metal sequestrant or remover before aggressive shocking.",
            "Keep pH near the low end of normal when metals are present to reduce staining risk.",
            "High magnesium/minerals often require dilution rather than a simple chemical fix."
        ],
        lowHigh: [
            "Low/normal: no product needed.",
            "High: avoid shocking blindly, treat metals, filter, clean/backwash, and retest."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain and runoff can introduce metals or minerals, especially from nearby soil, roofs, or fill water."),
            WeatherInfoNote(kind: .hot, message: "High pH and hot conditions can make scale/staining risk worse when metals or minerals are present.")
        ]
    ),
    InfoSection(
        id: "sanitizers",
        title: "Sanitizers",
        icon: "shield.fill",
        idealRange: "Chlorine and bromine pools: 1–3 ppm free chlorine/bromine. Salt pools: 2–4 ppm free chlorine.",
        overview: "Chlorine is added directly, salt systems generate chlorine from salt, and bromine can be used as an alternate sanitizer. All sanitizer systems still need proper pH, circulation, and testing.",
        bullets: [
            "Chlorine: common and fast-acting, but sunlight can reduce it quickly without enough CYA.",
            "Salt: still uses chlorine, but the salt cell generates it slowly over time.",
            "Bromine: more common in spas but can be used in some pool systems; do not manage it as CYA-dependent."
        ],
        lowHigh: [
            "Low sanitizer: unsafe water risk. Correct pH/alkalinity first when needed, then raise sanitizer.",
            "High sanitizer: stop adding sanitizer and wait for levels to fall before swimming."
        ],
        weather: [
            WeatherInfoNote(kind: .sunny, message: "Sun mainly affects chlorine/salt chlorine systems; bromine does not use CYA the same way."),
            WeatherInfoNote(kind: .hot, message: "Heat increases sanitizer demand for all systems."),
            WeatherInfoNote(kind: .rain, message: "Rain can dilute sanitizer and add contamination, so retest after circulation.")
        ]
    )
]

// MARK: - Spa chemistry data

private let spaChemistrySections: [InfoSection] = [
    InfoSection(
        id: "sanitizer",
        title: "Sanitizer",
        icon: "shield.fill",
        idealRange: "Chlorine, bromine, and salt spas: 3–5 ppm sanitizer residual. Enzyme spas still need chlorine or bromine backup unless product instructions say otherwise.",
        overview: "Spa sanitizer is critical because hot water and small volume create high sanitizer demand. Chlorine and salt spas use free chlorine; bromine spas need a bromine reading; enzyme systems still need a sanitizer residual.",
        bullets: [
            "Test sanitizer before use and after heavy usage.",
            "For bromine, use a bromine reading — do not judge it from free chlorine alone.",
            "For enzyme systems, use enzymes as support, not proof the water is safe."
        ],
        lowHigh: [
            "Low: do not use the spa. Correct pH if needed, then raise sanitizer.",
            "High: do not use the spa. Remove floater/tabs if applicable, leave cover open, circulate, and wait for sanitizer to drop."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Hot outdoor temperatures add to already-warm spa water and can increase sanitizer demand."),
            WeatherInfoNote(kind: .sunny, message: "Outdoor chlorine/salt spas can lose chlorine faster in sun. Bromine does not use CYA the same way."),
            WeatherInfoNote(kind: .rain, message: "Rain can quickly dilute an uncovered spa because the water volume is small.")
        ]
    ),
    InfoSection(
        id: "ph",
        title: "pH",
        icon: "dial.medium.fill",
        idealRange: "7.2–7.8 for spas.",
        overview: "pH affects sanitizer strength, comfort, scale, corrosion, and equipment protection. Spa pH can drift because hot water and aeration from jets change the water quickly.",
        bullets: [
            "Correct alkalinity first when both alkalinity and pH are off.",
            "Use small staged doses because spa volume is small.",
            "Retest after circulation before adding more product."
        ],
        lowHigh: [
            "Low: can irritate skin/eyes and corrode equipment. Raise carefully.",
            "High: can cause cloudy/milky water, scale, and weaker sanitizer. Lower with pH decreaser/acid."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain can affect pH if the spa is uncovered or rainwater enters."),
            WeatherInfoNote(kind: .hot, message: "Hot water and aeration can make pH drift more often than in pools.")
        ]
    ),
    InfoSection(
        id: "alkalinity",
        title: "Alkalinity",
        icon: "chart.bar.fill",
        idealRange: "80–120 ppm.",
        overview: "Alkalinity buffers pH. In spas, stable alkalinity helps prevent pH bounce from jets, heat, and frequent use.",
        bullets: [
            "Raise low alkalinity with alkalinity increaser.",
            "Lower high alkalinity with acid and aeration cycles.",
            "Retest pH afterward."
        ],
        lowHigh: [
            "Low: pH may swing quickly and equipment corrosion risk rises.",
            "High: pH tends to rise and scale/cloudiness can develop."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rainwater can shift alkalinity in uncovered spas; retest after circulation.")
        ]
    ),
    InfoSection(
        id: "cya",
        title: "CYA / Stabilizer",
        icon: "sun.max.fill",
        idealRange: "Optional for spas. Outdoor chlorine/salt spas may use about 20–30 ppm; bromine spas should not use CYA.",
        overview: "CYA protects chlorine from sunlight, but spas often do not need much because they are covered or use bromine. Too much CYA can make chlorine less effective.",
        bullets: [
            "Only consider CYA for outdoor chlorine or salt spas in direct sun.",
            "Do not add CYA for bromine spas.",
            "Do not add CYA before clearing cloudy/green contaminated water."
        ],
        lowHigh: [
            "Low: only matters if the spa is outdoor, chlorine-based, and exposed to sun.",
            "High: avoid stabilized chlorine and consider drain/refill."
        ],
        weather: [
            WeatherInfoNote(kind: .sunny, message: "Sunlight is the only reason CYA usually matters for spas."),
            WeatherInfoNote(kind: .rain, message: "Rain/refill can dilute CYA in uncovered outdoor spas.")
        ]
    ),
    InfoSection(
        id: "calcium",
        title: "Calcium Hardness",
        icon: "hexagon.fill",
        idealRange: "150–250 ppm for most portable spas.",
        overview: "Calcium protects surfaces and equipment, but too much can cause scale, milky water, and heater buildup. Low calcium can contribute to foaming.",
        bullets: [
            "Raise low calcium with calcium hardness increaser.",
            "High calcium often needs partial drain/refill or scale control.",
            "Use small doses and retest because spa volume is small."
        ],
        lowHigh: [
            "Low: can contribute to foam and corrosive water.",
            "High: can create scale, cloudy/milky water, and heater issues."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Evaporation and heat can concentrate minerals and increase scale risk."),
            WeatherInfoNote(kind: .rain, message: "Rain/refill can dilute hardness in an uncovered spa.")
        ]
    ),
    InfoSection(
        id: "phosphates",
        title: "Phosphates",
        icon: "leaf.fill",
        idealRange: "Below 100 ppb if tested.",
        overview: "Phosphates are optional for spa testing and should be treated after sanitizer, pH, alkalinity, water age, and filtration are handled.",
        bullets: [
            "Do not treat phosphates first when sanitizer is low or water is cloudy.",
            "Clean the filter before and after phosphate treatment if the product label recommends it.",
            "Phosphates are secondary compared with safe sanitizer."
        ],
        lowHigh: [
            "Normal/low: no action needed.",
            "High: treat last if water still has issues after sanitizer and filtration are correct."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain, pollen, leaves, and debris can add phosphates to outdoor or uncovered spas.")
        ]
    ),
    InfoSection(
        id: "metals",
        title: "Metals",
        icon: "atom",
        idealRange: "Copper ≤ 0.2 ppm, iron ≤ 0.1 ppm, magnesium ≤ 50 ppm.",
        overview: "Metals and minerals can cause brown, black, green, or discolored water, especially after shocking. Spa volume is small, so source water can strongly affect readings.",
        bullets: [
            "If water turns brown/black/clear green after shock, stop shocking and suspect metals.",
            "Use spa-safe metal sequestrant/remover and clean the filter.",
            "High magnesium/minerals may require drain/refill."
        ],
        lowHigh: [
            "Normal: no treatment needed.",
            "High: treat metals before aggressive oxidizing/shocking."
        ],
        weather: [
            WeatherInfoNote(kind: .rain, message: "Rain or runoff can introduce metals/minerals if the spa is uncovered."),
            WeatherInfoNote(kind: .hot, message: "High pH plus heat can increase scale/staining risk."
            )
        ]
    ),
    InfoSection(
        id: "sanitizer_types",
        title: "Sanitizer Types",
        icon: "bubbles.and.sparkles",
        idealRange: "Chlorine, bromine, and salt spas target 3–5 ppm. Enzyme systems still need a sanitizer backup unless product directions say otherwise.",
        overview: "Chlorine is direct sanitizer, bromine is common in hot water, salt systems generate chlorine, and enzymes help break down oils/organics but are not usually a sanitizer replacement.",
        bullets: [
            "Chlorine: fast and common, but can drop faster in hot/sunny conditions.",
            "Bromine: stable in hot water and often used with floaters or bromide banks.",
            "Salt: still chlorine, generated by a salt cell. Check salt level/output/runtime if FC stays low.",
            "Enzyme: helps with organics, but still verify chlorine or bromine residual."
        ],
        lowHigh: [
            "Low sanitizer: do not use the spa until corrected.",
            "High sanitizer: do not use the spa until levels return to range."
        ],
        weather: [
            WeatherInfoNote(kind: .hot, message: "Warm weather and high bather load can make sanitizer fall quickly."),
            WeatherInfoNote(kind: .sunny, message: "Sun mainly impacts chlorine/salt chlorine systems; bromine does not use CYA."),
            WeatherInfoNote(kind: .rain, message: "Rain can dilute sanitizer quickly in uncovered spas.")
        ]
    )
]

// MARK: - Maintenance data

private let poolMaintenanceSections: [InfoSection] = [
    maintenanceSection(id: "sand", title: "Sand Filters", icon: "line.3.horizontal.decrease.circle.fill", overview: "Sand filters trap debris as water passes through sand media. They are durable and simple, but need backwashing when pressure rises.", bullets: ["Backwash when pressure rises about 8–10 psi above clean pressure.", "Replace sand when it becomes channeled, clumped, or no longer filters well.", "Run the pump long enough for proper daily turnover."], weather: [.rain]),
    maintenanceSection(id: "de", title: "DE Filters", icon: "circle.grid.3x3.fill", overview: "DE filters use diatomaceous earth powder for very fine filtration. They clear water well but need proper cleaning and recharging.", bullets: ["Backwash/clean according to pressure rise and manufacturer instructions.", "Recharge with the correct amount of DE after cleaning.", "Do not run a DE filter without DE if the model requires it."], weather: [.rain]),
    maintenanceSection(id: "chlorinators", title: "Chlorinators", icon: "capsule.fill", overview: "Inline/offline chlorinators feed chlorine tablets gradually. They help maintain sanitizer but can also raise CYA if tablets are stabilized.", bullets: ["Check tablet level and feeder setting regularly.", "Avoid overfeeding if chlorine or CYA is high.", "Do not rely only on tablets during algae cleanup."], weather: [.sunny, .hot]),
    maintenanceSection(id: "salt", title: "Salt Generators", icon: "waveform", overview: "Salt generators create chlorine from salt. They are maintenance systems, not instant cleanup tools for green water.", bullets: ["Keep salt ppm in the manufacturer range.", "Inspect/clean the cell when output drops or scale appears.", "Increase runtime/output only when chlorine demand requires it."], weather: [.sunny, .hot]),
    maintenanceSection(id: "backwashing", title: "Backwashing", icon: "arrow.triangle.2.circlepath", overview: "Backwashing reverses water flow to flush dirt from sand or DE filters. It restores flow but also removes water and chemicals.", bullets: ["Backwash after heavy debris, rain, algae cleanup, or pressure rise.", "Retest chemistry after major backwashing/refill.", "Do not backwash right after adding stabilizer unless product instructions allow it."], weather: [.rain]),
    maintenanceSection(id: "pump", title: "Pool Pump", icon: "powerplug.fill", overview: "The pump moves water through the filter, heater, chlorinator, and returns. Without circulation, chemicals cannot mix safely or work properly.", bullets: ["Run longer during algae, cloudiness, rain cleanup, or hot weather.", "Check baskets and filter pressure if flow is weak.", "Do not add major chemicals while the pump is off."], weather: [.hot, .rain]),
    maintenanceSection(id: "jets", title: "Pool Jets", icon: "wind", overview: "Jets/returns help distribute chemicals and push water toward circulation patterns that reduce dead spots.", bullets: ["Angle returns to improve surface movement and circulation.", "Aim to avoid stagnant corners where algae can grow.", "Use circulation before retesting after rain or chemical additions."], weather: [.rain]),
    maintenanceSection(id: "heaters", title: "Pool Heaters", icon: "flame.fill", overview: "Heaters work best with balanced water. Low pH or high calcium can damage or scale heater components.", bullets: ["Keep pH, alkalinity, and calcium in range to protect the heater.", "Do not run unsafe chemistry through expensive equipment for long periods.", "Watch scale risk when pH/calcium are high."], weather: [.hot])
]

private let spaMaintenanceSections: [InfoSection] = [
    maintenanceSection(id: "filters", title: "Spa Filters", icon: "line.3.horizontal.decrease.circle.fill", overview: "Spa filters remove oils, debris, dead algae/biofilm, and suspended particles. Because spas are small and heavily used, filters clog quickly.", bullets: ["Rinse weekly during regular use.", "Deep clean monthly or after foamy/cloudy water.", "Replace cartridges when pleats are damaged or cleaning no longer restores flow."], weather: [.rain, .hot]),
    maintenanceSection(id: "jets", title: "Jets", icon: "wind", overview: "Jets circulate water, improve chemical mixing, and create aeration. They also affect pH movement in spas.", bullets: ["Run jets after adding chemicals to mix safely.", "Clean around jet fittings where biofilm can collect.", "Aeration can raise pH without raising alkalinity."], weather: [.rain]),
    maintenanceSection(id: "floater", title: "Chlorine/Bromine Floater", icon: "capsule.fill", overview: "A floating dispenser slowly releases tablets into the spa. It helps maintain sanitizer but needs adjustment based on usage and readings.", bullets: ["Remove or close the floater if sanitizer is high.", "Open/increase only if sanitizer is low and pH is safe.", "Never mix different sanitizer tablets in the same floater."], weather: [.hot, .sunny]),
    maintenanceSection(id: "cover", title: "Spa Cover", icon: "rectangle.fill.on.rectangle.fill", overview: "The cover keeps heat in, limits debris, and reduces weather exposure. It can also trap gases after shocking if left closed too soon.", bullets: ["Leave cover open during and shortly after shocking/oxidizing.", "Keep the cover clean so contaminants do not drip back into the spa.", "Use the cover during rain if possible to prevent dilution."], weather: [.rain, .sunny]),
    maintenanceSection(id: "water_changes", title: "Water Changes", icon: "calendar", overview: "Spa water builds up dissolved solids faster than pool water. Old water becomes harder to balance and may foam or smell.", bullets: ["Change water about every 3–4 months, sooner with heavy use.", "Drain/refill sooner if water is foamy, cloudy, smelly, or sanitizer will not hold.", "Use spa purge/plumbing cleaner before draining if biofilm is suspected."], weather: [.hot]),
    maintenanceSection(id: "circulation", title: "Circulation", icon: "arrow.triangle.2.circlepath", overview: "Circulation keeps chemicals mixed and pushes water through the filter. It is required before reliable retesting.", bullets: ["Run jets/pump after adding chemicals.", "Retest only after water has mixed.", "Increase circulation after rain, heavy use, foam, or cloudiness."], weather: [.rain, .hot]),
    maintenanceSection(id: "heater", title: "Spa Heater", icon: "flame.fill", overview: "Spa heaters are sensitive to scale and corrosive water. Balanced pH, alkalinity, and calcium protect the heater.", bullets: ["Do not use above 104°F / 40°C.", "Keep pH and calcium controlled to avoid scale.", "Low pH can be corrosive to heater components."], weather: [.hot])
]

private func maintenanceSection(id: String, title: String, icon: String, overview: String, bullets: [String], weather: [WeatherInfoKind]) -> InfoSection {
    InfoSection(
        id: id,
        title: title,
        icon: icon,
        idealRange: nil,
        overview: overview,
        bullets: bullets,
        lowHigh: [],
        weather: weather.map { kind in
            switch kind {
            case .hot:
                return WeatherInfoNote(kind: .hot, message: "Hot weather increases sanitizer demand and can require longer circulation or closer monitoring.")
            case .sunny:
                return WeatherInfoNote(kind: .sunny, message: "Sunny conditions can reduce chlorine faster and may require closer sanitizer checks.")
            case .rain:
                return WeatherInfoNote(kind: .rain, message: "Rain can add debris, dilute chemistry, and require circulation before accurate retesting.")
            }
        }
    )
}

// MARK: - Testing article data

private let howToTestSections: [InfoArticleSection] = [
    InfoArticleSection(
        title: "Before You Test",
        icon: "hand.raised.fill",
        bullets: [
            "Wash and dry your hands before touching strips.",
            "Check the strip bottle expiry date and keep strips dry.",
            "Do not test from water sitting on the surface after rain. Run the pump first so the water is mixed.",
            "Avoid testing immediately beside returns, skimmers, jets, chlorinators, or freshly added chemicals."
        ]
    ),
    InfoArticleSection(
        title: "Where to Take the Sample",
        icon: "drop.fill",
        bullets: [
            "For pools, collect from elbow depth away from returns and skimmers.",
            "For spas, collect away from jets and filters after circulation has mixed the water.",
            "Do not scoop from the very top layer of water during or immediately after rain."
        ]
    ),
    InfoArticleSection(
        title: "How to Use the Strip",
        icon: "testtube.2",
        bullets: [
            "Dip the strip according to the bottle instructions, usually only a quick dip is needed.",
            "Hold the strip level so pads do not bleed into each other.",
            "Wait exactly the bottle’s recommended time before comparing colours.",
            "Read in natural light when possible, not under coloured indoor lighting."
        ]
    ),
    InfoArticleSection(
        title: "When to Retest",
        icon: "clock.arrow.circlepath",
        bullets: [
            "Retest after major chemical additions once the pump has circulated the water.",
            "Retest a few hours after rain stops, after the pump has mixed the water.",
            "Retest sanitizer more often during hot, sunny weather or after heavy use.",
            "If a reading looks impossible, test again before adding a large dose."
        ]
    ),
    InfoArticleSection(
        title: "Common Mistakes",
        icon: "exclamationmark.triangle.fill",
        bullets: [
            "Do not compare strip colours too early or too late.",
            "Do not use wet fingers inside the strip bottle.",
            "Do not make large chemical changes from an unmixed rainwater sample.",
            "Do not treat weather alerts as chemical readings — they are reminders to monitor and retest."
        ]
    )
]

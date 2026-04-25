import SwiftUI

// MARK: - Data

struct InfoTopic: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private let poolTopics: [InfoTopic] = [
    InfoTopic(icon: "thermometer",         title: "Temperature Effects",   description: "How water temperature affects chemical balance and dosing"),
    InfoTopic(icon: "cloud.rain.fill",     title: "Weather Impact",        description: "How sun, rain and temperature swings affect pool chemistry"),
    InfoTopic(icon: "drop.fill",           title: "Chlorine (Free & Total)",description: "Understanding chlorine levels and combined chlorine"),
    InfoTopic(icon: "waveform",            title: "Salt Chlorination",     description: "How saltwater systems generate and maintain chlorine"),
    InfoTopic(icon: "flame.fill",          title: "Bromine",               description: "Using bromine as an alternative sanitizer"),
    InfoTopic(icon: "dial.medium.fill",    title: "pH Balance",            description: "Maintaining proper pH and why it matters"),
    InfoTopic(icon: "chart.bar.fill",      title: "Total Alkalinity",      description: "How alkalinity buffers pH and stabilises your pool"),
    InfoTopic(icon: "sun.max.fill",        title: "Cyanuric Acid",         description: "Protecting chlorine from UV degradation"),
    InfoTopic(icon: "hexagon.fill",        title: "Calcium Hardness",      description: "Preventing scale buildup and protecting equipment"),
    InfoTopic(icon: "bubbles.and.sparkles",title: "Shocking Your Pool",    description: "When and how to shock for clear, safe water"),
]

private let spaTopics: [InfoTopic] = [
    InfoTopic(icon: "thermometer",         title: "Temperature & Chemistry",description: "How high heat changes sanitizer demand in hot tubs"),
    InfoTopic(icon: "drop.fill",           title: "Sanitizer Levels",      description: "Maintaining safe chlorine or bromine in a spa"),
    InfoTopic(icon: "waveform",            title: "Salt Systems for Spas", description: "Salt chlorination in compact hot tub environments"),
    InfoTopic(icon: "dial.medium.fill",    title: "pH Balance",            description: "Managing pH in heated, aerated spa water"),
    InfoTopic(icon: "chart.bar.fill",      title: "Total Alkalinity",      description: "Alkalinity management in high-turnover spa water"),
    InfoTopic(icon: "calendar",            title: "Water Change Schedule", description: "When and how to drain and refill your spa"),
    InfoTopic(icon: "bubbles.and.sparkles",title: "Foam & Cloudiness",     description: "Causes and solutions for foam and cloudy spa water"),
    InfoTopic(icon: "shield.fill",         title: "Biofilm Prevention",    description: "Preventing bacterial buildup in spa lines and jets"),
    InfoTopic(icon: "hexagon.fill",        title: "Calcium Hardness",      description: "Protecting spa surfaces and equipment from scale"),
]

// MARK: - Info view

struct InfoView: View {
    @State private var selectedSegment = "pool"

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header with segment control
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water Care Info")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Learn about your water chemistry")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                }

                // Pool / Spa toggle
                HStack(spacing: 0) {
                    ForEach([("pool", "Pool"), ("spa", "Hot Tub / Spa")], id: \.0) { value, label in
                        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedSegment = value } } label: {
                            Text(label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(
                                    selectedSegment == value
                                    ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                    : .white.opacity(0.8)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selectedSegment == value
                                    ? Color.white
                                    : Color.white.opacity(0.15)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 14))
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

            // Topic list
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(selectedSegment == "pool" ? poolTopics : spaTopics) { topic in
                        InfoTopicRow(topic: topic)
                    }
                }
                .padding(24)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }
}

// MARK: - Topic row

struct InfoTopicRow: View {
    let topic: InfoTopic

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: topic.icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                .frame(width: 46, height: 46)
                .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(topic.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                Text(topic.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .lineLimit(2)
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

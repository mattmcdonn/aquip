import SwiftUI

// MARK: - Setting row component

private struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let detail: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
                    .frame(width: 42, height: 42)
                    .background(iconBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    if let detail {
                        Text(detail)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 209/255, green: 213/255, blue: 219/255))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Temperature unit subpage

private struct TemperatureUnitView: View {
    @Environment(AppSettings.self) private var settings
    var onBack: () -> Void

    private let gradient = LinearGradient(
        colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                 Color(red: 6/255, green: 182/255, blue: 212/255)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                            Text("Back").font(.system(size: 15))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.bottom, 14)
                Text("Temperature Unit")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text("Choose how temperatures are displayed")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .background(gradient)

            // Options
            VStack(spacing: 0) {
                optionRow(
                    label: "Celsius (°C)",
                    subtitle: "e.g. 26°C",
                    value: "celsius"
                )
                Divider().padding(.leading, 60)
                optionRow(
                    label: "Fahrenheit (°F)",
                    subtitle: "e.g. 78°F",
                    value: "fahrenheit"
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding(20)

            Spacer()
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }

    @ViewBuilder
    private func optionRow(label: String, subtitle: String, value: String) -> some View {
        Button {
            settings.temperatureUnit = value
            settings.save()
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
                Spacer()
                if settings.temperatureUnit == value {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Volume unit subpage

private struct VolumeUnitView: View {
    @Environment(AppSettings.self) private var settings
    var onBack: () -> Void

    private let gradient = LinearGradient(
        colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                 Color(red: 6/255, green: 182/255, blue: 212/255)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                            Text("Back").font(.system(size: 15))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.bottom, 14)
                Text("Volume Unit")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                Text("Choose how volumes are displayed")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .background(gradient)

            // Options
            VStack(spacing: 0) {
                optionRow(
                    label: "Litres (L)",
                    subtitle: "e.g. 50,000 L",
                    value: "litres"
                )
                Divider().padding(.leading, 60)
                optionRow(
                    label: "Gallons (gal)",
                    subtitle: "e.g. 13,209 gal",
                    value: "gallons"
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
            .padding(20)

            Spacer()
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }

    @ViewBuilder
    private func optionRow(label: String, subtitle: String, value: String) -> some View {
        Button {
            settings.volumeUnit = value
            settings.save()
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
                Spacer()
                if settings.volumeUnit == value {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Main settings view

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    @State private var showTempUnit = false
    @State private var showVolumeUnit = false
    @State private var showTerms = false

    private let gradient = LinearGradient(
        colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                 Color(red: 6/255, green: 182/255, blue: 212/255)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        ZStack {
            settingsMain

            if showTempUnit {
                TemperatureUnitView(onBack: {
                    withAnimation(.easeInOut(duration: 0.3)) { showTempUnit = false }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            if showVolumeUnit {
                VolumeUnitView(onBack: {
                    withAnimation(.easeInOut(duration: 0.3)) { showVolumeUnit = false }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            if showTerms {
                TermsAndConditionsView(onBack: {
                    withAnimation(.easeInOut(duration: 0.3)) { showTerms = false }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showTempUnit)
        .animation(.easeInOut(duration: 0.3), value: showVolumeUnit)
        .animation(.easeInOut(duration: 0.3), value: showTerms)
    }

    private var settingsMain: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                Text("App preferences and options")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 32)
            .background(gradient)

            ScrollView {
                VStack(spacing: 20) {
                    // Measurements section
                    VStack(spacing: 0) {
                        sectionHeader(title: "Measurements")

                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "thermometer.medium",
                                iconColor: Color(red: 239/255, green: 68/255, blue: 68/255),
                                iconBg: Color(red: 254/255, green: 226/255, blue: 226/255),
                                title: "Temperature Unit",
                                detail: settings.temperatureUnit == "celsius" ? "Celsius (°C)" : "Fahrenheit (°F)"
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) { showTempUnit = true }
                            }

                            Divider().padding(.leading, 72)

                            SettingRow(
                                icon: "drop.fill",
                                iconColor: Color(red: 37/255, green: 99/255, blue: 235/255),
                                iconBg: Color(red: 219/255, green: 234/255, blue: 254/255),
                                title: "Volume Unit",
                                detail: settings.volumeUnit == "litres" ? "Litres (L)" : "Gallons (gal)"
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) { showVolumeUnit = true }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    }

                    // Legal section
                    VStack(spacing: 0) {
                        sectionHeader(title: "Legal")

                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "doc.text.fill",
                                iconColor: Color(red: 37/255, green: 99/255, blue: 235/255),
                                iconBg: Color(red: 219/255, green: 234/255, blue: 254/255),
                                title: "Terms & Conditions",
                                detail: settings.hasAgreedToTerms ? "Agreed" : "Not agreed"
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) { showTerms = true }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color.white)
    }

    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}

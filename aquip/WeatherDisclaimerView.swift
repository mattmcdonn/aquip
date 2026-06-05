import SwiftUI

// MARK: - Pill button rendered inside the blue gradient header

struct WeatherPillButton: View {
    var testType: String?
    @State private var weatherService = WeatherService()
    @State private var isSheetOpen = false
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Button {
            var t = Transaction(animation: nil)
            t.disablesAnimations = true
            withTransaction(t) { isSheetOpen = true }
        } label: {
            HStack(spacing: 6) {
                // Condition icon
                Group {
                    if weatherService.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.gray)
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: weatherService.isAvailable
                              ? weatherService.conditionSymbol
                              : "location.slash.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(weatherService.isAvailable
                                             ? weatherService.conditionColor
                                             : Color(.systemGray3))
                    }
                }
                .frame(width: 26, height: 26)
                .background(Color.white)
                .clipShape(Circle())

                // Temperature
                Text(weatherService.isLoading ? "···" : weatherService.displayTemperature(settings: settings))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.white)
                    .clipShape(Capsule())

                Text("Weather")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
            .padding(.leading, 6)
            .padding(.trailing, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.25))
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .onAppear { weatherService.start() }
        .fullScreenCover(isPresented: $isSheetOpen) {
            WeatherSheetCover(testType: testType, weatherService: weatherService, isPresented: $isSheetOpen)
                .presentationBackground(.clear)
        }
    }
}

// MARK: - Full-screen wrapper with dim + slide-up panel

struct WeatherSheetCover: View {
    var testType: String?
    var weatherService: WeatherService
    @Binding var isPresented: Bool
    @State private var showDim = false
    @State private var showPanel = false

    var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                // Dimmed backdrop — fades in immediately, independently of the panel
                Color.black.opacity(showDim ? 0.45 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { dismissSheet() }

                // Full-width panel — slides up slightly after the dim
                WeatherSheetView(
                    testType: testType,
                    weatherService: weatherService,
                    isPresented: $isPresented,
                    screenHeight: screenHeight,
                    onDismiss: dismissSheet
                )
                .frame(maxWidth: .infinity)
                .offset(y: showPanel ? 0 : screenHeight)
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear {
            // Dim appears instantly
            withAnimation(.easeOut(duration: 0.15)) {
                showDim = true
            }
            // Panel slides up just after the dim is fully visible
            withAnimation(.spring(response: 0.38, dampingFraction: 0.88).delay(0.12)) {
                showPanel = true
            }
        }
    }

    func dismissSheet() {
        withAnimation(.easeIn(duration: 0.22)) {
            showPanel = false
            showDim = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            // Suppress the fullScreenCover dismiss slide-down animation
            var t = Transaction(animation: nil)
            t.disablesAnimations = true
            withTransaction(t) { isPresented = false }
        }
    }
}

// MARK: - Bottom sheet content

struct WeatherSheetView: View {
    var testType: String?
    var weatherService: WeatherService
    @Binding var isPresented: Bool
    var screenHeight: CGFloat
    var onDismiss: () -> Void
    @Environment(AppSettings.self) private var settings

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar row with X button
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 209/255, green: 213/255, blue: 219/255))
                    .frame(width: 48, height: 5)

                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .frame(width: 32, height: 32)
                            .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 20)
                }
            }
            .frame(height: 44)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 20) {

                    // ── Current condition + temperature circles ──
                    HStack(spacing: 24) {
                        // Weather icon circle
                        Group {
                            if weatherService.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(Color(.systemGray))
                                    .scaleEffect(1.2)
                            } else {
                                Image(systemName: weatherService.isAvailable
                                      ? weatherService.conditionSymbol
                                      : "location.slash.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(weatherService.isAvailable
                                                     ? weatherService.conditionColor
                                                     : Color(.systemGray3))
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(weatherService.isAvailable
                                    ? weatherService.conditionBgColor
                                    : Color(red: 243/255, green: 244/255, blue: 246/255))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

                        // Temperature circle
                        VStack(spacing: 4) {
                            Image(systemName: weatherService.isAvailable ? "thermometer.medium" : "thermometer.slash")
                                .font(.system(size: 28))
                                .foregroundStyle(weatherService.isAvailable
                                                 ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                                 : Color(.systemGray3))
                            Text(weatherService.isLoading ? "···" : weatherService.displayTemperature(settings: settings))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(weatherService.isAvailable
                                                 ? Color(red: 55/255, green: 65/255, blue: 81/255)
                                                 : Color(.systemGray3))
                        }
                        .frame(width: 80, height: 80)
                        .background(weatherService.isAvailable
                                    ? Color(red: 219/255, green: 234/255, blue: 254/255)
                                    : Color(red: 243/255, green: 244/255, blue: 246/255))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 8)

                    // ── Weather Impact card ──
                    let impactText = weatherService.impactText(for: testType)
                    let (impactBg, impactBorder, impactTitle, impactBody): (Color, Color, Color, Color) = weatherService.isAvailable
                        ? (
                            Color(red: 255/255, green: 251/255, blue: 235/255),
                            Color(red: 252/255, green: 211/255, blue: 77/255),
                            Color(red: 120/255, green: 53/255, blue: 15/255),
                            Color(red: 146/255, green: 64/255, blue: 14/255)
                          )
                        : (
                            Color(red: 249/255, green: 250/255, blue: 251/255),
                            Color(red: 229/255, green: 231/255, blue: 235/255),
                            Color(red: 55/255, green: 65/255, blue: 81/255),
                            Color(red: 107/255, green: 114/255, blue: 128/255)
                          )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(weatherService.isAvailable ? "Current Weather Impact" : "Weather Unavailable")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(impactTitle)
                        Text(impactText)
                            .font(.system(size: 14))
                            .foregroundStyle(impactBody)
                            .lineSpacing(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(impactBg)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(impactBorder, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // ── Weather Conditions reference section ──
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weather Conditions")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))

                        WeatherConditionRow(
                            iconName: "sun.max.fill",
                            iconColor: Color(red: 245/255, green: 158/255, blue: 11/255),
                            iconBg: Color(red: 254/255, green: 243/255, blue: 199/255),
                            cardBg: Color(red: 255/255, green: 251/255, blue: 235/255),
                            cardBorder: Color(red: 252/255, green: 211/255, blue: 77/255),
                            title: "Sunny",
                            description: "UV rays break down chlorine faster. Test more frequently and add stabilizer to protect chlorine levels."
                        )

                        WeatherConditionRow(
                            iconName: "cloud.fill",
                            iconColor: Color(.systemGray),
                            iconBg: Color(red: 243/255, green: 244/255, blue: 246/255),
                            cardBg: Color(red: 249/255, green: 250/255, blue: 251/255),
                            cardBorder: Color(red: 229/255, green: 231/255, blue: 235/255),
                            title: "Cloudy",
                            description: "Reduced UV exposure helps chlorine last longer. Maintain regular testing schedule for balanced chemistry."
                        )

                        WeatherConditionRow(
                            iconName: "cloud.rain.fill",
                            iconColor: Color(red: 59/255, green: 130/255, blue: 246/255),
                            iconBg: Color(red: 219/255, green: 234/255, blue: 254/255),
                            cardBg: Color(red: 239/255, green: 246/255, blue: 255/255),
                            cardBorder: Color(red: 191/255, green: 219/255, blue: 254/255),
                            title: "Rainy",
                            description: "Rain dilutes chemicals and lowers pH. Test immediately after heavy rain and rebalance as needed."
                        )

                        WeatherConditionRow(
                            iconName: "cloud.snow.fill",
                            iconColor: Color(red: 8/255, green: 145/255, blue: 178/255),
                            iconBg: Color(red: 207/255, green: 250/255, blue: 254/255),
                            cardBg: Color(red: 236/255, green: 254/255, blue: 255/255),
                            cardBorder: Color(red: 165/255, green: 243/255, blue: 252/255),
                            title: "Snow / Freezing",
                            description: "Cold conditions slow chemical reactions. Monitor circulation to prevent freezing and check chemistry less frequently."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // ── Temperature Effects section ──
                    let isFahrenheit = settings.temperatureUnit == "fahrenheit"
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Temperature Effects")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))

                        WeatherConditionRow(
                            iconName: "snowflake",
                            iconColor: Color(red: 8/255, green: 145/255, blue: 178/255),
                            iconBg: Color(red: 207/255, green: 250/255, blue: 254/255),
                            cardBg: Color(red: 236/255, green: 254/255, blue: 255/255),
                            cardBorder: Color(red: 165/255, green: 243/255, blue: 252/255),
                            title: isFahrenheit ? "Cold (<60°F)" : "Cold (<16°C)",
                            description: "Chlorine dissipates slowly. Chemical reactions are slower, requiring less frequent adjustments."
                        )

                        WeatherConditionRow(
                            iconName: "thermometer.low",
                            iconColor: Color(red: 22/255, green: 163/255, blue: 74/255),
                            iconBg: Color(red: 220/255, green: 252/255, blue: 231/255),
                            cardBg: Color(red: 240/255, green: 253/255, blue: 244/255),
                            cardBorder: Color(red: 187/255, green: 247/255, blue: 208/255),
                            title: isFahrenheit ? "Ideal (60–75°F)" : "Ideal (16–24°C)",
                            description: "Optimal temperature range for balanced chemistry. Standard testing schedule is sufficient."
                        )

                        WeatherConditionRow(
                            iconName: "thermometer.medium",
                            iconColor: Color(red: 234/255, green: 88/255, blue: 12/255),
                            iconBg: Color(red: 255/255, green: 237/255, blue: 213/255),
                            cardBg: Color(red: 255/255, green: 247/255, blue: 237/255),
                            cardBorder: Color(red: 254/255, green: 215/255, blue: 170/255),
                            title: isFahrenheit ? "Warm (75–90°F)" : "Warm (24–32°C)",
                            description: "Chlorine evaporates faster and bacteria multiply quicker. Test 2–3 times per week and maintain higher chlorine levels."
                        )

                        WeatherConditionRow(
                            iconName: "thermometer.high",
                            iconColor: Color(red: 220/255, green: 38/255, blue: 38/255),
                            iconBg: Color(red: 254/255, green: 226/255, blue: 226/255),
                            cardBg: Color(red: 255/255, green: 241/255, blue: 242/255),
                            cardBorder: Color(red: 254/255, green: 202/255, blue: 202/255),
                            title: isFahrenheit ? "Hot (>90°F)" : "Hot (>32°C)",
                            description: "Extreme chlorine loss and rapid bacteria growth. Test daily and consider shock treatment more frequently."
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
        .clipShape(.rect(topLeadingRadius: 28, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 28))
        .frame(maxHeight: screenHeight * 0.85, alignment: .top)
        .frame(maxWidth: .infinity)
    }
}

struct WeatherConditionRow: View {
    let iconName: String
    let iconColor: Color
    let iconBg: Color
    let cardBg: Color
    let cardBorder: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
                .frame(width: 48, height: 48)
                .background(iconBg)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(cardBg)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    WeatherPillButton(testType: nil)
        .padding()
        .background(
            LinearGradient(
                colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                         Color(red: 6/255, green: 182/255, blue: 212/255)],
                startPoint: .leading, endPoint: .trailing
            )
        )
}

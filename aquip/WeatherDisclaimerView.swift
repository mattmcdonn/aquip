import SwiftUI

enum WeatherCondition: String {
    case sunny, cloudy, rainy
}

struct WeatherData {
    let condition: WeatherCondition
    let temperature: Int
}

struct WeatherDisclaimerView: View {
    var testType: String?
    @State private var isModalOpen = false

    // Mock weather data
    private let weather = WeatherData(condition: .sunny, temperature: 78)

    private var weatherIconName: String {
        switch weather.condition {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        }
    }

    private var weatherIconColor: Color {
        switch weather.condition {
        case .sunny: return Color(red: 245/255, green: 158/255, blue: 11/255)
        case .cloudy: return .gray
        case .rainy: return .blue
        }
    }

    private var weatherImpact: String {
        let waterType = testType == "spa" ? "spa" : "pool"

        if weather.condition == .sunny && weather.temperature > 85 {
            return "Hot sunny weather increases chlorine consumption. UV rays break down chlorine faster, requiring more frequent testing and chemical additions to maintain safe \(waterType) water."
        } else if weather.condition == .sunny {
            return "Sunny weather increases UV exposure, which can reduce chlorine effectiveness. Consider testing your \(waterType) more frequently during prolonged sun exposure."
        } else if weather.condition == .rainy {
            return "Rain can dilute \(waterType) chemicals and introduce contaminants. After heavy rain, test your water and adjust chemical levels as needed. pH levels may drop after rainfall."
        } else {
            return "Cloudy weather reduces UV exposure, helping chlorine last longer. However, continue regular testing to maintain balanced \(waterType) chemistry."
        }
    }

    var body: some View {
        Button {
            isModalOpen = true
        } label: {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: weatherIconName)
                        .font(.system(size: 18))
                        .foregroundStyle(weatherIconColor)

                    // Temperature pill
                    HStack(spacing: 4) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.systemGray))
                        Text("\(weather.temperature)°F")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("Weather Impact")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(red: 120/255, green: 53/255, blue: 15/255))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 217/255, green: 119/255, blue: 6/255))
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 255/255, green: 251/255, blue: 235/255),
                        Color(red: 255/255, green: 247/255, blue: 237/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 252/255, green: 211/255, blue: 77/255), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $isModalOpen) {
            WeatherModalView(
                weather: weather,
                weatherIconName: weatherIconName,
                weatherIconColor: weatherIconColor,
                weatherImpact: weatherImpact,
                isPresented: $isModalOpen
            )
        }
    }
}

struct WeatherModalView: View {
    let weather: WeatherData
    let weatherIconName: String
    let weatherIconColor: Color
    let weatherImpact: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal card
            VStack(alignment: .leading, spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }

                // Weather icon + temperature
                HStack(spacing: 12) {
                    Image(systemName: weatherIconName)
                        .font(.system(size: 20))
                        .foregroundStyle(weatherIconColor)

                    HStack(spacing: 8) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.systemGray))
                        Text("\(weather.temperature)°F")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 4)

                Text("Weather Impact")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.top, 16)

                Text(weatherImpact)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                    .lineSpacing(4)
                    .padding(.top, 12)

                Button {
                    isPresented = false
                } label: {
                    Text("Got it")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 24)
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
            .padding(.horizontal, 24)
        }
        .background(ClearBackground())
    }
}

// Makes the fullScreenCover background transparent
struct ClearBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    WeatherDisclaimerView(testType: nil)
        .padding()
}

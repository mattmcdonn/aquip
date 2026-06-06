import Foundation
import WeatherKit
import CoreLocation
import SwiftUI


// MARK: - Weather impact models

struct WeatherSnapshot: Codable, Hashable {
    var isAvailable: Bool
    var temperatureCelsius: Double
    var conditionSymbol: String
    var conditionDescription: String

    var temperatureFahrenheit: Double {
        temperatureCelsius * 9 / 5 + 32
    }

    var isHot: Bool {
        temperatureFahrenheit > 80 || temperatureCelsius > 27
    }

    var isSunny: Bool {
        ["sun.max.fill", "cloud.sun.fill"].contains(conditionSymbol)
    }

    var isRaining: Bool {
        ["cloud.rain.fill", "cloud.drizzle.fill", "cloud.bolt.rain.fill"].contains(conditionSymbol)
    }

    var hasWeatherImpact: Bool {
        isAvailable && (isHot || isSunny || isRaining)
    }
}

struct WeatherImpactResult: Hashable {
    let title: String
    let message: String
    let nextStepTitle: String
    let nextStepDescription: String
}

// MARK: - Live weather service

@Observable
final class WeatherService: NSObject {

    static let shared = WeatherService()

    // MARK: - State

    enum LoadState {
        case loading
        case available
        case unavailable
    }

    var loadState: LoadState = .loading
    var conditionSymbol: String = "cloud.fill"
    var conditionColor: Color = Color(.systemGray)
    /// Always stored in Celsius. Use displayTemperature(settings:) for UI.
    var temperatureCelsius: Double = 0

    var isLoading: Bool { loadState == .loading }
    var isAvailable: Bool { loadState == .available }

    /// Returns a display string like "26°" or "78°" depending on the given settings.
    func displayTemperature(settings: AppSettings) -> String {
        guard isAvailable else { return "–" }
        if settings.temperatureUnit == "fahrenheit" {
            let f = Int((temperatureCelsius * 9 / 5 + 32).rounded())
            return "\(f)°"
        } else {
            return "\(Int(temperatureCelsius.rounded()))°"
        }
    }

    /// Legacy property retained for impactText parsing.
    var temperatureDisplay: String {
        let f = Int((temperatureCelsius * 9 / 5 + 32).rounded())
        return "\(f)°"
    }


    var snapshot: WeatherSnapshot {
        WeatherSnapshot(
            isAvailable: isAvailable,
            temperatureCelsius: temperatureCelsius,
            conditionSymbol: conditionSymbol,
            conditionDescription: readableConditionName
        )
    }

    private var readableConditionName: String {
        switch conditionSymbol {
        case "sun.max.fill": return "Sunny"
        case "cloud.sun.fill": return "Partly Sunny"
        case "cloud.rain.fill": return "Rain"
        case "cloud.drizzle.fill": return "Drizzle"
        case "cloud.bolt.rain.fill": return "Storms"
        case "cloud.fill": return "Cloudy"
        case "cloud.fog.fill": return "Foggy"
        case "cloud.snow.fill", "snowflake": return "Snow"
        case "cloud.sleet.fill": return "Sleet"
        default: return "Current Weather"
        }
    }

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private let kitService = WeatherKit.WeatherService.shared

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // Call this when the pill appears to begin the location + weather fetch.
    func start() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            loadState = .unavailable
        }
    }

    // MARK: - Weather fetch

    private func fetchWeather(for location: CLLocation) {
        Task { @MainActor in
            do {
                let weather = try await kitService.weather(for: location)
                let current = weather.currentWeather
                let (symbol, color) = Self.mapCondition(current.condition)
                conditionSymbol = symbol
                conditionColor = color
                temperatureCelsius = current.temperature.converted(to: .celsius).value
                loadState = .available
            } catch {
                loadState = .unavailable
            }
        }
    }

    // MARK: - WeatherKit condition → SF Symbol + Color

    static func mapCondition(_ condition: WeatherKit.WeatherCondition) -> (String, Color) {
        switch condition {
        case .clear, .mostlyClear, .hot:
            return ("sun.max.fill", Color(red: 245/255, green: 158/255, blue: 11/255))
        case .partlyCloudy, .sunShowers, .sunFlurries:
            return ("cloud.sun.fill", Color(red: 245/255, green: 158/255, blue: 11/255))
        case .mostlyCloudy, .cloudy, .breezy, .windy:
            return ("cloud.fill", Color(.systemGray))
        case .foggy, .haze, .smoky, .blowingDust:
            return ("cloud.fog.fill", Color(.systemGray2))
        case .drizzle:
            return ("cloud.drizzle.fill", Color(red: 96/255, green: 165/255, blue: 250/255))
        case .rain, .heavyRain:
            return ("cloud.rain.fill", Color(red: 59/255, green: 130/255, blue: 246/255))
        case .thunderstorms, .strongStorms, .isolatedThunderstorms, .scatteredThunderstorms:
            return ("cloud.bolt.rain.fill", Color(red: 99/255, green: 102/255, blue: 241/255))
        case .snow, .heavySnow, .blowingSnow, .flurries:
            return ("cloud.snow.fill", Color(red: 8/255, green: 145/255, blue: 178/255))
        case .sleet, .freezingRain, .freezingDrizzle, .wintryMix:
            return ("cloud.sleet.fill", Color(red: 8/255, green: 145/255, blue: 178/255))
        case .blizzard, .frigid:
            return ("snowflake", Color(red: 8/255, green: 145/255, blue: 178/255))
        case .hail:
            return ("cloud.hail.fill", Color(red: 59/255, green: 130/255, blue: 246/255))
        case .hurricane, .tropicalStorm:
            return ("hurricane", Color(red: 239/255, green: 68/255, blue: 68/255))
        @unknown default:
            return ("cloud.fill", Color(.systemGray))
        }
    }

    // MARK: - Impact text

    /// Returns a description of how the current weather affects pool/spa chemistry.
    func impactText(for testType: String?) -> String {
        guard isAvailable else {
            return "Weather data is currently unavailable. Enable location services and ensure you have an internet connection to see local weather impact on your \(testType == "spa" ? "spa" : "pool") chemistry."
        }
        let waterType = testType == "spa" ? "spa" : "pool"
        let tempVal = Int(temperatureDisplay.filter { $0.isNumber || $0 == "-" }) ?? 0

        switch conditionSymbol {
        case "sun.max.fill":
            if tempVal > 85 {
                return "Hot, sunny conditions significantly increase chlorine consumption. UV rays break down chlorine faster and high temperatures speed up bacterial growth. Test your \(waterType) daily and be prepared to add extra sanitiser."
            }
            return "Sunny weather increases UV exposure, which gradually reduces chlorine effectiveness. Consider testing your \(waterType) more frequently during prolonged sun exposure."
        case "cloud.sun.fill":
            return "Partly cloudy conditions have a moderate effect on chlorine. UV exposure is intermittent — maintain your normal testing schedule."
        case "cloud.rain.fill", "cloud.drizzle.fill":
            return "Rain can dilute \(waterType) chemicals and introduce contaminants. After heavy rain, test your water and adjust chemical levels as needed. pH levels often drop after rainfall."
        case "cloud.bolt.rain.fill":
            return "Thunderstorm conditions can significantly dilute your \(waterType) chemistry and introduce debris and contaminants. Test and rebalance your water after the storm passes."
        case "cloud.snow.fill", "snowflake", "cloud.sleet.fill":
            return "Cold or snowy conditions slow chemical reactions and reduce chlorine consumption. If your \(waterType) is open, check that circulation is functioning and monitor for freezing."
        default:
            return "Cloudy or overcast weather reduces UV exposure, helping chlorine last longer. Continue your regular \(waterType) testing schedule."
        }
    }



    // MARK: - Weather impact result for test results + next steps

    static func weatherImpact(
        from snapshot: WeatherSnapshot?,
        testType: String,
        sanitizer: String
    ) -> WeatherImpactResult? {
        guard let snapshot, snapshot.hasWeatherImpact else { return nil }

        let isSpa = testType == "spa"
        let waterType = isSpa ? "spa" : "pool"
        let isHot = snapshot.isHot
        let isSunny = snapshot.isSunny
        let isRaining = snapshot.isRaining

        let sanitizerWord: String = {
            switch sanitizer {
            case "bromine": return "bromine"
            case "enzyme": return "chlorine or bromine backup sanitizer"
            default: return "chlorine"
            }
        }()

        let title = "Weather Notice"
        let message: String
        let nextStepTitle: String
        let nextStepDescription: String

        switch (isHot, isSunny, isRaining) {
        case (true, true, true):
            message = "Hot, sunny, and rainy conditions can make chemistry change quickly. Heat and sun can lower sanitizer faster, while rain can dilute chemicals and affect test readings."
            nextStepTitle = "Monitor weather-related chemistry changes"
            nextStepDescription = "Because it is hot, sunny, and raining, monitor \(sanitizerWord) closely, keep the pump running if safe, and retest a few hours after the rain stops. Do not rely on test strips taken from unmixed surface water during or immediately after rain."

        case (true, true, false):
            message = "Hot and sunny weather can lower sanitizer faster. Heat increases sanitizer demand, and sunlight can burn off chlorine."
            nextStepTitle = "Test sanitizer more often during hot, sunny weather"
            nextStepDescription = "Because it is hot and sunny, test \(sanitizerWord) more often over the next day or two. If chlorine keeps dropping in a chlorine or salt system, check CYA/stabilizer after the water is otherwise balanced."

        case (true, false, true):
            message = "Hot weather can increase sanitizer demand, while rain can dilute chemicals and affect test readings."
            nextStepTitle = "Retest after rain and monitor sanitizer"
            nextStepDescription = "Because it is hot and raining, keep the pump running if safe, wait until the rain stops, then retest after circulation. Heat can make \(sanitizerWord) drop faster, and rain can dilute or distort readings."

        case (false, true, true):
            message = "Sun can lower chlorine, while rain can dilute chemicals and affect test readings."
            nextStepTitle = "Retest after rain before major adjustments"
            nextStepDescription = "Because sun and rain can both affect sanitizer readings, avoid large corrections during active rain unless the water is unsafe. Retest a few hours after the rain stops and the pump has mixed the water."

        case (true, false, false):
            message = "Outdoor temperature is above 80°F / 27°C. Heat can increase sanitizer demand and cause chlorine or bromine to drop faster."
            nextStepTitle = "Test sanitizer more often during hot weather"
            nextStepDescription = "Because the outside temperature is above 80°F / 27°C, test \(sanitizerWord) more often over the next day or two. Heat can increase sanitizer demand and cause levels to drop faster, especially after heavy use."

        case (false, true, false):
            message = "Sunny weather can lower chlorine faster, especially if stabilizer/CYA is low."
            nextStepTitle = "Monitor sanitizer during sunny weather"
            if sanitizer == "bromine" {
                nextStepDescription = "Because it is sunny, monitor bromine more closely. Do not add CYA/stabilizer for a bromine system."
            } else if sanitizer == "enzyme" {
                nextStepDescription = "Because it is sunny, monitor the chlorine or bromine backup sanitizer more closely. Enzymes do not replace sanitizer testing."
            } else {
                nextStepDescription = "Because it is sunny, monitor chlorine closely. Sunlight can break down chlorine faster, especially when CYA/stabilizer is low."
            }

        case (false, false, true):
            message = "It is currently raining. Rain can dilute chemicals, add contaminants, and temporarily affect test readings."
            nextStepTitle = "Retest after the rain stops"
            nextStepDescription = "Because it is currently raining, wait to make large chemical adjustments until a few hours after the rain stops if the water is not dangerously unsafe. Keep the pump running if safe, then retest after circulation so the rainwater is mixed into the \(waterType). Test strips taken from unmixed surface water may read rainwater more than the actual mixed water."

        default:
            return nil
        }

        return WeatherImpactResult(
            title: title,
            message: message,
            nextStepTitle: nextStepTitle,
            nextStepDescription: nextStepDescription
        )
    }

    // MARK: - Background circle color for weather icon in sheet

    var conditionBgColor: Color {
        switch conditionSymbol {
        case "sun.max.fill", "cloud.sun.fill":
            return Color(red: 254/255, green: 243/255, blue: 199/255)
        case "cloud.rain.fill", "cloud.drizzle.fill", "cloud.bolt.rain.fill":
            return Color(red: 219/255, green: 234/255, blue: 254/255)
        case "cloud.snow.fill", "snowflake", "cloud.sleet.fill":
            return Color(red: 207/255, green: 250/255, blue: 254/255)
        case "hurricane":
            return Color(red: 254/255, green: 226/255, blue: 226/255)
        default:
            return Color(red: 243/255, green: 244/255, blue: 246/255)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherService: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.requestLocation()
            case .denied, .restricted:
                self.loadState = .unavailable
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor [weak self] in
            self?.fetchWeather(for: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.loadState = .unavailable
        }
    }
}

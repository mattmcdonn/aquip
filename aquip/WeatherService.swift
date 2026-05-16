import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

// MARK: - Live weather service

@Observable
final class WeatherService: NSObject {

    // MARK: - State

    enum LoadState {
        case loading
        case available
        case unavailable
    }

    var loadState: LoadState = .loading
    var conditionSymbol: String = "cloud.fill"
    var conditionColor: Color = Color(.systemGray)
    var temperatureDisplay: String = "–"

    var isLoading: Bool { loadState == .loading }
    var isAvailable: Bool { loadState == .available }

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
                let tempF = Int(current.temperature.converted(to: .fahrenheit).value.rounded())
                temperatureDisplay = "\(tempF)°"
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

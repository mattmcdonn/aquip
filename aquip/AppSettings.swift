import Foundation

// MARK: - App-wide settings store

@Observable
class AppSettings {

    // "celsius" or "fahrenheit"  — default celsius
    var temperatureUnit: String = "celsius"

    // "litres" or "gallons"  — default litres
    var volumeUnit: String = "litres"

    // "metric" (grams) or "imperial" (ounces) — default metric
    var productWeightUnit: String = "metric"

    // Whether the user has agreed to the Terms & Conditions
    var hasAgreedToTerms: Bool = false

    private let storageKey = "aquip.appSettings.v1"

    init() { load() }

    // MARK: - Persistence

    private struct Stored: Codable {
        var temperatureUnit: String
        var volumeUnit: String
        var productWeightUnit: String?
        var hasAgreedToTerms: Bool
    }

    func save() {
        let s = Stored(
            temperatureUnit: temperatureUnit,
            volumeUnit: volumeUnit,
            productWeightUnit: productWeightUnit,
            hasAgreedToTerms: hasAgreedToTerms
        )
        guard let data = try? JSONEncoder().encode(s) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(Stored.self, from: data)
        else { return }
        temperatureUnit   = decoded.temperatureUnit
        volumeUnit        = decoded.volumeUnit
        productWeightUnit = decoded.productWeightUnit ?? "metric"
        hasAgreedToTerms  = decoded.hasAgreedToTerms
    }

    // MARK: - Temperature helpers

    /// Symbol for the current temperature unit (e.g. "°C")
    var temperatureUnitSymbol: String {
        temperatureUnit == "fahrenheit" ? "°F" : "°C"
    }

    /// Format a celsius value as a display string in the user's preferred unit.
    func displayTemperature(celsius: Double) -> String {
        if temperatureUnit == "fahrenheit" {
            let f = Int((celsius * 9.0 / 5.0 + 32.0).rounded())
            return "\(f)°"
        } else {
            return "\(Int(celsius.rounded()))°"
        }
    }

    // MARK: - Product weight helpers

    var productWeightUnitLabel: String {
        productWeightUnit == "imperial" ? "oz" : "g"
    }

    // MARK: - Volume helpers

    /// Short label for the current volume unit (e.g. "L")
    var volumeUnitLabel: String {
        volumeUnit == "gallons" ? "gal" : "L"
    }

    /// Long label for the current volume unit (e.g. "Litres")
    var volumeUnitLong: String {
        volumeUnit == "gallons" ? "Gallons" : "Litres"
    }

    /// Format a litres value as a display string in the user's preferred unit.
    func displayVolume(litres: Double) -> String {
        if volumeUnit == "gallons" {
            let gal = litres / 3.78541
            let formatted = gal >= 1000
                ? String(format: "%.0f", gal)
                : String(format: "%.1f", gal)
            return "\(formatted) gal"
        } else {
            let formatted = litres >= 1000
                ? String(format: "%.0f", litres)
                : String(format: "%.1f", litres)
            return "\(formatted) L"
        }
    }

    /// Convert a value in the current unit to litres.
    func toLitres(_ value: Double) -> Double {
        volumeUnit == "gallons" ? value * 3.78541 : value
    }

    /// Convert a value in the current temperature unit to celsius.
    func toCelsius(_ value: Double) -> Double {
        temperatureUnit == "fahrenheit" ? (value - 32.0) * 5.0 / 9.0 : value
    }
}

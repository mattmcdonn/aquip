import Foundation

// MARK: - Spa result types

enum SpaSanitizerKind {
    case chlorine
    case bromine
    case enzyme
    case salt
}

/// Result of analysing a spa water sample. Mirrors `PoolAnalysis` but follows the
/// spa-specific ideal ranges (sanitizer target 3–5 ppm, pH 7.2–7.8, etc.) and
/// adapts to the selected sanitizer type.
struct SpaAnalysis {
    let kind: SpaSanitizerKind
    /// Enzyme backing residual: "chlorine" / "bromine" / "unknown" (empty otherwise).
    let backingType: String
    /// True when the primary sanitizer residual is read as bromine.
    let usesBromineReading: Bool
    /// True when a sanitizer residual reading was supplied.
    let sanitizerProvided: Bool
    /// Numeric sanitizer residual, if supplied.
    let sanitizerValue: Double?
    let sanitizerLabel: String
    let sanitizerAbbrev: String

    let sanitizerResidual: ParameterResult
    let combinedChlorine: ParameterResult
    let showCombinedChlorine: Bool
    let combinedChlorineValue: Double?

    let pH: ParameterResult
    let alkalinity: ParameterResult
    let calcium: ParameterResult
    let stabilizer: ParameterResult
    let phosphates: ParameterResult
    let copper: ParameterResult
    let iron: ParameterResult
    let magnesium: ParameterResult

    /// CYA / stabilizer only matters for outdoor chlorine-based spas.
    let cyaRelevant: Bool
    let tempUnsafe: Bool
    let tempProvided: Bool

    var totalIssueCount: Int {
        var results: [ParameterResult] = [
            sanitizerResidual, pH, alkalinity, calcium, phosphates, copper, iron, magnesium
        ]
        if showCombinedChlorine { results.append(combinedChlorine) }
        if cyaRelevant { results.append(stabilizer) }
        var count = results.filter { $0.level != .ok }.count
        if tempUnsafe { count += 1 }
        return count
    }
}

// MARK: - Engine

enum SpaChemistryEngine {

    static func analyze(_ data: PoolFormData) -> SpaAnalysis {
        let kind = sanitizerKind(data)
        let reading = resolveReading(kind: kind, backing: data.sanitizerBackingType, data: data)

        let usesBromine = reading.usesBromine
        let value = reading.value
        let provided = value != nil

        // Combined chlorine only applies to chlorine-side spas with FC + TC present.
        let fc = Double(data.freeChlorine)
        let tc = Double(data.totalChlorine)
        var ccValue: Double? = nil
        var ccResult = ParameterResult(level: .ok, issues: [])
        var showCC = false
        if !usesBromine, let fcVal = fc, let tcVal = tc {
            let cc = max(0, tcVal - fcVal)
            ccValue = cc
            showCC = true
            ccResult = ParameterResult(level: cc > 0.5 ? .high : .ok, issues: [])
        }

        let cyaRelevant = isCyaRelevant(kind: kind, backing: data.sanitizerBackingType, usesBromine: usesBromine, data: data)

        let tempF = fahrenheit(data)

        return SpaAnalysis(
            kind: kind,
            backingType: data.sanitizerBackingType,
            usesBromineReading: usesBromine,
            sanitizerProvided: provided,
            sanitizerValue: value,
            sanitizerLabel: usesBromine ? "Bromine" : "Free Chlorine",
            sanitizerAbbrev: usesBromine ? "Br" : "FC",
            sanitizerResidual: analyzeResidual(value),
            combinedChlorine: ccResult,
            showCombinedChlorine: showCC,
            combinedChlorineValue: ccValue,
            pH: analyzePH(data),
            alkalinity: analyzeAlkalinity(data),
            calcium: analyzeCalcium(data),
            stabilizer: analyzeStabilizer(relevant: cyaRelevant, data: data),
            phosphates: analyzePhosphates(data),
            copper: analyzeCopper(data),
            iron: analyzeIron(data),
            magnesium: analyzeMagnesium(data),
            cyaRelevant: cyaRelevant,
            tempUnsafe: (tempF ?? 0) > 104,
            tempProvided: tempF != nil
        )
    }

    // MARK: Sanitizer resolution

    static func sanitizerKind(_ data: PoolFormData) -> SpaSanitizerKind {
        switch data.sanitizer {
        case "bromine": return .bromine
        case "enzyme":  return .enzyme
        case "salt":    return .salt
        default:        return .chlorine
        }
    }

    private static func resolveReading(
        kind: SpaSanitizerKind, backing: String, data: PoolFormData
    ) -> (usesBromine: Bool, value: Double?) {
        let fc = Double(data.freeChlorine)
        let br = Double(data.bromine)
        switch kind {
        case .bromine:
            return (true, br)
        case .chlorine, .salt:
            return (false, fc)
        case .enzyme:
            switch backing {
            case "bromine":  return (true, br)
            case "chlorine": return (false, fc)
            default:
                // Unknown backing: use whichever residual was supplied.
                if br != nil && fc == nil { return (true, br) }
                return (false, fc)
            }
        }
    }

    private static func isCyaRelevant(
        kind: SpaSanitizerKind, backing: String, usesBromine: Bool, data: PoolFormData
    ) -> Bool {
        guard data.directSunlight == "yes" else { return false }
        if usesBromine { return false }
        switch kind {
        case .chlorine, .salt: return true
        case .enzyme:          return backing == "chlorine"
        case .bromine:         return false
        }
    }

    // MARK: Parameter analysis

    private static func analyzeResidual(_ value: Double?) -> ParameterResult {
        guard let v = value else {
            // No reading — flag as an issue so the user is told to test.
            return ParameterResult(level: .low, issues: [.init(id: "san_missing", label: "Not Tested")])
        }
        if v < 3 { return ParameterResult(level: .low,  issues: [.init(id: "san_low",  label: "Too Low")]) }
        if v > 5 { return ParameterResult(level: .high, issues: [.init(id: "san_high", label: "Too High")]) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzePH(_ data: PoolFormData) -> ParameterResult {
        guard let ph = Double(data.pH) else { return ParameterResult(level: .ok, issues: []) }
        if ph < 7.2 { return ParameterResult(level: .low,  issues: []) }
        if ph > 7.8 { return ParameterResult(level: .high, issues: []) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeAlkalinity(_ data: PoolFormData) -> ParameterResult {
        guard let alk = Double(data.alkalinity) else { return ParameterResult(level: .ok, issues: []) }
        if alk < 80  { return ParameterResult(level: .low,  issues: []) }
        if alk > 120 { return ParameterResult(level: .high, issues: []) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeCalcium(_ data: PoolFormData) -> ParameterResult {
        guard let cal = Double(data.calciumHardness) else { return ParameterResult(level: .ok, issues: []) }
        if cal < 150 { return ParameterResult(level: .low,  issues: []) }
        if cal > 300 { return ParameterResult(level: .high, issues: []) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeStabilizer(relevant: Bool, data: PoolFormData) -> ParameterResult {
        guard relevant, let cya = Double(data.cyanuricAcid) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if cya < 20 { return ParameterResult(level: .low,  issues: []) }
        if cya > 50 { return ParameterResult(level: .high, issues: []) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzePhosphates(_ data: PoolFormData) -> ParameterResult {
        guard let phos = Double(data.phosphates) else { return ParameterResult(level: .ok, issues: []) }
        if phos > 100 { return ParameterResult(level: .high, issues: []) }
        return ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeCopper(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.copper) else { return ParameterResult(level: .ok, issues: []) }
        return val > 0.2 ? ParameterResult(level: .high, issues: []) : ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeIron(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.iron) else { return ParameterResult(level: .ok, issues: []) }
        return val > 0.1 ? ParameterResult(level: .high, issues: []) : ParameterResult(level: .ok, issues: [])
    }

    private static func analyzeMagnesium(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.magnesium) else { return ParameterResult(level: .ok, issues: []) }
        return val > 50 ? ParameterResult(level: .high, issues: []) : ParameterResult(level: .ok, issues: [])
    }

    // MARK: Helpers

    static func fahrenheit(_ data: PoolFormData) -> Double? {
        guard let t = Double(data.waterTemp) else { return nil }
        return data.tempUnit == "celsius" ? t * 9 / 5 + 32 : t
    }
}

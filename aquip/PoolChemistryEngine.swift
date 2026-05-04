import Foundation

// MARK: - Result types

enum ChemistryLevel {
    case ok
    case low
    case high
}

struct ChemistryIssue: Identifiable {
    let id: String
    let label: String
}

struct ParameterResult {
    let level: ChemistryLevel
    let issues: [ChemistryIssue]   // populated for .low and .high cases
}

struct PoolAnalysis {
    let freeChlorine: ParameterResult
    let combinedChlorine: ParameterResult
    let pH: ParameterResult
    let alkalinity: ParameterResult
    let stabilizer: ParameterResult
    let phosphates: ParameterResult
    let calcium: ParameterResult
    let copper: ParameterResult
    let iron: ParameterResult
    let magnesium: ParameterResult

    var totalIssueCount: Int {
        [freeChlorine, combinedChlorine, pH, alkalinity, stabilizer, phosphates,
         calcium, copper, iron, magnesium].filter { $0.level != .ok }.count
    }
}

// MARK: - Engine

enum PoolChemistryEngine {

    static func analyze(_ data: PoolFormData) -> PoolAnalysis {
        PoolAnalysis(
            freeChlorine: analyzeChlorine(data),
            combinedChlorine: analyzeCombinedChlorine(data),
            pH: analyzePH(data),
            alkalinity: analyzeAlkalinity(data),
            stabilizer: analyzeStabilizer(data),
            phosphates: analyzePhosphates(data),
            calcium: analyzeCalcium(data),
            copper: analyzeCopper(data),
            iron: analyzeIron(data),
            magnesium: analyzeMagnesium(data)
        )
    }

    // MARK: Calcium Hardness

    private static func analyzeCalcium(_ data: PoolFormData) -> ParameterResult {
        guard let cal = Double(data.calciumHardness) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if cal >= 200 && cal <= 500 {
            return ParameterResult(level: .ok, issues: [])
        }
        if cal < 200 {
            var issues: [ChemistryIssue] = []
            if data.recentlyOpened == "yes" {
                issues.append(.init(id: "cal_low_opened", label: "Recently Opened"))
            }
            return ParameterResult(level: .low, issues: issues)
        }
        // cal > 500
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "cal_high_opened", label: "Recently Opened"))
        }
        if data.directSunlight == "yes" {
            issues.append(.init(id: "cal_high_sun", label: "Direct Sunlight"))
        }
        return ParameterResult(level: .high, issues: issues)
    }

    // MARK: Copper

    private static func analyzeCopper(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.copper) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if val <= 0.2 {
            return ParameterResult(level: .ok, issues: [])
        }
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "cu_opened", label: "Recently Opened"))
        }
        if let ph = Double(data.pH), ph < 7.2 {
            issues.append(.init(id: "cu_low_ph", label: "Low pH"))
        }
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF > 85 {
                issues.append(.init(id: "cu_high_temp", label: "High Water Temp"))
            }
        }
        return ParameterResult(level: .high, issues: issues)
    }

    // MARK: Iron

    private static func analyzeIron(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.iron) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if val <= 0.1 {
            return ParameterResult(level: .ok, issues: [])
        }
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "fe_opened", label: "Recently Opened"))
        }
        if let ph = Double(data.pH), ph < 7.2 {
            issues.append(.init(id: "fe_low_ph", label: "Low pH"))
        }
        if data.hasCirculation == "no" {
            issues.append(.init(id: "fe_no_circ", label: "No Circulation"))
        } else if ["4_8", "under_4", "rarely"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "fe_low_pump", label: "Low Pump Runtime"))
        }
        return ParameterResult(level: .high, issues: issues)
    }

    // MARK: Magnesium

    private static func analyzeMagnesium(_ data: PoolFormData) -> ParameterResult {
        guard let val = Double(data.magnesium) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if val <= 50 {
            return ParameterResult(level: .ok, issues: [])
        }
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "mg_opened", label: "Recently Opened"))
        }
        return ParameterResult(level: .high, issues: issues)
    }

    // MARK: Stabilizer (Cyanuric Acid)

    private static func analyzeStabilizer(_ data: PoolFormData) -> ParameterResult {
        guard let cya = Double(data.cyanuricAcid) else {
            return ParameterResult(level: .ok, issues: [])
        }
        let isSalt = data.sanitizer == "salt"
        let lowThreshold: Double = isSalt ? 60 : 30
        let highThreshold: Double = isSalt ? 90 : 70
        if cya >= lowThreshold && cya <= highThreshold {
            return ParameterResult(level: .ok, issues: [])
        }
        if cya < lowThreshold {
            return ParameterResult(level: .low, issues: lowStabilizerIssues(data))
        }
        return ParameterResult(level: .high, issues: highStabilizerIssues(data))
    }

    private static func lowStabilizerIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "stab_low_opened", label: "Recently Opened"))
        }
        return issues
    }

    private static func highStabilizerIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "stab_high_opened", label: "Recently Opened"))
        }
        if data.higherUsage == "no" {
            issues.append(.init(id: "stab_high_usage", label: "Low Usage"))
        }
        return issues
    }

    // MARK: Phosphates

    private static func analyzePhosphates(_ data: PoolFormData) -> ParameterResult {
        guard let phos = Double(data.phosphates) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if phos <= 500 {
            return ParameterResult(level: .ok, issues: [])
        }
        return ParameterResult(level: .high, issues: highPhosphateIssues(data))
    }

    private static func highPhosphateIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Water appearance (green/black/brown/cloudy)
        if ["green", "black", "brown", "cloudy"].contains(data.waterColor) {
            issues.append(.init(id: "phos_water", label: "Discoloured Water"))
        }

        // 2. Algae presence
        if !data.algaeType.isEmpty {
            issues.append(.init(id: "phos_algae", label: "Algae Present"))
        }

        // 3. High usage
        if data.higherUsage == "yes" {
            issues.append(.init(id: "phos_usage", label: "High Usage"))
        }

        // 4. Recently opened
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "phos_opened", label: "Recently Opened"))
        }

        // 5. No / low circulation
        if data.hasCirculation == "no" {
            issues.append(.init(id: "phos_no_circ", label: "No Circulation"))
        } else if ["4_8", "under_4", "rarely"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "phos_low_pump", label: "Low Pump Runtime"))
        }

        // 6. Low free chlorine (<1 ppm)
        if let fc = Double(data.freeChlorine), fc < 1.0 {
            issues.append(.init(id: "phos_low_cl", label: "Low Free Chlorine"))
        }

        // 7. No direct sunlight
        if data.directSunlight == "no" {
            issues.append(.init(id: "phos_no_sun", label: "No Direct Sunlight"))
        }

        return issues
    }

    // MARK: Combined Chlorine  (total - free)

    private static func analyzeCombinedChlorine(_ data: PoolFormData) -> ParameterResult {
        guard let fc = Double(data.freeChlorine),
              let tc = Double(data.totalChlorine) else {
            // Can't compute — treat as ok so no false positive
            return ParameterResult(level: .ok, issues: [])
        }
        let cc = tc - fc
        // Combined chlorine cannot physically be negative; treat as ok
        if cc <= 0.5 {
            return ParameterResult(level: .ok, issues: [])
        }
        return ParameterResult(level: .high, issues: highCombinedChlorineIssues(data, fc: fc, cc: cc))
    }

    private static func highCombinedChlorineIssues(_ data: PoolFormData, fc: Double, cc: Double) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "cc_recently_opened", label: "Recently Opened"))
        }

        // 2. Algae present or green water
        if !data.algaeType.isEmpty || data.waterColor == "green" {
            issues.append(.init(id: "cc_algae", label: "Algae / Green Water"))
        }

        // 3. High bather load
        if data.higherUsage == "yes" {
            issues.append(.init(id: "cc_high_usage", label: "High Usage"))
        }

        // 4. Low free chlorine (<1 ppm)
        if fc < 1.0 {
            issues.append(.init(id: "cc_low_fc", label: "Low Free Chlorine"))
        }

        // 5. Poor or no circulation
        if data.hasCirculation == "no" {
            issues.append(.init(id: "cc_no_circ", label: "No Circulation"))
        } else if ["4_8", "under_4", "rarely"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "cc_low_pump", label: "Low Pump Runtime"))
        }

        // 6. High stabilizer (CYA)
        if let cya = Double(data.cyanuricAcid) {
            let threshold: Double = data.sanitizer == "salt" ? 90 : 70
            if cya > threshold {
                issues.append(.init(id: "cc_high_cya", label: "High Stabilizer"))
            }
        }

        // 7. High pH (>7.8)
        if let ph = Double(data.pH), ph > 7.8 {
            issues.append(.init(id: "cc_high_ph", label: "High pH"))
        }

        // 8. Cloudy water
        if data.waterColor == "cloudy" {
            issues.append(.init(id: "cc_cloudy", label: "Cloudy Water"))
        }

        // 9. High phosphates (>500 ppb)
        if let phos = Double(data.phosphates), phos > 500 {
            issues.append(.init(id: "cc_high_phos", label: "High Phosphates"))
        }

        // 10. High water temperature (>85 °F / >29 °C)
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF > 85 {
                issues.append(.init(id: "cc_high_temp", label: "High Water Temp"))
            }
        }

        // 11. Low sunlight (no direct sunlight)
        if data.directSunlight == "no" {
            issues.append(.init(id: "cc_low_sunlight", label: "Low Sunlight"))
        }

        // 12. No recent shock
        if data.recentlyShocked == "no" {
            issues.append(.init(id: "cc_no_shock", label: "No Recent Shock"))
        }

        return issues
    }

    // MARK: pH

    private static func analyzePH(_ data: PoolFormData) -> ParameterResult {
        guard let ph = Double(data.pH) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if ph >= 7.2 && ph <= 7.8 {
            return ParameterResult(level: .ok, issues: [])
        }
        if ph < 7.2 {
            return ParameterResult(level: .low, issues: lowPHIssues(data))
        }
        return ParameterResult(level: .high, issues: highPHIssues(data))
    }

    private static func lowPHIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "ph_low_opened", label: "Recently Opened"))
        }

        // 2. High bather load
        if data.higherUsage == "yes" {
            issues.append(.init(id: "ph_low_usage", label: "High Usage"))
        }

        // 3. Algae present or non-clear water
        if !data.algaeType.isEmpty || (data.waterColor != "clear" && !data.waterColor.isEmpty) {
            issues.append(.init(id: "ph_low_algae", label: "Algae / Discoloured Water"))
        }

        // 4. Low alkalinity (<80 ppm)
        if let alk = Double(data.alkalinity), alk < 80 {
            issues.append(.init(id: "ph_low_alk", label: "Low Alkalinity"))
        }

        // 5. Recently added chlorine (shock)
        if data.recentlyShocked == "yes" {
            issues.append(.init(id: "ph_low_shock", label: "Recently Shocked"))
        }

        return issues
    }

    private static func highPHIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. High alkalinity (>120 ppm)
        if let alk = Double(data.alkalinity), alk > 120 {
            issues.append(.init(id: "ph_high_alk", label: "High Alkalinity"))
        }

        // 2. Algae present or green/black water
        if !data.algaeType.isEmpty || data.waterColor == "green" || data.waterColor == "black" {
            issues.append(.init(id: "ph_high_algae", label: "Algae / Green or Black Water"))
        }

        // 3. Low bather load
        if data.higherUsage == "no" {
            issues.append(.init(id: "ph_high_usage", label: "Low Usage"))
        }

        // 4. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "ph_high_opened", label: "Recently Opened"))
        }

        // 5. High water temperature (>85 °F / >29 °C)
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF > 85 {
                issues.append(.init(id: "ph_high_temp", label: "High Water Temp"))
            }
        }

        // 6. High circulation
        if data.hasCirculation == "yes",
           ["24_hours", "12_plus"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "ph_high_circ", label: "High Circulation"))
        }

        return issues
    }

    // MARK: Alkalinity

    private static func analyzeAlkalinity(_ data: PoolFormData) -> ParameterResult {
        guard let alk = Double(data.alkalinity) else {
            return ParameterResult(level: .ok, issues: [])
        }
        if alk >= 80 && alk <= 120 {
            return ParameterResult(level: .ok, issues: [])
        }
        if alk < 80 {
            return ParameterResult(level: .low, issues: lowAlkalinityIssues(data))
        }
        return ParameterResult(level: .high, issues: highAlkalinityIssues(data))
    }

    private static func lowAlkalinityIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "alk_low_opened", label: "Recently Opened"))
        }

        // 2. Heavy usage
        if data.higherUsage == "yes" {
            issues.append(.init(id: "alk_low_usage", label: "High Usage"))
        }

        // 3. Algae or discoloured water
        if !data.algaeType.isEmpty || ["green", "black", "cloudy"].contains(data.waterColor) {
            issues.append(.init(id: "alk_low_water", label: "Algae / Discoloured Water"))
        }

        // 4. Low pH (<7.2)
        if let ph = Double(data.pH), ph < 7.2 {
            issues.append(.init(id: "alk_low_ph", label: "Low pH"))
        }

        // 5. Recently shocked
        if data.recentlyShocked == "yes" {
            issues.append(.init(id: "alk_low_shock", label: "Recently Shocked"))
        }

        // 6. High water temperature (>85 °F / >29 °C)
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF > 85 {
                issues.append(.init(id: "alk_low_temp", label: "High Water Temp"))
            }
        }

        return issues
    }

    private static func highAlkalinityIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "alk_high_opened", label: "Recently Opened"))
        }

        // 2. Low usage
        if data.higherUsage == "no" {
            issues.append(.init(id: "alk_high_usage", label: "Low Usage"))
        }

        // 3. High pH (>7.8)
        if let ph = Double(data.pH), ph > 7.8 {
            issues.append(.init(id: "alk_high_ph", label: "High pH"))
        }

        // 4. High circulation
        if data.hasCirculation == "yes",
           ["24_hours", "12_plus"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "alk_high_circ", label: "High Circulation"))
        }

        return issues
    }

    // MARK: Free Chlorine

    private static func analyzeChlorine(_ data: PoolFormData) -> ParameterResult {
        guard let fc = Double(data.freeChlorine) else {
            return ParameterResult(level: .low, issues: lowChlorineIssues(data))
        }
        if fc >= 1.0 && fc <= 5.0 {
            return ParameterResult(level: .ok, issues: [])
        }
        if fc < 1.0 {
            return ParameterResult(level: .low, issues: lowChlorineIssues(data))
        }
        // fc > 5.0
        return ParameterResult(level: .high, issues: highChlorineIssues(data))
    }

    private static func highChlorineIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. Low water temperature (<60 °F / <15 °C) — slow chlorine consumption
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF < 60 {
                issues.append(.init(id: "low_temp", label: "Low Water Temp"))
            }
        }

        // 2. Recently shocked
        if data.recentlyShocked == "yes" {
            issues.append(.init(id: "recently_shocked", label: "Recently Shocked"))
        }

        // 3. Lower bather load — less chlorine demand
        if data.higherUsage == "no" {
            issues.append(.init(id: "low_usage", label: "Low Usage"))
        }

        // 4. No direct sunlight — chlorine not burned off by UV
        if data.directSunlight == "no" {
            issues.append(.init(id: "no_sunlight", label: "No Direct Sunlight"))
        }

        // 5. Poor or no circulation — chlorine not distributed/consumed
        if data.hasCirculation == "no" {
            issues.append(.init(id: "no_circulation", label: "No Circulation"))
        } else if ["4_8", "under_4", "rarely"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "low_pump_runtime", label: "Low Pump Runtime"))
        }

        // 6. High stabilizer (CYA) — traps chlorine in pool
        if let cya = Double(data.cyanuricAcid) {
            let highThreshold: Double = data.sanitizer == "salt" ? 90 : 70
            if cya > highThreshold {
                issues.append(.init(id: "high_cya", label: "High Stabilizer"))
            }
        }

        return issues
    }

    private static func lowChlorineIssues(_ data: PoolFormData) -> [ChemistryIssue] {
        var issues: [ChemistryIssue] = []

        // 1. High water temperature (≥85 °F / ≥29 °C)
        if let tempRaw = Double(data.waterTemp) {
            let tempF = data.tempUnit == "celsius" ? tempRaw * 9 / 5 + 32 : tempRaw
            if tempF >= 85 {
                issues.append(.init(id: "high_temp", label: "High Water Temp"))
            }
        }

        // 2. Recently opened pool
        if data.recentlyOpened == "yes" {
            issues.append(.init(id: "recently_opened", label: "Recently Opened"))
        }

        // 3. Algae present
        if !data.algaeType.isEmpty {
            let label: String
            switch data.algaeType {
            case "green":    label = "Green Algae"
            case "black":    label = "Black Algae"
            case "pink":     label = "Pink Algae"
            case "mustard":  label = "Mustard Algae"
            case "white":    label = "White Algae"
            case "invisible": label = "Invisible Algae"
            default:         label = "\(data.algaeType.capitalized) Algae"
            }
            issues.append(.init(id: "algae", label: label))
        }

        // 4. Higher bather load
        if data.higherUsage == "yes" {
            issues.append(.init(id: "higher_usage", label: "Higher Usage"))
        }

        // 5. Direct sunlight
        if data.directSunlight == "yes" {
            issues.append(.init(id: "direct_sunlight", label: "Direct Sunlight"))
        }

        // 6. Poor or no circulation
        if data.hasCirculation == "no" {
            issues.append(.init(id: "no_circulation", label: "No Circulation"))
        } else if ["4_8", "under_4", "rarely"].contains(data.pumpRunFrequency) {
            issues.append(.init(id: "low_pump_runtime", label: "Low Pump Runtime"))
        }

        // 7. Low salt level (salt sanitizer only)
        if data.sanitizer == "salt", let saltVal = Double(data.saltLevel) {
            let threshold: Double = data.hasLowSaltGenerator == "yes" ? 1200 : 2700
            if saltVal < threshold {
                issues.append(.init(id: "low_salt", label: "Low Salt Level"))
            }
        }

        // 8. Low cyanuric acid / stabilizer (<30 ppm)
        if let cya = Double(data.cyanuricAcid), cya < 30 {
            issues.append(.init(id: "low_cya", label: "Low Stabilizer"))
        }

        // 9. High pH (>7.8)
        if let ph = Double(data.pH), ph > 7.8 {
            issues.append(.init(id: "high_ph", label: "High pH"))
        }

        // 10. High phosphates (>500 ppb)
        if let phos = Double(data.phosphates), phos > 500 {
            issues.append(.init(id: "high_phosphates", label: "High Phosphates"))
        }

        return issues
    }
}

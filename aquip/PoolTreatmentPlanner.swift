import Foundation

// MARK: - Treatment Step Model

struct TreatmentStep: Identifiable {
    let id: Int
    let title: String
    let product: String?
    let description: String
}

// MARK: - Planner

enum PoolTreatmentPlanner {

    static func steps(formData: PoolFormData, analysis: PoolAnalysis) -> [TreatmentStep] {
        var raw: [StepBuilder] = []

        // Convenience flags
        let isSalt          = formData.sanitizer == "salt"
        let fcLow           = analysis.freeChlorine.level == .low
        let fcHigh          = analysis.freeChlorine.level == .high
        let ccHigh          = analysis.combinedChlorine.level == .high
        let phLow           = analysis.pH.level == .low
        let phHigh          = analysis.pH.level == .high
        let alkLow          = analysis.alkalinity.level == .low
        let alkHigh         = analysis.alkalinity.level == .high
        let cyaLow          = analysis.stabilizer.level == .low
        let cyaHigh         = analysis.stabilizer.level == .high
        let calLow          = analysis.calcium.level == .low
        let calHigh         = analysis.calcium.level == .high
        let phosHigh        = analysis.phosphates.level == .high
        let copperHigh      = analysis.copper.level == .high
        let ironHigh        = analysis.iron.level == .high
        let magHigh         = analysis.magnesium.level == .high

        let hasMetals       = copperHigh || ironHigh
        let poolVolume      = Double(formData.volume) ?? 0
        let volumeGal       = formData.volumeUnit == "liters" ? poolVolume * 0.264172 : poolVolume
        let hasVolume       = volumeGal > 0

        // MARK: Step 1 – Dilution-first problems
        // CYA high, calcium hardness very high, or magnesium high → dilute before balancing chemicals
        if cyaHigh || calHigh || magHigh {
            let cyaVal  = Double(formData.cyanuricAcid) ?? 0
            let calVal  = Double(formData.calciumHardness) ?? 0
            let magVal  = Double(formData.magnesium) ?? 0

            var reasons: [String] = []
            var fraction = 0.0
            var note = ""

            if cyaHigh && cyaVal > 0 {
                let target: Double = isSalt ? 70 : 50
                let f = 1 - (target / cyaVal)
                if f > fraction { fraction = f; note = "CYA" }
                reasons.append("high CYA (\(Int(cyaVal)) ppm)")
            }
            if calHigh && calVal > 0 {
                let f = 1 - (300 / calVal)
                if f > fraction { fraction = f; note = "calcium hardness" }
                reasons.append("high calcium hardness (\(Int(calVal)) ppm)")
            }
            if magHigh && magVal > 0 {
                let f = 1 - (40 / magVal)
                if f > fraction { fraction = f; note = "magnesium" }
                reasons.append("high magnesium (\(Int(magVal)) ppm)")
            }

            let pct = Int((fraction * 100).rounded())
            var desc = "Your water has \(reasons.joined(separator: " and ")), which can only be lowered by replacing water. Adding chemicals before dilution wastes product and can overshoot other levels."
            if pct > 0 && pct < 100 {
                desc += " Drain and refill approximately \(pct)% of the pool (about \(volumeStr(volumeGal * fraction)) of water)."
            }
            desc += " After refilling, retest all levels before adding any chemicals."

            raw.append(StepBuilder(
                title: "Partial drain and refill",
                product: nil,
                description: desc
            ))
        }

        // MARK: Step 2 – Stop chlorine sources if FC high
        if fcHigh {
            raw.append(StepBuilder(
                title: "Stop all chlorine sources",
                product: nil,
                description: "Free chlorine is too high. Turn off the salt chlorine generator if you have one, remove any chlorine tablets or pucks from feeders, and stop adding chlorine. Allow sunlight and circulation to naturally lower the level. Retest in 24–48 hours. Only use a chlorine neutralizer (sodium thiosulfate) if the level is critically high and urgent — follow the product label dose carefully."
            ))
        }

        // MARK: Step 3 – pH and Alkalinity (handled as a pair)
        appendPhAlkSteps(
            &raw,
            phLow: phLow, phHigh: phHigh,
            alkLow: alkLow, alkHigh: alkHigh,
            volumeGal: volumeGal, hasVolume: hasVolume,
            formData: formData
        )

        // MARK: Step 4 – Metals before any chlorine work
        if hasMetals {
            let metalStr = [copperHigh ? "copper" : nil, ironHigh ? "iron" : nil]
                .compactMap { $0 }.joined(separator: " and ")
            raw.append(StepBuilder(
                title: "Treat high \(metalStr) with metal sequestrant",
                product: "Metal sequestrant / metal remover (labeled for \(metalStr))",
                description: "Do not shock or aggressively raise chlorine while \(metalStr) is elevated. High chlorine or high pH will oxidize dissolved metals and cause staining or discolored water. Keep pH near 7.2 if it is high. Add a metal sequestrant or metal remover following the product label dosage. Run the pump and filter continuously. Clean or backwash the filter as directed by the product label. Retest metal levels before proceeding to sanitizer corrections."
            ))
        }

        // MARK: Step 5 – Calcium Hardness low
        if calLow {
            let calVal  = Double(formData.calciumHardness) ?? 0
            let target  = 300.0
            let increase = target - calVal
            var desc = "Low calcium hardness can cause corrosive water that damages pool surfaces and equipment."
            if hasVolume && increase > 0 {
                // 0.9 lb per 10,000 gal raises CH by 10 ppm (100% calcium chloride)
                let lbs = 0.9 * (volumeGal / 10_000) * (increase / 10)
                desc += " Estimated dose: \(formatWeight(lbs)) of calcium chloride (100% product) to raise calcium hardness by approximately \(Int(increase)) ppm toward a target of \(Int(target)) ppm. If your product is 77% calcium chloride, multiply this amount by 1.33."
            }
            desc += " Add in stages — do not add more than half the estimated dose at once. Brush the pool after adding granular product. Do not add calcium increaser at the same time as soda ash or alkalinity increaser. Circulate and retest before adding more."
            raw.append(StepBuilder(
                title: "Raise calcium hardness",
                product: "Calcium hardness increaser / calcium chloride",
                description: desc
            ))
        }

        // MARK: Step 6 – CYA low
        if cyaLow {
            let cyaVal  = Double(formData.cyanuricAcid) ?? 0
            let target: Double = isSalt ? 70 : 50
            let increase = target - cyaVal
            var desc = "Low CYA (stabilizer) means sunlight can burn off chlorine quickly, reducing its effectiveness."
            if hasVolume && increase > 0 {
                // 13 oz per 10,000 gal raises CYA by 10 ppm
                let oz = 13 * (volumeGal / 10_000) * (increase / 10)
                desc += " Estimated dose: \(formatOz(oz)) of cyanuric acid / pool stabilizer to raise CYA by approximately \(Int(increase)) ppm toward a target of \(Int(target)) ppm."
            }
            desc += " CYA dissolves slowly — add it to a skimmer sock or dissolve it before adding. Do not backwash shortly after adding stabilizer. Do not overshoot because lowering CYA requires draining and refilling."
            raw.append(StepBuilder(
                title: "Add CYA stabilizer",
                product: "Cyanuric acid / pool stabilizer",
                description: desc
            ))
        }

        // MARK: Step 7 – Free chlorine low (metals already handled)
        if fcLow && !hasMetals {
            let fcVal   = Double(formData.freeChlorine) ?? 0
            let target: Double = isSalt ? 3 : 2
            let increase = target - fcVal
            var desc = "Free chlorine is below the ideal range. Balance pH and alkalinity first (if not already done), then raise chlorine."
            if hasVolume && increase > 0 {
                // 12.8 fl oz of 10% liquid chlorine per 10,000 gal raises FC by 1 ppm
                let flOz = 12.8 * (volumeGal / 10_000) * increase
                desc += " Estimated dose using 10% liquid chlorine: \(formatFlOz(flOz)) to raise free chlorine by approximately \(String(format: "%.1f", increase)) ppm toward a target of \(String(format: "%.1f", target)) ppm."
            }
            if cyaHigh {
                desc += " Avoid stabilized chlorine (dichlor, trichlor, stabilized tablets/pucks) because CYA is already high."
            }
            if calHigh {
                desc += " Avoid calcium hypochlorite (cal-hypo) because calcium hardness is already high."
            }
            desc += " Prefer liquid chlorine (sodium hypochlorite) as it does not add CYA or calcium."
            raw.append(StepBuilder(
                title: "Raise free chlorine",
                product: chlorineProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: desc
            ))
        }

        // MARK: Step 7b – Free chlorine low WITH metals (after metal step already added)
        if fcLow && hasMetals {
            raw.append(StepBuilder(
                title: "Raise free chlorine (after metal treatment)",
                product: chlorineProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Only raise chlorine after metal levels have been brought under control. Use liquid chlorine (sodium hypochlorite) and add slowly. Start with a partial dose and retest. Avoid cal-hypo if calcium hardness is high and avoid stabilized chlorine if CYA is high."
            ))
        }

        // MARK: Step 8 – Combined chlorine high → shock
        if ccHigh && !hasMetals {
            var desc = "Combined chlorine is high, indicating chloramines or organic contamination. Shocking the pool will oxidize combined chlorine and restore water clarity."
            desc += " Balance pH (ideally 7.2–7.4) and alkalinity before shocking — chlorine works most effectively in balanced water."
            if cyaHigh {
                desc += " Use an unstabilized shock such as liquid chlorine or cal-hypo (if calcium is not high) because CYA is already elevated. Avoid dichlor or trichlor shock."
            } else if calHigh {
                desc += " Avoid calcium hypochlorite (cal-hypo) shock because calcium hardness is already high. Use liquid chlorine or non-calcium shock."
            } else {
                desc += " Choose a shock appropriate for your pool: liquid chlorine, cal-hypo, or non-chlorine shock depending on current CYA and calcium levels."
            }
            desc += " Add shock at dusk or night when sunlight cannot degrade it. Keep pump running for at least 8 hours after shocking. Retest before swimming."
            raw.append(StepBuilder(
                title: "Shock the pool to eliminate combined chlorine",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: desc
            ))
        } else if ccHigh && hasMetals {
            raw.append(StepBuilder(
                title: "Shock pool after metals are treated",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Do not shock yet — shocking while copper or iron is present will oxidize metals and cause staining. Complete the metal sequestrant treatment first. Once metal levels are controlled, balance pH and alkalinity, then shock to remove combined chlorine."
            ))
        }

        // MARK: Step 9 – Phosphates high
        if phosHigh {
            raw.append(StepBuilder(
                title: "Treat high phosphates",
                product: "Phosphate remover",
                description: "Phosphates feed algae and reduce chlorine efficiency. Add phosphate remover according to the product label dosage for your pool volume. The water may turn cloudy temporarily — this is normal. Run the filter continuously after treatment. Backwash or clean the filter cartridge as directed by the product label. Retest phosphate levels after the filter has cleared the water."
            ))
        }

        // MARK: Final safety reminder (only when there are real steps)
        if raw.isEmpty {
            // No issues — no steps needed
            return []
        }

        raw.append(StepBuilder(
            title: "Retest all levels before swimming",
            product: nil,
            description: "After completing the treatment steps, run the pump for at least 8 hours and retest all parameters. Free chlorine should be in range, pH should be 7.2–7.6, and alkalinity 80–120 ppm before the pool is safe to use. Never add multiple chemicals at the same time, and never mix chemicals outside the pool."
        ))

        return raw.enumerated().map { i, b in
            TreatmentStep(id: i + 1, title: b.title, product: b.product, description: b.description)
        }
    }

    // MARK: - Private helpers

    private struct StepBuilder {
        let title: String
        let product: String?
        let description: String
    }

    // pH / Alkalinity scenario table
    private static func appendPhAlkSteps(
        _ steps: inout [StepBuilder],
        phLow: Bool, phHigh: Bool,
        alkLow: Bool, alkHigh: Bool,
        volumeGal: Double, hasVolume: Bool,
        formData: PoolFormData
    ) {
        let phVal  = Double(formData.pH) ?? 7.4
        let alkVal = Double(formData.alkalinity) ?? 100

        // Case A: pH low + alkalinity low
        if phLow && alkLow {
            let alkIncrease = 100 - alkVal
            var desc = "Both pH and alkalinity are low. Fix alkalinity first — it buffers pH, and without it your pH will be unstable even after correction."
            if hasVolume && alkIncrease > 0 {
                // 1.5 lb per 10,000 gal raises alkalinity by 10 ppm
                let lbs = 1.5 * (volumeGal / 10_000) * (alkIncrease / 10)
                desc += " Estimated dose: \(formatWeight(lbs)) of sodium bicarbonate (baking soda) to raise alkalinity by approximately \(Int(alkIncrease)) ppm toward a target of 100 ppm."
            }
            desc += " Add in stages and circulate for at least 4–6 hours, then retest. pH may rise slightly after adding sodium bicarbonate."
            steps.append(StepBuilder(title: "Raise alkalinity first", product: "Sodium bicarbonate / Alkalinity Up / baking soda", description: desc))

            let phIncrease = 7.4 - phVal
            var desc2 = "After alkalinity is corrected and stable, retest pH. If pH is still below 7.2, add pH increaser."
            if hasVolume && phIncrease > 0 {
                // 6 oz soda ash per 10,000 gal raises pH by ~0.2
                let oz = 6 * (volumeGal / 10_000) * (phIncrease / 0.2)
                desc2 += " Estimated dose: \(formatOz(oz)) of soda ash (sodium carbonate) to raise pH by approximately \(String(format: "%.1f", phIncrease)). pH response is not perfectly linear — add in stages and retest."
            }
            steps.append(StepBuilder(title: "Raise pH after alkalinity is stable", product: "pH increaser / soda ash / sodium carbonate", description: desc2))
            return
        }

        // Case B: pH low + alkalinity normal
        if phLow && !alkLow && !alkHigh {
            let phIncrease = 7.4 - phVal
            var desc = "pH is low but alkalinity is in range. Add pH increaser to bring pH up toward 7.4."
            if hasVolume && phIncrease > 0 {
                let oz = 6 * (volumeGal / 10_000) * (phIncrease / 0.2)
                desc += " Estimated dose: \(formatOz(oz)) of soda ash to raise pH by approximately \(String(format: "%.1f", phIncrease)). Use staged dosing and retest — do not add the full amount at once."
            }
            steps.append(StepBuilder(title: "Raise pH", product: "pH increaser / soda ash / sodium carbonate", description: desc))
            return
        }

        // Case C: pH low + alkalinity high
        if phLow && alkHigh {
            steps.append(StepBuilder(
                title: "Aerate to raise pH without increasing alkalinity",
                product: nil,
                description: "pH is low but alkalinity is high. Do not add pH increaser — it will make alkalinity worse. Instead, aerate the water to raise pH naturally. Point return jets upward, run waterfalls, spa spillover, air blower, or other water agitation. Once pH is in range (7.2–7.6), carefully add acid to lower alkalinity. This will drop pH again, so aerate once more. Repeat these acid and aeration cycles slowly until both are in range."
            ))
            return
        }

        // Case D: pH normal + alkalinity low
        if !phLow && !phHigh && alkLow {
            let alkIncrease = 100 - alkVal
            var desc = "Alkalinity is low. Add sodium bicarbonate to bring it up toward 100 ppm. Note: pH may rise slightly after correction."
            if hasVolume && alkIncrease > 0 {
                let lbs = 1.5 * (volumeGal / 10_000) * (alkIncrease / 10)
                desc += " Estimated dose: \(formatWeight(lbs)) of sodium bicarbonate to raise alkalinity by approximately \(Int(alkIncrease)) ppm."
            }
            desc += " Circulate and retest. If pH has risen above 7.6, lower it carefully with a small amount of acid."
            steps.append(StepBuilder(title: "Raise alkalinity", product: "Sodium bicarbonate / Alkalinity Up / baking soda", description: desc))
            return
        }

        // Case E: pH normal + alkalinity high
        if !phLow && !phHigh && alkHigh {
            let alkDecrease = alkVal - 100
            var desc = "Alkalinity is high. Add acid carefully to bring it down — this will also lower pH. After adding acid, aerate the water (point jets upward, run water features) to raise pH back up without raising alkalinity."
            if hasVolume && alkDecrease > 0 {
                // ~12 fl oz muriatic acid per 10,000 gal lowers pH by ~0.2; use cautiously for alk
                let oz = 12 * (volumeGal / 10_000) * (alkDecrease / 20)
                desc += " Start with no more than \(formatFlOz(oz / 2)) of muriatic acid, circulate, and retest before adding more. Alkalinity drops require multiple staged treatments."
            }
            desc += " Never add acid and chlorine at the same time. Add acid with the pump running."
            steps.append(StepBuilder(title: "Lower alkalinity with acid and aeration cycles", product: "Muriatic acid or dry acid (sodium bisulfate)", description: desc))
            return
        }

        // Case F: pH high + alkalinity low
        if phHigh && alkLow {
            let alkIncrease = 100 - alkVal
            var desc = "pH is high and alkalinity is low. Fix alkalinity first — adding acid to lower pH when alkalinity is already low can make alkalinity dangerously unstable."
            if hasVolume && alkIncrease > 0 {
                let lbs = 1.5 * (volumeGal / 10_000) * (alkIncrease / 10)
                desc += " Estimated dose: \(formatWeight(lbs)) of sodium bicarbonate to raise alkalinity by approximately \(Int(alkIncrease)) ppm toward 100 ppm."
            }
            desc += " Circulate and retest. Then lower pH with acid and recheck alkalinity, since acid can reduce it."
            steps.append(StepBuilder(title: "Raise alkalinity first", product: "Sodium bicarbonate / Alkalinity Up / baking soda", description: desc))

            let phDecrease = phVal - 7.4
            var desc2 = "After alkalinity is corrected, lower pH with acid. Add in small stages — pH response is not linear."
            if hasVolume && phDecrease > 0 {
                let oz = 12 * (volumeGal / 10_000) * (phDecrease / 0.2)
                desc2 += " Estimated starting dose: \(formatFlOz(oz)) of muriatic acid. Add only half first, circulate, and retest before adding more."
            }
            desc2 += " Never add acid and chlorine at the same time. Retest alkalinity after pH correction — acid can lower both."
            steps.append(StepBuilder(title: "Lower pH after alkalinity is stable", product: "Muriatic acid or dry acid (sodium bisulfate)", description: desc2))
            return
        }

        // Case G: pH high + alkalinity normal
        if phHigh && !alkLow && !alkHigh {
            let phDecrease = phVal - 7.4
            var desc = "pH is above the ideal range. Lower it with acid. Add in small stages."
            if hasVolume && phDecrease > 0 {
                let oz = 12 * (volumeGal / 10_000) * (phDecrease / 0.2)
                desc += " Estimated dose: \(formatFlOz(oz)) of muriatic acid to lower pH by approximately \(String(format: "%.1f", phDecrease)). Add half first, circulate, retest, then add the remainder if needed."
            }
            desc += " Check alkalinity afterward because acid can lower it. Never add acid and chlorine at the same time."
            steps.append(StepBuilder(title: "Lower pH", product: "Muriatic acid or dry acid (sodium bisulfate)", description: desc))
            return
        }

        // Case H: pH high + alkalinity high
        if phHigh && alkHigh {
            let phDecrease = phVal - 7.4
            var desc = "Both pH and alkalinity are high. Acid will lower both at once. Add in careful stages, circulate, and retest between each addition."
            if hasVolume && phDecrease > 0 {
                let oz = 12 * (volumeGal / 10_000) * (phDecrease / 0.2)
                desc += " Estimated starting dose: \(formatFlOz(oz)) of muriatic acid. Add only half at a time, circulate, and retest."
            }
            desc += " If pH drops into range but alkalinity is still high, use acid and aeration cycles: add acid to lower alkalinity, then aerate to bring pH back up without re-raising alkalinity. Repeat until both are in range. Never use pH increaser to fix a pH dip caused by acid when the goal is lowering alkalinity."
            steps.append(StepBuilder(title: "Lower pH and alkalinity with acid (staged)", product: "Muriatic acid or dry acid (sodium bisulfate)", description: desc))
            return
        }
    }

    private static func chlorineProduct(cyaHigh: Bool, calHigh: Bool) -> String {
        if cyaHigh || calHigh {
            return "Liquid chlorine / sodium hypochlorite (unstabilized)"
        }
        return "Liquid chlorine / sodium hypochlorite"
    }

    private static func shockProduct(cyaHigh: Bool, calHigh: Bool) -> String {
        if cyaHigh && calHigh {
            return "Non-chlorine shock or liquid chlorine (avoid dichlor, trichlor, and cal-hypo)"
        }
        if cyaHigh {
            return "Unstabilized shock: liquid chlorine or cal-hypo (avoid dichlor/trichlor)"
        }
        if calHigh {
            return "Non-calcium shock or liquid chlorine (avoid cal-hypo)"
        }
        return "Pool shock (liquid chlorine, cal-hypo, or non-chlorine shock)"
    }

    // MARK: - Formatting helpers

    private static func volumeStr(_ gallons: Double) -> String {
        if gallons < 1 { return "less than 1 gallon" }
        return "\(Int(gallons.rounded())) gallons"
    }

    private static func formatWeight(_ lbs: Double) -> String {
        if lbs < 0.1 { return "a small amount" }
        if lbs < 1 { return String(format: "%.1f oz (%.0f g)", lbs * 16, lbs * 453.6) }
        return String(format: "%.1f lb", lbs)
    }

    private static func formatOz(_ oz: Double) -> String {
        if oz < 0.5 { return "a small amount" }
        if oz >= 16 {
            return String(format: "%.1f lb (%.0f oz)", oz / 16, oz)
        }
        return String(format: "%.0f oz", oz)
    }

    private static func formatFlOz(_ flOz: Double) -> String {
        if flOz < 0.5 { return "a small amount" }
        if flOz >= 128 {
            return String(format: "%.1f gal (%.0f fl oz)", flOz / 128, flOz)
        }
        if flOz >= 32 {
            return String(format: "%.0f fl oz (%.1f qt)", flOz, flOz / 32)
        }
        return String(format: "%.0f fl oz", flOz)
    }
}

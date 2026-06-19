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

    static func steps(
        formData: PoolFormData,
        analysis: PoolAnalysis,
        weatherSnapshot: WeatherSnapshot? = nil
    ) -> [TreatmentStep] {
        var raw: [StepBuilder] = []

        // MARK: - Convenience flags

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

        // Context flags
        let hasAlgae        = !formData.algaeType.isEmpty && formData.algaeType != "none"
        let pumpStopped     = formData.hasCirculation == "no"
        let pumpLow         = formData.pumpRunFrequency == "rarely" || formData.pumpRunFrequency == "under_4"
        let recentlyOpened  = formData.recentlyOpened == "yes"
        let recentlyShocked = formData.recentlyShocked == "yes"
        let higherUsage     = formData.higherUsage == "yes"
        let inDirectSun     = formData.directSunlight == "yes"
        let waterColor      = formData.waterColor
        let algaeType       = formData.algaeType

        // Temperature in °F
        let rawTemp         = Double(formData.waterTemp) ?? 0
        let tempF: Double   = formData.tempUnit == "celsius" ? rawTemp * 9/5 + 32 : rawTemp
        let tempWarm        = rawTemp > 0 && tempF > 82
        let tempCold        = rawTemp > 0 && tempF < 65

        // Water color danger overrides
        let dangerousMetalColor = (waterColor == "brown" || waterColor == "purple")
        let waterLooksGreen     = waterColor == "green"

        // MARK: - Context Block 0: Pump is not running → chemicals must wait
        if pumpStopped {
            raw.append(StepBuilder(
                title: "Restore pump circulation before adding chemicals",
                product: nil,
                description: "Your pump is not running. Chemicals added to standing water will not distribute evenly and can damage pool surfaces or create dangerous concentration pockets. Fix the pump or filtration issue first, then run it for at least 8 hours before adding any chemicals."
            ))
        } else if pumpLow {
            raw.append(StepBuilder(
                title: "Increase pump runtime before treating",
                product: nil,
                description: "Your pump is running less than 4 hours per day, which is not enough to properly circulate and distribute chemicals. For treatment to be effective, increase pump runtime to at least 12 hours per day — ideally 24 hours per day while actively correcting water chemistry."
            ))
        }

        // MARK: - Context Block 1: Recently opened pool → physical cleaning first
        if recentlyOpened {
            raw.append(StepBuilder(
                title: "Clean pool physically before adding chemicals",
                product: nil,
                description: "Your pool was recently opened. Before adding any chemicals, skim the surface, brush walls and floor, vacuum the pool, and clean or backwash the filter. Run the pump for 24 hours after opening to circulate the water fully. Physical cleaning removes organic debris that would consume chemicals unnecessarily. Then test and treat."
            ))
        }

        // MARK: - Context Block 2: Recently shocked → wait and retest
        if recentlyShocked {
            raw.append(StepBuilder(
                title: "Continue circulating and retest before adding more chemicals",
                product: nil,
                description: "Your pool was recently shocked. Keep the pump running and allow the shock to fully circulate and dissipate before evaluating results or adding any additional chemicals. Retest free chlorine, combined chlorine, pH, and alkalinity in 8–24 hours. Adding more chemicals before shock has done its job can overshoot or interfere with results."
            ))
        }

        // MARK: - Context Block 2b: Rain/current weather impact
        if let impact = WeatherService.weatherImpact(
            from: weatherSnapshot,
            testType: "pool",
            sanitizer: formData.sanitizer
        ), weatherSnapshot?.isRaining == true {
            raw.append(StepBuilder(
                title: impact.nextStepTitle,
                product: nil,
                description: impact.nextStepDescription
            ))
        }

        // MARK: - Context Block 3: Dangerous water color (metals from oxidation)
        if dangerousMetalColor && !hasMetals {
            raw.append(StepBuilder(
                title: "Stop shocking — suspect dissolved metals",
                product: "Metal sequestrant / metal remover",
                description: "Brown or purple water often indicates dissolved copper or iron being oxidized by chlorine. Even if metal readings appear normal on a basic test, this discoloration is a strong indicator. Do not add shock or raise chlorine further — that will worsen the staining. Add a metal sequestrant immediately, keep pH near 7.2, and run the filter continuously. Test metals with a more sensitive test kit and retest after treatment."
            ))
        }

        // MARK: - Context Block 4: Algae treatment (takes priority over most chemical corrections)
        if hasAlgae {
            let algaePriority = algaeTypeSteps(algaeType, cyaHigh: cyaHigh, calHigh: calHigh,
                                               hasMetals: hasMetals, phLow: phLow, phHigh: phHigh)
            raw.append(contentsOf: algaePriority)
        } else if waterLooksGreen {
            raw.append(StepBuilder(
                title: "Green water detected — suspect algae",
                product: nil,
                description: "Your water appears green, which typically indicates algae growth even if you have not observed it directly. Brush the walls and floor, then shock the pool aggressively (at least 10 ppm free chlorine). Keep the pump running continuously and retest after 24 hours. If the water turns cloudy white or blue, the shock is working — continue filtering. If it stays green, repeat the shock."
            ))
        }

        // MARK: - Context Block 5: Higher usage note
        if higherUsage {
            raw.append(StepBuilder(
                title: "Higher usage — check free and combined chlorine first",
                product: nil,
                description: "With higher bather load, chlorine demand increases significantly. Verify that free chlorine is in range before addressing other parameters. Combined chlorine (chloramines) may also rise faster after heavy use — if combined chlorine is above 0.5 ppm, shock the pool. Increase pump runtime and plan to test more frequently."
            ))
        }

        // MARK: - Context Block 6: Temperature context
        if tempWarm {
            raw.append(StepBuilder(
                title: "Warm water — expect higher chemical demand",
                product: nil,
                description: "Water temperature above 82°F accelerates algae growth, increases chlorine consumption, and causes chemical changes to happen faster. Test more frequently (every 1–2 days), maintain free chlorine toward the upper end of the ideal range, and keep CYA in range to protect chlorine from sunlight. Be conservative with acid doses since pH can shift quickly in warm water."
            ))
        } else if tempCold {
            raw.append(StepBuilder(
                title: "Cold water — dose carefully and allow extra time",
                product: nil,
                description: "Water temperature below 65°F slows chemical reactions significantly. After adding any chemical, allow extra circulation time before retesting — at least 24–48 hours for some products. Avoid overdosing because chemicals will take longer to distribute and equilibrate. Granular products may not dissolve as quickly; pre-dissolve in a bucket of warm water before adding to the pool."
            ))
        }

        // MARK: Step 1 – Dilution-first problems
        if cyaHigh || calHigh || magHigh {
            let cyaVal  = Double(formData.cyanuricAcid) ?? 0
            let calVal  = Double(formData.calciumHardness) ?? 0
            let magVal  = Double(formData.magnesium) ?? 0

            var reasons: [String] = []
            var fraction = 0.0

            if cyaHigh && cyaVal > 0 {
                let target: Double = isSalt ? 70 : 50
                let f = 1 - (target / cyaVal)
                if f > fraction { fraction = f }
                reasons.append("high CYA (\(Int(cyaVal)) ppm)")
            }
            if calHigh && calVal > 0 {
                let f = 1 - (300 / calVal)
                if f > fraction { fraction = f }
                reasons.append("high calcium hardness (\(Int(calVal)) ppm)")
            }
            if magHigh && magVal > 0 {
                let f = 1 - (40 / magVal)
                if f > fraction { fraction = f }
                reasons.append("high magnesium (\(Int(magVal)) ppm)")
            }

            let pct = Int((fraction * 100).rounded())
            var desc = "Your water has \(reasons.joined(separator: " and ")), which can only be lowered by replacing water. Adding chemicals before dilution wastes product and can overshoot other levels."
            if pct > 0 && pct < 100 {
                desc += " Drain and refill approximately \(pct)% of the pool."
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
            alkLow: alkLow, alkHigh: alkHigh
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
            raw.append(StepBuilder(
                title: "Raise calcium hardness",
                product: "Calcium hardness increaser / calcium chloride",
                description: "Low calcium hardness can cause corrosive water that damages pool surfaces and equipment. Add calcium hardness increaser following the product label dosage for your pool volume. Add in stages — do not add more than half the dose at once. Brush the pool after adding granular product. Do not add calcium increaser at the same time as soda ash or alkalinity increaser. Circulate and retest before adding more."
            ))
        }

        // MARK: Step 6 – CYA low
        if cyaLow && !hasAlgae {
            var desc = "Low CYA (stabilizer) means sunlight can burn off chlorine quickly, reducing its effectiveness."
            if inDirectSun {
                desc = "Your pool is in direct sunlight, which accelerates chlorine degradation. With low CYA, sunlight will destroy chlorine rapidly. " + desc
            }
            desc += " Add cyanuric acid / pool stabilizer following the product label dosage for your pool volume. CYA dissolves slowly — add it to a skimmer sock or dissolve it before adding. Do not backwash shortly after adding stabilizer. Do not overshoot because lowering CYA requires draining and refilling."
            raw.append(StepBuilder(
                title: "Add CYA stabilizer",
                product: "Cyanuric acid / pool stabilizer",
                description: desc
            ))
        }

        // MARK: Step 7 – Free chlorine low (metals already handled)
        if fcLow && !hasMetals {
            var desc = "Free chlorine is below the ideal range. Balance pH and alkalinity first (if not already done), then add chlorine following the product label dosage for your pool volume."
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

        // MARK: Step 7c – Weather sanitizer monitoring (hot/sunny)
        if let impact = WeatherService.weatherImpact(
            from: weatherSnapshot,
            testType: "pool",
            sanitizer: formData.sanitizer
        ), weatherSnapshot?.isRaining != true {
            raw.append(StepBuilder(
                title: impact.nextStepTitle,
                product: nil,
                description: impact.nextStepDescription
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
            desc += " Add shock at dusk or night when sunlight cannot degrade it. Follow the product label dosage for your pool volume. Keep the pump running for at least 8 hours after shocking. Retest before swimming."
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

        // MARK: Step 10 – Deferred CYA (add after algae is resolved)
        if cyaLow && hasAlgae {
            let desc = "CYA is low, but adding stabilizer while algae is active can help algae resist chlorine treatment. Complete algae elimination first. Once the water is clear and free chlorine has been maintained for 24–48 hours with no green or cloudy recurrence, add cyanuric acid following the product label dosage for your pool volume. CYA dissolves slowly — add it to a skimmer sock or dissolve it before adding. Do not overshoot."
            raw.append(StepBuilder(
                title: "Add CYA stabilizer (after algae is resolved)",
                product: "Cyanuric acid / pool stabilizer",
                description: desc
            ))
        }

        // MARK: Final safety reminder
        if raw.isEmpty { return [] }

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

    private static func appendPhAlkSteps(
        _ steps: inout [StepBuilder],
        phLow: Bool, phHigh: Bool,
        alkLow: Bool, alkHigh: Bool
    ) {
        // Case A: pH low + alkalinity low
        if phLow && alkLow {
            steps.append(StepBuilder(
                title: "Raise alkalinity first",
                product: "Sodium bicarbonate / Alkalinity Up / baking soda",
                description: "Both pH and alkalinity are low. Fix alkalinity first — it buffers pH, and without it your pH will be unstable even after correction. Add alkalinity increaser following the product label dosage for your pool volume. Add in stages and circulate for at least 4–6 hours, then retest. pH may rise slightly after adding sodium bicarbonate."
            ))
            steps.append(StepBuilder(
                title: "Raise pH after alkalinity is stable",
                product: "pH increaser / soda ash / sodium carbonate",
                description: "After alkalinity is corrected and stable, retest pH. If pH is still below 7.2, add pH increaser following the product label dosage. pH response is not perfectly linear — add in stages and retest."
            ))
            return
        }

        // Case B: pH low + alkalinity normal
        if phLow && !alkLow && !alkHigh {
            steps.append(StepBuilder(
                title: "Raise pH",
                product: "pH increaser / soda ash / sodium carbonate",
                description: "pH is low but alkalinity is in range. Add pH increaser following the product label dosage for your pool volume to bring pH up toward 7.4. Use staged dosing and retest — do not add the full amount at once."
            ))
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
            steps.append(StepBuilder(
                title: "Raise alkalinity",
                product: "Sodium bicarbonate / Alkalinity Up / baking soda",
                description: "Alkalinity is low. Add alkalinity increaser following the product label dosage for your pool volume to bring it up toward 100 ppm. Note: pH may rise slightly after correction. Circulate and retest. If pH has risen above 7.6, lower it carefully with a small amount of acid."
            ))
            return
        }

        // Case E: pH normal + alkalinity high
        if !phLow && !phHigh && alkHigh {
            steps.append(StepBuilder(
                title: "Lower alkalinity with acid and aeration cycles",
                product: "Muriatic acid or dry acid (sodium bisulfate)",
                description: "Alkalinity is high. Add acid carefully to bring it down — this will also lower pH. After adding acid, aerate the water (point jets upward, run water features) to raise pH back up without raising alkalinity. Start with a small amount, circulate, and retest before adding more. Alkalinity drops require multiple staged treatments. Never add acid and chlorine at the same time. Add acid with the pump running."
            ))
            return
        }

        // Case F: pH high + alkalinity low
        if phHigh && alkLow {
            steps.append(StepBuilder(
                title: "Raise alkalinity first",
                product: "Sodium bicarbonate / Alkalinity Up / baking soda",
                description: "pH is high and alkalinity is low. Fix alkalinity first — adding acid to lower pH when alkalinity is already low can make alkalinity dangerously unstable. Add alkalinity increaser following the product label dosage for your pool volume. Circulate and retest. Then lower pH with acid and recheck alkalinity, since acid can reduce it."
            ))
            steps.append(StepBuilder(
                title: "Lower pH after alkalinity is stable",
                product: "Muriatic acid or dry acid (sodium bisulfate)",
                description: "After alkalinity is corrected, lower pH with acid. Add in small stages — pH response is not linear. Never add acid and chlorine at the same time. Retest alkalinity after pH correction — acid can lower both."
            ))
            return
        }

        // Case G: pH high + alkalinity normal
        if phHigh && !alkLow && !alkHigh {
            steps.append(StepBuilder(
                title: "Lower pH",
                product: "Muriatic acid or dry acid (sodium bisulfate)",
                description: "pH is above the ideal range. Lower it with acid following the product label dosage for your pool volume. Add in small stages — add half first, circulate, retest, then add the remainder if needed. Check alkalinity afterward because acid can lower it. Never add acid and chlorine at the same time."
            ))
            return
        }

        // Case H: pH high + alkalinity high
        if phHigh && alkHigh {
            steps.append(StepBuilder(
                title: "Lower pH and alkalinity with acid (staged)",
                product: "Muriatic acid or dry acid (sodium bisulfate)",
                description: "Both pH and alkalinity are high. Acid will lower both at once. Add in careful stages, circulate, and retest between each addition. If pH drops into range but alkalinity is still high, use acid and aeration cycles: add acid to lower alkalinity, then aerate to bring pH back up without re-raising alkalinity. Repeat until both are in range. Never use pH increaser to fix a pH dip caused by acid when the goal is lowering alkalinity."
            ))
            return
        }
    }

    // MARK: - Algae type-specific treatment steps

    private static func algaeTypeSteps(
        _ algaeType: String,
        cyaHigh: Bool, calHigh: Bool,
        hasMetals: Bool, phLow: Bool, phHigh: Bool
    ) -> [StepBuilder] {
        var steps: [StepBuilder] = []
        let shockNote = "Use \(shockProduct(cyaHigh: cyaHigh, calHigh: calHigh)) and shock to at least 10 ppm free chlorine following the product label dosage. Add shock at dusk to prevent UV degradation. Run the pump continuously until the water clears."

        switch algaeType {

        case "green":
            if phHigh {
                steps.append(StepBuilder(
                    title: "Lower pH before shocking for green algae",
                    product: "Muriatic acid or dry acid",
                    description: "Chlorine effectiveness drops sharply above pH 7.6. Lower pH to between 7.2 and 7.4 before shocking for best results."
                ))
            }
            steps.append(StepBuilder(
                title: "Brush pool and shock aggressively (green algae)",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Brush all walls, steps, and the floor thoroughly to dislodge algae from surfaces. \(shockNote) Keep the pump running continuously. Clean or backwash the filter every 8–12 hours until the water clears. The water will turn milky white as the algae dies — this is normal. Continue running the filter until the water becomes clear blue."
            ))

        case "mustard":
            steps.append(StepBuilder(
                title: "Clean all pool equipment before treating mustard algae",
                product: nil,
                description: "Mustard (yellow) algae is resistant and reinfects the pool through equipment, toys, swimsuits, and ladders. Before shocking: remove all pool toys, floats, and accessories and clean them with a diluted chlorine solution. Clean ladders, rails, and any other items that enter the pool. Wash swimsuits in hot water without softener."
            ))
            steps.append(StepBuilder(
                title: "Brush and shock for mustard algae",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Brush all surfaces aggressively — mustard algae clings to walls and crevices. \(shockNote) Re-brush after shocking to expose any remaining algae to the chlorine. Monitor closely for 48–72 hours and re-shock if needed."
            ))

        case "black":
            steps.append(StepBuilder(
                title: "Aggressively brush black algae to break its protective layer",
                product: "Wire brush (for plaster) or stiff nylon brush (for vinyl/fibreglass)",
                description: "Black algae has a protective outer coating that must be physically broken before chemicals can reach it. Scrub affected spots with a stiff or wire brush repeatedly. If possible, apply granular trichlor or cal-hypo directly to the spot to create concentrated contact — check that this is safe for your pool surface."
            ))
            steps.append(StepBuilder(
                title: "Shock and maintain high chlorine to treat black algae",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Black algae is the hardest to eradicate. \(shockNote) After shocking, maintain free chlorine at 5–10 ppm for several days, continuing to brush daily. Clean and backwash the filter frequently. Black algae may require multiple treatment cycles and may not be fully eliminated in one treatment."
            ))

        case "pink":
            steps.append(StepBuilder(
                title: "Brush hidden areas and treat pink algae (pink slime)",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Pink slime forms in low-flow or hidden areas such as behind stairs, inside return fittings, and in skimmer baskets. Clean those areas physically and brush the pool thoroughly. \(shockNote) Run the pump continuously and increase flow through problem areas if possible."
            ))

        case "white":
            steps.append(StepBuilder(
                title: "Remove visible material and treat white water mold",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "White water mold is a fungal-like growth. Remove any visible clumps with a net. Clean pool equipment, hoses, and any accessories that have been in the water. Brush the pool thoroughly. \(shockNote) Run the filter continuously and clean it every 8 hours. The filter media or cartridge may need replacement if it is heavily contaminated."
            ))

        case "invisible":
            if phHigh {
                steps.append(StepBuilder(
                    title: "Lower pH before shocking for chlorine demand",
                    product: "Muriatic acid or dry acid",
                    description: "Chlorine works best between pH 7.2 and 7.4. Lower pH before shocking to maximise effectiveness."
                ))
            }
            steps.append(StepBuilder(
                title: "Shock to address invisible chlorine demand",
                product: shockProduct(cyaHigh: cyaHigh, calHigh: calHigh),
                description: "Invisible or chlorine-demanding algae is present even without visible discolouration. Brush the pool even if nothing is visible — this disrupts biofilm. \(shockNote) Monitor free chlorine closely — if it drops back to zero within 24 hours, repeat the shock. This pattern of rapid chlorine loss confirms invisible algae or organic contamination."
            ))

        default:
            break
        }

        if !steps.isEmpty {
            steps.append(StepBuilder(
                title: "Filter and retest after algae treatment",
                product: nil,
                description: "After treating for algae, run the pump continuously and clean the filter frequently — at least every 8–12 hours. Cloudy white or blue water clearing to clear blue is the expected outcome. Continue monitoring free chlorine daily. If algae returns within a week, re-treat and consider adding a weekly algaecide."
            ))
        }

        return steps
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
}

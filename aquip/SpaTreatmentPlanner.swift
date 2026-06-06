import Foundation

/// Builds an ordered list of spa treatment steps from the form data and analysis,
/// following the shared spa treatment order plus the sanitizer-specific rules
/// (chlorine / bromine / enzyme / salt).
enum SpaTreatmentPlanner {

    static func steps(formData data: PoolFormData, analysis: SpaAnalysis) -> [TreatmentStep] {
        var raw: [StepBuilder] = []

        let appearance   = data.waterColor
        let waterOld     = data.waterChangeAge == "> 4 months"
        let recentShock  = data.recentlyShocked == "yes"
        let higherUsage  = data.higherUsage == "yes"
        let opaque       = ["green", "brown", "black", "milky"].contains(appearance)
        let metals       = analysis.copper.level == .high
                        || analysis.iron.level == .high
                        || ["brown", "black"].contains(appearance)

        // 1. Safety
        if let safety = safetyStep(data: data, analysis: analysis, opaque: opaque) {
            raw.append(safety)
        }

        // Temperature
        if analysis.tempUnsafe {
            raw.append(StepBuilder(
                title: "Lower the water temperature before use",
                product: nil,
                description: "The water is above the safe maximum of 104°F / 40°C. Turn the heater down and let the water cool before anyone soaks. You can still continue chemistry corrections, but do not use the spa until the temperature is back in the 100–104°F / 38–40°C range."
            ))
        }

        // 2. Water age
        if waterOld && (opaque || appearance == "cloudy" || appearance == "foamy" || analysis.sanitizerResidual.level != .ok) {
            raw.append(StepBuilder(
                title: "Drain and refill the spa",
                product: "Fresh water (plus spa flush before draining)",
                description: "Your spa water is more than 4 months old and is showing problems (cloudy, foamy, discoloured, or unstable sanitizer). Old spa water builds up dissolved solids that make it very hard to balance. Use a spa flush/purge product, drain fully, clean the shell and filter, then refill and rebalance from scratch. This is faster and cheaper than adding more chemicals to worn-out water."
            ))
        }

        // 3. Circulation / filter
        if opaque || ["cloudy", "foamy", "milky"].contains(appearance) || higherUsage {
            raw.append(StepBuilder(
                title: "Clean the filter and run the jets",
                product: "Filter cleaner / cartridge rinse",
                description: "Remove and rinse the filter cartridge (deep-soak it in filter cleaner if it is dirty). Run the pump and jets to circulate the water. Good filtration and circulation are essential for clearing cloudy, foamy or contaminated water and for distributing chemicals evenly. Clean the filter again after the water clears."
            ))
        }

        // 4. Water appearance
        if let appearanceStep = appearanceStep(appearance: appearance, metals: metals) {
            raw.append(appearanceStep)
        }

        // 5. Balance alkalinity and pH
        raw.append(contentsOf: phAlkSteps(analysis: analysis))

        // 6. Sanitizer correction
        raw.append(contentsOf: sanitizerSteps(data: data, analysis: analysis,
                                              metals: metals, recentShock: recentShock,
                                              higherUsage: higherUsage, appearance: appearance))

        // 7. Calcium hardness (optional)
        if analysis.calcium.level == .low {
            raw.append(StepBuilder(
                title: "Raise calcium hardness",
                product: "Calcium hardness increaser",
                description: "Calcium hardness is below the spa range of 150–250 ppm. Low calcium can cause foaming and is corrosive to the heater and equipment. Add a calcium hardness increaser following the product label, circulate, and retest."
            ))
        } else if analysis.calcium.level == .high {
            raw.append(StepBuilder(
                title: "Address high calcium hardness",
                product: "Partial drain / refill with softer water",
                description: "Calcium hardness is above 300 ppm, which can cause scale and cloudy/milky water. There is no simple chemical to lower calcium — do a partial drain and refill with softer water, and avoid calcium-based (cal-hypo) products. Keep pH and alkalinity controlled to limit scale."
            ))
        }

        // 8. CYA / stabilizer (only relevant outdoor chlorine-based spas)
        if analysis.cyaRelevant {
            if Double(data.cyanuricAcid) == nil {
                raw.append(StepBuilder(
                    title: "Test cyanuric acid (stabilizer)",
                    product: nil,
                    description: "This is an outdoor chlorine-based spa in direct sunlight, so a small amount of stabilizer can help chlorine last longer. Test CYA before adding any. Do not add stabilizer while the water is still green or cloudy."
                ))
            } else if analysis.stabilizer.level == .low {
                raw.append(StepBuilder(
                    title: "Add a small amount of stabilizer (CYA)",
                    product: "Cyanuric acid / stabilizer",
                    description: "CYA is below the useful 20–30 ppm range for an outdoor chlorine spa. Add stabilizer in small amounts only after the water is clear and chlorine demand is under control. Do not exceed about 30 ppm — too much stabilizer weakens chlorine in a small spa."
                ))
            } else if analysis.stabilizer.level == .high {
                raw.append(StepBuilder(
                    title: "Reduce cyanuric acid (CYA)",
                    product: "Partial drain / refill",
                    description: "CYA is above ~50 ppm, which over-stabilizes chlorine in a small spa and weakens sanitizing. Avoid stabilized chlorine (dichlor/trichlor) and do a partial drain and refill to bring CYA back down."
                ))
            }
        }

        // 9. Metals
        if metals {
            raw.append(StepBuilder(
                title: "Treat suspected metals",
                product: "Spa-safe metal sequestrant / remover",
                description: "Copper, iron, or brown/black/clear-green water after oxidising points to metals in the water. Do not shock aggressively and do not raise pH — keep pH around 7.2–7.4. Add a spa-safe metal sequestrant, then filter and clean/rinse the filter. Resume sanitizer correction once the metal issue improves."
            ))
        }
        if analysis.magnesium.level == .high {
            raw.append(StepBuilder(
                title: "Address high magnesium",
                product: "Partial drain / refill",
                description: "Magnesium is high. There is usually no simple chemical fix — if the water is cloudy, milky, old, or hard to balance, do a partial drain and refill, then retest."
            ))
        }

        // 10. Phosphates (last)
        if analysis.phosphates.level == .high {
            raw.append(StepBuilder(
                title: "Treat phosphates last",
                product: "Spa phosphate remover",
                description: "Phosphates are above 100 ppb. Phosphates are low priority — only treat them after the water age, filtration, pH/alkalinity, and sanitizer are all corrected and the water is no longer cloudy or green. Add a spa phosphate remover by the label, then filter and clean the filter."
            ))
        }

        if raw.isEmpty { return [] }

        // 11. Retest reminder
        raw.append(StepBuilder(
            title: "Retest before soaking",
            product: nil,
            description: "After completing these steps, run the pump/jets and retest. The spa is safe to use only when the sanitizer is 3–5 ppm, pH is 7.2–7.8 (ideally 7.4–7.6), alkalinity is 80–120 ppm, and the water is clear with the seats and bottom visible. Never add multiple chemicals at once, and always retest between major steps."
        ))

        return raw.enumerated().map { i, b in
            TreatmentStep(id: i + 1, title: b.title, product: b.product, description: b.description)
        }
    }

    // MARK: - Safety

    private static func safetyStep(data: PoolFormData, analysis: SpaAnalysis, opaque: Bool) -> StepBuilder? {
        var reasons: [String] = []
        if analysis.tempUnsafe {
            reasons.append("the water is hotter than 104°F / 40°C")
        }
        if !analysis.sanitizerProvided {
            reasons.append("no \(analysis.sanitizerLabel.lowercased()) reading was entered, so sanitizer safety can't be confirmed")
        } else if analysis.sanitizerResidual.level == .low {
            reasons.append("\(analysis.sanitizerLabel.lowercased()) is below 3 ppm")
        } else if analysis.sanitizerResidual.level == .high {
            reasons.append("\(analysis.sanitizerLabel.lowercased()) is above 5 ppm")
        }
        if analysis.pH.level != .ok {
            reasons.append("pH is outside the safe 7.2–7.8 range")
        }
        if opaque {
            reasons.append("the water is not clear enough to see the seats and bottom")
        }

        guard !reasons.isEmpty else { return nil }

        let intro: String
        switch analysis.kind {
        case .bromine:
            intro = "Do not use the spa until bromine, pH, and water clarity are safe."
        case .enzyme:
            intro = "Enzymes alone cannot make the water safe — a chlorine or bromine residual is still required. Do not use the spa until the sanitizer residual, pH, and water clarity are safe."
        case .salt:
            intro = "A salt spa is still a chlorine spa. Do not use it until free chlorine, pH, and water clarity are safe."
        case .chlorine:
            intro = "Do not use the spa until free chlorine, pH, and water clarity are safe."
        }

        let reasonText = reasons.joined(separator: "; ")
        return StepBuilder(
            title: "Do not use the spa yet",
            product: nil,
            description: "\(intro) Right now, \(reasonText). Work through the steps below and retest before anyone soaks."
        )
    }

    // MARK: - Appearance

    private static func appearanceStep(appearance: String, metals: Bool) -> StepBuilder? {
        switch appearance {
        case "foamy":
            return StepBuilder(
                title: "Clear up foamy water",
                product: "Spa anti-foam (short term) + filter clean",
                description: "Foam usually comes from body oils, lotions, detergents, low calcium hardness, or old water. Clean/rinse the filter, confirm the sanitizer residual, and check calcium hardness. Anti-foam is only a short-term fix — if the water is old, a drain and refill is the real solution."
            )
        case "milky":
            return StepBuilder(
                title: "Clear up milky water",
                product: "Filter clean + balancing",
                description: "Milky water usually points to high pH, high alkalinity, calcium scale, old water, or a dirty filter. Clean the filter, balance alkalinity and pH, and check calcium hardness. If the water is old, do a drain and refill."
            )
        case "cloudy":
            return StepBuilder(
                title: "Clear up cloudy water",
                product: "Filter clean + balancing",
                description: "Cloudy water is usually caused by filtration, balance, or sanitizer demand. Clean the filter and circulate, balance pH and alkalinity, and correct the sanitizer. If it does not clear, check calcium hardness and water age."
            )
        case "green":
            if metals {
                return StepBuilder(
                    title: "Investigate green water (possible metals)",
                    product: nil,
                    description: "A clear green tint can mean metals rather than algae. Do not shock blindly — if copper or iron is present or suspected, treat the metals first (see the metals step) before oxidising."
                )
            }
            return StepBuilder(
                title: "Treat green / contaminated water",
                product: "Spa shock / oxidiser (sanitizer-appropriate)",
                description: "Green, slimy, or contaminated water means sanitizer demand, algae, or biofilm. Brush/wipe the surfaces, clean the filter, balance pH first, then shock/oxidise with the product appropriate for your sanitizer. Circulate and retest, and repeat if the sanitizer drops back to zero quickly."
            )
        case "brown", "black":
            return StepBuilder(
                title: "Investigate brown / black water (possible metals)",
                product: nil,
                description: "Brown or black water — or water that changes colour after shocking — points to metals. Do not keep shocking. Treat the metals first (see the metals step), keep pH around 7.2–7.4, and filter before resuming sanitizer correction."
            )
        default:
            return nil
        }
    }

    // MARK: - pH / alkalinity pair rules

    private static func phAlkSteps(analysis: SpaAnalysis) -> [StepBuilder] {
        let ph  = analysis.pH.level
        let alk = analysis.alkalinity.level
        if ph == .ok && alk == .ok { return [] }

        let title = "Balance total alkalinity and pH"
        let desc: String

        switch (ph, alk) {
        case (.low, .low):
            desc = "Both pH and alkalinity are low. Add alkalinity increaser (sodium bicarbonate) first, circulate, and retest. If pH is still below 7.2 afterward, add a small amount of pH increaser. Target alkalinity ~100 ppm and pH 7.4–7.6."
        case (.low, .ok):
            desc = "pH is low but alkalinity is in range. Add pH increaser carefully, circulate, and retest. Don't touch alkalinity unless it moves out of the 80–120 ppm range. Target pH 7.4–7.6."
        case (.low, .high):
            desc = "pH is low and alkalinity is high. Use the jets/aeration to raise pH without adding alkalinity, and add acid carefully to bring alkalinity down. Aerate again if pH drops, and repeat slowly until both are in range."
        case (.ok, .low):
            desc = "Alkalinity is low but pH is in range. Add alkalinity increaser, circulate, and retest. Adjust pH afterward only if it drifts out of 7.2–7.8."
        case (.ok, .high):
            desc = "Alkalinity is high but pH is in range. Add acid carefully to lower alkalinity, then use the jets/aeration to bring pH back up without raising alkalinity. Repeat as needed."
        case (.high, .low):
            desc = "pH is high and alkalinity is low. Raise alkalinity first with alkalinity increaser, circulate, and retest. Then lower pH carefully with acid and recheck alkalinity, since acid lowers it too."
        case (.high, .ok):
            desc = "pH is high but alkalinity is in range. Lower pH with a pH decreaser/acid, circulate, and retest. Check alkalinity afterward in case the acid lowered it."
        case (.high, .high):
            desc = "Both pH and alkalinity are high. Add acid to lower both, circulate, and retest. If pH reaches range but alkalinity is still high, use acid-then-aeration cycles, preferring aeration over pH increaser to raise pH while reducing alkalinity."
        default:
            desc = "Balance alkalinity to 80–120 ppm first, then bring pH to 7.4–7.6. Add chemicals slowly and retest between additions."
        }

        return [StepBuilder(title: title, product: "Alkalinity increaser / pH adjusters", description: desc)]
    }

    // MARK: - Sanitizer correction

    private static func sanitizerSteps(
        data: PoolFormData, analysis: SpaAnalysis, metals: Bool,
        recentShock: Bool, higherUsage: Bool, appearance: String
    ) -> [StepBuilder] {
        var steps: [StepBuilder] = []
        let level    = analysis.sanitizerResidual.level
        let provided = analysis.sanitizerProvided
        let label    = analysis.sanitizerLabel
        let contaminated = ["green", "cloudy", "milky", "foamy"].contains(appearance)

        // Missing reading
        if !provided {
            steps.append(StepBuilder(
                title: "Test your sanitizer residual",
                product: nil,
                description: "No \(label.lowercased()) reading was entered. The app cannot confirm the water is safe without it. Test and maintain a residual of 3–5 ppm (use the residual your system requires) before using the spa."
            ))
        }

        switch analysis.kind {
        case .chlorine:
            steps.append(contentsOf: chlorineSteps(level: level, provided: provided, metals: metals,
                                                   recentShock: recentShock, higherUsage: higherUsage,
                                                   contaminated: contaminated, analysis: analysis))
        case .salt:
            steps.append(contentsOf: saltSteps(data: data, level: level, provided: provided,
                                               metals: metals, contaminated: contaminated, analysis: analysis))
        case .bromine:
            steps.append(contentsOf: bromineSteps(level: level, provided: provided))
        case .enzyme:
            steps.append(contentsOf: enzymeSteps(level: level, provided: provided, label: label, contaminated: contaminated))
        }

        // Combined chlorine (chlorine-side spas)
        if analysis.showCombinedChlorine && analysis.combinedChlorine.level == .high && !metals {
            steps.append(StepBuilder(
                title: "Shock to clear combined chlorine",
                product: "Spa shock / oxidiser",
                description: "Combined chlorine is above 0.5 ppm, which causes a chlorine smell and irritation. Once pH is in range, shock/oxidise the spa to burn off the combined chlorine. Leave the cover open afterward and circulate before retesting. Skip this if metals are suspected."
            ))
        }

        return steps
    }

    private static func chlorineSteps(
        level: ChemistryLevel, provided: Bool, metals: Bool, recentShock: Bool,
        higherUsage: Bool, contaminated: Bool, analysis: SpaAnalysis
    ) -> [StepBuilder] {
        var steps: [StepBuilder] = []
        if level == .low && provided {
            var extra = ""
            if higherUsage { extra += " Recent heavy use increases chlorine demand, so expect to add a bit more." }
            if recentShock { extra += " You shocked within the last 24 hours — keep circulating with the cover open and retest before adding more." }
            steps.append(StepBuilder(
                title: "Raise free chlorine to 3–5 ppm",
                product: metals ? "Liquid chlorine (avoid cal-hypo)" : "Liquid chlorine / spa chlorine granules",
                description: "Free chlorine is below 3 ppm. Add chlorine by the product label to reach 3–5 ppm, circulate, and retest.\(extra)"
            ))
            if contaminated {
                steps.append(StepBuilder(
                    title: "Shock and clear the water",
                    product: "Spa shock / oxidiser",
                    description: "The water is cloudy/green/contaminated. After pH is in range, shock/oxidise, brush/wipe the surfaces, clean the filter, circulate, and retest. Repeat if chlorine keeps dropping to zero."
                ))
            }
        } else if level == .high {
            steps.append(StepBuilder(
                title: "Let high free chlorine fall",
                product: nil,
                description: "Free chlorine is above 5 ppm — do not use the spa. Stop adding chlorine, leave the cover open, and circulate. Chlorine will drop on its own; retest until it is back in the 3–5 ppm range before soaking."
            ))
        }
        return steps
    }

    private static func saltSteps(
        data: PoolFormData, level: ChemistryLevel, provided: Bool,
        metals: Bool, contaminated: Bool, analysis: SpaAnalysis
    ) -> [StepBuilder] {
        var steps: [StepBuilder] = []

        if level == .low && provided {
            if contaminated {
                steps.append(StepBuilder(
                    title: "Don't rely on the salt cell — shock the water",
                    product: "Liquid chlorine / spa shock",
                    description: "Free chlorine is low and the water is cloudy/green. The salt cell alone won't clear contamination. Balance pH, shock/oxidise with liquid chlorine or an approved spa shock, clean the filter and circulate, then return to normal salt-cell maintenance."
                ))
            } else {
                steps.append(StepBuilder(
                    title: "Boost chlorine production from the salt cell",
                    product: "Salt cell adjustment + liquid chlorine (immediate)",
                    description: "Free chlorine is low but the water is clear. Increase the salt cell output/runtime, verify the salt level is within your system's target, and clean/inspect the cell if production seems weak. Add a small dose of liquid chlorine if you need an immediate residual to reach 3–5 ppm."
                ))
            }
        } else if level == .high {
            steps.append(StepBuilder(
                title: "Let high free chlorine fall",
                product: nil,
                description: "Free chlorine is above 5 ppm — do not use the spa. Lower the salt cell output/runtime, leave the cover open, and circulate until chlorine drops back into the 3–5 ppm range."
            ))
        }

        // Salt system diagnostics availability
        let haveSaltData = !data.saltLevel.isEmpty || !data.saltCellOutput.isEmpty || !data.saltCellRuntime.isEmpty
        if !haveSaltData {
            steps.append(StepBuilder(
                title: "Record salt level, cell output and runtime",
                product: nil,
                description: "Salt-cell production can't be evaluated without the salt level, cell output %, and runtime. Check these against your salt system's manufacturer targets — salt ppm targets vary by system, so follow the manufacturer rather than a universal number."
            ))
        }

        // Scale protection
        if analysis.pH.level == .high || analysis.alkalinity.level == .high || analysis.calcium.level == .high {
            steps.append(StepBuilder(
                title: "Protect the salt cell from scale",
                product: nil,
                description: "High pH, high alkalinity, or high calcium can scale the salt cell and heater. Keep pH and alkalinity controlled, avoid calcium-adding (cal-hypo) products, and inspect/clean the cell if scale builds up. Salt spas tend to push pH up, so monitor pH more often."
            ))
        }

        return steps
    }

    private static func bromineSteps(level: ChemistryLevel, provided: Bool) -> [StepBuilder] {
        var steps: [StepBuilder] = []
        if level == .low && provided {
            steps.append(StepBuilder(
                title: "Raise bromine to 3–5 ppm",
                product: "Bromine tablets / granules (or oxidiser to activate a bromide bank)",
                description: "Bromine is below 3 ppm. Add bromine per the product label to reach 3–5 ppm. If you use a floater/feeder, increase the setting; if you use a bromide bank, an oxidiser/shock may be needed to activate the bromide. Circulate and retest."
            ))
        } else if level == .high {
            steps.append(StepBuilder(
                title: "Let high bromine fall",
                product: nil,
                description: "Bromine is above 5 ppm — do not use the spa. Remove tablets/reduce the floater or feeder setting, leave the cover open, and circulate until bromine drops back into the 3–5 ppm range."
            ))
        }
        return steps
    }

    private static func enzymeSteps(level: ChemistryLevel, provided: Bool, label: String, contaminated: Bool) -> [StepBuilder] {
        var steps: [StepBuilder] = []
        if level == .low && provided {
            steps.append(StepBuilder(
                title: "Raise your sanitizer residual to 3–5 ppm",
                product: label == "Bromine" ? "Bromine product" : "Chlorine product",
                description: "Your \(label.lowercased()) residual is below 3 ppm. Enzymes do not sanitize on their own — raise the \(label.lowercased()) to 3–5 ppm (unless your exact enzyme product states a different safe range) before using the spa."
            ))
            if contaminated {
                steps.append(StepBuilder(
                    title: "Oxidise the contaminated water",
                    product: "Shock / oxidiser per product instructions",
                    description: "The water is cloudy/foamy/contaminated. Oxidise/shock per your sanitizer product instructions, leave the cover open, clean the filter, and circulate. Do not rely on enzymes to fix unsafe water."
                ))
            }
        } else if level == .high {
            steps.append(StepBuilder(
                title: "Let the high sanitizer residual fall",
                product: nil,
                description: "Your \(label.lowercased()) residual is above 5 ppm — do not use the spa. Stop adding sanitizer, leave the cover open, and circulate until it drops back into the 3–5 ppm range."
            ))
        }
        steps.append(StepBuilder(
            title: "Add the enzyme product as maintenance only",
            product: "Spa enzyme product (label dose)",
            description: "Add your enzyme product at the label maintenance dose to help break down oils and organics. Use it as support only — never as a replacement for sanitizer correction or shocking when the water is contaminated."
        ))
        return steps
    }

    // MARK: - Helpers

    private struct StepBuilder {
        let title: String
        let product: String?
        let description: String
    }
}

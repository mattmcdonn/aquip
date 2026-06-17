import Foundation
import SwiftUI

// MARK: - Pool product type

enum PoolProductType: String, CaseIterable, Identifiable, Codable {
    case increaseAlkalinity = "increase_alkalinity"
    case lowerAlkalinity    = "lower_alkalinity"
    case increasePH         = "increase_ph"
    case lowerPH            = "lower_ph"
    case increaseSanitizer  = "increase_sanitizer"
    case increaseSalt       = "increase_salt"
    case increaseCalcium    = "increase_calcium"
    case increaseStabilizer = "increase_stabilizer"
    case lowerPhosphates    = "lower_phosphates"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .increaseAlkalinity: return "Increase Alkalinity"
        case .lowerAlkalinity:    return "Lower Alkalinity"
        case .increasePH:         return "Increase pH"
        case .lowerPH:            return "Lower pH"
        case .increaseSanitizer:  return "Increase Sanitizer"
        case .increaseSalt:       return "Increase Salt"
        case .increaseCalcium:    return "Increase Calcium"
        case .increaseStabilizer: return "Increase Stabilizer"
        case .lowerPhosphates:    return "Lower Phosphates"
        }
    }

    var subtitle: String {
        switch self {
        case .increaseAlkalinity: return "e.g. sodium bicarbonate"
        case .lowerAlkalinity:    return "e.g. muriatic acid / dry acid"
        case .increasePH:         return "e.g. soda ash / pH Up"
        case .lowerPH:            return "e.g. pH Down / dry acid"
        case .increaseSanitizer:  return "chlorine or bromine"
        case .increaseSalt:       return "e.g. pool salt"
        case .increaseCalcium:    return "e.g. calcium chloride"
        case .increaseStabilizer: return "e.g. cyanuric acid"
        case .lowerPhosphates:    return "e.g. phosphate remover"
        }
    }

    var icon: String {
        switch self {
        case .increaseAlkalinity: return "arrow.up.circle.fill"
        case .lowerAlkalinity:    return "arrow.down.circle.fill"
        case .increasePH:         return "arrow.up.circle.fill"
        case .lowerPH:            return "arrow.down.circle.fill"
        case .increaseSanitizer:  return "drop.fill"
        case .increaseSalt:       return "waveform"
        case .increaseCalcium:    return "plus.circle.fill"
        case .increaseStabilizer: return "sun.max.fill"
        case .lowerPhosphates:    return "minus.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .lowerAlkalinity, .lowerPH, .lowerPhosphates:
            return Color(red: 220/255, green: 38/255, blue: 38/255)
        default:
            return Color(red: 37/255, green: 99/255, blue: 235/255)
        }
    }

    var iconBackground: Color {
        switch self {
        case .lowerAlkalinity, .lowerPH, .lowerPhosphates:
            return Color(red: 254/255, green: 226/255, blue: 226/255)
        default:
            return Color(red: 219/255, green: 234/255, blue: 254/255)
        }
    }

    // "raise" or "lower"
    var direction: String {
        switch self {
        case .lowerAlkalinity, .lowerPH, .lowerPhosphates: return "lower"
        default: return "raise"
        }
    }

    var parameterName: String {
        switch self {
        case .increaseAlkalinity, .lowerAlkalinity: return "alkalinity"
        case .increasePH, .lowerPH:                 return "pH"
        case .increaseSanitizer:                    return "sanitizer level"
        case .increaseSalt:                         return "salt level"
        case .increaseCalcium:                      return "calcium level"
        case .increaseStabilizer:                   return "stabilizer (CYA)"
        case .lowerPhosphates:                      return "phosphates"
        }
    }

    var changeUnit: String {
        switch self {
        case .lowerPhosphates:        return "ppb"
        case .increasePH, .lowerPH:   return "pH units"
        default:                      return "ppm"
        }
    }
}

// MARK: - Pool product

struct PoolProduct: Codable {
    var name: String = ""
    var amountGrams: Double = 0
    var perLiters: Double = 0
    var toChangeBy: Double = 0

    var isConfigured: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && amountGrams > 0
            && perLiters > 0
            && toChangeBy > 0
    }
}

// MARK: - Store

@Observable
final class PoolProductStore {
    var products: [String: PoolProduct] = [:]

    private let storageKey = "aquip.poolProducts.v1"

    init() { load() }

    func product(for type: PoolProductType) -> PoolProduct {
        products[type.rawValue] ?? PoolProduct()
    }

    func setProduct(_ product: PoolProduct, for type: PoolProductType) {
        products[type.rawValue] = product
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(products) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([String: PoolProduct].self, from: data)
        else { return }
        products = decoded
    }
}

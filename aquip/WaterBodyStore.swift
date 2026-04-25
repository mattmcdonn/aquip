import SwiftUI

// MARK: - Data model

struct UserWaterBody: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var type: String        // "pool" or "spa"
    var volumeLiters: Double
    var volumeUnit: String  // display unit user entered in: "gallons" or "liters"
    var hasHeater: Bool     // pool only
    var waterSource: String
    var sanitizer: String

    init(
        id: UUID = UUID(),
        name: String,
        type: String,
        volumeLiters: Double,
        volumeUnit: String,
        hasHeater: Bool,
        waterSource: String,
        sanitizer: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.volumeLiters = volumeLiters
        self.volumeUnit = volumeUnit
        self.hasHeater = hasHeater
        self.waterSource = waterSource
        self.sanitizer = sanitizer
    }
}

// MARK: - Store (UserDefaults persistence)

@Observable
class WaterBodyStore {
    var bodies: [UserWaterBody] = []

    private let storageKey = "aquip.waterBodies.v1"

    init() { load() }

    func add(_ body: UserWaterBody) {
        bodies.append(body)
        save()
    }

    func update(_ body: UserWaterBody) {
        guard let index = bodies.firstIndex(where: { $0.id == body.id }) else { return }
        bodies[index] = body
        save()
    }

    func delete(id: UUID) {
        bodies.removeAll { $0.id == id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(bodies) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([UserWaterBody].self, from: data)
        else { return }
        bodies = decoded
    }
}

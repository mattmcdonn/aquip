import Foundation

// MARK: - Record

struct TestHistoryRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var testType: String    // "pool" or "spa"
    var poolName: String    // display name captured at test time
    var formData: PoolFormData
    var issueCount: Int
    var weatherSnapshot: WeatherSnapshot?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        testType: String,
        poolName: String,
        formData: PoolFormData,
        issueCount: Int,
        weatherSnapshot: WeatherSnapshot? = nil
    ) {
        self.id = id
        self.date = date
        self.testType = testType
        self.poolName = poolName
        self.formData = formData
        self.issueCount = issueCount
        self.weatherSnapshot = weatherSnapshot
    }
}

// MARK: - Store

let testHistoryLimit = 10

@Observable
class TestHistoryStore {
    /// Sorted newest-first.
    var records: [TestHistoryRecord] = []

    private let storageKey = "aquip.testHistory.v1"

    init() { load() }

    var isFull: Bool { records.count >= testHistoryLimit }

    func add(_ record: TestHistoryRecord) {
        records.insert(record, at: 0)
        save()
    }

    /// Delete the record with `deleteID` and insert the new record at position 0.
    func replace(deleteID: UUID, with record: TestHistoryRecord) {
        records.removeAll { $0.id == deleteID }
        records.insert(record, at: 0)
        save()
    }

    func delete(id: UUID) {
        records.removeAll { $0.id == id }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([TestHistoryRecord].self, from: data)
        else { return }
        records = decoded
    }
}

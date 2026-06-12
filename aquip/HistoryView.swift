import SwiftUI

// MARK: - Main history list

struct HistoryView: View {
    @Environment(TestHistoryStore.self) private var historyStore
    @State private var selectedRecord: TestHistoryRecord? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Blue gradient header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Test History")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Previous water test results")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 72)
                .padding(.bottom, 32)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 37/255, green: 99/255, blue: 235/255),
                            Color(red: 6/255, green: 182/255, blue: 212/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                if historyStore.records.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                            .frame(width: 88, height: 88)
                            .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                            .clipShape(Circle())

                        Text("No Test History Yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))

                        Text("Your completed water tests will appear here. Start by running your first test!")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 280)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyStore.records) { record in
                                TestHistoryCard(record: record)
                                    .onTapGesture { selectedRecord = record }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .padding(.bottom, 100)
                    }
                    .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(item: $selectedRecord) { record in
                Group {
                    if record.testType == "spa" {
                        SpaTestResultsView(
                            formData: record.formData,
                            weatherSnapshot: record.weatherSnapshot,
                            backAction: { selectedRecord = nil },
                            recordID: record.id,
                            headerTopPadding: 10
                        )
                    } else {
                        PoolTestResultsView(
                            formData: record.formData,
                            weatherSnapshot: record.weatherSnapshot,
                            backAction: { selectedRecord = nil },
                            recordID: record.id,
                            headerTopPadding: 10
                        )
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

// MARK: - History card

private struct TestHistoryCard: View {
    let record: TestHistoryRecord

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(spacing: 14) {
            // Pool/Spa icon
            Image(systemName: record.testType == "spa" ? "drop.fill" : "water.waves")
                .font(.system(size: 22))
                .foregroundStyle(
                    record.testType == "spa"
                        ? Color(red: 8/255, green: 145/255, blue: 178/255)
                        : Color(red: 37/255, green: 99/255, blue: 235/255)
                )
                .frame(width: 52, height: 52)
                .background(
                    record.testType == "spa"
                        ? Color(red: 207/255, green: 250/255, blue: 254/255)
                        : Color(red: 219/255, green: 234/255, blue: 254/255)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.poolName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))

                Text(record.testType == "spa" ? "Hot Tub / Spa" : "Swimming Pool")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))

                Text(Self.dateFormatter.string(from: record.date))
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                // Issue count pill
                let noIssues = record.issueCount == 0
                Text(noIssues ? "No Issues" : "\(record.issueCount) Issue\(record.issueCount == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(
                        noIssues
                            ? Color(red: 22/255, green: 163/255, blue: 74/255)
                            : Color(red: 180/255, green: 83/255, blue: 9/255)
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        noIssues
                            ? Color(red: 220/255, green: 252/255, blue: 231/255)
                            : Color(red: 254/255, green: 243/255, blue: 199/255)
                    )
                    .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 209/255, green: 213/255, blue: 219/255))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    HistoryView()
        .environment(TestHistoryStore())
}


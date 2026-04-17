import SwiftUI

struct HistoryView: View {
    var body: some View {
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
        }
        .background(Color.white)
    }
}

#Preview {
    HistoryView()
}

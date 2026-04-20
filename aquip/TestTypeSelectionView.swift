import SwiftUI

struct TestTypeSelectionView: View {
    var onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Blue gradient header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Testing")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Test your water")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                }

                Spacer()

                WeatherPillButton(testType: nil)
            }
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

            // Content area (white background)
            VStack(spacing: 24) {
                // Select Water Type label
                VStack(spacing: 6) {
                    Text("Select Water Type")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    Text("Choose what you'd like to test")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }

                // Water type cards
                VStack(spacing: 16) {
                    // Swimming Pool card
                    Button {
                        onSelect("pool")
                    } label: {
                        WaterTypeCard(
                            title: "Swimming Pool",
                            subtitle: "Test pool water chemistry",
                            iconName: "water.waves",
                            iconColor: Color(red: 37/255, green: 99/255, blue: 235/255),
                            iconBackground: Color(red: 219/255, green: 234/255, blue: 254/255),
                            chevronColor: Color(red: 37/255, green: 99/255, blue: 235/255)
                        )
                    }
                    .buttonStyle(.plain)

                    // Hot Tub / Spa card
                    Button {
                        onSelect("spa")
                    } label: {
                        WaterTypeCard(
                            title: "Hot Tub / Spa",
                            subtitle: "Test spa water chemistry",
                            iconName: "drop.fill",
                            iconColor: Color(red: 8/255, green: 145/255, blue: 178/255),
                            iconBackground: Color(red: 207/255, green: 250/255, blue: 254/255),
                            chevronColor: Color(red: 8/255, green: 145/255, blue: 178/255)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
        }
        .background(Color.white)
    }
}

struct WaterTypeCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let iconBackground: Color
    let chevronColor: Color

    var body: some View {
        HStack {
            HStack(spacing: 16) {
                // Icon container
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 56, height: 56)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(chevronColor)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TestTypeSelectionView(onSelect: { _ in })
}

import SwiftUI
import MapKit

struct TestTypeSelectionView: View {
    var storeSearchService: PoolStoreSearchService
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

            // Content area
            ScrollView {
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

                    NearbyPoolStoresSection(service: storeSearchService)
                        .padding(.top, 12)
                }
                .padding(24)
                .padding(.bottom, 110)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .task {
            storeSearchService.start()
        }
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
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 56, height: 56)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

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

// MARK: - Nearby pool stores

struct NearbyPoolStoresSection: View {
    let service: PoolStoreSearchService

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pool Product Stores Near Me")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                .frame(maxWidth: .infinity, alignment: .leading)

            switch service.loadState {
            case .idle, .loading:
                PoolStoreLoadingCard()

            case .unavailable:
                PoolStoreUnavailableCard(message: service.message)

            case .available:
                if service.stores.isEmpty {
                    PoolStoreUnavailableCard(
                        message: "No relevant nearby pool stores were found. Try searching in Maps for “pool supply store”."
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(service.stores) { store in
                            PoolStoreCard(store: store)
                        }
                    }
                }
            }
        }
    }
}

struct PoolStoreLoadingCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color(red: 37/255, green: 99/255, blue: 235/255))
                .frame(width: 42, height: 42)
                .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text("Finding nearby stores")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                Text("Searching for pool supply stores near your location...")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct PoolStoreUnavailableCard: View {
    let message: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                .frame(width: 42, height: 42)
                .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

struct PoolStoreCard: View {
    let store: PoolStoreLocation

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "cart.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                .frame(width: 44, height: 44)
                .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 5) {
                Text(store.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))
                    .lineLimit(1)

                Text(store.address)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .lineLimit(2)

                PoolStoreMetaPill(icon: "location.fill", text: store.distanceText)
            }

            Spacer(minLength: 8)

            Button {
                openDirections()
            } label: {
                Text("Directions")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
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
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private func openDirections() {
        store.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

struct PoolStoreMetaPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(.system(size: 10, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(Color(red: 75/255, green: 85/255, blue: 99/255))
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        .clipShape(Capsule())
    }
}

#Preview {
    TestTypeSelectionView(storeSearchService: PoolStoreSearchService(), onSelect: { _ in })
}

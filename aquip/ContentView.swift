import SwiftUI

enum Tab {
    case history, test, settings
}

struct ContentView: View {
    @State private var selectedTab: Tab = .test

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .history:
                    HistoryView()
                case .test:
                    TestFlowView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    private let activeColor = Color(red: 37/255, green: 99/255, blue: 235/255)
    private let inactiveColor = Color(red: 156/255, green: 163/255, blue: 175/255)

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            // History tab
            Button {
                selectedTab = .history
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 26))
                    Text("History")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(selectedTab == .history ? activeColor : inactiveColor)
                .frame(maxWidth: .infinity)
            }

            // Test tab (large circle protruding above bar)
            Button {
                selectedTab = .test
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 37/255, green: 99/255, blue: 235/255),
                                        Color(red: 6/255, green: 182/255, blue: 212/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.35), radius: 6, x: 0, y: 3)

                        Image(systemName: "testtube.2")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 36)
                    .offset(y: -18)

                    Text("Test")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(selectedTab == .test ? activeColor : inactiveColor)
                }
                .frame(maxWidth: .infinity)
            }

            // Settings tab
            Button {
                selectedTab = .settings
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 26))
                    Text("Settings")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(selectedTab == .settings ? activeColor : inactiveColor)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

#Preview {
    ContentView()
}

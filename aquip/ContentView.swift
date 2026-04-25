import SwiftUI

enum Tab {
    case info, history, test, pools, settings
}

struct ContentView: View {
    @State private var selectedTab: Tab = .test
    @State private var store = WaterBodyStore()
    @State private var isInTestQuestionnaire = false
    @State private var showTestExitConfirm = false
    @State private var pendingTab: Tab? = nil
    @State private var shouldResetTestFlow = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .info:     InfoView()
                case .history:  HistoryView()
                case .test:
                    TestFlowView(
                        isInQuestionnaire: $isInTestQuestionnaire,
                        shouldReset: $shouldResetTestFlow
                    )
                case .pools:    MyWaterBodiesView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(
                selectedTab: $selectedTab,
                onTabSelect: { newTab in
                    guard newTab != selectedTab else { return }
                    if isInTestQuestionnaire && selectedTab == .test {
                        pendingTab = newTab
                        withAnimation(.easeOut(duration: 0.2)) {
                            showTestExitConfirm = true
                        }
                    } else {
                        selectedTab = newTab
                    }
                }
            )

            // Exit confirm popup when switching away from in-progress test
            if showTestExitConfirm {
                ExitTestConfirmPopup(
                    onCancel: {
                        withAnimation(.easeIn(duration: 0.18)) { showTestExitConfirm = false }
                        pendingTab = nil
                    },
                    onExit: {
                        withAnimation(.easeIn(duration: 0.18)) { showTestExitConfirm = false }
                        if let tab = pendingTab {
                            isInTestQuestionnaire = false
                            shouldResetTestFlow = true
                            selectedTab = tab
                            pendingTab = nil
                        }
                    }
                )
                .zIndex(10)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: showTestExitConfirm)
        .ignoresSafeArea(.all, edges: .top)
        .ignoresSafeArea(.keyboard)
        .environment(store)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onTabSelect: (Tab) -> Void

    private let activeColor   = Color(red: 37/255,  green: 99/255,  blue: 235/255)
    private let inactiveColor = Color(red: 156/255, green: 163/255, blue: 175/255)

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {

            // Info
            tabButton(icon: "info.circle.fill", label: "Info", tab: .info)

            // History
            tabButton(icon: "clock.fill", label: "History", tab: .history)

            // Test (centre protrusion)
            Button {
                onTabSelect(.test)
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
                            .shadow(
                                color: Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.35),
                                radius: 6, x: 0, y: 3
                            )

                        Image(systemName: "testtube.2")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 36)
                    .offset(y: -18)

                    Text("Test")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(selectedTab == .test ? activeColor : inactiveColor)
                }
                .frame(maxWidth: .infinity)
            }

            // My Pools
            tabButton(icon: "drop.circle.fill", label: "Pools", tab: .pools)

            // Settings
            tabButton(icon: "gearshape.fill", label: "Settings", tab: .settings)
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }

    private func tabButton(icon: String, label: String, tab: Tab) -> some View {
        Button {
            onTabSelect(tab)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? activeColor : inactiveColor)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}

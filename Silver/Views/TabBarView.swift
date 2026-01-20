import SwiftUI

struct TabBarView: View {

    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, holdings, settings
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: Main Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .holdings:
                    HoldingsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.09, blue: 0.17),
                        Color(red: 0.12, green: 0.16, blue: 0.23)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()   // ✅ Removes black bars

            // MARK: Custom Tab Bar
            HStack {
                TabBarButton(
                    tab: .home,
                    selectedTab: $selectedTab,
                    icon: "chart.line.uptrend.xyaxis",
                    label: "Home"
                )

                TabBarButton(
                    tab: .holdings,
                    selectedTab: $selectedTab,
                    icon: "cube.box.fill",
                    label: "Holdings"
                )

                TabBarButton(
                    tab: .settings,
                    selectedTab: $selectedTab,
                    icon: "gearshape.fill",
                    label: "Settings"
                )
            }
            .padding(.top, 12)
            .padding(.bottom, bottomSafeAreaPadding())
            .background(
                Color(red: 0.12, green: 0.16, blue: 0.23)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: Safe Area Helper
    private func bottomSafeAreaPadding() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .safeAreaInsets.bottom ?? 16
    }
}

//
// MARK: - TabBarButton (REQUIRED)
//

struct TabBarButton: View {

    let tab: TabBarView.Tab
    @Binding var selectedTab: TabBarView.Tab
    let icon: String
    let label: String

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))

                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(
                selectedTab == tab ? .green : .white.opacity(0.5)
            )
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TabBarView()
}

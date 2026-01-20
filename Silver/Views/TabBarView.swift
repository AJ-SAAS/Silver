import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, holdings, settings
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                // Main content
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)   // ← pass binding here
                    case .holdings:
                        HoldingsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppBackground())
                
                // Custom tab bar
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack(spacing: 0) {
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(red: 0.12, green: 0.16, blue: 0.23))
                            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: -4)
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 4)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Shared Background

private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.14),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Tab Bar Button with Indicator

struct TabBarButton: View {
    
    let tab: TabBarView.Tab
    @Binding var selectedTab: TabBarView.Tab
    let icon: String
    let label: String
    
    private var isSelected: Bool { selectedTab == tab }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .green : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 28, height: 3)
                        .offset(y: -4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TabBarView()
}

import SwiftUI

struct SettingsView: View {

    @State private var enableNotifications: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                SettingsRow(title: "Enable Notifications", icon: "bell.fill", toggle: $enableNotifications)
                SettingsRow(title: "Dark Mode", icon: "moon.fill")
                SettingsRow(title: "Privacy Policy", icon: "lock.shield.fill")
                SettingsRow(title: "Terms of Service", icon: "doc.text.fill")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .background(
            LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.17),
                                    Color(red: 0.12, green: 0.16, blue: 0.23)],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

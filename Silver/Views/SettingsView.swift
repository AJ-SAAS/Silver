import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var viewModel: SettingsViewModel

    init(authVM: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(authVM: authVM))
    }

    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    if let email = viewModel.userEmail {
                        HStack {
                            Label("Email", systemImage: "envelope")
                            Spacer()
                            Text(email)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button(role: .destructive) {
                        viewModel.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.red)
                    }
                }

                // App Info Section
                Section(header: Text("About Silver")) {
                    LabeledContent("Version", value: "1.0 (MVP)")
                    LabeledContent("Data Source", value: "MetalpriceAPI")
                    LabeledContent("Build Date", value: "January 2026")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView(authVM: AuthViewModel())
        .environmentObject(AuthViewModel())
}

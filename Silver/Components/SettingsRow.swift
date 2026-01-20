import SwiftUI

struct SettingsRow: View {

    let title: String
    var value: String = ""
    let icon: String
    @Binding var toggle: Bool

    init(title: String, value: String = "", icon: String, toggle: Binding<Bool>? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        if let t = toggle {
            self._toggle = t
        } else {
            self._toggle = .constant(false)
        }
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 32)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            if value != "" {
                Text(value)
                    .foregroundColor(.white.opacity(0.7))
            }

            Toggle("", isOn: $toggle)
                .labelsHidden()
                .tint(.green)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

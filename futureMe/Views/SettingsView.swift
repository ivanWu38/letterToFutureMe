import SwiftUI


struct SettingsView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    Toggle("Password Lock (Face ID)", isOn: $appLockEnabled)
                        .onChange(of: appLockEnabled) { _, newValue in
                            if newValue { Task { await AppLock.shared.lockIfNeeded(force: true) } }
                        }
                }
                Section("About this app") {
                    HStack { Text("Version"); Spacer(); Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

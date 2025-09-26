import SwiftUI


struct SettingsView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @StateObject private var languageManager = LanguageManager.shared


    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("settings.section.basic", comment: "")) {
                    Toggle(NSLocalizedString("settings.app_lock", comment: ""), isOn: $appLockEnabled)
                        .onChange(of: appLockEnabled) { _, newValue in
                            if newValue { Task { await AppLock.shared.lockIfNeeded(force: true) } }
                        }
                }

                Section(NSLocalizedString("settings.section.language", comment: "")) {
                    NavigationLink {
                        LanguageSelectionView()
                    } label: {
                        HStack {
                            Text(NSLocalizedString("settings.language", comment: ""))
                            Spacer()
                            Text(languageManager.currentLanguage.nativeDisplayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(NSLocalizedString("settings.section.about", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("settings.version", comment: ""))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
        }
    }
}

struct LanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(Language.allCases, id: \.rawValue) { language in
                HStack {
                    Text(language.nativeDisplayName)
                    Spacer()
                    if languageManager.currentLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    languageManager.currentLanguage = language
                    // Small delay to show the checkmark, then dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings.language", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

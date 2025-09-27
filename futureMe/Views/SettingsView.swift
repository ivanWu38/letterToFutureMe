import SwiftUI


struct SettingsView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @StateObject private var languageManager = LanguageManager.shared

    var body: some View {
        NavigationStack {
            List {
                Section(NSLocalizedString("settings.section.basic", comment: "")) {
                    // App Lock Toggle
                    HStack {
                        Text(NSLocalizedString("settings.app_lock", comment: ""))
                        Spacer()
                        Toggle("", isOn: $appLockEnabled)
                    }

                    // Language Selection
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
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Future Me Team")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background {
                Image("settings_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all)
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
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

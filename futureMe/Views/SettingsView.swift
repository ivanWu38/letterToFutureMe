import SwiftUI


struct SettingsView: View {
    @AppStorage("appLockEnabled") private var appLockEnabled: Bool = false
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background image - 與 Home 和 Inbox 相同的設定方式
                    Image("settings")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)

                    VStack(spacing: 0) {
                        // Top navigation bar with title - 模仿 Inbox 的結構
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .opacity(0) // Invisible for balance

                            Spacer()

                            Text(NSLocalizedString("settings.title", comment: ""))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)

                            Spacer()

                            // Invisible placeholder for balance
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .opacity(0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 20)

                        // Settings content
                        List {
                            Section(NSLocalizedString("settings.section.basic", comment: "")) {
                                // App Lock Toggle
                                HStack {
                                    Text(NSLocalizedString("settings.app_lock", comment: ""))
                                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                                    Spacer()
                                    Toggle("", isOn: $appLockEnabled)
                                        .tint(Color(red: 0.518, green: 0.604, blue: 0.733))
                                }

                                // Language Selection
                                NavigationLink {
                                    LanguageSelectionView()
                                } label: {
                                    HStack {
                                        Text(NSLocalizedString("settings.language", comment: ""))
                                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                                        Spacer()
                                        Text(languageManager.currentLanguage.nativeDisplayName)
                                            .foregroundStyle(colorScheme == .dark ? .gray : .secondary)
                                    }
                                }
                            }

                            Section(NSLocalizedString("settings.section.about", comment: "")) {
                                HStack {
                                    Text("Version")
                                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundStyle(colorScheme == .dark ? .gray : .secondary)
                                }

                                HStack {
                                    Text("Developer")
                                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                                    Spacer()
                                    Text("kureIkuhei design")
                                        .foregroundStyle(colorScheme == .dark ? .gray : .secondary)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LanguageSelectionView: View {
    @StateObject private var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List {
            ForEach(Language.allCases, id: \.rawValue) { language in
                HStack {
                    Text(language.nativeDisplayName)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
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
        .scrollContentBackground(.hidden)
        .navigationTitle(NSLocalizedString("settings.language", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(NSLocalizedString("settings.title", comment: ""))
                    }
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

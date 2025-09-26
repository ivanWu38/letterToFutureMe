import Foundation
import SwiftUI

enum Language: String, CaseIterable {
    case english = "en"
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    case japanese = "ja"

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        case .simplifiedChinese:
            return "简体中文"
        case .japanese:
            return "日本語"
        }
    }

    var nativeDisplayName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        case .simplifiedChinese:
            return "简体中文"
        case .japanese:
            return "日本語"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            setAppLanguage(currentLanguage.rawValue)
        }
    }

    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .english
        setAppLanguage(currentLanguage.rawValue)
    }

    private func setAppLanguage(_ languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        // Update the bundle for runtime language switching
        Bundle.setLanguage(languageCode)

        // Post notification to trigger UI refresh
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
}

// Extension to support runtime language switching
extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle {
        // Always get the current language to support dynamic switching
        let language = LanguageManager.shared.currentLanguage.rawValue
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = Bundle(path: path ?? Bundle.main.path(forResource: "en", ofType: "lproj")!) ?? Bundle.main
        return bundle
    }

    public static func setLanguage(_ language: String) {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        bundle = Bundle(path: path ?? Bundle.main.path(forResource: "en", ofType: "lproj")!) ?? Bundle.main
    }
}

// Localized string function
func NSLocalizedString(_ key: String, comment: String = "") -> String {
    return Bundle.localizedBundle().localizedString(forKey: key, value: nil, table: nil)
}

// Notification for language change
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
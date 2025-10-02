import Foundation
import SwiftUI

enum Language: String, CaseIterable {
    case english = "en"
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    case japanese = "ja"
    case arabic = "ar"
    case catalan = "ca"
    case czech = "cs"
    case danish = "da"
    case german = "de"
    case greek = "el"
    case spanish = "es"
    case finnish = "fi"
    case french = "fr"
    case hebrew = "he"
    case hindi = "hi"
    case croatian = "hr"
    case hungarian = "hu"
    case indonesian = "id"
    case italian = "it"
    case korean = "ko"
    case malay = "ms"
    case norwegian = "nb"
    case dutch = "nl"
    case polish = "pl"
    case portugueseBrazil = "pt-BR"
    case portuguesePortugal = "pt-PT"
    case romanian = "ro"
    case russian = "ru"
    case slovak = "sk"
    case swedish = "sv"
    case thai = "th"
    case turkish = "tr"
    case ukrainian = "uk"
    case vietnamese = "vi"

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
        case .arabic:
            return "العربية"
        case .catalan:
            return "Català"
        case .czech:
            return "Čeština"
        case .danish:
            return "Dansk"
        case .german:
            return "Deutsch"
        case .greek:
            return "Ελληνικά"
        case .spanish:
            return "Español"
        case .finnish:
            return "Suomi"
        case .french:
            return "Français"
        case .hebrew:
            return "עברית"
        case .hindi:
            return "हिन्दी"
        case .croatian:
            return "Hrvatski"
        case .hungarian:
            return "Magyar"
        case .indonesian:
            return "Bahasa Indonesia"
        case .italian:
            return "Italiano"
        case .korean:
            return "한국어"
        case .malay:
            return "Bahasa Melayu"
        case .norwegian:
            return "Norsk Bokmål"
        case .dutch:
            return "Nederlands"
        case .polish:
            return "Polski"
        case .portugueseBrazil:
            return "Português (Brasil)"
        case .portuguesePortugal:
            return "Português (Portugal)"
        case .romanian:
            return "Română"
        case .russian:
            return "Русский"
        case .slovak:
            return "Slovenčina"
        case .swedish:
            return "Svenska"
        case .thai:
            return "ไทย"
        case .turkish:
            return "Türkçe"
        case .ukrainian:
            return "Українська"
        case .vietnamese:
            return "Tiếng Việt"
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
        case .arabic:
            return "العربية"
        case .catalan:
            return "Català"
        case .czech:
            return "Čeština"
        case .danish:
            return "Dansk"
        case .german:
            return "Deutsch"
        case .greek:
            return "Ελληνικά"
        case .spanish:
            return "Español"
        case .finnish:
            return "Suomi"
        case .french:
            return "Français"
        case .hebrew:
            return "עברית"
        case .hindi:
            return "हिन्दी"
        case .croatian:
            return "Hrvatski"
        case .hungarian:
            return "Magyar"
        case .indonesian:
            return "Bahasa Indonesia"
        case .italian:
            return "Italiano"
        case .korean:
            return "한국어"
        case .malay:
            return "Bahasa Melayu"
        case .norwegian:
            return "Norsk Bokmål"
        case .dutch:
            return "Nederlands"
        case .polish:
            return "Polski"
        case .portugueseBrazil:
            return "Português (Brasil)"
        case .portuguesePortugal:
            return "Português (Portugal)"
        case .romanian:
            return "Română"
        case .russian:
            return "Русский"
        case .slovak:
            return "Slovenčina"
        case .swedish:
            return "Svenska"
        case .thai:
            return "ไทย"
        case .turkish:
            return "Türkçe"
        case .ukrainian:
            return "Українська"
        case .vietnamese:
            return "Tiếng Việt"
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
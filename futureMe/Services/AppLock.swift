import Foundation
import LocalAuthentication
import UIKit


@MainActor
final class AppLock: ObservableObject {
    static let shared = AppLock()
    @Published var showLockScreen: Bool = false

    private var isLocked: Bool = false

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(backgrounded), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foregrounded), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func backgrounded() {
        if UserDefaults.standard.bool(forKey: "appLockEnabled") {
            isLocked = true
            showLockScreen = true
        }
    }

    @objc private func foregrounded() {
        if UserDefaults.standard.bool(forKey: "appLockEnabled") && isLocked {
            showLockScreen = true
        }
    }

    func lockIfNeeded(force: Bool = false) async {
        guard UserDefaults.standard.bool(forKey: "appLockEnabled") || force else { return }
        isLocked = true
        showLockScreen = true
    }

    func authenticate() async {
        await authenticateUser()
    }

    private func authenticateUser() async {
        let ctx = LAContext()
        var error: NSError?

        let reason = NSLocalizedString("applock.reason", comment: "")

        // Try biometric authentication first
        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                let success = try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                if success {
                    unlockApp()
                    return
                }
            } catch {
                // Biometric failed, fall through to passcode
            }
        }

        // Try device passcode as fallback
        var passcodeError: NSError?
        if ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &passcodeError) {
            do {
                let success = try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                if success {
                    unlockApp()
                }
            } catch {
                // Authentication failed completely
            }
        }
    }

    private func unlockApp() {
        isLocked = false
        showLockScreen = false
    }
}

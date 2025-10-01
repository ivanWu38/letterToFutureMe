import Foundation
import LocalAuthentication
import UIKit


@MainActor
final class AppLock: ObservableObject {
    static let shared = AppLock()
    @Published var showLockScreen: Bool = false

    private var isLocked: Bool = false
    private var hasBeenBackgrounded: Bool = false

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(backgrounded), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foregrounded), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func backgrounded() {
        if UserDefaults.standard.bool(forKey: "appLockEnabled") {
            hasBeenBackgrounded = true
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
        // Only lock if the app has been backgrounded at least once
        // This prevents locking on initial app launch
        guard hasBeenBackgrounded || force else { return }
        isLocked = true
        showLockScreen = true
    }

    func authenticate() async {
        await authenticateUser()
    }

    // Check if biometric authentication is available on this device
    func canUseBiometrics() -> Bool {
        let ctx = LAContext()
        var error: NSError?
        return ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }

    private func authenticateUser() async {
        let ctx = LAContext()
        var error: NSError?

        let reason = NSLocalizedString("applock.reason", comment: "")

        // Use .deviceOwnerAuthentication which includes both biometrics and passcode
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("❌ Cannot evaluate authentication policy: \(error?.localizedDescription ?? "Unknown error")")
            // If device doesn't support authentication, unlock anyway to prevent lockout
            await MainActor.run {
                unlockApp()
            }
            return
        }

        do {
            let success = try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if success {
                await MainActor.run {
                    unlockApp()
                }
            }
        } catch let authError as LAError {
            print("❌ Authentication error: \(authError.localizedDescription)")
            // Handle specific errors
            switch authError.code {
            case .userCancel, .systemCancel, .appCancel:
                // User cancelled, keep the lock screen visible
                print("⚠️ User cancelled authentication")
            case .userFallback:
                // User chose to enter password, keep lock screen visible
                print("⚠️ User requested fallback")
            default:
                // Other errors - for now, keep lock screen visible
                print("⚠️ Authentication failed: \(authError.code.rawValue)")
            }
        } catch {
            print("❌ Unexpected authentication error: \(error.localizedDescription)")
        }
    }

    private func unlockApp() {
        isLocked = false
        showLockScreen = false
    }
}

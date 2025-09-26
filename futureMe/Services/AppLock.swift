import Foundation
import LocalAuthentication
import UIKit


@MainActor
final class AppLock: ObservableObject {
    static let shared = AppLock()
    @Published var shouldLock: Bool = false
    
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(backgrounded), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foregrounded), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    @objc private func backgrounded() { shouldLock = true }
    @objc private func foregrounded() { }
    
    
    func lockIfNeeded(force: Bool = false) async {
        guard UserDefaults.standard.bool(forKey: "appLockEnabled") || force else { return }
        let ctx = LAContext()
        var error: NSError?
        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = NSLocalizedString("applock.reason", comment: "")
            do { _ = try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason); shouldLock = false } catch { }
        }
    }
}

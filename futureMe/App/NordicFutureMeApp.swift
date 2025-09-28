import SwiftUI
import SwiftData
import UserNotifications
import GoogleMobileAds


@main
struct NordicFutureMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(for: Letter.self)
                .onAppear { NotificationManager.shared.requestAuthorization() }
        }
    }
}


final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        print("📱 App launched successfully")

        // Initialize AdMob SDK with delay to avoid app startup crash
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AdManager.shared.initializeAdSDK()
        }

        return true
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }

    // Handle notification tap to deep-link into Inbox
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.shared.lastOpenedLetterID = response.notification.request.identifier
        completionHandler()
    }
}

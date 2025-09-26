import SwiftUI
import SwiftData
import UserNotifications


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
        return true
    }
    
    
    // Handle notification tap to deep-link into Inbox
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationManager.shared.lastOpenedLetterID = response.notification.request.identifier
        completionHandler()
    }
}

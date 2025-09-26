import Foundation
import UserNotifications


final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}
    
    
    // Use this to navigate to the tapped letter
    @Published var lastOpenedLetterID: String? = nil
    
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    
    func schedule(for letter: Letter) async throws {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.title", comment: "")
        content.body = letter.title.isEmpty ? NSLocalizedString("notification.body_default", comment: "") : letter.title
        content.sound = .default
        content.userInfo = ["letterID": letter.id]
        
        
        let triggerDate = letter.deliverAt
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: triggerDate), repeats: false)
        
        
        let request = UNNotificationRequest(identifier: letter.id, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
    
    
    func removePending(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

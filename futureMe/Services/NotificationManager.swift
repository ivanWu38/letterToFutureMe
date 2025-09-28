import Foundation
import UserNotifications
import UIKit

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {
        setupNotificationCategories()
    }

    // Use this to navigate to the tapped letter
    @Published var lastOpenedLetterID: String? = nil

    // Track notification permission status
    @Published var notificationPermissionGranted = false

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
                if granted {
                    print("📱 Notification permission granted")
                    self?.updateAppBadge()
                } else {
                    print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

        // Also check current permission status
        checkNotificationPermission()
    }

    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
                print("📱 Current notification status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }

    private func setupNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_LETTER",
            title: NSLocalizedString("notification.action.open", comment: "Open"),
            options: [.foreground]
        )

        let letterCategory = UNNotificationCategory(
            identifier: "LETTER_DELIVERY",
            actions: [openAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([letterCategory])
    }

    func schedule(for letter: Letter) async throws {
        // Check permission first
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            print("❌ Cannot schedule notification: permission not granted")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.title", comment: "")

        // Create more engaging notification body
        if letter.title.isEmpty {
            content.body = NSLocalizedString("notification.body_default", comment: "")
        } else {
            content.body = String(format: NSLocalizedString("notification.body_with_title", comment: ""), letter.title)
        }

        content.sound = .default

        // Calculate badge count based on how many letters will be unread when this notification fires
        let badgeCount = await calculateBadgeCountForNotification(targetDate: letter.deliverAt)
        content.badge = NSNumber(value: badgeCount)

        content.categoryIdentifier = "LETTER_DELIVERY"
        content.userInfo = [
            "letterID": letter.id,
            "letterTitle": letter.title,
            "deliveryTime": letter.deliverAt.timeIntervalSince1970
        ]

        // Add subtitle for more context
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        content.subtitle = String(format: NSLocalizedString("notification.subtitle", comment: ""), formatter.string(from: letter.deliverAt))

        let triggerDate = letter.deliverAt
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: letter.id, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("📅 Notification scheduled for letter: \(letter.title.isEmpty ? "Untitled" : letter.title) at \(triggerDate) with badge: \(badgeCount)")
        } catch {
            print("❌ Failed to schedule notification: \(error.localizedDescription)")
            throw error
        }
    }

    private func calculateBadgeCountForNotification(targetDate: Date) async -> Int {
        // This is a simplified calculation - in a real scenario we'd need access to the data model
        // For now, we'll use a conservative approach and assume this will be 1 new unread letter
        return 1
    }

    func removePending(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("🗑 Removed pending notification for letter: \(id)")
    }

    func updateAppBadge() {
        // This method will be called from LetterDetailView with actual unread count
        // We need a way to get the current unread count from the data model
        print("📱 App badge update requested")
    }

    func updateAppBadge(unreadCount: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
            print("📱 Updated app badge to: \(unreadCount)")
        }
    }

    func clearAppBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // Debug function to check pending notifications
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextDate = trigger.nextTriggerDate() {
                    print("  - \(request.identifier): \(nextDate)")
                }
            }
        }
    }
}

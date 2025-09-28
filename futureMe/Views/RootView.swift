import SwiftUI
import SwiftData
import UIKit


struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: [SortDescriptor(\Letter.deliverAt, order: .forward)]) private var letters: [Letter]
    @ObservedObject private var languageManager = LanguageManager.shared
    @ObservedObject private var appLock = AppLock.shared
    @State private var tab: Int = 1 // 0: Inbox, 1: Home, 2: Settings
    @State private var showLock = UserDefaults.standard.bool(forKey: "appLockEnabled")
    @State private var currentTime = Date()
    @State private var updateTrigger = 0 // 用於強制重新計算 unreadCount


    var unreadCount: Int {
        let now = Date() // 使用即時時間，而不是 currentTime 狀態
        let _ = updateTrigger // 引用觸發器強制重新計算
        let count = letters.filter { $0.deliverAt <= now && !$0.isRead }.count
        print("🐛 Unread count calculation: \(count) letters (trigger: \(updateTrigger))")
        for letter in letters {
            print("🐛 Letter '\(letter.title)' - deliverAt: \(letter.deliverAt) - now: \(now) - isRead: \(letter.isRead) - delivered: \(letter.deliverAt <= now)")
        }
        return count
    }


    var body: some View {
        TabView(selection: $tab) {
            Group {
                if unreadCount > 0 {
                    InboxView()
                        .tabItem { Label(NSLocalizedString("tab.inbox", comment: ""), systemImage: "envelope") }
                        .badge(unreadCount)
                        .tag(0)
                } else {
                    InboxView()
                        .tabItem { Label(NSLocalizedString("tab.inbox", comment: ""), systemImage: "envelope") }
                        .tag(0)
                }
            }


            HomeView(onSendTapped: { tab = 1; NotificationCenter.default.post(name: .init("openCompose"), object: nil) })
                .tabItem { Label(NSLocalizedString("tab.home", comment: ""), systemImage: "house") }
                .tag(1)


            SettingsView()
                .tabItem { Label(NSLocalizedString("tab.settings", comment: ""), systemImage: "gearshape") }
                .tag(2)
        }
        .tint(colorScheme == .dark ? Color(red: 0.102, green: 0.125, blue: 0.184) : NordicTheme.slate)
        .onAppear {
            currentTime = Date()
            updateTrigger += 1
            configureTabBarAppearance()
            // Update app badge on app launch
            updateAppBadgeOnAppear()
        }
        .onChange(of: colorScheme) { _, _ in
            configureTabBarAppearance()
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
            updateTrigger += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            currentTime = Date()
            updateTrigger += 1
            // Update app badge when returning to foreground
            updateAppBadgeOnAppear()
        }
        .onChange(of: tab) { _, newTab in
            // 提供觸覺反饋 - 輕微震動
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .task {
            if UserDefaults.standard.bool(forKey: "appLockEnabled") {
                await appLock.lockIfNeeded()
            }
        }
        .fullScreenCover(isPresented: $appLock.showLockScreen) {
            LockScreenView()
        }
    }

    private func updateAppBadgeOnAppear() {
        let now = Date()
        let unreadCount = letters.filter { $0.deliverAt <= now && !$0.isRead }.count
        NotificationManager.shared.updateAppBadge(unreadCount: unreadCount)
    }

    private func configureTabBarAppearance() {
        if colorScheme == .dark {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()

            // 未選中狀態的顏色 - #4E6185
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 78/255.0, green: 97/255.0, blue: 133/255.0, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(red: 78/255.0, green: 97/255.0, blue: 133/255.0, alpha: 1.0)
            ]

            // 選中狀態的顏色 - #1A202F
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.102, green: 0.125, blue: 0.184, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(red: 0.102, green: 0.125, blue: 0.184, alpha: 1.0)
            ]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Reset to default appearance for light mode
            UITabBar.appearance().standardAppearance = UITabBarAppearance()
            UITabBar.appearance().scrollEdgeAppearance = nil
        }
    }
}

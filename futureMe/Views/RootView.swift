import SwiftUI
import SwiftData


struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Letter.deliverAt, order: .forward)]) private var letters: [Letter]
    @ObservedObject private var languageManager = LanguageManager.shared
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
        .tint(NordicTheme.slate)
        .onAppear {
            currentTime = Date()
            updateTrigger += 1
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
            updateTrigger += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            currentTime = Date()
            updateTrigger += 1
        }
        .onChange(of: tab) { _, newTab in
            // Tab switching logic if needed in the future
        }
        .task { await AppLock.shared.lockIfNeeded() }
        .onReceive(AppLock.shared.$shouldLock) { should in
            if should { Task { await AppLock.shared.lockIfNeeded() } }
        }
    }
}

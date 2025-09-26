import SwiftUI
import SwiftData


struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var date: Date = Calendar.current.date(byAdding: .minute, value: 2, to: .now) ?? .now
    @State private var img1: Data? = nil
    @State private var img2: Data? = nil
    @State private var isSaving = false
    @State private var error: String?
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") { TextField("Optional title", text: $title) }
                Section("Message") { TextEditor(text: $bodyText).frame(minHeight: 160) }
                Section("Delivery time") {
                    DatePicker("Deliver at", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Photos (optional)") {
                    PhotoPickerView(data: $img1, label: "Photo 1")
                    PhotoPickerView(data: $img2, label: "Photo 2")
                }
            }
            .navigationTitle("Write a Letter")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel", role: .cancel) { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schedule") { Task { await save() } }.disabled(isSaving || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: .constant(error != nil), actions: { Button("OK") { error = nil } }, message: { Text(error ?? "") })
        }
    }
    
    
    private func save() async {
        guard date >= Date().addingTimeInterval(-60) else { self.error = "Invalid date selected."; return }
        isSaving = true
        let letter = Letter(title: title, body: bodyText, deliverAt: date, isRead: false, image1: img1, image2: img2)
        print("🐛 Creating letter with title: '\(letter.title)', body: '\(letter.body)', deliverAt: \(letter.deliverAt)")
        context.insert(letter)
        print("🐛 Letter inserted into context")
        do {
            try context.save()
            print("🐛 Context saved successfully")
            try await NotificationManager.shared.schedule(for: letter)
            print("🐛 Notification scheduled successfully")
            isSaving = false
            dismiss()
        } catch {
            print("🐛 Error saving: \(error.localizedDescription)")
            self.error = error.localizedDescription
            isSaving = false
        }
    }
}

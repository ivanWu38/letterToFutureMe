import SwiftUI
import SwiftData


struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var languageManager = LanguageManager.shared

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var date: Date = Calendar.current.date(byAdding: .minute, value: 2, to: .now) ?? .now
    @State private var img1: Data? = nil
    @State private var img2: Data? = nil
    @State private var isSaving = false
    @State private var error: String?
    @State private var showingConfirmation = false

    @FocusState private var isFieldFocused: FocusedField?

    enum FocusedField {
        case title, message
    }
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background color - adaptive for light/dark mode
                    (colorScheme == .dark ? Color(red: 0.306, green: 0.381, blue: 0.533) : Color(red: 0.91, green: 0.84, blue: 0.89))
                        .ignoresSafeArea(.all)

                    VStack(spacing: 0) {
                        // Top navigation bar
                        HStack {
                            Button(action: { dismiss() }) {
                                Text(NSLocalizedString("compose.button.cancel", comment: ""))
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(Color(red: 0.102, green: 0.125, blue: 0.184))
                            }

                            Spacer()

                            Text(NSLocalizedString("compose.title", comment: ""))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)

                            Spacer()

                            Button(action: { Task { await save() } }) {
                                Text(NSLocalizedString("compose.button.schedule", comment: ""))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(red: 0.102, green: 0.125, blue: 0.184))
                            }
                            .disabled(isSaving || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(isSaving || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 20)

                        // Main content area - matching the mostly empty design
                        VStack(spacing: 24) {
                            // Title input
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("compose.section.title", comment: ""))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                TextField(NSLocalizedString("compose.title_placeholder", comment: ""), text: $title)
                                    .padding(12)
                                    .background(colorScheme == .dark ? Color(red: 0.52, green: 0.58, blue: 0.70) : Color.white.opacity(0.8))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .focused($isFieldFocused, equals: .title)
                            }

                            // Message input
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("compose.section.message", comment: ""))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                TextEditor(text: $bodyText)
                                    .padding(12)
                                    .scrollContentBackground(.hidden)
                                    .background(colorScheme == .dark ? Color(red: 0.52, green: 0.58, blue: 0.70) : Color.white.opacity(0.8))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(height: 150)
                                    .focused($isFieldFocused, equals: .message)
                            }

                            // Delivery time
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("compose.section.delivery_time", comment: ""))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                HStack {
//                                    
                                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                        .labelsHidden()
                                        .colorScheme(colorScheme == .dark ? .light : colorScheme)
                                }
                                .padding(12)
                                .background(colorScheme == .dark ? Color(red: 0.52, green: 0.58, blue: 0.70) : Color.white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            // Photos section
                            VStack(alignment: .leading, spacing: 8) {
                                Text(NSLocalizedString("compose.section.photos", comment: ""))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)

                                VStack(spacing: 12) {
                                    PhotoPickerView(data: $img1, label: NSLocalizedString("compose.photo1", comment: ""))
                                    PhotoPickerView(data: $img2, label: NSLocalizedString("compose.photo2", comment: ""))
                                }
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .onTapGesture {
                    // 點擊空白區域收起鍵盤
                    isFieldFocused = nil
                }
            }
            .navigationBarHidden(true)
            .alert(NSLocalizedString("compose.alert.error", comment: ""), isPresented: .constant(error != nil), actions: { Button(NSLocalizedString("compose.button.ok", comment: "")) { error = nil } }, message: { Text(error ?? "") })
            .fullScreenCover(isPresented: $showingConfirmation) {
                LetterSentConfirmationView {
                    showingConfirmation = false
                    dismiss()
                }
            }
        }
    }
    
    
    private func save() async {
        guard date >= Date().addingTimeInterval(-60) else { self.error = NSLocalizedString("compose.error.invalid_date", comment: ""); return }
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
            showingConfirmation = true
        } catch {
            print("🐛 Error saving: \(error.localizedDescription)")
            self.error = error.localizedDescription
            isSaving = false
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

import SwiftUI
import PhotosUI


struct NordicButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(NordicTheme.slate.opacity(0.9))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}


struct PhotoPickerView: View {
    @Binding var data: Data?
    @State private var item: PhotosPickerItem?
    
    
    var label: String
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                if let data, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill().frame(width: 84, height: 84).clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12).fill(.quaternary).frame(width: 84, height: 84).overlay(Image(systemName: "photo").imageScale(.large))
                }
                PhotosPicker(selection: $item, matching: .images, photoLibrary: .shared()) {
                    Label(NSLocalizedString("photo.choose", comment: ""), systemImage: "photo.on.rectangle")
                }
                if data != nil {
                    Button(role: .destructive) { data = nil } label: { Label(NSLocalizedString("photo.remove", comment: ""), systemImage: "trash") }
                }
            }
        }
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task { if let data = try? await newItem.loadTransferable(type: Data.self) { self.data = data } }
        }
    }
}

import Foundation
import SwiftData


@Model
final class Letter: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var body: String
    var createdAt: Date
    var deliverAt: Date
    var delivered: Bool
    var isRead: Bool
    var image1: Data? // JPEG/PNG data
    var image2: Data?
    
    
    init(id: String = UUID().uuidString, title: String, body: String, createdAt: Date = .now, deliverAt: Date, delivered: Bool = false, isRead: Bool = false, image1: Data? = nil, image2: Data? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.deliverAt = deliverAt
        self.delivered = delivered
        self.isRead = isRead
        self.image1 = image1
        self.image2 = image2
    }
}

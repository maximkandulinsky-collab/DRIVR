import Foundation
import SwiftData

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var make: String
    var model: String
    var year: Int
    var engine: String
    var nickname: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    @Attribute(.externalStorage) var imageData: Data?

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        engine: String,
        nickname: String,
        isActive: Bool = true,
        imageData: Data? = nil
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.engine = engine
        self.nickname = nickname
        self.isActive = isActive
        self.imageData = imageData
        self.createdAt = .now
        self.updatedAt = .now
    }
}

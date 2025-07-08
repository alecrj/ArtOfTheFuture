import Foundation
import PencilKit

struct Artwork: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    let createdAt: Date
    var modifiedAt: Date  // Changed from let to var
    let drawing: Data
    let thumbnailData: Data?
    let duration: TimeInterval
    let strokeCount: Int
    var tags: [String]
    var isFavorite: Bool
    let width: CGFloat
    let height: CGFloat
    
    init(
        id: String = UUID().uuidString,
        title: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        drawing: Data,
        thumbnailData: Data? = nil,
        duration: TimeInterval,
        strokeCount: Int,
        tags: [String] = [],
        isFavorite: Bool = false,
        width: CGFloat,
        height: CGFloat
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.drawing = drawing
        self.thumbnailData = thumbnailData
        self.duration = duration
        self.strokeCount = strokeCount
        self.tags = tags
        self.isFavorite = isFavorite
        self.width = width
        self.height = height
    }
    
    // Computed properties
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

// MARK: - Gallery Stats
struct GalleryStats {
    let totalArtworks: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let favoriteCount: Int
    let lastCreated: Date?
    let mostUsedTags: [String]
    
    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}

// MARK: - Gallery Service Protocol
protocol GalleryServiceProtocol {
    func loadArtworks() async -> [Artwork]
    func saveArtwork(_ artwork: Artwork) async throws
    func deleteArtwork(withId id: String) async throws
    func updateArtwork(_ artwork: Artwork) async throws
    func generateThumbnail(for drawing: PKDrawing, size: CGSize) async -> Data?
    func exportArtwork(_ artwork: Artwork) async throws -> URL
    func calculateStats() async -> GalleryStats
}
// MARK: - Relative Date Extension
extension Artwork {
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: modifiedAt, relativeTo: Date())
    }
}

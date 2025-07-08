import Foundation
import PencilKit

struct Artwork: Identifiable, Codable {
    let id: String
    let title: String
    var drawing: Data // PKDrawing data
    let createdAt: Date
    let modifiedAt: Date
    let thumbnailData: Data?
    let duration: TimeInterval // Time spent drawing
    let strokeCount: Int
    var tags: [String]
    var isFavorite: Bool
    
    // Metadata
    var width: CGFloat
    var height: CGFloat
    
    init(
        id: String = UUID().uuidString,
        title: String,
        drawing: Data,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        thumbnailData: Data? = nil,
        duration: TimeInterval = 0,
        strokeCount: Int = 0,
        tags: [String] = [],
        isFavorite: Bool = false,
        width: CGFloat = 768,
        height: CGFloat = 1024
    ) {
        self.id = id
        self.title = title
        self.drawing = drawing
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
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
    
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Gallery Collection Model
struct GalleryCollection: Identifiable, Codable {
    let id: String
    var name: String
    var artworkIds: [String]
    let createdAt: Date
    var icon: String // SF Symbol name
    var color: String // Hex color
    
    init(
        id: String = UUID().uuidString,
        name: String,
        artworkIds: [String] = [],
        createdAt: Date = Date(),
        icon: String = "folder.fill",
        color: String = "#007AFF"
    ) {
        self.id = id
        self.name = name
        self.artworkIds = artworkIds
        self.createdAt = createdAt
        self.icon = icon
        self.color = color
    }
}

// MARK: - Gallery Statistics
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
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Sort Options
enum ArtworkSortOption: String, CaseIterable {
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
    case titleAZ = "Title A-Z"
    case titleZA = "Title Z-A"
    case duration = "Longest First"
    case favorite = "Favorites First"
    
    var icon: String {
        switch self {
        case .dateNewest, .dateOldest: return "calendar"
        case .titleAZ, .titleZA: return "textformat"
        case .duration: return "clock"
        case .favorite: return "star"
        }
    }
}

// MARK: - View Style
enum GalleryViewStyle: String, CaseIterable {
    case grid = "Grid"
    case list = "List"
    case compact = "Compact"
    
    var icon: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        case .compact: return "square.grid.3x3"
        }
    }
}

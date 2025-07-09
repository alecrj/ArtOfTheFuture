
import Foundation

// This lets your app build and gets rid of missing type errors!
enum ArtworkSortOption: String, CaseIterable {
    case dateNewest = "Newest"
    case dateOldest = "Oldest"
    case titleAZ = "A-Z"
    case titleZA = "Z-A"
    case duration = "Duration"
    case favorite = "Favorite"

    var icon: String {
        switch self {
        case .dateNewest: return "arrow.down"
        case .dateOldest: return "arrow.up"
        case .titleAZ: return "textformat.abc"
        case .titleZA: return "textformat.abc"
        case .duration: return "clock"
        case .favorite: return "star"
        }
    }
}

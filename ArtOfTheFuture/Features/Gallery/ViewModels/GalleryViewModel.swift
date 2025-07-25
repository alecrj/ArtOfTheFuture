import Foundation
import SwiftUI
import PencilKit

@MainActor
final class GalleryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var artworks: [Artwork] = []
    @Published var filteredArtworks: [Artwork] = []
    @Published var searchText = ""
    @Published var sortOption: ArtworkSortOption = .dateNewest
    @Published var selectedTags: Set<String> = []
    @Published var showOnlyFavorites = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var stats = GalleryStats(
        totalArtworks: 0,
        totalDuration: 0,
        averageDuration: 0,
        favoriteCount: 0,
        lastCreated: nil,
        mostUsedTags: []
    )
    
    // MARK: - Services
    private let galleryService: GalleryServiceProtocol

    // MARK: - Computed Properties
    var allTags: [String] {
        let tags = artworks.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    var hasActiveFilters: Bool {
        !selectedTags.isEmpty || showOnlyFavorites
    }
    
    // MARK: - Initialization
    init(galleryService: GalleryServiceProtocol? = nil) {
        self.galleryService = galleryService ?? GalleryService()
        // No Combine/subscriptions needed
    }
    
    // MARK: - Data Loading
    func loadArtworks() async {
        isLoading = true
        errorMessage = nil
        do {
            let loadedArtworks = await galleryService.loadArtworks()
            self.artworks = loadedArtworks
            self.applyFiltersAndSort()
            await updateStats()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Filtering and Sorting
    private func applyFiltersAndSort() {
        var filtered = artworks
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { artwork in
                artwork.title.localizedCaseInsensitiveContains(searchText) ||
                artwork.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Tag filter
        if !selectedTags.isEmpty {
            filtered = filtered.filter { artwork in
                !selectedTags.isDisjoint(with: artwork.tags)
            }
        }
        
        // Favorites filter
        if showOnlyFavorites {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Sort
        switch sortOption {
        case .dateNewest:
            filtered.sort { $0.modifiedAt > $1.modifiedAt }
        case .dateOldest:
            filtered.sort { $0.modifiedAt < $1.modifiedAt }
        case .titleAZ:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .duration:
            filtered.sort { $0.duration > $1.duration }
        case .favorite:
            filtered.sort { artwork1, artwork2 in
                if artwork1.isFavorite == artwork2.isFavorite {
                    return artwork1.modifiedAt > artwork2.modifiedAt
                }
                return artwork1.isFavorite && !artwork2.isFavorite
            }
        }
        
        filteredArtworks = filtered
    }
    
    // MARK: - Artwork Actions
    func saveArtwork(title: String, drawing: PKDrawing, duration: TimeInterval) async {
        do {
            let thumbnailData = await galleryService.generateThumbnail(
                for: drawing,
                size: CGSize(width: 200, height: 200)
            )
            let artwork = Artwork(
                title: title.isEmpty ? "Untitled \(Date().formatted(date: .abbreviated, time: .shortened))" : title,
                drawing: drawing.dataRepresentation(),
                thumbnailData: thumbnailData,
                duration: duration,
                strokeCount: drawing.strokes.count,
                width: drawing.bounds.width,
                height: drawing.bounds.height
            )
            try await galleryService.saveArtwork(artwork)
            await HapticManager.shared.impact(.medium)
            await loadArtworks() // Refresh
        } catch {
            errorMessage = "Failed to save artwork: \(error.localizedDescription)"
        }
    }
    
    func updateArtwork(_ artwork: Artwork) async {
        do {
            try await galleryService.updateArtwork(artwork)
            await loadArtworks()
        } catch {
            errorMessage = "Failed to update artwork: \(error.localizedDescription)"
        }
    }
    
    func deleteArtwork(_ artwork: Artwork) async {
        do {
            await HapticManager.shared.impact(.light)
            try await galleryService.deleteArtwork(withId: artwork.id)
            await loadArtworks()
        } catch {
            errorMessage = "Failed to delete artwork: \(error.localizedDescription)"
        }
    }
    
    func toggleFavorite(for artwork: Artwork) async {
        var updatedArtwork = artwork
        updatedArtwork.isFavorite.toggle()
        await HapticManager.shared.impact(.light)
        await updateArtwork(updatedArtwork)
    }
    
    func duplicateArtwork(_ artwork: Artwork) async {
        do {
            let duplicatedArtwork = Artwork(
                title: "\(artwork.title) Copy",
                drawing: artwork.drawing,
                thumbnailData: artwork.thumbnailData,
                duration: artwork.duration,
                strokeCount: artwork.strokeCount,
                tags: artwork.tags,
                width: artwork.width,
                height: artwork.height
            )
            try await galleryService.saveArtwork(duplicatedArtwork)
            await HapticManager.shared.impact(.medium)
            await loadArtworks()
        } catch {
            errorMessage = "Failed to duplicate artwork: \(error.localizedDescription)"
        }
    }
    
    func shareArtwork(_ artwork: Artwork) async {
        do {
            let exportURL = try await galleryService.exportArtwork(artwork)
            await MainActor.run {
                let activityVC = UIActivityViewController(
                    activityItems: [exportURL],
                    applicationActivities: nil
                )
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    activityVC.popoverPresentationController?.sourceView = window
                    activityVC.popoverPresentationController?.sourceRect = CGRect(
                        x: window.bounds.midX,
                        y: window.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    rootVC.present(activityVC, animated: true)
                }
            }
        } catch {
            errorMessage = "Failed to share artwork: \(error.localizedDescription)"
        }
    }
    
    func renameArtwork(_ artwork: Artwork, newTitle: String) async {
        guard !newTitle.isEmpty else { return }
        var updatedArtwork = artwork
        updatedArtwork.title = newTitle
        await updateArtwork(updatedArtwork)
    }
    
    func updateTags(for artwork: Artwork, tags: [String]) async {
        var updatedArtwork = artwork
        updatedArtwork.tags = tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        await updateArtwork(updatedArtwork)
    }
    
    // MARK: - Statistics
    private func updateStats() async {
        stats = await galleryService.calculateStats()
    }
    
    // MARK: - Batch Operations
    func deleteMultipleArtworks(_ artworkIds: Set<String>) async {
        for id in artworkIds {
            if let artwork = artworks.first(where: { $0.id == id }) {
                await deleteArtwork(artwork)
            }
        }
    }
    
    func toggleFavoriteMultiple(_ artworkIds: Set<String>) async {
        for id in artworkIds {
            if let artwork = artworks.first(where: { $0.id == id }) {
                await toggleFavorite(for: artwork)
            }
        }
    }
}

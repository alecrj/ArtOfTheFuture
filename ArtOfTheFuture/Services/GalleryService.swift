import Foundation
import PencilKit
import UIKit
import AVFoundation  // Added for AVMakeRect

@MainActor
final class GalleryService: GalleryServiceProtocol {
    
    // MARK: - Properties
    private let fileManager = FileManager.default
    private var artworks: [Artwork] = []
    
    // MARK: - Paths
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var artworksDirectory: URL {
        documentsDirectory.appendingPathComponent("Artworks")
    }
    
    private var exportDirectory: URL {
        documentsDirectory.appendingPathComponent("Exports")
    }
    
    // MARK: - Initialization
    init() {
        setupDirectories()
    }
    
    private func setupDirectories() {
        try? fileManager.createDirectory(at: artworksDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Load Artworks
    func loadArtworks() async -> [Artwork] {
        guard let files = try? fileManager.contentsOfDirectory(at: artworksDirectory, includingPropertiesForKeys: nil) else {
            return []
        }
        
        let metadataFiles = files.filter { $0.pathExtension == "json" }
        
        var loadedArtworks: [Artwork] = []
        
        for metadataURL in metadataFiles {
            guard let data = try? Data(contentsOf: metadataURL),
                  let metadata = try? JSONDecoder().decode(ArtworkMetadata.self, from: data) else {
                continue
            }
            
            let drawingURL = artworksDirectory.appendingPathComponent("\(metadata.id).drawing")
            let thumbnailURL = artworksDirectory.appendingPathComponent("\(metadata.id).thumbnail")
            
            guard let drawingData = try? Data(contentsOf: drawingURL) else {
                continue
            }
            
            let thumbnailData = try? Data(contentsOf: thumbnailURL)
            
            let artwork = Artwork(
                id: metadata.id,
                title: metadata.title,
                createdAt: metadata.createdAt,
                modifiedAt: metadata.modifiedAt,
                drawing: drawingData,
                thumbnailData: thumbnailData,
                duration: metadata.duration,
                strokeCount: metadata.strokeCount,
                tags: metadata.tags,
                isFavorite: metadata.isFavorite,
                width: metadata.width,
                height: metadata.height
            )
            
            loadedArtworks.append(artwork)
        }
        
        // Sort by creation date (newest first)
        loadedArtworks.sort { $0.createdAt > $1.createdAt }
        
        // Cache in memory
        self.artworks = loadedArtworks
        
        return loadedArtworks
    }
    
    // MARK: - Save Artwork
    func saveArtwork(_ artwork: Artwork) async throws {
        // Create metadata
        let metadata = ArtworkMetadata(from: artwork)
        
        // Save files
        let metadataURL = artworksDirectory.appendingPathComponent("\(artwork.id).json")
        let drawingURL = artworksDirectory.appendingPathComponent("\(artwork.id).drawing")
        let thumbnailURL = artworksDirectory.appendingPathComponent("\(artwork.id).thumbnail")
        
        // Save metadata
        let metadataData = try JSONEncoder().encode(metadata)
        try metadataData.write(to: metadataURL)
        
        // Save drawing
        try artwork.drawing.write(to: drawingURL)
        
        // Save thumbnail if available
        if let thumbnailData = artwork.thumbnailData {
            try thumbnailData.write(to: thumbnailURL)
        }
        
        // Update cache
        if let index = artworks.firstIndex(where: { $0.id == artwork.id }) {
            artworks[index] = artwork
        } else {
            artworks.append(artwork)
            artworks.sort { $0.createdAt > $1.createdAt }
        }
    }
    
    // MARK: - Delete Artwork
    func deleteArtwork(withId id: String) async throws {
        let metadataURL = artworksDirectory.appendingPathComponent("\(id).json")
        let drawingURL = artworksDirectory.appendingPathComponent("\(id).drawing")
        let thumbnailURL = artworksDirectory.appendingPathComponent("\(id).thumbnail")
        
        try? fileManager.removeItem(at: metadataURL)
        try? fileManager.removeItem(at: drawingURL)
        try? fileManager.removeItem(at: thumbnailURL)
        
        // Update cache
        await MainActor.run {
            artworks.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Update Artwork
    func updateArtwork(_ artwork: Artwork) async throws {
        try await saveArtwork(artwork)
    }
    
    // MARK: - Generate Thumbnail
    func generateThumbnail(for drawing: PKDrawing, size: CGSize) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let scale = UIScreen.main.scale
                let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
                
                let image = drawing.image(from: drawing.bounds, scale: scale)
                
                UIGraphicsBeginImageContextWithOptions(scaledSize, false, scale)
                defer { UIGraphicsEndImageContext() }
                
                guard let context = UIGraphicsGetCurrentContext() else {
                    continuation.resume(returning: Data())  // Fixed: return empty Data instead of nil
                    return
                }
                
                // White background
                context.setFillColor(UIColor.systemBackground.cgColor)
                context.fill(CGRect(origin: .zero, size: scaledSize))
                
                // Draw the image - Fixed: using AVMakeRect
                let drawRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: scaledSize))
                image.draw(in: drawRect)
                
                guard let thumbnail = UIGraphicsGetImageFromCurrentImageContext(),
                      let data = thumbnail.jpegData(compressionQuality: 0.8) else {
                    continuation.resume(returning: Data())  // Fixed: return empty Data instead of nil
                    return
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    // MARK: - Export Artwork
    func exportArtwork(_ artwork: Artwork) async throws -> URL {
        guard let drawing = try? PKDrawing(data: artwork.drawing) else {
            throw GalleryError.invalidDrawingData
        }
        
        let image = drawing.image(from: drawing.bounds, scale: 2.0)
        guard let pngData = image.pngData() else {
            throw GalleryError.exportFailed
        }
        
        let filename = "\(artwork.title.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970).png"
        let exportURL = exportDirectory.appendingPathComponent(filename)
        
        try pngData.write(to: exportURL)
        
        return exportURL
    }
    
    // MARK: - Statistics
    func calculateStats() async -> GalleryStats {
        let artworks = self.artworks
        
        let totalDuration = artworks.reduce(0) { $0 + $1.duration }
        let favoriteCount = artworks.filter { $0.isFavorite }.count
        let lastCreated = artworks.map { $0.createdAt }.max()
        
        // Calculate most used tags
        var tagCounts: [String: Int] = [:]
        for artwork in artworks {
            for tag in artwork.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        let mostUsedTags = tagCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return GalleryStats(
            totalArtworks: artworks.count,
            totalDuration: totalDuration,
            averageDuration: artworks.isEmpty ? 0 : totalDuration / Double(artworks.count),
            favoriteCount: favoriteCount,
            lastCreated: lastCreated,
            mostUsedTags: Array(mostUsedTags)
        )
    }
}

// MARK: - Supporting Types
private struct ArtworkMetadata: Codable {
    let id: String
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let duration: TimeInterval
    let strokeCount: Int
    let tags: [String]
    let isFavorite: Bool
    let width: CGFloat
    let height: CGFloat
    
    init(from artwork: Artwork) {
        self.id = artwork.id
        self.title = artwork.title
        self.createdAt = artwork.createdAt
        self.modifiedAt = artwork.modifiedAt
        self.duration = artwork.duration
        self.strokeCount = artwork.strokeCount
        self.tags = artwork.tags
        self.isFavorite = artwork.isFavorite
        self.width = artwork.width
        self.height = artwork.height
    }
}

// MARK: - Errors
enum GalleryError: LocalizedError {
    case artworkNotFound
    case invalidDrawingData
    case exportFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .artworkNotFound:
            return "Artwork not found"
        case .invalidDrawingData:
            return "Invalid drawing data"
        case .exportFailed:
            return "Failed to export artwork"
        case .saveFailed:
            return "Failed to save artwork"
        }
    }
}

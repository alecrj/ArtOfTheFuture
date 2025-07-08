import Foundation
import PencilKit
import UIKit
import Combine

// MARK: - Gallery Service Protocol
protocol GalleryServiceProtocol {
    func saveArtwork(_ artwork: Artwork) async throws
    func loadArtwork(id: String) async throws -> Artwork
    func loadAllArtworks() async throws -> [Artwork]
    func deleteArtwork(id: String) async throws
    func updateArtwork(_ artwork: Artwork) async throws
    func generateThumbnail(for drawing: PKDrawing, size: CGSize) async -> Data?
    func exportArtwork(_ artwork: Artwork) async throws -> URL
    var artworksPublisher: AnyPublisher<[Artwork], Never> { get }
}

// MARK: - Gallery Service Implementation
final class GalleryService: GalleryServiceProtocol {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let artworksDirectory: URL
    private let thumbnailsDirectory: URL
    private let exportDirectory: URL
    
    @Published private var artworks: [Artwork] = []
    var artworksPublisher: AnyPublisher<[Artwork], Never> {
        $artworks.eraseToAnyPublisher()
    }
    
    init() {
        // Setup directories
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        artworksDirectory = documentsDirectory.appendingPathComponent("Artworks")
        thumbnailsDirectory = documentsDirectory.appendingPathComponent("Thumbnails")
        exportDirectory = documentsDirectory.appendingPathComponent("Exports")
        
        // Create directories if they don't exist
        createDirectoriesIfNeeded()
        
        // Load existing artworks
        Task {
            try? await loadAllArtworksIntoMemory()
        }
    }
    
    private func createDirectoriesIfNeeded() {
        let directories = [artworksDirectory, thumbnailsDirectory, exportDirectory]
        
        for directory in directories {
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
        }
    }
    
    // MARK: - Save Artwork
    func saveArtwork(_ artwork: Artwork) async throws {
        // Save drawing data
        let drawingURL = artworksDirectory.appendingPathComponent("\(artwork.id).drawing")
        try artwork.drawing.write(to: drawingURL)
        
        // Save thumbnail if available
        if let thumbnailData = artwork.thumbnailData {
            let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(artwork.id).jpg")
            try thumbnailData.write(to: thumbnailURL)
        }
        
        // Save metadata
        let metadataURL = artworksDirectory.appendingPathComponent("\(artwork.id).json")
        let metadata = ArtworkMetadata(from: artwork)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let metadataData = try encoder.encode(metadata)
        try metadataData.write(to: metadataURL)
        
        // Update in-memory cache
        await MainActor.run {
            if let index = artworks.firstIndex(where: { $0.id == artwork.id }) {
                artworks[index] = artwork
            } else {
                artworks.append(artwork)
            }
        }
    }
    
    // MARK: - Load Artwork
    func loadArtwork(id: String) async throws -> Artwork {
        // Check cache first
        if let cached = artworks.first(where: { $0.id == id }) {
            return cached
        }
        
        // Load from disk
        let drawingURL = artworksDirectory.appendingPathComponent("\(id).drawing")
        let metadataURL = artworksDirectory.appendingPathComponent("\(id).json")
        
        guard fileManager.fileExists(atPath: drawingURL.path),
              fileManager.fileExists(atPath: metadataURL.path) else {
            throw GalleryError.artworkNotFound
        }
        
        let drawingData = try Data(contentsOf: drawingURL)
        let metadataData = try Data(contentsOf: metadataURL)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let metadata = try decoder.decode(ArtworkMetadata.self, from: metadataData)
        
        // Load thumbnail if exists
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(id).jpg")
        let thumbnailData = try? Data(contentsOf: thumbnailURL)
        
        let artwork = Artwork(
            id: metadata.id,
            title: metadata.title,
            drawing: drawingData,
            createdAt: metadata.createdAt,
            modifiedAt: metadata.modifiedAt,
            thumbnailData: thumbnailData,
            duration: metadata.duration,
            strokeCount: metadata.strokeCount,
            tags: metadata.tags,
            isFavorite: metadata.isFavorite,
            width: metadata.width,
            height: metadata.height
        )
        
        return artwork
    }
    
    // MARK: - Load All Artworks
    func loadAllArtworks() async throws -> [Artwork] {
        return artworks
    }
    
    private func loadAllArtworksIntoMemory() async throws {
        let contents = try fileManager.contentsOfDirectory(at: artworksDirectory, includingPropertiesForKeys: nil)
        let metadataFiles = contents.filter { $0.pathExtension == "json" }
        
        var loadedArtworks: [Artwork] = []
        
        for metadataURL in metadataFiles {
            let id = metadataURL.deletingPathExtension().lastPathComponent
            if let artwork = try? await loadArtwork(id: id) {
                loadedArtworks.append(artwork)
            }
        }
        
        await MainActor.run {
            self.artworks = loadedArtworks.sorted { $0.modifiedAt > $1.modifiedAt }
        }
    }
    
    // MARK: - Delete Artwork
    func deleteArtwork(id: String) async throws {
        // Delete files
        let drawingURL = artworksDirectory.appendingPathComponent("\(id).drawing")
        let metadataURL = artworksDirectory.appendingPathComponent("\(id).json")
        let thumbnailURL = thumbnailsDirectory.appendingPathComponent("\(id).jpg")
        
        try? fileManager.removeItem(at: drawingURL)
        try? fileManager.removeItem(at: metadataURL)
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
                    continuation.resume(returning: nil)
                    return
                }
                
                // White background
                context.setFillColor(UIColor.systemBackground.cgColor)
                context.fill(CGRect(origin: .zero, size: scaledSize))
                
                // Draw the image
                let drawRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: scaledSize))
                image.draw(in: drawRect)
                
                guard let thumbnail = UIGraphicsGetImageFromCurrentImageContext(),
                      let data = thumbnail.jpegData(compressionQuality: 0.8) else {
                    continuation.resume(returning: nil)
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

import SwiftUI
import PencilKit
enum GalleryViewStyle: String, CaseIterable {
    case grid
    case list
    case compact

    var icon: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        case .compact: return "rectangle.grid.1x2"
        }
    }

    var rawValue: String {
        switch self {
        case .grid: return "Grid"
        case .list: return "List"
        case .compact: return "Compact"
        }
    }
}


struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @State private var searchText = ""
    @State private var selectedViewStyle: GalleryViewStyle = .grid
    @State private var selectedSortOption: ArtworkSortOption = .dateNewest
    @State private var showingFilterSheet = false
    @State private var selectedArtwork: Artwork?
    @State private var showingArtworkDetail = false
    @State private var showingStats = false
    
    // Grid layout
    private let gridColumns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    private let compactColumns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.filteredArtworks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Stats Card
                            if !searchText.isEmpty || viewModel.filteredArtworks.count > 3 {
                                statsCard
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            }
                            
                            // Artwork Grid/List
                            switch selectedViewStyle {
                            case .grid:
                                gridView
                            case .list:
                                listView
                            case .compact:
                                compactView
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search artworks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingStats.toggle() }) {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        // View Style Options
                        Section("View Style") {
                            ForEach(GalleryViewStyle.allCases, id: \.self) { style in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedViewStyle = style
                                    }
                                }) {
                                    Label(style.rawValue, systemImage: style.icon)
                                }
                            }
                        }
                        
                        // Sort Options
                        Section("Sort By") {
                            ForEach(ArtworkSortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedSortOption = option
                                    viewModel.sortOption = option
                                }) {
                                    Label(option.rawValue, systemImage: option.icon)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    
                    Button(action: { showingFilterSheet.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(viewModel.hasActiveFilters ? .fill : .none)
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                GalleryStatsView(stats: viewModel.stats)
            }
            .sheet(item: $selectedArtwork) { artwork in
                ArtworkDetailView(artwork: artwork, viewModel: viewModel)
            }
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
            }
            .task {
                await viewModel.loadArtworks()
            }
        }
    }
    
    // MARK: - Grid View
    private var gridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(viewModel.filteredArtworks) { artwork in
                ArtworkGridItem(artwork: artwork)
                    .onTapGesture {
                        selectedArtwork = artwork
                    }
                    .contextMenu {
                        artworkContextMenu(for: artwork)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - List View
    private var listView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredArtworks) { artwork in
                ArtworkListItem(artwork: artwork)
                    .onTapGesture {
                        selectedArtwork = artwork
                    }
                    .contextMenu {
                        artworkContextMenu(for: artwork)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Compact View
    private var compactView: some View {
        LazyVGrid(columns: compactColumns, spacing: 12) {
            ForEach(viewModel.filteredArtworks) { artwork in
                ArtworkCompactItem(artwork: artwork)
                    .onTapGesture {
                        selectedArtwork = artwork
                    }
                    .contextMenu {
                        artworkContextMenu(for: artwork)
                    }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 20) {
            StatItem(
                icon: "photo.stack",
                value: "\(viewModel.filteredArtworks.count)",
                label: "Artworks"
            )
            
            Divider()
                .frame(height: 30)
            
            StatItem(
                icon: "clock",
                value: viewModel.stats.formattedTotalDuration,
                label: "Total Time"
            )
            
            Divider()
                .frame(height: 30)
            
            StatItem(
                icon: "star.fill",
                value: "\(viewModel.stats.favoriteCount)",
                label: "Favorites"
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Artworks Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start creating your first masterpiece!")
                .foregroundColor(.secondary)
            
            Button(action: {
                // Navigate to drawing view
            }) {
                Label("Create Artwork", systemImage: "paintbrush.fill")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Context Menu
    @ViewBuilder
    private func artworkContextMenu(for artwork: Artwork) -> some View {
        Button(action: {
            Task {
                await viewModel.toggleFavorite(for: artwork)
            }
        }) {
            Label(artwork.isFavorite ? "Unfavorite" : "Favorite",
                  systemImage: artwork.isFavorite ? "star.slash" : "star")
        }
        
        Button(action: {
            Task {
                await viewModel.duplicateArtwork(artwork)
            }
        }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Button(action: {
            Task {
                await viewModel.shareArtwork(artwork)
            }
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        Divider()
        
        Button(role: .destructive, action: {
            Task {
                await viewModel.deleteArtwork(artwork)
            }
        }) {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Grid Item View
struct ArtworkGridItem: View {
    let artwork: Artwork
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            ZStack {
                if let thumbnailData = artwork.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
                
                // Favorite Badge
                if artwork.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(artwork.relativeDate)
                    Spacer()
                    Text(artwork.formattedDuration)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - List Item View
struct ArtworkListItem: View {
    let artwork: Artwork
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let thumbnailData = artwork.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(artwork.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if artwork.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(artwork.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(artwork.formattedDuration, systemImage: "clock")
                    Spacer()
                    Label("\(artwork.strokeCount)", systemImage: "scribble")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Compact Item View
struct ArtworkCompactItem: View {
    let artwork: Artwork
    
    var body: some View {
        VStack(spacing: 6) {
            // Thumbnail
            ZStack {
                if let thumbnailData = artwork.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                
                if artwork.isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                                .padding(4)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            .cornerRadius(8)
            
            Text(artwork.title)
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    GalleryView()
}

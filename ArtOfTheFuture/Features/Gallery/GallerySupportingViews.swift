import SwiftUI
import PencilKit

// MARK: - Filter Sheet
struct FilterSheet: View {
    @ObservedObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Favorites Filter
                Section {
                    Toggle("Show Only Favorites", isOn: $viewModel.showOnlyFavorites)
                }
                
                // Tags Filter
                if !viewModel.allTags.isEmpty {
                    Section("Filter by Tags") {
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Spacer()
                                if viewModel.selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    if viewModel.selectedTags.contains(tag) {
                                        viewModel.selectedTags.remove(tag)
                                    } else {
                                        viewModel.selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Clear Filters
                if viewModel.hasActiveFilters {
                    Section {
                        Button("Clear All Filters") {
                            withAnimation {
                                viewModel.selectedTags.removeAll()
                                viewModel.showOnlyFavorites = false
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Artwork Detail View
struct ArtworkDetailView: View {
    let artwork: Artwork
    @ObservedObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var isEditingTags = false
    @State private var tagInput = ""
    @State private var showingDeleteAlert = false
    @State private var showingDrawingView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Artwork Image
                    if let drawing = try? PKDrawing(data: artwork.drawing) {
                        GeometryReader { geometry in
                            DrawingPreview(drawing: drawing)
                                .frame(width: geometry.size.width, height: geometry.size.width * (artwork.height / artwork.width))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        }
                        .aspectRatio(artwork.width / artwork.height, contentMode: .fit)
                    }
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if isEditingTitle {
                                TextField("Artwork Title", text: $editedTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        saveTitle()
                                    }
                                
                                Button("Save") {
                                    saveTitle()
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Text(artwork.title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Button(action: {
                                    editedTitle = artwork.title
                                    isEditingTitle = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await viewModel.toggleFavorite(for: artwork)
                                    dismiss()
                                }
                            }) {
                                Image(systemName: artwork.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(artwork.isFavorite ? .yellow : .gray)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Cards
                    VStack(spacing: 16) {
                        InfoCard(
                            icon: "calendar",
                            title: "Created",
                            value: artwork.formattedDate,
                            color: .blue
                        )
                        
                        HStack(spacing: 16) {
                            InfoCard(
                                icon: "clock",
                                title: "Duration",
                                value: artwork.formattedDuration,
                                color: .orange
                            )
                            
                            InfoCard(
                                icon: "scribble",
                                title: "Strokes",
                                value: "\(artwork.strokeCount)",
                                color: .purple
                            )
                        }
                        
                        InfoCard(
                            icon: "square.dashed",
                            title: "Dimensions",
                            value: "\(Int(artwork.width)) × \(Int(artwork.height))",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Tags")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                isEditingTags.toggle()
                            }) {
                                Text(isEditingTags ? "Done" : "Edit")
                                    .font(.caption)
                            }
                        }
                        
                        if isEditingTags {
                            HStack {
                                TextField("Add tag", text: $tagInput)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button("Add", action: addTag)
                                    .buttonStyle(.bordered)
                            }
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(artwork.tags, id: \.self) { tag in
                                TagChip(tag: tag, isEditing: isEditingTags) {
                                    removeTag(tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingDrawingView = true
                        }) {
                            Label("Continue Drawing", systemImage: "paintbrush")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await viewModel.duplicateArtwork(artwork)
                                    dismiss()
                                }
                            }) {
                                Label("Duplicate", systemImage: "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                Task {
                                    await viewModel.shareArtwork(artwork)
                                }
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete Artwork", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Artwork?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteArtwork(artwork)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
            .fullScreenCover(isPresented: $showingDrawingView) {
                // Navigate to drawing view with existing artwork
                Text("Drawing View Placeholder")
            }
        }
    }
    
    private func saveTitle() {
        Task {
            await viewModel.renameArtwork(artwork, newTitle: editedTitle)
            isEditingTitle = false
            dismiss()
        }
    }
    
    private func addTag() {
        guard !tagInput.isEmpty else { return }
        
        var updatedTags = artwork.tags
        if !updatedTags.contains(tagInput) {
            updatedTags.append(tagInput)
            Task {
                await viewModel.updateTags(for: artwork, tags: updatedTags)
            }
        }
        tagInput = ""
    }
    
    private func removeTag(_ tag: String) {
        var updatedTags = artwork.tags
        updatedTags.removeAll { $0 == tag }
        Task {
            await viewModel.updateTags(for: artwork, tags: updatedTags)
        }
    }
}

// MARK: - Drawing Preview
struct DrawingPreview: View {
    let drawing: PKDrawing
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: drawing.image(from: drawing.bounds, scale: 2.0))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(.systemBackground))
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    let isEditing: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
            
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray5))
        .cornerRadius(16)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                     y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                
                x += size.width + spacing
                maxHeight = max(maxHeight, size.height)
                
                self.size.width = max(self.size.width, x - spacing)
            }
            
            self.size.height = y + maxHeight
        }
    }
}

// MARK: - Gallery Stats View
struct GalleryStatsView: View {
    let stats: GalleryStats
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Section
                    VStack(spacing: 16) {
                        Text("Gallery Overview")
                            .font(.headline)
                        
                        StatsGrid(stats: stats)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Most Used Tags
                    if !stats.mostUsedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Tags")
                                .font(.headline)
                            
                            ForEach(stats.mostUsedTags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Recent Activity
                    if let lastCreated = stats.lastCreated {
                        VStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                            
                            Text("Last artwork created")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(lastCreated.formatted(date: .abbreviated, time: .shortened))
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Gallery Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatsGrid: View {
    let stats: GalleryStats
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "photo.stack",
                label: "Total Artworks",
                value: "\(stats.totalArtworks)",
                color: .blue
            )
            
            StatCard(
                title: "Total Time",
                value: stats.formattedTotalDuration,
                icon: "clock.fill",
                color: .orange
            )
            
            StatCard(
                title: "Favorites",
                value: "\(stats.favoriteCount)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "Avg. Duration",
                value: formatDuration(stats.averageDuration),
                icon: "chart.bar.fill",
                color: .purple
            )
        }
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

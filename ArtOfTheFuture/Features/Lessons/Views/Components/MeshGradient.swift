// MARK: - MeshGradient Fallback
// File: ArtOfTheFuture/Features/Lessons/Views/Components/MeshGradient.swift

import SwiftUI
import simd

struct MeshGradient: View {
    let width: Int
    let height: Int
    let points: [[Float]]
    let colors: [Color]
    
    var body: some View {
        if #available(iOS 18.0, *) {
            SwiftUI.MeshGradient(
                width: width,
                height: height,
                points: convertToSIMDPoints(points),
                colors: colors
            )
        } else {
            LinearGradient(
                colors: [
                    colors.first ?? .blue,
                    colors[safe: colors.count / 2] ?? .purple,
                    colors.last ?? .orange
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func convertToSIMDPoints(_ array: [[Float]]) -> [SIMD2<Float>] {
        array.compactMap { pair in
            guard pair.count == 2 else { return nil }
            return SIMD2<Float>(pair[0], pair[1])
        }
    }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

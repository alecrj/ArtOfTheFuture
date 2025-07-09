import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var isActive = false

    var body: some View {
        if isActive {
            HomeDashboardView()
        } else {
            VStack(spacing: 20) {
                Image("iconv1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("Pikaso")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    self.scale = 1.0
                    self.opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

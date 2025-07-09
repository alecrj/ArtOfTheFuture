import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Pikaso")
                    .font(.largeTitle)
                    .bold()
                
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Learn • Draw • Create")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
}

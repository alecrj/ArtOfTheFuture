import SwiftUI

struct ChallengesView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Daily Challenges")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming Soon!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Complete daily art challenges\nand compete with others")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Challenges")
        }
    }
}

#Preview {
    ChallengesView()
}

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView() // FIXED: Changed from HomeView() to HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            LessonsView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(1)
            
            DrawingView()
                .tabItem {
                    Label("Draw", systemImage: "paintbrush.fill")
                }
                .tag(2)
            
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "flag.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}

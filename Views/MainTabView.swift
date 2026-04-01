import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "wand.and.stars")
                }
                .tag(0)
            
            GearView()
                .tabItem {
                    Label("Gear", systemImage: "shield")
                }
                .tag(1)
            
            BuildsListView()
                .tabItem {
                    Label("Builds", systemImage: "person.3")
                }
                .tag(2)
            
            ProgressView_()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
                .tag(3)
        }
        .tint(Color(hex: "e07020"))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

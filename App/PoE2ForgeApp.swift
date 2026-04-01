import SwiftUI

@main
struct PoE2ForgeApp: App {
    @StateObject private var gameData = GameDataService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gameData)
                .preferredColorScheme(.dark)
        }
    }
}

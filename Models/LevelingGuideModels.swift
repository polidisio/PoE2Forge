import Foundation

// MARK: - Leveling Guide Entry
struct LevelingGuideEntry: Identifiable, Codable {
    var id: Int { level }
    let level: Int
    let act: Int
    let title: String
    let description: String
    let suggestedNodes: [String]
    let notes: String
}

// MARK: - Leveling Guide
struct LevelingGuide {
    let entries: [LevelingGuideEntry]

    static let defaultGuide: [LevelingGuideEntry] = [
        // Act 1
        LevelingGuideEntry(level: 1, act: 1, title: "Act 1 Start", description: "Start with your basic skill. Focus on completing the campaign.", suggestedNodes: [], notes: "Don't worry about passive tree much early on."),
        LevelingGuideEntry(level: 4, act: 1, title: "First Passive Points", description: "You now have 3 passive points. Focus on damage or defense based on your skill.", suggestedNodes: ["str_start", "dex_start", "int_start"], notes: "Pick the start node for your main stat."),
        LevelingGuideEntry(level: 10, act: 1, title: "Mid Act 1", description: "Consider grabbing life nodes if you're taking damage.", suggestedNodes: [], notes: "Look for gear with life resist."),
        LevelingGuideEntry(level: 15, act: 1, title: "Act 1 Complete", description: "End of Act 1. Ensure you have enough damage to kill bosses.", suggestedNodes: [], notes: "Buy new gems from vendor if available."),

        // Act 2
        LevelingGuideEntry(level: 18, act: 2, title: "Act 2 Start", description: "New area types. Magic find is helpful here.", suggestedNodes: [], notes: "Look for items with resistances."),
        LevelingGuideEntry(level: 24, act: 2, title: "Mid Act 2", description: "You should have 9 passive points. Focus on your build's core nodes.", suggestedNodes: [], notes: "Consider your first notable passive."),
        LevelingGuideEntry(level: 28, act: 2, title: "Act 2 Complete", description: "Time for Act 3. Make sure your resistances are decent.", suggestedNodes: [], notes: "Resistances help a lot in later acts."),

        // Act 3
        LevelingGuideEntry(level: 32, act: 3, title: "Act 3 Start", description: "More complex zones. Bosses hit harder.", suggestedNodes: [], notes: "Stack resistances if dying often."),
        LevelingGuideEntry(level: 38, act: 3, title: "Mid Act 3", description: "15 passive points now. Build starts coming together.", suggestedNodes: [], notes: "Look for gear with linked colors."),
        LevelingGuideEntry(level: 45, act: 3, title: "Act 3 Complete", description: "Crucible is challenging. Make sure your build scales.", suggestedNodes: [], notes: "This is where many builds get stuck."),

        // Act 4
        LevelingGuideEntry(level: 50, act: 4, title: "Act 4 Start", description: "Monster damage increases significantly.", suggestedNodes: [], notes: "Health and resists are crucial."),
        LevelingGuideEntry(level: 55, act: 4, title: "Act 4 Complete", description: "Ready for endgame maps. Make sure you're happy with your build.", suggestedNodes: [], notes: "This is the real start of PoE2."),

        // General
        LevelingGuideEntry(level: 60, act: 5, title: "Maps Start", description: "Endgame begins. Focus on building your character properly.", suggestedNodes: [], notes: "Trading becomes important."),
        LevelingGuideEntry(level: 70, act: 6, title: "Mid Maps", description: "You're inMaps now. Keep upgrading gear.", suggestedNodes: [], notes: "Chaos resistance helps in higher maps."),
        LevelingGuideEntry(level: 80, act: 7, title: "High Maps", description: "T15+ requires solid defenses.", suggestedNodes: [], notes: "Consider aurabots or support characters."),
        LevelingGuideEntry(level: 90, act: 8, title: "Endgame", description: "Endgame content. Your build should be fully optimized.", suggestedNodes: [], notes: "Enjoy the journey!")
    ]

    static func entriesForLevel(_ level: Int) -> [LevelingGuideEntry] {
        defaultGuide.filter { $0.level <= level }
    }

    static func nextMilestone(afterLevel level: Int) -> LevelingGuideEntry? {
        defaultGuide.first { $0.level > level }
    }
}

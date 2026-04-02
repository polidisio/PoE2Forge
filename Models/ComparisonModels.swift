import Foundation

// MARK: - Item Stats (extracted from weapon/armor for comparison)
struct ItemStats: Equatable {
    var damageMin: Int = 0
    var damageMax: Int = 0
    var aps: Double = 0
    var defense: Int = 0
    var level: Int = 0
    var strength: Int = 0
    var dexterity: Int = 0
    var intelligence: Int = 0

    var damageRange: String {
        if damageMin == 0 && damageMax == 0 { return "N/A" }
        return "\(damageMin)-\(damageMax)"
    }

    var totalDamage: Int { damageMin + damageMax }

    static func from(weapon: Weapon) -> ItemStats {
        var stats = ItemStats()
        let parts = weapon.damage.split(separator: "-")
        if parts.count == 2 {
            stats.damageMin = Int(parts[0]) ?? 0
            stats.damageMax = Int(parts[1]) ?? 0
        }
        stats.aps = Double(weapon.aps) ?? 0
        stats.level = weapon.requirements.level
        stats.strength = weapon.requirements.strength ?? 0
        stats.dexterity = weapon.requirements.dexterity ?? 0
        stats.intelligence = weapon.requirements.intelligence ?? 0
        return stats
    }

    static func from(armor: Armor) -> ItemStats {
        var stats = ItemStats()
        stats.defense = Int(armor.defense) ?? 0
        stats.level = armor.requirements.level
        stats.strength = armor.requirements.strength ?? 0
        stats.dexterity = armor.requirements.dexterity ?? 0
        stats.intelligence = armor.requirements.intelligence ?? 0
        return stats
    }
}

// MARK: - Single Stat Difference
struct StatDiff: Identifiable, Equatable {
    let id = UUID()
    let statName: String
    let oldValue: Int
    let newValue: Int

    var diff: Int { newValue - oldValue }

    var isImprovement: Bool { diff > 0 }
    var isWorse: Bool { diff < 0 }
    var isSame: Bool { diff == 0 }

    var diffText: String {
        if diff > 0 { return "+\(diff)" }
        if diff < 0 { return "\(diff)" }
        return "0"
    }

    static func == (lhs: StatDiff, rhs: StatDiff) -> Bool {
        lhs.statName == rhs.statName && lhs.oldValue == rhs.oldValue && lhs.newValue == rhs.newValue
    }
}

// MARK: - Item Comparison Result
struct ItemComparison: Equatable {
    let itemName: String
    let isWeapon: Bool
    let oldStats: ItemStats?
    let newStats: ItemStats
    let statDiffs: [StatDiff]

    var hasOldItem: Bool { oldStats != nil }

    var overallDiff: Int {
        statDiffs.reduce(0) { $0 + $1.diff }
    }

    var isImprovement: Bool { overallDiff > 0 }
    var isWorse: Bool { overallDiff < 0 }

    // Summary text
    var summaryText: String {
        guard let old = oldStats else { return "New item" }
        if isImprovement { return "Better (\(overallDiff > 0 ? "+" : "")\(overallDiff))" }
        if isWorse { return "Worse (\(overallDiff))" }
        return "Same"
    }
}

import Foundation

// MARK: - Passive Skill Node Type
enum PassiveNodeType: String, Codable {
    case start
    case minor
    case notable
    case keystone

    var displayName: String {
        switch self {
        case .start: return "Start"
        case .minor: return "Minor"
        case .notable: return "Notable"
        case .keystone: return "Keystone"
        }
    }

    var color: String {
        switch self {
        case .start: return "#ffffff"
        case .minor: return "#9d9d9d"
        case .notable: return "#ffff77"
        case .keystone: return "#af6025"
        }
    }
}

// MARK: - Node Position
struct NodePosition: Codable {
    let x: Double
    let y: Double
}

// MARK: - Passive Skill Node
struct PassiveSkillNode: Codable, Identifiable {
    let id: String
    let name: String
    let type: PassiveNodeType
    let stats: [String: Int]
    let position: NodePosition
    let connections: [String]
    let tier: Int

    var rarityColor: String {
        switch type {
        case .start: return "#ffffff"
        case .minor: return "#9d9d9d"
        case .notable: return "#ffff77"
        case .keystone: return "#af6025"
        }
    }

    func hasPercentBonus() -> Bool {
        stats["percent"] == 1
    }

    func getPrimaryStat() -> (String, Int) {
        if let strength = stats["strength"] { return ("Strength", strength) }
        if let dexterity = stats["dexterity"] { return ("Dexterity", dexterity) }
        if let intelligence = stats["intelligence"] { return ("Intelligence", intelligence) }
        if let meleeDamage = stats["meleeDamage"] { return ("Melee Damage", meleeDamage) }
        if let projectileDamage = stats["projectileDamage"] { return ("Projectile Damage", projectileDamage) }
        if let spellDamage = stats["spellDamage"] { return ("Spell Damage", spellDamage) }
        if let elementalDamage = stats["elementalDamage"] { return ("Elemental Damage", elementalDamage) }
        if let armor = stats["armor"] { return ("Armor", armor) }
        if let evasion = stats["evasion"] { return ("Evasion", evasion) }
        if let minionDamage = stats["minionDamage"] { return ("Minion Damage", minionDamage) }
        if let minionLife = stats["minionLife"] { return ("Minion Life", minionLife) }
        if let maxMana = stats["maxMana"] { return ("Max Mana", maxMana) }
        if let castSpeed = stats["castSpeed"] { return ("Cast Speed", castSpeed) }
        if let attackSpeed = stats["attackSpeed"] { return ("Attack Speed", attackSpeed) }
        if let lifeOnHit = stats["lifeOnHit"] { return ("Life on Hit", lifeOnHit) }
        if let dodgeChance = stats["dodgeChance"] { return ("Dodge Chance", dodgeChance) }
        if let chainCount = stats["chainCount"] { return ("Chain", chainCount) }
        if let projectileSpeed = stats["projectileSpeed"] { return ("Projectile Speed", projectileSpeed) }
        if let critMultiplier = stats["critMultiplier"] { return ("Crit Multiplier", critMultiplier) }
        if let elementalPenetration = stats["elementalPenetration"] { return ("Ele Penetration", elementalPenetration) }
        if let bowDamage = stats["bowDamage"] { return ("Bow Damage", bowDamage) }
        if let movementSpeed = stats["movementSpeed"] { return ("Move Speed", movementSpeed) }
        if let overpowerDamage = stats["overpowerDamage"] { return ("Overpower Damage", overpowerDamage) }
        return ("Bonus", stats.values.first ?? 0)
    }
}

// MARK: - Passive Tree
struct PassiveTree: Codable {
    var allocatedNodes: Set<String>

    init(allocatedNodes: Set<String> = []) {
        self.allocatedNodes = allocatedNodes
    }

    mutating func toggleNode(_ nodeId: String) {
        if allocatedNodes.contains(nodeId) {
            allocatedNodes.remove(nodeId)
        } else {
            allocatedNodes.insert(nodeId)
        }
    }

    func isAllocated(_ nodeId: String) -> Bool {
        allocatedNodes.contains(nodeId)
    }

    func canAllocate(from allocated: Set<String>, allNodes: [PassiveSkillNode]) -> Bool {
        // Simple version: any unallocated node can be allocated
        // TODO: Implement path-checking (must have adjacent allocated node)
        return true
    }

    func isConnectedToStart(_ nodeId: String, allNodes: [PassiveSkillNode], visited: Set<String> = []) -> Bool {
        var visited = visited
        if visited.contains(nodeId) { return false }
        visited.insert(nodeId)

        guard let node = allNodes.first(where: { $0.id == nodeId }) else { return false }

        // Start nodes are always connected
        if node.type == .start { return true }

        // Check if any connected node is allocated
        for connectionId in node.connections {
            if allocatedNodes.contains(connectionId) { return true }
            if isConnectedToStart(connectionId, allNodes: allNodes, visited: visited) { return true }
        }

        return false
    }
}

// MARK: - Passive Bonus Summary
struct PassiveBonus {
    var strength: Int = 0
    var dexterity: Int = 0
    var intelligence: Int = 0
    var meleeDamage: Int = 0
    var projectileDamage: Int = 0
    var spellDamage: Int = 0
    var elementalDamage: Int = 0
    var armor: Int = 0
    var evasion: Int = 0
    var minionDamage: Int = 0
    var minionLife: Int = 0
    var maxMana: Int = 0
    var castSpeed: Int = 0
    var attackSpeed: Int = 0
    var lifeOnHit: Int = 0
    var dodgeChance: Int = 0
    var chainCount: Int = 0
    var projectileSpeed: Int = 0
    var critMultiplier: Int = 0
    var elementalPenetration: Int = 0
    var bowDamage: Int = 0
    var movementSpeed: Int = 0
    var overpowerDamage: Int = 0
    var fireResist: Int = 0
    var coldResist: Int = 0
    var lightningResist: Int = 0
    var chaosResist: Int = 0

    var totalPoints: Int { strength + dexterity + intelligence }
}

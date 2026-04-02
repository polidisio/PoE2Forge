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

    static let sampleNodes: [PassiveSkillNode] = [
        // Strength Tree (Left)
        PassiveSkillNode(id: "str_start", name: "Strength", type: .start, stats: ["strength": 10], position: NodePosition(x: 0, y: 200), connections: ["str_1", "str_2"], tier: 0),
        PassiveSkillNode(id: "str_1", name: "+10 Strength", type: .minor, stats: ["strength": 10], position: NodePosition(x: 80, y: 160), connections: ["str_start", "str_3", "melee_1"], tier: 1),
        PassiveSkillNode(id: "str_2", name: "+10 Strength", type: .minor, stats: ["strength": 10], position: NodePosition(x: 80, y: 240), connections: ["str_start", "str_4", "armor_1"], tier: 1),
        PassiveSkillNode(id: "str_3", name: "+15 Strength", type: .minor, stats: ["strength": 15], position: NodePosition(x: 160, y: 120), connections: ["str_1", "melee_2"], tier: 2),
        PassiveSkillNode(id: "str_4", name: "+15 Strength", type: .minor, stats: ["strength": 15], position: NodePosition(x: 160, y: 280), connections: ["str_2", "armor_2"], tier: 2),
        PassiveSkillNode(id: "melee_1", name: "Melee Damage", type: .notable, stats: ["meleeDamage": 25], position: NodePosition(x: 160, y: 180), connections: ["str_1", "melee_3", "str_3"], tier: 2),
        PassiveSkillNode(id: "melee_2", name: "+20% Melee Damage", type: .notable, stats: ["meleeDamage": 20, "percent": 1], position: NodePosition(x: 240, y: 100), connections: ["str_3", "melee_keystone"], tier: 3),
        PassiveSkillNode(id: "melee_3", name: "Life on Hit", type: .notable, stats: ["lifeOnHit": 5], position: NodePosition(x: 240, y: 200), connections: ["melee_1", "melee_2", "str_5"], tier: 3),
        PassiveSkillNode(id: "str_5", name: "+20 Strength", type: .minor, stats: ["strength": 20], position: NodePosition(x: 320, y: 240), connections: ["melee_3", "armor_2"], tier: 4),
        PassiveSkillNode(id: "melee_keystone", name: "Overpower", type: .keystone, stats: ["overpowerDamage": 40], position: NodePosition(x: 360, y: 80), connections: ["melee_2"], tier: 4),
        PassiveSkillNode(id: "armor_1", name: "Armor", type: .notable, stats: ["armor": 80], position: NodePosition(x: 160, y: 280), connections: ["str_2", "armor_2"], tier: 2),
        PassiveSkillNode(id: "armor_2", name: "+30% Armor", type: .notable, stats: ["armor": 30, "percent": 1], position: NodePosition(x: 240, y: 300), connections: ["str_4", "armor_1"], tier: 3),

        // Dexterity Tree (Right)
        PassiveSkillNode(id: "dex_start", name: "Dexterity", type: .start, stats: ["dexterity": 10], position: NodePosition(x: 0, y: 400), connections: ["dex_1", "dex_2"], tier: 0),
        PassiveSkillNode(id: "dex_1", name: "+10 Dexterity", type: .minor, stats: ["dexterity": 10], position: NodePosition(x: 80, y: 360), connections: ["dex_start", "dex_3", "evasion_1"], tier: 1),
        PassiveSkillNode(id: "dex_2", name: "+10 Dexterity", type: .minor, stats: ["dexterity": 10], position: NodePosition(x: 80, y: 440), connections: ["dex_start", "dex_4", "projectile_1"], tier: 1),
        PassiveSkillNode(id: "dex_3", name: "+15 Dexterity", type: .minor, stats: ["dexterity": 15], position: NodePosition(x: 160, y: 320), connections: ["dex_1", "evasion_2"], tier: 2),
        PassiveSkillNode(id: "dex_4", name: "+15 Dexterity", type: .minor, stats: ["dexterity": 15], position: NodePosition(x: 160, y: 480), connections: ["dex_2", "projectile_2"], tier: 2),
        PassiveSkillNode(id: "evasion_1", name: "Evasion", type: .notable, stats: ["evasion": 80], position: NodePosition(x: 160, y: 380), connections: ["dex_1", "evasion_3", "dex_3"], tier: 2),
        PassiveSkillNode(id: "projectile_1", name: "Projectile Damage", type: .notable, stats: ["projectileDamage": 20], position: NodePosition(x: 160, y: 420), connections: ["dex_2", "projectile_2", "dex_4"], tier: 2),
        PassiveSkillNode(id: "evasion_2", name: "+30% Evasion", type: .notable, stats: ["evasion": 30, "percent": 1], position: NodePosition(x: 240, y: 300), connections: ["dex_3", "evasion_keystone"], tier: 3),
        PassiveSkillNode(id: "projectile_2", name: "Projectile Speed", type: .notable, stats: ["projectileSpeed": 25], position: NodePosition(x: 240, y: 500), connections: ["dex_4", "chain_1"], tier: 3),
        PassiveSkillNode(id: "evasion_3", name: "Dodge Chance", type: .notable, stats: ["dodgeChance": 10], position: NodePosition(x: 240, y: 380), connections: ["evasion_1", "evasion_2", "dex_5"], tier: 3),
        PassiveSkillNode(id: "dex_5", name: "+20 Dexterity", type: .minor, stats: ["dexterity": 20], position: NodePosition(x: 320, y: 400), connections: ["evasion_3", "projectile_2"], tier: 4),
        PassiveSkillNode(id: "evasion_keystone", name: "Acrobatics", type: .keystone, stats: ["dodgeChance": 30], position: NodePosition(x: 360, y: 280), connections: ["evasion_2"], tier: 4),
        PassiveSkillNode(id: "chain_1", name: "Chain", type: .notable, stats: ["chainCount": 2], position: NodePosition(x: 320, y: 520), connections: ["projectile_2", "chain_keystone"], tier: 4),
        PassiveSkillNode(id: "chain_keystone", name: "Far Shot", type: .keystone, stats: ["projectileDamage": 50], position: NodePosition(x: 400, y: 520), connections: ["chain_1"], tier: 5),

        // Intelligence Tree (Bottom)
        PassiveSkillNode(id: "int_start", name: "Intelligence", type: .start, stats: ["intelligence": 10], position: NodePosition(x: 200, y: 600), connections: ["int_1", "int_2"], tier: 0),
        PassiveSkillNode(id: "int_1", name: "+10 Intelligence", type: .minor, stats: ["intelligence": 10], position: NodePosition(x: 120, y: 660), connections: ["int_start", "int_3", "spell_1"], tier: 1),
        PassiveSkillNode(id: "int_2", name: "+10 Intelligence", type: .minor, stats: ["intelligence": 10], position: NodePosition(x: 280, y: 660), connections: ["int_start", "int_4", "elemental_1"], tier: 1),
        PassiveSkillNode(id: "int_3", name: "+15 Intelligence", type: .minor, stats: ["intelligence": 15], position: NodePosition(x: 60, y: 720), connections: ["int_1", "spell_2"], tier: 2),
        PassiveSkillNode(id: "int_4", name: "+15 Intelligence", type: .minor, stats: ["intelligence": 15], position: NodePosition(x: 340, y: 720), connections: ["int_2", "elemental_2"], tier: 2),
        PassiveSkillNode(id: "spell_1", name: "Spell Damage", type: .notable, stats: ["spellDamage": 25], position: NodePosition(x: 120, y: 720), connections: ["int_1", "spell_3", "int_3"], tier: 2),
        PassiveSkillNode(id: "elemental_1", name: "Elemental Damage", type: .notable, stats: ["elementalDamage": 20], position: NodePosition(x: 280, y: 720), connections: ["int_2", "elemental_3", "int_4"], tier: 2),
        PassiveSkillNode(id: "spell_2", name: "+30% Spell Damage", type: .notable, stats: ["spellDamage": 30, "percent": 1], position: NodePosition(x: 40, y: 800), connections: ["int_3", "spell_keystone"], tier: 3),
        PassiveSkillNode(id: "spell_3", name: "Cast Speed", type: .notable, stats: ["castSpeed": 20], position: NodePosition(x: 140, y: 800), connections: ["spell_1", "spell_keystone", "mana_1"], tier: 3),
        PassiveSkillNode(id: "elemental_2", name: "+30% Elemental Damage", type: .notable, stats: ["elementalDamage": 30, "percent": 1], position: NodePosition(x: 360, y: 800), connections: ["elemental_1", "elemental_keystone"], tier: 3),
        PassiveSkillNode(id: "elemental_3", name: "Elemental Penetration", type: .notable, stats: ["elementalPenetration": 10], position: NodePosition(x: 280, y: 800), connections: ["elemental_1", "elemental_keystone", "mana_1"], tier: 3),
        PassiveSkillNode(id: "mana_1", name: "+50 Maximum Mana", type: .minor, stats: ["maxMana": 50], position: NodePosition(x: 200, y: 860), connections: ["spell_3", "elemental_3", "mana_2"], tier: 4),
        PassiveSkillNode(id: "mana_2", name: "+100 Maximum Mana", type: .notable, stats: ["maxMana": 100], position: NodePosition(x: 200, y: 920), connections: ["mana_1", "mana_keystone"], tier: 5),
        PassiveSkillNode(id: "spell_keystone", name: "Archmage", type: .keystone, stats: ["spellDamage": 40], position: NodePosition(x: 80, y: 880), connections: ["spell_2", "spell_3"], tier: 4),
        PassiveSkillNode(id: "elemental_keystone", name: "Elemental Overload", type: .keystone, stats: ["critMultiplier": 100], position: NodePosition(x: 340, y: 880), connections: ["elemental_2", "elemental_3"], tier: 4),
        PassiveSkillNode(id: "mana_keystone", name: "Mind Over Matter", type: .keystone, stats: ["maxMana": 30], position: NodePosition(x: 200, y: 980), connections: ["mana_2"], tier: 5)
    ]
}

// MARK: - Passive Tree
struct PassiveTree: Codable, Hashable {
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

import Foundation

// MARK: - Stats
struct Stats: Codable {
    let strength: Int
    let dexterity: Int
    let intelligence: Int
}

// MARK: - Requirements
struct Requirements: Codable {
    let level: Int
    let strength: Int?
    let dexterity: Int?
    let intelligence: Int?
}

// MARK: - Character Class
struct CharacterClass: Codable, Identifiable {
    let id: String
    let name: String
    let baseStats: Stats
    let recommendedTags: [String]
}

// MARK: - Enums
enum GemType: String, Codable, CaseIterable {
    case attack = "attack"
    case spell = "spell"
    case buff = "buff"
    case debuff = "debuff"
    case aura = "aura"
    case curse = "curse"
    case movement = "movement"
    case totem = "totem"
    case minion = "minion"
    
    var displayName: String {
        rawValue.capitalized
    }
}

enum DamageType: String, Codable {
    case physical
    case fire
    case cold
    case lightning
    case chaos
    case holy
}

enum WeaponType: String, Codable, CaseIterable {
    case oneHandSword = "oneHandSword"
    case oneHandAxe = "oneHandAxe"
    case oneHandMace = "oneHandMace"
    case dagger = "dagger"
    case claw = "claw"
    case wand = "wand"
    case scepter = "scepter"
    case twoHandSword = "twoHandSword"
    case twoHandAxe = "twoHandAxe"
    case twoHandMace = "twoHandMace"
    case bow = "bow"
    case staff = "staff"
    case warstaff = "warstaff"
    case shield = "shield"
    case quiver = "quiver"
    
    var displayName: String {
        switch self {
        case .oneHandSword: return "1H Sword"
        case .oneHandAxe: return "1H Axe"
        case .oneHandMace: return "1H Mace"
        case .twoHandSword: return "2H Sword"
        case .twoHandAxe: return "2H Axe"
        case .twoHandMace: return "2H Mace"
        default: return rawValue.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression).capitalized.trimmingCharacters(in: .whitespaces)
        }
    }
}

enum ArmorType: String, Codable, CaseIterable {
    case helmet, bodyArmor, gloves, boots, shield, belt, amulet, ring
    
    var displayName: String {
        switch self {
        case .bodyArmor: return "Body"
        default: return rawValue.capitalized
        }
    }
}

enum ItemRarity: String, Codable {
    case normal, magic, rare, unique
    
    var color: String {
        switch self {
        case .normal: return "#9d9d9d"
        case .magic: return "#8888ff"
        case .rare: return "#ffff77"
        case .unique: return "#af6025"
        }
    }
}

// MARK: - Skill Gem
struct SkillGem: Codable, Identifiable {
    let id: String
    let name: String
    let gemType: GemType
    let damageType: DamageType?
    let description: String
    let baseStats: [String: String]
    let cost: String
    let tags: [String]
}

// MARK: - Support Gem
struct SupportGem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let supportedTypes: [GemType]
    let tags: [String]
    let damageMultiplier: String?
}

// MARK: - Weapon
struct Weapon: Codable, Identifiable {
    let id: String
    let name: String
    let weaponType: WeaponType
    let damage: String
    let damageType: DamageType?
    let aps: String
    let requirements: Requirements
    let rarity: ItemRarity
}

// MARK: - Armor
struct Armor: Codable, Identifiable {
    let id: String
    let name: String
    let armorType: ArmorType
    let defense: String
    let requirements: Requirements
    let rarity: ItemRarity
}

// MARK: - Build
struct Build: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var forClass: String?
    var gearSets: [GearSet]
    var skillIds: [String]
    var passiveTree: PassiveTree
    var skillSockets: [String: SkillSocket]  // skillId -> socket with supports
    var flaskSets: [FlaskSet]
    var notes: String
    var createdAt: Date
    var isFavorite: Bool
    var characterLevel: Int

    static func == (lhs: Build, rhs: Build) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        forClass: String? = nil,
        gearSets: [GearSet] = [],
        skillIds: [String] = [],
        passiveTree: PassiveTree = PassiveTree(),
        skillSockets: [String: SkillSocket] = [:],
        flaskSets: [FlaskSet] = [],
        notes: String = "",
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        characterLevel: Int = 1
    ) {
        self.id = id
        self.name = name
        self.forClass = forClass
        self.gearSets = gearSets
        self.skillIds = skillIds
        self.passiveTree = passiveTree
        self.skillSockets = skillSockets
        self.flaskSets = flaskSets
        self.notes = notes
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.characterLevel = characterLevel
    }

    // MARK: - Gear Set Helpers
    // Active gear set (first one, or create default)
    var activeGearSet: GearSet {
        gearSets.first ?? GearSet()
    }

    // Computed property for backward compatibility
    var equippedItems: [EquippedItem] {
        activeGearSet.equippedItems
    }

    // Get the first (default) flask set, or create an empty one
    var activeFlaskSet: FlaskSet {
        flaskSets.first ?? FlaskSet()
    }

    // Helper to get equipped item in a specific slot
    func item(in slot: EquipmentSlot) -> EquippedItem? {
        activeGearSet.item(in: slot)
    }

    // Helper to get all equipped weapons
    var weapons: [EquippedItem] {
        activeGearSet.equippedItems.filter { $0.isWeapon }
    }

    // Helper to get all equipped armor
    var armors: [EquippedItem] {
        activeGearSet.equippedItems.filter { !$0.isWeapon }
    }

    // Helper to get socket for a skill
    func socketFor(_ skillId: String) -> SkillSocket {
        skillSockets[skillId] ?? SkillSocket()
    }

    // Helper to update socket for a skill
    mutating func updateSocket(for skillId: String, with socket: SkillSocket) {
        skillSockets[skillId] = socket
    }

    // MARK: - Gear Set Management
    // Add or update item in active gear set
    mutating func updateItem(_ item: EquippedItem) {
        if gearSets.isEmpty {
            gearSets = [GearSet(equippedItems: [item])]
        } else {
            var activeSet = gearSets[0]
            activeSet.equippedItems.removeAll { $0.slot == item.slot }
            activeSet.equippedItems.append(item)
            gearSets[0] = activeSet
        }
    }

    // Remove item from active gear set
    mutating func removeItem(in slot: EquipmentSlot) {
        guard !gearSets.isEmpty else { return }
        var activeSet = gearSets[0]
        activeSet.equippedItems.removeAll { $0.slot == slot }
        gearSets[0] = activeSet
    }

    // Add a new gear set
    mutating func addGearSet(_ set: GearSet) {
        gearSets.append(set)
    }
}

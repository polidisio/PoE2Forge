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
    case twoHandSword = "twoHandSword"
    case twoHandAxe = "twoHandAxe"
    case twoHandMace = "twoHandMace"
    case bow = "bow"
    case staff = "staff"
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
struct Build: Codable, Identifiable {
    let id: UUID
    var name: String
    var forClass: String?
    var skills: [String]
    var gear: [String]
    var notes: String
    var createdAt: Date
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String = "", forClass: String? = nil, skills: [String] = [], gear: [String] = [], notes: String = "", createdAt: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.forClass = forClass
        self.skills = skills
        self.gear = gear
        self.notes = notes
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

// MARK: - Run
struct Run: Codable, Identifiable {
    let id: UUID
    var buildName: String
    var act: Int
    var completed: Bool
    var deaths: Int
    var notes: String
    var date: Date
    
    init(id: UUID = UUID(), buildName: String = "", act: Int = 1, completed: Bool = false, deaths: Int = 0, notes: String = "", date: Date = Date()) {
        self.id = id
        self.buildName = buildName
        self.act = act
        self.completed = completed
        self.deaths = deaths
        self.notes = notes
        self.date = date
    }
}

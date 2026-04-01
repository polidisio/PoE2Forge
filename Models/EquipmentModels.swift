import Foundation

// MARK: - Equipment Slot
enum EquipmentSlot: String, Codable, CaseIterable, Identifiable {
    case head
    case body
    case hands
    case feet
    case mainHand
    case offHand
    case ring1
    case ring2
    case amulet
    case belt

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .head: return "Head"
        case .body: return "Body"
        case .hands: return "Hands"
        case .feet: return "Feet"
        case .mainHand: return "Main Hand"
        case .offHand: return "Off Hand"
        case .ring1: return "Ring (1)"
        case .ring2: return "Ring (2)"
        case .amulet: return "Amulet"
        case .belt: return "Belt"
        }
    }

    var icon: String {
        switch self {
        case .head: return "person.fill"
        case .body: return "tshirt"
        case .hands: return "hand.raised"
        case .feet: return "shoeprints.fill"
        case .mainHand, .offHand: return "sword"
        case .ring1, .ring2: return "circle.circle"
        case .amulet: return "lanyardcard"
        case .belt: return "minus"
        }
    }

    /// Maps ArmorType to corresponding EquipmentSlot
    static func from(armorType: ArmorType) -> EquipmentSlot? {
        switch armorType {
        case .helmet: return .head
        case .bodyArmor: return .body
        case .gloves: return .hands
        case .boots: return .feet
        case .shield: return .offHand
        case .belt: return .belt
        case .amulet: return .amulet
        case .ring: return .ring1
        }
    }
}

// MARK: - Equipped Item
struct EquippedItem: Codable, Identifiable, Equatable {
    let id: UUID
    let itemId: String
    let slot: EquipmentSlot
    let isWeapon: Bool

    init(id: UUID = UUID(), itemId: String, slot: EquipmentSlot, isWeapon: Bool) {
        self.id = id
        self.itemId = itemId
        self.slot = slot
        self.isWeapon = isWeapon
    }

    static func == (lhs: EquippedItem, rhs: EquippedItem) -> Bool {
        lhs.itemId == rhs.itemId && lhs.slot == rhs.slot
    }
}

// MARK: - Character Stats
struct CharacterStats: Codable {
    var strength: Int
    var dexterity: Int
    var intelligence: Int
    var level: Int

    var additionalStrength: Int = 0
    var additionalDexterity: Int = 0
    var additionalIntelligence: Int = 0
    var additionalLevel: Int = 0

    var totalStrength: Int { strength + additionalStrength }
    var totalDexterity: Int { dexterity + additionalDexterity }
    var totalIntelligence: Int { intelligence + additionalIntelligence }
    var totalLevel: Int { level + additionalLevel }

    var totalDefense: Int = 0

    init(baseStats: Stats, level: Int = 1) {
        self.strength = baseStats.strength
        self.dexterity = baseStats.dexterity
        self.intelligence = baseStats.intelligence
        self.level = level
    }

    mutating func addBonus(from requirements: Requirements) {
        additionalStrength += requirements.strength ?? 0
        additionalDexterity += requirements.dexterity ?? 0
        additionalIntelligence += requirements.intelligence ?? 0
        additionalLevel += requirements.level
    }
}

// MARK: - Equipment Validation Result
struct EquipmentValidationResult {
    let isValid: Bool
    let failedRequirements: [String]

    static let valid = EquipmentValidationResult(isValid: true, failedRequirements: [])

    static func invalid(_ reasons: [String]) -> EquipmentValidationResult {
        EquipmentValidationResult(isValid: false, failedRequirements: reasons)
    }
}

// MARK: - WeaponType Extension
extension WeaponType {
    var isTwoHanded: Bool {
        switch self {
        case .twoHandSword, .twoHandAxe, .twoHandMace, .bow, .staff:
            return true
        default:
            return false
        }
    }

    var isOneHanded: Bool {
        !isTwoHanded && self != .shield && self != .quiver
    }
}

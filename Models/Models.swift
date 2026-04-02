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

    static let sampleClasses: [CharacterClass] = [
        CharacterClass(id: "warrior", name: "Warrior", baseStats: Stats(strength: 14, dexterity: 8, intelligence: 8), recommendedTags: ["melee", "armor", "strength"]),
        CharacterClass(id: "ranger", name: "Ranger", baseStats: Stats(strength: 8, dexterity: 14, intelligence: 8), recommendedTags: ["bow", "evasion", "dexterity"]),
        CharacterClass(id: "mage", name: "Mage", baseStats: Stats(strength: 8, dexterity: 8, intelligence: 14), recommendedTags: ["spell", "mana", "intelligence"]),
        CharacterClass(id: "duelist", name: "Duelist", baseStats: Stats(strength: 10, dexterity: 12, intelligence: 8), recommendedTags: ["dual_wield", "attack", "dexterity"]),
        CharacterClass(id: "templar", name: "Templar", baseStats: Stats(strength: 12, dexterity: 8, intelligence: 10), recommendedTags: ["melee", "spell", "strength"]),
        CharacterClass(id: "shadow", name: "Shadow", baseStats: Stats(strength: 8, dexterity: 12, intelligence: 10), recommendedTags: ["dagger", "spell", "dexterity"]),
        CharacterClass(id: "scion", name: "Scion", baseStats: Stats(strength: 10, dexterity: 10, intelligence: 10), recommendedTags: ["all", "hybrid", "versatile"])
    ]
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

    static let sampleGems: [SkillGem] = [
        SkillGem(id: "fireball", name: "Fireball", gemType: .spell, damageType: .fire, description: "Hurls a ball of fire that explodes on impact", baseStats: ["Damage": "100-150"], cost: "12 mana", tags: ["fire", "projectile", "aoe"]),
        SkillGem(id: "lightning_strike", name: "Lightning Strike", gemType: .attack, damageType: .lightning, description: "Emits lightning from your weapon that chains", baseStats: ["Damage": "80-120"], cost: "8 mana", tags: ["lightning", "melee", "projectile"]),
        SkillGem(id: "frost_blink", name: "Frost Blink", gemType: .movement, damageType: .cold, description: "Teleport to target location dealing cold damage", baseStats: ["Damage": "30-50"], cost: "20 mana", tags: ["cold", "teleport", "movement"]),
        SkillGem(id: "ice_nova", name: "Ice Nova", gemType: .spell, damageType: .cold, description: "Releases a ring of ice from your position", baseStats: ["Damage": "70-90"], cost: "16 mana", tags: ["cold", "aoe", "nova"]),
        SkillGem(id: "heavy_strike", name: "Heavy Strike", gemType: .attack, damageType: .physical, description: "A powerful melee attack with increased damage", baseStats: ["Damage": "150-200"], cost: "14 mana", tags: ["physical", "melee", "stun"]),
        SkillGem(id: "arc", name: "Arc", gemType: .spell, damageType: .lightning, description: "Lightning chains between enemies up to 4 times", baseStats: ["Damage": "60-80"], cost: "10 mana", tags: ["lightning", "chain", "spell"]),
        SkillGem(id: "summon_zombie", name: "Raise Zombie", gemType: .minion, damageType: .physical, description: "Summons a zombie to fight for you", baseStats: ["Minions": "1"], cost: "40 mana", tags: ["minion", "undead", "summoning"]),
        SkillGem(id: "cyclone", name: "Cyclone", gemType: .attack, damageType: .physical, description: "Spin while moving forward dealing damage", baseStats: ["Damage": "50%"], cost: "12 mana", tags: ["physical", "melee", "aoe", "movement"]),
        SkillGem(id: "icarus_dash", name: "Icarus Dash", gemType: .movement, damageType: nil, description: "Quick dash in target direction", baseStats: ["Distance": "3m"], cost: "8 mana", tags: ["movement", "dash"]),
        SkillGem(id: "molten_shell", name: "Molten Shell", gemType: .buff, damageType: .fire, description: "Creates a protective fire shield", baseStats: ["Damage": "200"], cost: "30 mana", tags: ["fire", "defensive", "shield"]),
        SkillGem(id: "arctic_armor", name: "Arctic Armor", gemType: .buff, damageType: .cold, description: "Reduces damage taken and damages attackers", baseStats: ["Reduction": "10%"], cost: "24 mana", tags: ["cold", "defensive", "aura"]),
        SkillGem(id: "vulnerability", name: "Vulnerability", gemType: .curse, damageType: .physical, description: "Curses enemies to take increased damage", baseStats: ["Duration": "10s"], cost: "30 mana", tags: ["curse", "debuff", "aoe"]),
        SkillGem(id: "hatred", name: "Hatred", gemType: .aura, damageType: .cold, description: "Grants cold damage bonus based on physical damage", baseStats: ["Radius": "10m"], cost: "40 mana", tags: ["aura", "cold", "buff"]),
        SkillGem(id: "anger", name: "Anger", gemType: .aura, damageType: .fire, description: "Grants additional fire damage", baseStats: ["Radius": "10m"], cost: "40 mana", tags: ["aura", "fire", "buff"])
    ]
}

// MARK: - Support Gem
struct SupportGem: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let supportedTypes: [GemType]
    let tags: [String]
    let damageMultiplier: String?

    static let sampleSupportGems: [SupportGem] = [
        SupportGem(id: "multistrike", name: "Multistrike", description: "Attack repeatedly while channeling", supportedTypes: [.attack], tags: ["attack", "repeat"], damageMultiplier: "1.2x"),
        SupportGem(id: "added_fire", name: "Added Fire Damage", description: "Adds fire damage to attacks", supportedTypes: [.attack, .spell], tags: ["fire", "damage"], damageMultiplier: "1.1x"),
        SupportGem(id: "melee_phys", name: "Melee Physical Damage", description: "Adds physical damage to melee attacks", supportedTypes: [.attack], tags: ["physical", "melee"], damageMultiplier: "1.25x"),
        SupportGem(id: "faster_attacks", name: "Faster Attacks", description: "Increases attack speed", supportedTypes: [.attack], tags: ["speed", "attack"], damageMultiplier: "1.15x"),
        SupportGem(id: "spell_damage", name: "Increased Spell Damage", description: "Increases spell damage", supportedTypes: [.spell], tags: ["spell", "damage"], damageMultiplier: "1.2x"),
        SupportGem(id: "faster_casting", name: "Faster Casting", description: "Increases cast speed", supportedTypes: [.spell], tags: ["speed", "cast"], damageMultiplier: "1.15x"),
        SupportGem(id: "chain", name: "Chain", description: "Projectiles chain to nearby enemies", supportedTypes: [.attack, .spell], tags: ["projectile", "chain"], damageMultiplier: "1.1x"),
        SupportGem(id: "fork", name: "Fork", description: "Projectiles fork into two", supportedTypes: [.attack, .spell], tags: ["projectile", "fork"], damageMultiplier: "1.1x"),
        SupportGem(id: "controlled_destruction", name: "Controlled Destruction", description: "Large damage increase but prevents crits", supportedTypes: [.spell], tags: ["spell", "damage"], damageMultiplier: "1.5x"),
        SupportGem(id: "increased_crit", name: "Increased Critical Damage", description: "Increases critical damage multiplier", supportedTypes: [.attack, .spell], tags: ["crit", "damage"], damageMultiplier: "1.3x"),
        SupportGem(id: "blade_flurry", name: "Blade Flurry", description: "Releases a series of attacks in rapid succession", supportedTypes: [.attack], tags: ["attack", "aoe"], damageMultiplier: "1.4x")
    ]
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

    static let sampleWeapons: [Weapon] = [
        Weapon(id: "w1", name: "Rusted Sword", weaponType: .oneHandSword, damage: "10-15", damageType: .physical, aps: "1.2", requirements: Requirements(level: 1, strength: nil, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w2", name: "War Sword", weaponType: .oneHandSword, damage: "20-30", damageType: .physical, aps: "1.4", requirements: Requirements(level: 5, strength: 10, dexterity: nil, intelligence: nil), rarity: .magic),
        Weapon(id: "w3", name: "Cleaver", weaponType: .oneHandAxe, damage: "18-28", damageType: .physical, aps: "1.3", requirements: Requirements(level: 4, strength: 8, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w4", name: "Spiked Mace", weaponType: .oneHandMace, damage: "15-25", damageType: .physical, aps: "1.1", requirements: Requirements(level: 3, strength: 6, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w5", name: "Stiletto", weaponType: .dagger, damage: "8-16", damageType: .physical, aps: "1.8", requirements: Requirements(level: 2, strength: nil, dexterity: 8, intelligence: nil), rarity: .normal),
        Weapon(id: "w6", name: "Gutting Knife", weaponType: .dagger, damage: "12-18", damageType: .physical, aps: "1.6", requirements: Requirements(level: 4, strength: nil, dexterity: 12, intelligence: nil), rarity: .magic),
        Weapon(id: "w7", name: "Long Bow", weaponType: .bow, damage: "25-40", damageType: .physical, aps: "1.0", requirements: Requirements(level: 6, strength: nil, dexterity: 14, intelligence: nil), rarity: .normal),
        Weapon(id: "w8", name: "Reflex Bow", weaponType: .bow, damage: "30-50", damageType: .physical, aps: "1.2", requirements: Requirements(level: 10, strength: nil, dexterity: 20, intelligence: nil), rarity: .magic),
        Weapon(id: "w9", name: "Great Sword", weaponType: .twoHandSword, damage: "40-60", damageType: .physical, aps: "0.8", requirements: Requirements(level: 12, strength: 24, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w10", name: "Battle Axe", weaponType: .twoHandAxe, damage: "45-70", damageType: .physical, aps: "0.7", requirements: Requirements(level: 14, strength: 28, dexterity: nil, intelligence: nil), rarity: .magic),
        Weapon(id: "w11", name: "Warstaff", weaponType: .warstaff, damage: "30-45", damageType: .lightning, aps: "1.0", requirements: Requirements(level: 12, strength: nil, dexterity: nil, intelligence: 24), rarity: .magic),
        Weapon(id: "w12", name: "Apprentice Wand", weaponType: .wand, damage: "15-20", damageType: .fire, aps: "1.4", requirements: Requirements(level: 5, strength: nil, dexterity: nil, intelligence: 10), rarity: .normal),
        Weapon(id: "w13", name: "Serrated Claws", weaponType: .claw, damage: "10-18", damageType: .physical, aps: "1.5", requirements: Requirements(level: 3, strength: nil, dexterity: 10, intelligence: nil), rarity: .normal),
        Weapon(id: "w14", name: "Iron Scepter", weaponType: .scepter, damage: "18-25", damageType: .physical, aps: "1.2", requirements: Requirements(level: 6, strength: 12, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w15", name: "Oak Shield", weaponType: .shield, damage: "0-0", damageType: nil, aps: "0", requirements: Requirements(level: 2, strength: 6, dexterity: nil, intelligence: nil), rarity: .normal),
        Weapon(id: "w16", name: "Iron Arrow Quiver", weaponType: .quiver, damage: "0-0", damageType: nil, aps: "0", requirements: Requirements(level: 1, strength: nil, dexterity: nil, intelligence: nil), rarity: .normal)
    ]
}

// MARK: - Armor
struct Armor: Codable, Identifiable {
    let id: String
    let name: String
    let armorType: ArmorType
    let defense: String
    let requirements: Requirements
    let rarity: ItemRarity

    static let sampleArmors: [Armor] = [
        Armor(id: "a1", name: "Leather Cap", armorType: .helmet, defense: "5", requirements: Requirements(level: 1, strength: 4, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a2", name: "Iron Helm", armorType: .helmet, defense: "12", requirements: Requirements(level: 4, strength: 10, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a3", name: "Silk Hood", armorType: .helmet, defense: "6", requirements: Requirements(level: 2, strength: nil, dexterity: nil, intelligence: 8), rarity: .magic),
        Armor(id: "a4", name: "Chainmail Vest", armorType: .bodyArmor, defense: "30", requirements: Requirements(level: 6, strength: 16, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a5", name: "Plate Armor", armorType: .bodyArmor, defense: "50", requirements: Requirements(level: 10, strength: 24, dexterity: nil, intelligence: nil), rarity: .magic),
        Armor(id: "a6", name: "Silk Robe", armorType: .bodyArmor, defense: "8", requirements: Requirements(level: 3, strength: nil, dexterity: nil, intelligence: 12), rarity: .normal),
        Armor(id: "a7", name: "Mage's Vestment", armorType: .bodyArmor, defense: "15", requirements: Requirements(level: 8, strength: nil, dexterity: nil, intelligence: 20), rarity: .magic),
        Armor(id: "a8", name: "Leather Gloves", armorType: .gloves, defense: "4", requirements: Requirements(level: 1, strength: nil, dexterity: 4, intelligence: nil), rarity: .normal),
        Armor(id: "a9", name: "Chainmail Gloves", armorType: .gloves, defense: "10", requirements: Requirements(level: 5, strength: 10, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a10", name: "Silk Gloves", armorType: .gloves, defense: "5", requirements: Requirements(level: 3, strength: nil, dexterity: nil, intelligence: 10), rarity: .magic),
        Armor(id: "a11", name: "Leather Boots", armorType: .boots, defense: "6", requirements: Requirements(level: 2, strength: nil, dexterity: 6, intelligence: nil), rarity: .normal),
        Armor(id: "a12", name: "Iron Greaves", armorType: .boots, defense: "12", requirements: Requirements(level: 5, strength: 12, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a13", name: "Scholars Boots", armorType: .boots, defense: "8", requirements: Requirements(level: 4, strength: nil, dexterity: nil, intelligence: 12), rarity: .magic),
        Armor(id: "a14", name: "Oak Buckler", armorType: .shield, defense: "20", requirements: Requirements(level: 3, strength: 8, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a15", name: "Iron Round Shield", armorType: .shield, defense: "35", requirements: Requirements(level: 8, strength: 16, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a16", name: "Studded Belt", armorType: .belt, defense: "3", requirements: Requirements(level: 1, strength: 4, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a17", name: "Heavy Belt", armorType: .belt, defense: "8", requirements: Requirements(level: 6, strength: 14, dexterity: nil, intelligence: nil), rarity: .magic),
        Armor(id: "a18", name: "Silver Ring", armorType: .ring, defense: "0", requirements: Requirements(level: 1, strength: nil, dexterity: nil, intelligence: nil), rarity: .normal),
        Armor(id: "a19", name: "Ruby Ring", armorType: .ring, defense: "0", requirements: Requirements(level: 5, strength: 10, dexterity: nil, intelligence: nil), rarity: .magic),
        Armor(id: "a20", name: "Tourmaline Amulet", armorType: .amulet, defense: "0", requirements: Requirements(level: 3, strength: nil, dexterity: nil, intelligence: 8), rarity: .magic),
        Armor(id: "a21", name: "Coral Amulet", armorType: .amulet, defense: "0", requirements: Requirements(level: 1, strength: nil, dexterity: nil, intelligence: nil), rarity: .normal)
    ]
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

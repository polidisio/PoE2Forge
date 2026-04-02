import Foundation

// MARK: - Flask Type
enum FlaskType: String, Codable, CaseIterable {
    case life = "life"
    case mana = "mana"
    case hybrid = "hybrid"
    case utility = "utility"

    var displayName: String {
        switch self {
        case .life: return "Life Flask"
        case .mana: return "Mana Flask"
        case .hybrid: return "Hybrid Flask"
        case .utility: return "Utility Flask"
        }
    }
}

// MARK: - Flask Modifier
struct FlaskModifier: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let value: String  // e.g., "+50", "20%"
}

// MARK: - Flask Data (static game data)
struct FlaskData: Codable, Identifiable {
    let id: String
    let name: String
    let flaskType: FlaskType
    let modifiers: [FlaskModifier]
    let chargesMax: Int
    let chargesPerUse: Int
    let duration: Double
    let unique: Bool
    let rarityColor: String

    static let sampleFlasks: [FlaskData] = [
        // Life Flasks
        FlaskData(id: "lifeFlaskSmall", name: "Small Life Flask", flaskType: .life, modifiers: [
            FlaskModifier(name: "Restore", value: "+250 life")
        ], chargesMax: 150, chargesPerUse: 50, duration: 0.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "lifeFlaskMedium", name: "Medium Life Flask", flaskType: .life, modifiers: [
            FlaskModifier(name: "Restore", value: "+450 life")
        ], chargesMax: 250, chargesPerUse: 75, duration: 0.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "lifeFlaskLarge", name: "Large Life Flask", flaskType: .life, modifiers: [
            FlaskModifier(name: "Restore", value: "+700 life")
        ], chargesMax: 400, chargesPerUse: 120, duration: 0.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "vitalityLargerLife", name: "Vitality's Larger Life Flask", flaskType: .life, modifiers: [
            FlaskModifier(name: "Restore", value: "+900 life"),
            FlaskModifier(name: "Life Regen", value: "+50 life/sec during flask effect")
        ], chargesMax: 450, chargesPerUse: 150, duration: 4.0, unique: true, rarityColor: "af6028"),

        // Mana Flasks
        FlaskData(id: "manaFlaskSmall", name: "Small Mana Flask", flaskType: .mana, modifiers: [
            FlaskModifier(name: "Restore", value: "+150 mana")
        ], chargesMax: 100, chargesPerUse: 35, duration: 0.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "manaFlaskMedium", name: "Medium Mana Flask", flaskType: .mana, modifiers: [
            FlaskModifier(name: "Restore", value: "+280 mana")
        ], chargesMax: 200, chargesPerUse: 60, duration: 0.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "manaFlaskLarge", name: "Large Mana Flask", flaskType: .mana, modifiers: [
            FlaskModifier(name: "Restore", value: "+450 mana")
        ], chargesMax: 320, chargesPerUse: 100, duration: 0.0, unique: false, rarityColor: "9e9e9e"),

        // Hybrid Flasks
        FlaskData(id: "hybridFlaskSmall", name: "Small Hybrid Flask", flaskType: .hybrid, modifiers: [
            FlaskModifier(name: "Restore", value: "+100 life, +50 mana")
        ], chargesMax: 120, chargesPerUse: 40, duration: 0.0, unique: false, rarityColor: "9e9e9e"),

        // Utility Flasks
        FlaskData(id: "quicksilverFlask", name: "Quicksilver Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Movement Speed", value: "+30% during effect")
        ], chargesMax: 60, chargesPerUse: 20, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "diamondFlask", name: "Diamond Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Crit Chance", value: "+50% during effect")
        ], chargesMax: 50, chargesPerUse: 25, duration: 4.0, unique: false, rarityColor: "af6028"),
        FlaskData(id: "graniteFlask", name: "Granite Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Armor", value: "+3000 during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "basaltFlask", name: "Basalt Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Physical Damage reduction", value: "+15% during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "amethystFlask", name: "Amethyst Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Chaos Resist", value: "+40% during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "topazFlask", name: "Topaz Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Lightning Resist", value: "+50% during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "sapphireFlask", name: "Sapphire Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Cold Resist", value: "+50% during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "rubyFlask", name: "Ruby Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Fire Resist", value: "+50% during effect")
        ], chargesMax: 60, chargesPerUse: 30, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "stibniteFlask", name: "Stibnite Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Onslaugh", value: "25% increased movement speed during effect")
        ], chargesMax: 50, chargesPerUse: 25, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: " BismuthFlask", name: "Bismuth Flask", flaskType: .utility, modifiers: [
            FlaskModifier(name: "All Resistances", value: "+30% during effect")
        ], chargesMax: 50, chargesPerUse: 25, duration: 4.0, unique: false, rarityColor: "9e9e9e"),
        FlaskData(id: "rumi'sConcoction", name: "Rumi's Concoction", flaskType: .utility, modifiers: [
            FlaskModifier(name: "Block", value: "+20% during effect")
        ], chargesMax: 50, chargesPerUse: 25, duration: 3.0, unique: true, rarityColor: "af6028")
    ]
}

// MARK: - Equipped Flask (instance in a build)
struct EquippedFlask: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let flaskDataId: String
    var quantity: Int  // stacks, usually 1

    init(id: UUID = UUID(), flaskDataId: String, quantity: Int = 1) {
        self.id = id
        self.flaskDataId = flaskDataId
        self.quantity = quantity
    }

    static func == (lhs: EquippedFlask, rhs: EquippedFlask) -> Bool {
        lhs.flaskDataId == rhs.flaskDataId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(flaskDataId)
    }
}

// MARK: - Flask Set (preset of 5 flasks)
struct FlaskSet: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var flasks: [EquippedFlask]  // max 5

    init(id: UUID = UUID(), name: String = "Default", flasks: [EquippedFlask] = []) {
        self.id = id
        self.name = name
        self.flasks = Array(flasks.prefix(5))
    }

    mutating func updateFlask(at index: Int, with flask: EquippedFlask) {
        guard index >= 0 && index < 5 else { return }
        if index < flasks.count {
            flasks[index] = flask
        } else {
            flasks.append(flask)
        }
    }
}

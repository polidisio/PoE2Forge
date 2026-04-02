import Foundation

// MARK: - Build Template
struct BuildTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let characterClass: String
    let recommendedLevel: Int
    let skillIds: [String]
    let passiveTreeNodes: [String]
    let suggestedGearCategories: [String]  // e.g., "highLifeRegen", "attackSpeed"

    // Create a new Build from this template
    func createBuild(name: String) -> Build {
        Build(
            name: name,
            forClass: characterClass,
            gearSets: [],
            skillIds: skillIds,
            passiveTree: PassiveTree(allocatedNodes: Set(passiveTreeNodes)),
            skillSockets: Dictionary(uniqueKeysWithValues: skillIds.map { ($0, SkillSocket()) }),
            notes: "",
            characterLevel: recommendedLevel
        )
    }
}

// MARK: - Default Templates
extension BuildTemplate {
    static let defaultTemplates: [BuildTemplate] = [
        // Warrior templates
        BuildTemplate(
            id: "warrior-infernal",
            name: "Infernal Strike Warrior",
            description: "Melee fire build with Infernal Strike and high life regen",
            characterClass: "mercenary",
            recommendedLevel: 1,
            skillIds: ["infernalStrike"],
            passiveTreeNodes: ["str_start", "str_1", "str_2", "str_3"],
            suggestedGearCategories: ["lifeRegen", "fireDamage"]
        ),
        BuildTemplate(
            id: "warrior-bone",
            name: "Bone Splinter Marauder",
            description: "Physical attack build using Bone Splinter",
            characterClass: "mercenary",
            recommendedLevel: 1,
            skillIds: ["boneSplinter"],
            passiveTreeNodes: ["str_start", "str_1", "str_2", "str_3"],
            suggestedGearCategories: ["physicalDamage", "accuracy"]
        ),

        // Mage templates
        BuildTemplate(
            id: "mage-frost",
            name: "Frost Bomb Mage",
            description: "Cold spell caster with Frost Bomb and hypothermia",
            characterClass: "sorceress",
            recommendedLevel: 1,
            skillIds: ["frostBomb"],
            passiveTreeNodes: ["int_start", "int_1", "int_2", "int_3"],
            suggestedGearCategories: ["spellDamage", "coldDamage", "manaRegen"]
        ),
        BuildTemplate(
            id: "mage-fireball",
            name: "Fireball Sorceress",
            description: "High damage fire spell caster",
            characterClass: "sorceress",
            recommendedLevel: 1,
            skillIds: ["fireball"],
            passiveTreeNodes: ["int_start", "int_1", "int_2", "int_3"],
            suggestedGearCategories: ["spellDamage", "fireDamage", "castSpeed"]
        ),

        // Ranger templates
        BuildTemplate(
            id: "ranger-bow",
            name: "Lightning Arrow Ranger",
            description: "Projectile build with Lightning Arrow",
            characterClass: "deadeye",
            recommendedLevel: 1,
            skillIds: ["lightningArrow"],
            passiveTreeNodes: ["dex_start", "dex_1", "dex_2", "dex_3"],
            suggestedGearCategories: ["projectileDamage", "attackSpeed", "accuracy"]
        ),
        BuildTemplate(
            id: "ranger-double",
            name: "Double Strike Deadeye",
            description: "Fast dual-wield melee strikes",
            characterClass: "deadeye",
            recommendedLevel: 1,
            skillIds: ["doubleStrike"],
            passiveTreeNodes: ["dex_start", "dex_1", "dex_2", "dex_3"],
            suggestedGearCategories: ["attackSpeed", "physicalDamage", "critChance"]
        ),

        // Minion templates
        BuildTemplate(
            id: "minion-skeleton",
            name: "Skeleton Mage Necromancer",
            description: "Summon skeletons and buff with minion instability",
            characterClass: "necromancer",
            recommendedLevel: 1,
            skillIds: ["raiseSkeleton"],
            passiveTreeNodes: ["int_start", "minion_1", "minion_2"],
            suggestedGearCategories: ["minionDamage", "minionLife", "spellDamage"]
        ),
        BuildTemplate(
            id: "minion-zombie",
            name: "Zombie Brute Necromancer",
            description: "Tank zombies with enfeeble curses",
            characterClass: "necromancer",
            recommendedLevel: 1,
            skillIds: ["raiseZombie"],
            passiveTreeNodes: ["str_start", "minion_1", "minion_3"],
            suggestedGearCategories: ["minionLife", "armor", "curseEffect"]
        ),

        // Cross-class templates
        BuildTemplate(
            id: "elemental-bow",
            name: "Elemental Hit Deadeye",
            description: "Elemental damage bow build",
            characterClass: "deadeye",
            recommendedLevel: 1,
            skillIds: ["elementalHit"],
            passiveTreeNodes: ["dex_start", "dex_1", "dex_2", "int_1"],
            suggestedGearCategories: ["elementalDamage", "attackSpeed", "projectileSpeed"]
        ),
        BuildTemplate(
            id: "cold-attack",
            name: "Frost Blades Infernalist",
            description: "Cold attack skill with pc",
            characterClass: "infernalist",
            recommendedLevel: 1,
            skillIds: ["frostBlades"],
            passiveTreeNodes: ["dex_start", "dex_1", "dex_2", "str_1"],
            suggestedGearCategories: ["coldDamage", "attackSpeed", "lifeLeech"]
        )
    ]
}

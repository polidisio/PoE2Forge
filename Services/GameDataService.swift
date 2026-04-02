import Foundation
import SwiftUI

@MainActor
class GameDataService: ObservableObject {
    @Published var classes: [CharacterClass] = []
    @Published var skillGems: [SkillGem] = []
    @Published var supportGems: [SupportGem] = []
    @Published var weapons: [Weapon] = []
    @Published var armors: [Armor] = []
    @Published var passiveSkills: [PassiveSkillNode] = []
    @Published var flaskData: [FlaskData] = []

    @AppStorage("builds") private var buildsData: Data = Data()
    @AppStorage("runs") private var runsData: Data = Data()

    @Published var builds: [Build] = []
    @Published var runs: [Run] = []

    init() {
        loadData()
        loadBuilds()
        loadRuns()
    }

    func loadData() {
        // NOTE: JSON files contain swapped data - fix by loading correct files
        // classes.json contains SkillGem data -> load into skillGems
        // skillGems.json contains CharacterClass data -> load into classes
        // weapons.json contains SupportGem data -> load into supportGems
        // supportGems.json contains Weapon data -> load into weapons
        // armor.json contains Armor data -> load into armors (correct)
        classes = loadJSON("skillGems") ?? []
        skillGems = loadJSON("classes") ?? []
        supportGems = loadJSON("weapons") ?? []
        weapons = loadJSON("supportGems") ?? []
        armors = loadJSON("armor") ?? []
        passiveSkills = loadJSON("passiveSkills") ?? []
        flaskData = FlaskData.sampleFlasks
    }
    
    private func loadJSON<T: Decodable>(_ name: String) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Builds
    func loadBuilds() {
        guard let decoded = try? JSONDecoder().decode([Build].self, from: buildsData) else {
            builds = []
            return
        }
        builds = decoded
    }
    
    func saveBuild(_ build: Build) {
        if let index = builds.firstIndex(where: { $0.id == build.id }) {
            builds[index] = build
        } else {
            builds.append(build)
        }
        saveBuilds()
    }
    
    func deleteBuild(_ build: Build) {
        builds.removeAll { $0.id == build.id }
        saveBuilds()
    }
    
    private func saveBuilds() {
        if let encoded = try? JSONEncoder().encode(builds) {
            buildsData = encoded
        }
    }
    
    // MARK: - Runs
    func loadRuns() {
        guard let decoded = try? JSONDecoder().decode([Run].self, from: runsData) else {
            runs = []
            return
        }
        runs = decoded
    }
    
    func saveRun(_ run: Run) {
        if let index = runs.firstIndex(where: { $0.id == run.id }) {
            runs[index] = run
        } else {
            runs.append(run)
        }
        saveRuns()
    }
    
    func deleteRun(_ run: Run) {
        runs.removeAll { $0.id == run.id }
        saveRuns()
    }
    
    private func saveRuns() {
        if let encoded = try? JSONEncoder().encode(runs) {
            runsData = encoded
        }
    }
    
    // MARK: - Helpers
    func supportsFor(gemType: GemType) -> [SupportGem] {
        supportGems.filter { $0.supportedTypes.contains(gemType) }
    }
    
    func weaponBy(id: String) -> Weapon? {
        weapons.first { $0.id == id }
    }
    
    func armorBy(id: String) -> Armor? {
        armors.first { $0.id == id }
    }
    
    func skillBy(id: String) -> SkillGem? {
        skillGems.first { $0.id == id }
    }
    
    func classBy(id: String) -> CharacterClass? {
        classes.first { $0.id == id }
    }

    func passiveSkillBy(id: String) -> PassiveSkillNode? {
        passiveSkills.first { $0.id == id }
    }

    func flaskDataBy(id: String) -> FlaskData? {
        flaskData.first { $0.id == id }
    }

    // MARK: - Passive Tree Helpers
    func passiveNodeIsAllocated(_ nodeId: String, in build: Build) -> Bool {
        build.passiveTree.isAllocated(nodeId)
    }

    func passiveNodeCanAllocate(_ nodeId: String, in build: Build) -> Bool {
        guard let node = passiveSkillBy(id: nodeId) else { return false }

        // Already allocated
        if build.passiveTree.isAllocated(nodeId) { return true }

        // Start nodes can always be allocated
        if node.type == .start { return true }

        // Check if connected to any allocated node
        return build.passiveTree.isConnectedToStart(nodeId, allNodes: passiveSkills)
    }

    func calculatePassiveBonus(for build: Build) -> PassiveBonus {
        var bonus = PassiveBonus()

        for nodeId in build.passiveTree.allocatedNodes {
            guard let node = passiveSkillBy(id: nodeId) else { continue }

            // Skip percent-only stats (stored as helper values)
            if node.stats["percent"] == 1 { continue }

            let stats = node.stats
            if let val = stats["strength"] { bonus.strength += val }
            if let val = stats["dexterity"] { bonus.dexterity += val }
            if let val = stats["intelligence"] { bonus.intelligence += val }
            if let val = stats["meleeDamage"] { bonus.meleeDamage += val }
            if let val = stats["projectileDamage"] { bonus.projectileDamage += val }
            if let val = stats["spellDamage"] { bonus.spellDamage += val }
            if let val = stats["elementalDamage"] { bonus.elementalDamage += val }
            if let val = stats["armor"] { bonus.armor += val }
            if let val = stats["evasion"] { bonus.evasion += val }
            if let val = stats["minionDamage"] { bonus.minionDamage += val }
            if let val = stats["minionLife"] { bonus.minionLife += val }
            if let val = stats["maxMana"] { bonus.maxMana += val }
            if let val = stats["castSpeed"] { bonus.castSpeed += val }
            if let val = stats["attackSpeed"] { bonus.attackSpeed += val }
            if let val = stats["lifeOnHit"] { bonus.lifeOnHit += val }
            if let val = stats["dodgeChance"] { bonus.dodgeChance += val }
            if let val = stats["chainCount"] { bonus.chainCount += val }
            if let val = stats["projectileSpeed"] { bonus.projectileSpeed += val }
            if let val = stats["critMultiplier"] { bonus.critMultiplier += val }
            if let val = stats["elementalPenetration"] { bonus.elementalPenetration += val }
            if let val = stats["bowDamage"] { bonus.bowDamage += val }
            if let val = stats["movementSpeed"] { bonus.movementSpeed += val }
            if let val = stats["overpowerDamage"] { bonus.overpowerDamage += val }
            if let val = stats["fireResist"] { bonus.fireResist += val }
            if let val = stats["coldResist"] { bonus.coldResist += val }
            if let val = stats["lightningResist"] { bonus.lightningResist += val }
            if let val = stats["chaosResist"] { bonus.chaosResist += val }
        }

        return bonus
    }
    
    var completionRate: Double {
        guard !runs.isEmpty else { return 0 }
        let completedRuns = runs.filter { $0.isCompleted }.count
        return Double(completedRuns) / Double(runs.count) * 100
    }

    var totalDeaths: Int {
        runs.reduce(0) { $0 + $1.totalDeaths }
    }

    // MARK: - Run Helpers
    func buildBy(id: UUID) -> Build? {
        builds.first { $0.id == id }
    }

    func runsFor(buildId: UUID) -> [Run] {
        runs.filter { $0.buildId == buildId }
    }

    func activeRuns() -> [Run] {
        runs.filter { !$0.isCompleted }
    }

    func completedRuns() -> [Run] {
        runs.filter { $0.isCompleted }
    }

    // MARK: - Equipment Helpers
    func weaponIn(slot: EquipmentSlot, for build: Build) -> Weapon? {
        guard let equipped = build.item(in: slot), equipped.isWeapon else { return nil }
        return weaponBy(id: equipped.itemId)
    }

    func armorIn(slot: EquipmentSlot, for build: Build) -> Armor? {
        guard let equipped = build.item(in: slot), !equipped.isWeapon else { return nil }
        return armorBy(id: equipped.itemId)
    }

    func itemIn(slot: EquipmentSlot, for build: Build) -> (weapon: Weapon?, armor: Armor?) {
        guard let equipped = build.item(in: slot) else { return (nil, nil) }
        if equipped.isWeapon {
            return (weaponBy(id: equipped.itemId), nil)
        } else {
            return (nil, armorBy(id: equipped.itemId))
        }
    }

    // MARK: - Stats Calculation
    func calculateStats(for build: Build) -> CharacterStats {
        var stats: CharacterStats
        if let classId = build.forClass, let charClass = classBy(id: classId) {
            stats = CharacterStats(baseStats: charClass.baseStats, level: build.characterLevel)
        } else {
            stats = CharacterStats(baseStats: Stats(strength: 10, dexterity: 10, intelligence: 10), level: build.characterLevel)
        }

        // Add bonuses from equipped items
        for equipped in build.equippedItems {
            if equipped.isWeapon {
                if let weapon = weaponBy(id: equipped.itemId) {
                    stats.addBonus(from: weapon.requirements)
                    stats.totalDefense += parseDamageToInt(weapon.damage)
                }
            } else {
                if let armor = armorBy(id: equipped.itemId) {
                    stats.addBonus(from: armor.requirements)
                    stats.totalDefense += Int(armor.defense) ?? 0
                }
            }
        }

        // Add bonuses from passive tree
        let passiveBonus = calculatePassiveBonus(for: build)
        stats.additionalStrength += passiveBonus.strength
        stats.additionalDexterity += passiveBonus.dexterity
        stats.additionalIntelligence += passiveBonus.intelligence

        return stats
    }

    private func parseDamageToInt(_ damage: String) -> Int {
        let parts = damage.split(separator: "-")
        if parts.count == 2, let min = Int(parts[0]) {
            return min
        } else if let single = Int(damage) {
            return single
        }
        return 0
    }

    // MARK: - Equipment Validation
    func validateEquipment(for build: Build) -> EquipmentValidationResult {
        let stats = calculateStats(for: build)
        var failures: [String] = []

        for equipped in build.equippedItems {
            if equipped.isWeapon {
                if let weapon = weaponBy(id: equipped.itemId) {
                    let reqs = weapon.requirements
                    if stats.totalLevel < reqs.level {
                        failures.append("\(weapon.name) requires level \(reqs.level)")
                    }
                    if let str = reqs.strength, stats.totalStrength < str {
                        failures.append("\(weapon.name) requires \(str) STR")
                    }
                    if let dex = reqs.dexterity, stats.totalDexterity < dex {
                        failures.append("\(weapon.name) requires \(dex) DEX")
                    }
                    if let int = reqs.intelligence, stats.totalIntelligence < int {
                        failures.append("\(weapon.name) requires \(int) INT")
                    }
                }
            } else {
                if let armor = armorBy(id: equipped.itemId) {
                    let reqs = armor.requirements
                    if stats.totalLevel < reqs.level {
                        failures.append("\(armor.name) requires level \(reqs.level)")
                    }
                    if let str = reqs.strength, stats.totalStrength < str {
                        failures.append("\(armor.name) requires \(str) STR")
                    }
                    if let dex = reqs.dexterity, stats.totalDexterity < dex {
                        failures.append("\(armor.name) requires \(dex) DEX")
                    }
                    if let int = reqs.intelligence, stats.totalIntelligence < int {
                        failures.append("\(armor.name) requires \(int) INT")
                    }
                }
            }
        }

        return failures.isEmpty ? .valid : .invalid(failures)
    }

    // MARK: - Gear Comparison
    func compareGear(oldBuild: Build, newBuild: Build) -> (statDiff: CharacterStats, issues: [String]) {
        let oldStats = calculateStats(for: oldBuild)
        let newStats = calculateStats(for: newBuild)

        var diff = CharacterStats(baseStats: Stats(strength: 0, dexterity: 0, intelligence: 0))
        diff.additionalStrength = newStats.additionalStrength - oldStats.additionalStrength
        diff.additionalDexterity = newStats.additionalDexterity - oldStats.additionalDexterity
        diff.additionalIntelligence = newStats.additionalIntelligence - oldStats.additionalIntelligence
        diff.totalDefense = newStats.totalDefense - oldStats.totalDefense

        let issues = validateEquipment(for: newBuild).failedRequirements

        return (diff, issues)
    }

    // MARK: - Item Comparison
    func compareItems(oldItemId: String?, newItemId: String, isWeapon: Bool) -> ItemComparison {
        let newStats: ItemStats
        let newItemName: String

        if isWeapon {
            guard let weapon = weaponBy(id: newItemId) else {
                return ItemComparison(itemName: "Unknown", isWeapon: true, oldStats: nil, newStats: ItemStats(), statDiffs: [])
            }
            newStats = ItemStats.from(weapon: weapon)
            newItemName = weapon.name
        } else {
            guard let armor = armorBy(id: newItemId) else {
                return ItemComparison(itemName: "Unknown", isWeapon: false, oldStats: nil, newStats: ItemStats(), statDiffs: [])
            }
            newStats = ItemStats.from(armor: armor)
            newItemName = armor.name
        }

        let oldStats: ItemStats?
        if let oldId = oldItemId {
            if isWeapon {
                oldStats = weaponBy(id: oldId).map { ItemStats.from(weapon: $0) }
            } else {
                oldStats = armorBy(id: oldId).map { ItemStats.from(armor: $0) }
            }
        } else {
            oldStats = nil
        }

        // Calculate stat differences
        var statDiffs: [StatDiff] = []

        if isWeapon {
            if let old = oldStats {
                statDiffs.append(StatDiff(statName: "Damage", oldValue: old.damageMin, newValue: newStats.damageMin))
                statDiffs.append(StatDiff(statName: "Max Damage", oldValue: old.damageMax, newValue: newStats.damageMax))
                statDiffs.append(StatDiff(statName: "APS", oldValue: Int(old.aps * 100), newValue: Int(newStats.aps * 100)))
            }
        } else {
            if let old = oldStats {
                statDiffs.append(StatDiff(statName: "Defense", oldValue: old.defense, newValue: newStats.defense))
            }
        }

        if let old = oldStats {
            statDiffs.append(StatDiff(statName: "Level Req", oldValue: old.level, newValue: newStats.level))
            statDiffs.append(StatDiff(statName: "Strength", oldValue: old.strength, newValue: newStats.strength))
            statDiffs.append(StatDiff(statName: "Dexterity", oldValue: old.dexterity, newValue: newStats.dexterity))
            statDiffs.append(StatDiff(statName: "Intelligence", oldValue: old.intelligence, newValue: newStats.intelligence))
        }

        return ItemComparison(
            itemName: newItemName,
            isWeapon: isWeapon,
            oldStats: oldStats,
            newStats: newStats,
            statDiffs: statDiffs
        )
    }

    // MARK: - DPS Calculation
    func calculateBuildDPS(for build: Build) -> BuildDPSSummary {
        var summary = BuildDPSSummary()

        // Get equipped weapon
        var mainHandWeapon: Weapon?
        if let mainHand = build.item(in: .mainHand), mainHand.isWeapon {
            mainHandWeapon = weaponBy(id: mainHand.itemId)
        }

        // Calculate DPS for each skill
        for skillId in build.skillIds {
            guard let skill = skillBy(id: skillId) else { continue }
            let socket = build.socketFor(skillId)

            let calc = calculateSkillDPS(
                skill: skill,
                weapon: mainHandWeapon,
                socket: socket,
                build: build
            )

            summary.skillCalculations.append(calc)

            // Categorize DPS
            let isAttack = skill.gemType == .attack || skill.gemType == .movement
            let isProjectile = skill.gemType == .spell && skill.tags.contains("projectile")

            if isAttack {
                summary.totalMeleeDPS += calc.effectiveDPS
            } else if isProjectile {
                summary.totalProjectileDPS += calc.effectiveCastDPS
            } else {
                summary.totalSpellDPS += calc.effectiveCastDPS
            }
        }

        summary.totalDPS = summary.totalMeleeDPS + summary.totalProjectileDPS + summary.totalSpellDPS

        return summary
    }

    func calculateSkillDPS(skill: SkillGem, weapon: Weapon?, socket: SkillSocket, build: Build) -> DPSCalculation {
        var calc = DPSCalculation(
            skillId: skill.id,
            skillName: skill.name,
            gemLevel: socket.level,
            gemQuality: socket.quality,
            baseDamage: 0,
            effectiveDamage: 0,
            damageMultiplier: 1.0,
            attacksPerSecond: 0,
            effectiveDPS: 0,
            hitDamage: 0,
            critChance: 5.0,
            critMultiplier: 1.5,
            castSpeed: 1.0,
            effectiveCastDPS: 0,
            damageType: skill.damageType,
            isAttack: skill.gemType == .attack
        )

        // Parse base damage from skill
        if let damageStr = skill.baseStats["Damage"] {
            calc.baseDamage = parseDamageRange(damageStr)
        }

        // Apply gem level scaling: +10% per level above 1
        let levelScaling = 1.0 + (Double(socket.level - 1) * 0.10)
        calc.baseDamage *= levelScaling

        // Apply gem quality scaling: +2.5% per quality point
        let qualityScaling = 1.0 + (Double(socket.quality) * 0.025)
        calc.baseDamage *= qualityScaling

        // Apply support gem multipliers
        calc.damageMultiplier = socket.damageMultiplier(supportGems: supportGems)

        // For attack skills with weapon
        if skill.gemType == .attack, let weapon = weapon {
            if let aps = Double(weapon.aps) {
                calc.attacksPerSecond = aps
            }
            calc.hitDamage = calc.baseDamage * calc.damageMultiplier
            calc.effectiveDPS = calc.hitDamage * calc.attacksPerSecond
        } else {
            // Spell skills
            calc.castSpeed = 1.0  // Base cast speed
            calc.effectiveDamage = calc.baseDamage * calc.damageMultiplier
            calc.effectiveCastDPS = calc.effectiveDamage * calc.castSpeed
        }

        // Add passive bonuses
        let passiveBonus = calculatePassiveBonus(for: build)

        // Apply passive damage bonuses
        if skill.gemType == .attack {
            let damageBonus = Double(passiveBonus.meleeDamage + passiveBonus.bowDamage + passiveBonus.projectileDamage) / 100.0
            calc.damageMultiplier *= (1.0 + damageBonus)
            calc.hitDamage = calc.baseDamage * calc.damageMultiplier
            calc.effectiveDPS = calc.hitDamage * calc.attacksPerSecond
        } else {
            let spellBonus = Double(passiveBonus.spellDamage + passiveBonus.elementalDamage) / 100.0
            calc.damageMultiplier *= (1.0 + spellBonus)
            calc.effectiveDamage = calc.baseDamage * calc.damageMultiplier
            calc.effectiveCastDPS = calc.effectiveDamage * calc.castSpeed
        }

        // Apply crit from passives (base crit is 5%)
        let critBonus = Double(passiveBonus.critMultiplier) / 100.0
        calc.critMultiplier = 1.5 + critBonus

        // Apply elemental penetration from passives (reduces enemy resist)
        // This would affect effective damage but we just show it in breakdown

        return calc
    }

    private func parseDamageRange(_ str: String) -> Double {
        // Parse "100-150" or just "100"
        let parts = str.split(separator: "-")
        if parts.count == 2,
           let min = Double(parts[0].trimmingCharacters(in: .whitespaces)),
           let max = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
            return (min + max) / 2.0
        } else if let single = Double(str.trimmingCharacters(in: .whitespaces)) {
            return single
        }
        return 0
    }
}

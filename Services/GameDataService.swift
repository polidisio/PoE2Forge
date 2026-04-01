import Foundation
import SwiftUI

@MainActor
class GameDataService: ObservableObject {
    @Published var classes: [CharacterClass] = []
    @Published var skillGems: [SkillGem] = []
    @Published var supportGems: [SupportGem] = []
    @Published var weapons: [Weapon] = []
    @Published var armors: [Armor] = []
    
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
    
    var completionRate: Double {
        guard !runs.isEmpty else { return 0 }
        let completed = runs.filter { $0.completed }.count
        return Double(completed) / Double(runs.count) * 100
    }
    
    var totalDeaths: Int {
        runs.reduce(0) { $0 + $1.deaths }
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
}

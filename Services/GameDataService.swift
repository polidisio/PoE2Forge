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
        classes = loadJSON("classes") ?? []
        skillGems = loadJSON("skillGems") ?? []
        supportGems = loadJSON("supportGems") ?? []
        weapons = loadJSON("weapons") ?? []
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
}

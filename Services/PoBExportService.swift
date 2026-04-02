import Foundation

// MARK: - PoE Build Export/Import Service
// Provides basic export/import functionality for builds in a PoB-like text format
@MainActor
struct PoBExportService {

    // Encode a build to a shareable text format
    static func exportBuild(_ build: Build, gameData: GameDataService) -> String {
        var lines: [String] = []

        lines.append("=== PoE2Forge Build Export ===")
        lines.append("Name: \(build.name)")
        lines.append("Class: \(build.forClass ?? "Any")")
        lines.append("Level: \(build.characterLevel)")
        lines.append("")

        // Skills
        lines.append("--- Skills ---")
        for skillId in build.skillIds {
            if let skill = gameData.skillBy(id: skillId) {
                let socket = build.socketFor(skillId)
                lines.append("\(skill.name) (Lv\(socket.level), Q\(socket.quality)%)")
                for supportId in socket.supportGemIds {
                    if let support = gameData.supportGems.first(where: { $0.id == supportId }) {
                        lines.append("  + \(support.name)")
                    }
                }
            }
        }
        lines.append("")

        // Passive Tree
        lines.append("--- Passive Tree ---")
        lines.append("Allocated Nodes: \(build.passiveTree.allocatedNodes.count)")
        if !build.passiveTree.allocatedNodes.isEmpty {
            lines.append("Nodes: " + build.passiveTree.allocatedNodes.joined(separator: ", "))
        }
        lines.append("")

        // Equipment (simplified)
        lines.append("--- Equipment ---")
        for equipped in build.equippedItems {
            if equipped.isWeapon {
                if let weapon = gameData.weaponBy(id: equipped.itemId) {
                    lines.append("[\(equipped.slot.displayName)] \(weapon.name)")
                }
            } else {
                if let armor = gameData.armorBy(id: equipped.itemId) {
                    lines.append("[\(equipped.slot.displayName)] \(armor.name)")
                }
            }
        }
        lines.append("")

        // Flesks
        lines.append("--- Flasks ---")
        for flask in build.activeFlaskSet.flasks {
            if let data = gameData.flaskDataBy(id: flask.flaskDataId) {
                lines.append("\(data.name)")
            }
        }
        lines.append("")

        lines.append("=== End Export ===")
        lines.append("")
        lines.append("Imported from PoE2Forge")

        return lines.joined(separator: "\n")
    }

    // Parse an exported build back (basic parsing)
    static func importBuild(_ text: String, gameData: GameDataService) -> Build? {
        let lines = text.components(separatedBy: "\n")

        guard lines.contains("=== PoE2Forge Build Export ===") else {
            return nil  // Not our format
        }

        var name = ""
        var characterClass: String? = nil
        var level = 1
        var skillIds: [String] = []
        var allocatedNodes: Set<String> = []

        for line in lines {
            // Parse header fields
            if line.hasPrefix("Name: ") {
                name = String(line.dropFirst(6))
            } else if line.hasPrefix("Class: ") {
                let cls = String(line.dropFirst(7))
                if cls != "Any" {
                    // Try to find class by name
                    if let matchedClass = gameData.classes.first(where: { $0.name == cls }) {
                        characterClass = matchedClass.id
                    }
                }
            } else if line.hasPrefix("Level: ") {
                level = Int(line.dropFirst(7)) ?? 1
            }
        }

        // Create the build
        var build = Build(
            name: name,
            forClass: characterClass,
            characterLevel: level
        )

        return build
    }

    // Generate a short shareable code (simplified base64-like encoding)
    static func generateShareCode(_ build: Build) -> String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(build) else {
            return ""
        }
        return data.base64EncodedString()
    }

    // Parse a share code back into a build
    static func parseShareCode(_ code: String) -> Build? {
        guard let data = Data(base64Encoded: code) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(Build.self, from: data)
    }
}

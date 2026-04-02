import Foundation

// MARK: - Skill Socket (support gems linked to a skill)
struct SkillSocket: Codable, Equatable, Hashable {
    var supportGemIds: [String]
    var level: Int
    var quality: Int

    init(supportGemIds: [String] = [], level: Int = 1, quality: Int = 0) {
        self.supportGemIds = supportGemIds
        self.level = level
        self.quality = quality
    }

    // Calculate the multiplier from support gems
    func damageMultiplier(supportGems: [SupportGem]) -> Double {
        var multiplier = 1.0
        for supportId in supportGemIds {
            guard let support = supportGems.first(where: { $0.id == supportId }) else { continue }
            if let multStr = support.damageMultiplier,
               let mult = parseMultiplier(multStr) {
                multiplier += mult / 100.0
            }
        }
        return multiplier
    }

    private func parseMultiplier(_ str: String) -> Double? {
        // Parse strings like "+20%", "+50%", "+1 chain", etc.
        let numeric = str.replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespaces)

        if let value = Double(numeric) {
            return value
        }
        return nil
    }
}

// MARK: - DPS Calculation Result
struct DPSCalculation: Equatable {
    var skillId: String
    var skillName: String
    var gemLevel: Int
    var gemQuality: Int
    var baseDamage: Double
    var effectiveDamage: Double
    var damageMultiplier: Double
    var attacksPerSecond: Double
    var effectiveDPS: Double
    var hitDamage: Double
    var critChance: Double
    var critMultiplier: Double
    var castSpeed: Double
    var effectiveCastDPS: Double
    var damageType: DamageType?
    var isAttack: Bool

    // Breakdown text for display
    var breakdown: [String] {
        var lines: [String] = []
        lines.append("Gem Level: \(gemLevel), Quality: \(gemQuality)%")
        lines.append("Base Damage: \(String(format: "%.0f", baseDamage))")
        if damageMultiplier != 1.0 {
            lines.append("Multiplier: x\(String(format: "%.2f", damageMultiplier))")
        }
        lines.append("Effective Damage: \(String(format: "%.0f", effectiveDamage))")
        if isAttack {
            lines.append("APS: \(String(format: "%.2f", attacksPerSecond))")
            lines.append("DPS: \(String(format: "%.0f", effectiveDPS))")
        } else {
            lines.append("Cast Speed: \(String(format: "%.2f", castSpeed))/s")
            lines.append("Cast DPS: \(String(format: "%.0f", effectiveCastDPS))")
        }
        if critChance > 0 {
            lines.append("Crit Chance: \(String(format: "%.1f", critChance))%")
            lines.append("Crit Multiplier: x\(String(format: "%.2f", critMultiplier))")
            let avgCritDPS = effectiveDPS * (1 + (critChance / 100) * (critMultiplier - 1))
            lines.append("Avg DPS (w/ crit): \(String(format: "%.0f", avgCritDPS))")
        }
        return lines
    }
}

// MARK: - Full Build DPS Summary
struct BuildDPSSummary: Equatable {
    var totalMeleeDPS: Double = 0
    var totalSpellDPS: Double = 0
    var totalProjectileDPS: Double = 0
    var totalDPS: Double = 0
    var skillCalculations: [DPSCalculation] = []

    var summaryLines: [String] {
        var lines: [String] = []
        lines.append("=== DPS SUMMARY ===")
        if totalMeleeDPS > 0 {
            lines.append("Melee DPS: \(String(format: "%.0f", totalMeleeDPS))")
        }
        if totalProjectileDPS > 0 {
            lines.append("Projectile DPS: \(String(format: "%.0f", totalProjectileDPS))")
        }
        if totalSpellDPS > 0 {
            lines.append("Spell DPS: \(String(format: "%.0f", totalSpellDPS))")
        }
        lines.append("-------------------")
        lines.append("TOTAL DPS: \(String(format: "%.0f", totalDPS))")
        return lines
    }
}

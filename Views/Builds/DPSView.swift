import SwiftUI

struct DPSView: View {
    @EnvironmentObject var gameData: GameDataService
    let build: Build

    var dpsSummary: BuildDPSSummary {
        gameData.calculateBuildDPS(for: build)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("DAMAGE CALCULATOR")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }

            // Total DPS highlight
            VStack(spacing: 4) {
                Text("TOTAL DPS")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(formatNumber(dpsSummary.totalDPS))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "e07020"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(hex: "1a1a24"))
            .cornerRadius(12)

            // DPS breakdown by category
            HStack(spacing: 12) {
                if dpsSummary.totalMeleeDPS > 0 {
                    DPSCategoryCard(
                        title: "Melee",
                        value: dpsSummary.totalMeleeDPS,
                        icon: "sword",
                        color: .red
                    )
                }
                if dpsSummary.totalProjectileDPS > 0 {
                    DPSCategoryCard(
                        title: "Projectile",
                        value: dpsSummary.totalProjectileDPS,
                        icon: "arrow.right",
                        color: .green
                    )
                }
                if dpsSummary.totalSpellDPS > 0 {
                    DPSCategoryCard(
                        title: "Spell",
                        value: dpsSummary.totalSpellDPS,
                        icon: "sparkles",
                        color: .blue
                    )
                }
            }

            // Damage Type Breakdown
            DamageTypeBreakdownView(calculations: dpsSummary.skillCalculations)

            // Individual skill breakdowns
            if !dpsSummary.skillCalculations.isEmpty {
                Divider().background(Color.gray.opacity(0.3))

                Text("SKILL BREAKDOWN")
                    .font(.caption)
                    .foregroundColor(.gray)

                ForEach(dpsSummary.skillCalculations, id: \.skillId) { calc in
                    SkillDPSRow(calc: calc)
                }
            }
        }
        .padding()
        .background(Color(hex: "0a0a0f"))
    }

    func formatNumber(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

struct DPSCategoryCard: View {
    let title: String
    let value: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
            Text(formatValue(value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "1a1a24"))
        .cornerRadius(8)
    }

    func formatValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

struct SkillDPSRow: View {
    @State private var expanded = false
    let calc: DPSCalculation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                expanded.toggle()
            } label: {
                HStack {
                    Circle()
                        .fill(damageTypeColor(calc.damageType))
                        .frame(width: 8, height: 8)

                    Text(calc.skillName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Spacer()

                    if calc.isAttack {
                        Text("\(formatNumber(calc.effectiveDPS)) DPS")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "e07020"))
                    } else {
                        Text("\(formatNumber(calc.effectiveCastDPS)) Cast DPS")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "e07020"))
                    }

                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if expanded {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(calc.breakdown, id: \.self) { line in
                        Text(line)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding(.vertical, 4)
    }

    func formatNumber(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return String(format: "%.0f", value)
    }

    func damageTypeColor(_ type: DamageType?) -> Color {
        switch type {
        case .fire: return .orange
        case .cold: return .cyan
        case .lightning: return .yellow
        case .physical: return .brown
        case .chaos: return .purple
        case .holy: return .white
        case .none: return .gray
        }
    }
}

// MARK: - Damage Type Breakdown
struct DamageTypeBreakdownView: View {
    let calculations: [DPSCalculation]

    var damageByType: [DamageType: Double] {
        var result: [DamageType: Double] = [:]
        for calc in calculations {
            if let type = calc.damageType {
                let dps = calc.isAttack ? calc.effectiveDPS : calc.effectiveCastDPS
                result[type, default: 0] += dps
            } else {
                // Default to physical for unknown
                let dps = calc.isAttack ? calc.effectiveDPS : calc.effectiveCastDPS
                result[.physical, default: 0] += dps
            }
        }
        return result
    }

    var totalDamage: Double {
        damageByType.values.reduce(0, +)
    }

    var body: some View {
        if !damageByType.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("DAMAGE TYPE BREAKDOWN")
                    .font(.caption)
                    .foregroundColor(.gray)

                // Horizontal bar
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(Array(damageByType.keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { type in
                            let value = damageByType[type] ?? 0
                            let width = totalDamage > 0 ? (value / totalDamage) * geo.size.width : 0
                            Rectangle()
                                .fill(damageTypeColor(type))
                                .frame(width: max(width, 4))
                        }
                    }
                }
                .frame(height: 16)
                .cornerRadius(4)

                // Legend
                VStack(spacing: 6) {
                    ForEach(Array(damageByType.keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { type in
                        let value = damageByType[type] ?? 0
                        let percent = totalDamage > 0 ? (value / totalDamage) * 100 : 0
                        HStack {
                            Circle()
                                .fill(damageTypeColor(type))
                                .frame(width: 10, height: 10)
                            Text(damageTypeName(type))
                                .font(.caption)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(percent))%")
                                .font(.caption)
                                .foregroundColor(Color(hex: "e07020"))
                            Text("(\(formatNumber(value)))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
            .background(Color(hex: "1a1a24"))
            .cornerRadius(12)
        }
    }

    func damageTypeName(_ type: DamageType) -> String {
        switch type {
        case .fire: return "Fire"
        case .cold: return "Cold"
        case .lightning: return "Lightning"
        case .physical: return "Physical"
        case .chaos: return "Chaos"
        case .holy: return "Holy"
        }
    }

    func damageTypeColor(_ type: DamageType) -> Color {
        switch type {
        case .fire: return .orange
        case .cold: return .cyan
        case .lightning: return .yellow
        case .physical: return Color(hex: "8B4513")
        case .chaos: return .purple
        case .holy: return .white
        }
    }

    func formatNumber(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

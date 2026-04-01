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

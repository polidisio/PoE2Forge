import SwiftUI

struct BuildDetailView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let build: Build

    @State private var showingEditor = false
    @State private var showingGearPicker = false
    @State private var showingPassiveTree = false
    @State private var showingSkillSocket = false
    @State private var showingDPS = false
    @State private var selectedSlot: EquipmentSlot?

    var stats: CharacterStats {
        gameData.calculateStats(for: build)
    }

    var validation: EquipmentValidationResult {
        gameData.validateEquipment(for: build)
    }

    var passiveBonus: PassiveBonus {
        gameData.calculatePassiveBonus(for: build)
    }

    var dpsSummary: BuildDPSSummary {
        gameData.calculateBuildDPS(for: build)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Character visualization
                    CharacterView(build: build)
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)

                    // Passive Tree button
                    Button {
                        showingPassiveTree = true
                    } label: {
                        HStack {
                            Image(systemName: "circle.hexagongrid")
                                .foregroundColor(Color(hex: "e07020"))
                            Text("Passive Tree")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(build.passiveTree.allocatedNodes.count) pts")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                    }

                    // DPS Calculator button
                    Button {
                        showingDPS = true
                    } label: {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("DPS Calculator")
                                .foregroundColor(.white)
                            Spacer()
                            Text(formatNumber(dpsSummary.totalDPS))
                                .foregroundColor(Color(hex: "e07020"))
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                    }

                    // Stats breakdown
                    StatsBreakdownView(stats: stats)

                    // Requirement warnings
                    if !validation.isValid {
                        RequirementWarningsView(failures: validation.failedRequirements)
                    }

                    // Skills list with socket button
                    SkillsListView(
                        skillIds: build.skillIds,
                        onSocketTap: {
                            showingSkillSocket = true
                        }
                    )

                    // Equipment slot details
                    EquipmentSlotDetailsView(build: build, onSlotTap: { slot in
                        selectedSlot = slot
                        showingGearPicker = true
                    })
                }
                .padding()
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(build.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditor = true
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            .sheet(isPresented: $showingEditor) {
                BuildEditorView(build: build)
            }
            .sheet(isPresented: $showingGearPicker) {
                if let slot = selectedSlot {
                    SlotGearPickerView(slot: slot, currentBuild: build)
                }
            }
            .sheet(isPresented: $showingPassiveTree) {
                PassiveTreeView(build: .constant(build))
            }
            .sheet(isPresented: $showingSkillSocket) {
                SkillSocketView(build: .constant(build))
            }
            .sheet(isPresented: $showingDPS) {
                DPSView(build: build)
            }
        }
    }

    func formatNumber(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

struct StatsBreakdownView: View {
    let stats: CharacterStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CHARACTER STATS")
                .font(.caption)
                .foregroundColor(.gray)

            StatRow(label: "Strength", base: stats.strength, bonus: stats.additionalStrength, total: stats.totalStrength, color: .red)
            StatRow(label: "Dexterity", base: stats.dexterity, bonus: stats.additionalDexterity, total: stats.totalDexterity, color: .green)
            StatRow(label: "Intelligence", base: stats.intelligence, bonus: stats.additionalIntelligence, total: stats.totalIntelligence, color: .blue)

            Divider().background(Color.gray.opacity(0.3))

            HStack {
                Text("Total Defense")
                    .foregroundColor(.white)
                Spacer()
                Text("\(stats.totalDefense)")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "60a5fa"))
            }

            HStack {
                Text("Character Level")
                    .foregroundColor(.white)
                Spacer()
                Text("\(stats.totalLevel)")
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "e07020"))
            }
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
    }
}

struct StatRow: View {
    let label: String
    let base: Int
    let bonus: Int
    let total: Int
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.white)
            Spacer()
            if bonus > 0 {
                Text("\(total) (+\(bonus))")
                    .foregroundColor(Color(hex: "22c55e"))
            } else {
                Text("\(total)")
                    .foregroundColor(.white)
            }
        }
    }
}

struct RequirementWarningsView: View {
    let failures: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("REQUIREMENT WARNINGS")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            ForEach(failures, id: \.self) { failure in
                Text("• \(failure)")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color(hex: "2a2a1a"))
        .cornerRadius(16)
    }
}

struct SkillsListView: View {
    @EnvironmentObject var gameData: GameDataService
    let skillIds: [String]
    var onSocketTap: (() -> Void)? = nil

    var skills: [SkillGem] {
        skillIds.compactMap { gameData.skillBy(id: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SKILLS")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                if onSocketTap != nil && !skills.isEmpty {
                    Button {
                        onSocketTap?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "link.circle")
                                .font(.caption)
                            Text("Socket")
                                .font(.caption)
                        }
                        .foregroundColor(Color(hex: "e07020"))
                    }
                }
            }

            if skills.isEmpty {
                Text("No skills selected")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(skills) { skill in
                    HStack {
                        Circle()
                            .fill(damageTypeColor(skill.damageType))
                            .frame(width: 8, height: 8)
                        Text(skill.name)
                            .foregroundColor(.white)
                        Spacer()
                        Text(skill.gemType.displayName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
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

struct EquipmentSlotDetailsView: View {
    @EnvironmentObject var gameData: GameDataService
    let build: Build
    let onSlotTap: (EquipmentSlot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EQUIPMENT")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(EquipmentSlot.allCases) { slot in
                let item = gameData.itemIn(slot: slot, for: build)
                Button {
                    onSlotTap(slot)
                } label: {
                    SlotDetailRow(
                        slot: slot,
                        weapon: item.weapon,
                        armor: item.armor
                    )
                }
            }
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
    }
}

struct SlotDetailRow: View {
    let slot: EquipmentSlot
    let weapon: Weapon?
    let armor: Armor?

    var body: some View {
        HStack {
            Image(systemName: slot.icon)
                .foregroundColor(.gray)
                .frame(width: 24)

            Text(slot.displayName)
                .foregroundColor(.gray)

            Spacer()

            if let weapon = weapon {
                Text(weapon.name)
                    .foregroundColor(Color(hex: weapon.rarity.color))
                Text(weapon.damage + " dmg")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else if let armor = armor {
                Text(armor.name)
                    .foregroundColor(Color(hex: armor.rarity.color))
                Text(armor.defense + " def")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Empty")
                    .foregroundColor(.gray)
                    .italic()
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

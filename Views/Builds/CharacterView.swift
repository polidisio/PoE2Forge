import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var gameData: GameDataService
    let build: Build

    var body: some View {
        VStack(spacing: 16) {
            // Character portrait
            ZStack {
                Circle()
                    .fill(Color(hex: "2f2f40"))
                    .frame(width: 80, height: 80)

                if let classId = build.forClass, let charClass = gameData.classBy(id: classId) {
                    Text(String(charClass.name.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }

            // Class name
            if let classId = build.forClass, let charClass = gameData.classBy(id: classId) {
                Text(charClass.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "e07020"))
            } else {
                Text("Universal Build")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            // Stats bar
            StatsBar(stats: gameData.calculateStats(for: build))

            // Equipment slots grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(EquipmentSlot.allCases) { slot in
                    let item = gameData.itemIn(slot: slot, for: build)
                    EquipmentSlotView(
                        slot: slot,
                        weapon: item.weapon,
                        armor: item.armor
                    )
                }
            }
        }
        .padding()
    }
}

struct EquipmentSlotView: View {
    let slot: EquipmentSlot
    let weapon: Weapon?
    let armor: Armor?

    private var isEquipped: Bool {
        weapon != nil || armor != nil
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEquipped ? Color(hex: "2f2f40") : Color(hex: "1a1a24"))
                    .frame(height: 60)

                if let weapon = weapon {
                    VStack(spacing: 2) {
                        Text(weapon.name.prefix(8))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: weapon.rarity.color))
                            .lineLimit(1)
                        Text(weapon.weaponType.displayName)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else if let armor = armor {
                    VStack(spacing: 2) {
                        Text(armor.name.prefix(8))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: armor.rarity.color))
                            .lineLimit(1)
                        Text(armor.armorType.displayName)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: slot.icon)
                        .foregroundColor(.gray.opacity(0.5))
                }
            }

            Text(slot.displayName)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct StatsBar: View {
    let stats: CharacterStats

    var body: some View {
        HStack(spacing: 16) {
            StatBadge(icon: "figure.strengthtraining.traditional", value: stats.totalStrength, bonus: stats.additionalStrength, color: .red)
            StatBadge(icon: "figure.agility", value: stats.totalDexterity, bonus: stats.additionalDexterity, color: .green)
            StatBadge(icon: "brain", value: stats.totalIntelligence, bonus: stats.additionalIntelligence, color: .blue)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: Int
    let bonus: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(value)")
                .fontWeight(.bold)
                .foregroundColor(.white)
            if bonus > 0 {
                Text("+\(bonus)")
                    .font(.caption)
                    .foregroundColor(Color(hex: "22c55e"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "1a1a24"))
        .cornerRadius(8)
    }
}

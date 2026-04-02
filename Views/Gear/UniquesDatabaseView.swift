import SwiftUI

struct UniquesDatabaseView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedItem: UniqueItem?
    @State private var minLevel = 1
    @State private var maxLevel = 100

    var uniqueWeapons: [UniqueItem] {
        gameData.weapons
            .filter { $0.rarity == .unique }
            .map { UniqueItem(fromWeapon: $0) }
    }

    var uniqueArmors: [UniqueItem] {
        gameData.armors
            .filter { $0.rarity == .unique }
            .map { UniqueItem(fromArmor: $0) }
    }

    var filteredWeapons: [UniqueItem] {
        uniqueWeapons.filter { item in
            let meetsLevel = item.levelRequirement >= minLevel && item.levelRequirement <= maxLevel
            let meetsSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText)
            return meetsLevel && meetsSearch
        }
    }

    var filteredArmors: [UniqueItem] {
        uniqueArmors.filter { item in
            let meetsLevel = item.levelRequirement >= minLevel && item.levelRequirement <= maxLevel
            let meetsSearch = searchText.isEmpty ||
                item.name.localizedCaseInsensitiveContains(searchText)
            return meetsLevel && meetsSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tabs
                Picker("Item Type", selection: $selectedTab) {
                    Text("Weapons").tag(0)
                    Text("Armor").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Level filter
                HStack {
                    Text("Level:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Slider(value: Binding(
                        get: { Double(minLevel) },
                        set: { minLevel = Int($0) }
                    ), in: 1...100, step: 1)
                    .tint(Color(hex: "e07020"))
                    Text("\(minLevel)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 30)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                if selectedTab == 0 {
                    uniquesList(items: filteredWeapons)
                } else {
                    uniquesList(items: filteredArmors)
                }
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Uniques Database")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search uniques...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            .sheet(item: $selectedItem) { item in
                UniqueItemDetailSheet(item: item)
                    .presentationDetents([.large])
            }
        }
    }

    func uniquesList(items: [UniqueItem]) -> some View {
        Group {
            if items.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "star.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No uniques found")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Try adjusting your filters")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                List {
                    ForEach(items) { item in
                        UniqueItemRow(item: item)
                            .listRowBackground(Color(hex: "1a1a24"))
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct UniqueItem: Identifiable {
    let id: String
    let name: String
    let type: String
    let rarity: ItemRarity
    let defense: String?
    let damage: String?
    let aps: String?
    let requirements: Requirements
    let isWeapon: Bool

    var levelRequirement: Int {
        requirements.level
    }

    var primaryStat: String {
        if isWeapon {
            return (damage ?? "0") + " dmg" + (aps != nil ? " (\(aps!) APS)" : "")
        } else {
            return (defense ?? "0") + " DEF"
        }
    }

    init(fromWeapon weapon: Weapon) {
        self.id = weapon.id
        self.name = weapon.name
        self.type = weapon.weaponType.displayName
        self.rarity = weapon.rarity
        self.defense = nil
        self.damage = weapon.damage
        self.aps = weapon.aps
        self.requirements = weapon.requirements
        self.isWeapon = true
    }

    init(fromArmor armor: Armor) {
        self.id = armor.id
        self.name = armor.name
        self.type = armor.armorType.displayName
        self.rarity = armor.rarity
        self.defense = armor.defense
        self.damage = nil
        self.aps = nil
        self.requirements = armor.requirements
        self.isWeapon = false
    }
}

struct UniqueItemRow: View {
    let item: UniqueItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: itemIcon)
                .font(.title2)
                .foregroundColor(Color(hex: item.rarity.color))
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: item.rarity.color))

                HStack(spacing: 8) {
                    Text(item.type)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "2f2f40"))
                        .cornerRadius(4)
                        .foregroundColor(.white)

                    Text("Lvl \(item.levelRequirement)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.primaryStat)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)

                requirementStats
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }

    var itemIcon: String {
        if item.isWeapon {
            return "sword"
        } else {
            switch item.type.lowercased() {
            case "helmet": return "person.fill"
            case "body armor": return "tshirt"
            case "gloves": return "hand.raised"
            case "boots": return "shoeprints.fill"
            case "shield": return "shield.fill"
            case "ring": return "circle.circle"
            case "amulet": return "lanyardcard"
            case "belt": return "minus"
            default: return "shield"
            }
        }
    }

    var requirementStats: some View {
        HStack(spacing: 4) {
            if let str = item.requirements.strength, str > 0 {
                Text("STR \(str)")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            if let dex = item.requirements.dexterity, dex > 0 {
                Text("DEX \(dex)")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            if let int = item.requirements.intelligence, int > 0 {
                Text("INT \(int)")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct UniqueItemDetailSheet: View {
    let item: UniqueItem

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: item.isWeapon ? "sword" : "shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: item.rarity.color))

                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: item.rarity.color))
                            .multilineTextAlignment(.center)

                        Text(item.type)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STATS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Text(item.isWeapon ? "Damage" : "Defense")
                                .foregroundColor(.white)
                            Spacer()
                            Text(item.primaryStat)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }

                        if let aps = item.aps {
                            HStack {
                                Text("Attack Speed")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(aps + " APS")
                                    .foregroundColor(Color(hex: "60a5fa"))
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // Requirements
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REQUIREMENTS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Text("Level")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(item.levelRequirement)")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "e07020"))
                        }

                        if let str = item.requirements.strength, str > 0 {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Strength")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(str)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                        }

                        if let dex = item.requirements.dexterity, dex > 0 {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Dexterity")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(dex)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }

                        if let int = item.requirements.intelligence, int > 0 {
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                Text("Intelligence")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(int)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // Info
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("Unique items have special properties not found on regular items")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                .padding()
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

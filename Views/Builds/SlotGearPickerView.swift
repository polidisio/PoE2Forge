import SwiftUI

struct SlotGearPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let slot: EquipmentSlot
    @Binding var build: Build

    @State private var searchText = ""
    @State private var selectedItemId: String?
    @State private var selectedIsWeapon: Bool = false
    @State private var showAllItems: Bool = false

    // Currently equipped item
    var currentlyEquipped: EquippedItem? {
        build.item(in: slot)
    }

    // Character stats for level filtering
    var characterLevel: Int {
        build.characterLevel
    }

    var characterStats: CharacterStats {
        gameData.calculateStats(for: build)
    }

    // Comparison when item is selected
    var itemComparison: ItemComparison? {
        guard let selectedId = selectedItemId else { return nil }
        return gameData.compareItems(
            oldItemId: currentlyEquipped?.itemId,
            newItemId: selectedId,
            isWeapon: selectedIsWeapon
        )
    }

    // Determine what type of items can be equipped in this slot
    var canEquipWeapon: Bool {
        switch slot {
        case .mainHand, .offHand:
            return true
        default:
            return false
        }
    }

    var canEquipArmor: Bool {
        switch slot {
        case .mainHand, .offHand:
            return false
        default:
            return true
        }
    }

    // Get the armor type for this slot
    func armorTypeForSlot(_ slot: EquipmentSlot) -> ArmorType? {
        switch slot {
        case .head: return .helmet
        case .body: return .bodyArmor
        case .hands: return .gloves
        case .feet: return .boots
        case .amulet: return .amulet
        case .belt: return .belt
        case .ring1, .ring2: return .ring
        default: return nil
        }
    }

    // Check if item meets requirements
    func canEquip(weapon: Weapon) -> Bool {
        let reqs = weapon.requirements
        if characterLevel < reqs.level { return false }
        if let str = reqs.strength, characterStats.totalStrength < str { return false }
        if let dex = reqs.dexterity, characterStats.totalDexterity < dex { return false }
        if let int = reqs.intelligence, characterStats.totalIntelligence < int { return false }
        return true
    }

    func canEquip(armor: Armor) -> Bool {
        let reqs = armor.requirements
        if characterLevel < reqs.level { return false }
        if let str = reqs.strength, characterStats.totalStrength < str { return false }
        if let dex = reqs.dexterity, characterStats.totalDexterity < dex { return false }
        if let int = reqs.intelligence, characterStats.totalIntelligence < int { return false }
        return true
    }

    // Filtered weapons by search and level
    var filteredWeapons: [Weapon] {
        gameData.weapons.filter { weapon in
            let searchMatch = searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(searchText)
            return searchMatch
        }
    }

    var equippableWeapons: [Weapon] {
        filteredWeapons.filter { canEquip(weapon: $0) }
    }

    var unequippableWeapons: [Weapon] {
        filteredWeapons.filter { !canEquip(weapon: $0) }
    }

    // Filtered armors by search and level
    var filteredArmors: [Armor] {
        guard let armorType = armorTypeForSlot(slot) else { return [] }
        return gameData.armors.filter { armor in
            let typeMatch = armor.armorType == armorType
            let searchMatch = searchText.isEmpty || armor.name.localizedCaseInsensitiveContains(searchText)
            return typeMatch && searchMatch
        }
    }

    var equippableArmors: [Armor] {
        filteredArmors.filter { canEquip(armor: $0) }
    }

    var unequippableArmors: [Armor] {
        filteredArmors.filter { !canEquip(armor: $0) }
    }

    var body: some View {
        NavigationStack {
            List {
                // Character level header
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Character Level")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(characterLevel)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Toggle("Show All Items", isOn: $showAllItems)
                            .toggleStyle(.switch)
                            .tint(Color(hex: "e07020"))
                            .labelsHidden()

                        Text(showAllItems ? "Showing All" : "Equippable Only")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color(hex: "1a1a24"))

                // Currently equipped section
                if let equipped = build.item(in: slot) {
                    Section("CURRENTLY EQUIPPED") {
                        if let weapon = gameData.weaponBy(id: equipped.itemId) {
                            WeaponPickerRow(weapon: weapon, isSelected: true, isEquippable: true) {
                                unequipSlot()
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        } else if let armor = gameData.armorBy(id: equipped.itemId) {
                            ArmorPickerRow(armor: armor, isSelected: true, isEquippable: true) {
                                unequipSlot()
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available weapons - equippable
                if canEquipWeapon && !equippableWeapons.isEmpty {
                    Section("WEAPONS (EQUIPPABLE)") {
                        ForEach(equippableWeapons) { weapon in
                            WeaponPickerRow(weapon: weapon, isSelected: false, isEquippable: true) {
                                selectWeapon(weapon)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available weapons - unequippable
                if canEquipWeapon && showAllItems && !unequippableWeapons.isEmpty {
                    Section("WEAPONS (LEVEL TOO HIGH)") {
                        ForEach(unequippableWeapons) { weapon in
                            WeaponPickerRow(weapon: weapon, isSelected: false, isEquippable: false) {
                                selectWeapon(weapon)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available armor - equippable
                if canEquipArmor && !equippableArmors.isEmpty {
                    Section("ARMOR (\(slot.displayName.uppercased())) - EQUIPPABLE") {
                        ForEach(equippableArmors) { armor in
                            ArmorPickerRow(armor: armor, isSelected: false, isEquippable: true) {
                                selectArmor(armor)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available armor - unequippable
                if canEquipArmor && showAllItems && !unequippableArmors.isEmpty {
                    Section("ARMOR (LEVEL TOO HIGH)") {
                        ForEach(unequippableArmors) { armor in
                            ArmorPickerRow(armor: armor, isSelected: false, isEquippable: false) {
                                selectArmor(armor)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(slot.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            // Comparison panel at bottom
            if let comparison = itemComparison, selectedItemId != nil {
                ItemComparisonPanel(
                    comparison: comparison,
                    onEquip: {
                        if selectedIsWeapon, let weapon = gameData.weaponBy(id: selectedItemId!) {
                            equipWeapon(weapon)
                        } else if let armor = gameData.armorBy(id: selectedItemId!) {
                            equipArmor(armor)
                        }
                        selectedItemId = nil
                    },
                    onCancel: {
                        selectedItemId = nil
                    }
                )
            }
        }
    }

    func selectWeapon(_ weapon: Weapon) {
        selectedItemId = weapon.id
        selectedIsWeapon = true
    }

    func selectArmor(_ armor: Armor) {
        selectedItemId = armor.id
        selectedIsWeapon = false
    }

    func unequipSlot() {
        build.removeItem(in: slot)
        gameData.saveBuild(build)
    }

    func equipWeapon(_ weapon: Weapon) {
        // If two-handed weapon, remove offHand item
        if weapon.weaponType.isTwoHanded {
            build.removeItem(in: .offHand)
        }

        // Equip new weapon
        build.updateItem(EquippedItem(
            itemId: weapon.id,
            slot: slot,
            isWeapon: true
        ))

        gameData.saveBuild(build)
        dismiss()
    }

    func equipArmor(_ armor: Armor) {
        // Handle ring slot - alternate between ring1 and ring2
        var actualSlot = slot
        if slot == .ring1 || slot == .ring2 {
            if build.item(in: .ring1) != nil && build.item(in: .ring2) != nil {
                // Both rings full, replace ring1
                build.removeItem(in: .ring1)
                actualSlot = .ring1
            } else if build.item(in: .ring1) != nil {
                actualSlot = .ring2
            }
        }

        build.updateItem(EquippedItem(
            itemId: armor.id,
            slot: actualSlot,
            isWeapon: false
        ))

        gameData.saveBuild(build)
        dismiss()
    }
}

struct WeaponPickerRow: View {
    let weapon: Weapon
    let isSelected: Bool
    let isEquippable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weapon.name)
                        .fontWeight(.medium)
                        .foregroundColor(isEquippable ? Color(hex: weapon.rarity.color) : .gray)
                    HStack {
                        Text(weapon.weaponType.displayName)
                        Text("Lvl \(weapon.requirements.level)")
                            .foregroundColor(isEquippable ? .gray : .red)
                    }
                    .font(.caption)
                    .foregroundColor(isEquippable ? .gray : .red)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(weapon.damage + " dmg")
                        .font(.subheadline)
                        .foregroundColor(isEquippable ? .orange : .gray)
                    Text(weapon.aps + " APS")
                        .font(.caption)
                        .foregroundColor(isEquippable ? .gray : .gray.opacity(0.5))
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "e07020"))
                        .padding(.leading, 8)
                }
            }
        }
        .opacity(isEquippable ? 1.0 : 0.5)
    }
}

struct ArmorPickerRow: View {
    let armor: Armor
    let isSelected: Bool
    let isEquippable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(armor.name)
                        .fontWeight(.medium)
                        .foregroundColor(isEquippable ? Color(hex: armor.rarity.color) : .gray)
                    HStack {
                        Text(armor.armorType.displayName)
                        Text("Lvl \(armor.requirements.level)")
                    }
                    .font(.caption)
                    .foregroundColor(isEquippable ? .gray : .red)
                }

                Spacer()

                Text(armor.defense + " def")
                    .font(.subheadline)
                    .foregroundColor(isEquippable ? Color(hex: "60a5fa") : .gray)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "e07020"))
                        .padding(.leading, 8)
                }
            }
        }
        .opacity(isEquippable ? 1.0 : 0.5)
    }
}

struct ItemComparisonPanel: View {
    let comparison: ItemComparison
    let onEquip: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("COMPARING")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(comparison.itemName)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(comparison.summaryText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(comparison.isImprovement ? .green : (comparison.isWorse ? .red : .gray))
            }

            // Stat differences
            if comparison.hasOldItem {
                VStack(spacing: 6) {
                    ForEach(comparison.statDiffs) { diff in
                        HStack {
                            Text(diff.statName)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            if !diff.isSame {
                                Text(diff.diffText)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(diff.isImprovement ? .green : .red)
                            } else {
                                Text("-")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            } else {
                Text("New item - no comparison available")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .italic()
            }

            // Action buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.gray)

                Button("Equip") {
                    onEquip()
                }
                .foregroundColor(Color(hex: "e07020"))
                .fontWeight(.bold)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
        .padding()
    }
}

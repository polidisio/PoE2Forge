import SwiftUI

struct SlotGearPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let slot: EquipmentSlot
    let currentBuild: Build

    @State private var searchText = ""
    @State private var draftBuild: Build

    init(slot: EquipmentSlot, currentBuild: Build) {
        self.slot = slot
        self.currentBuild = currentBuild
        self._draftBuild = State(initialValue: currentBuild)
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

    var filteredWeapons: [Weapon] {
        gameData.weapons.filter { weapon in
            searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredArmors: [Armor] {
        guard let armorType = armorTypeForSlot(slot) else { return [] }
        return gameData.armors.filter { armor in
            let typeMatch = armor.armorType == armorType
            let searchMatch = searchText.isEmpty || armor.name.localizedCaseInsensitiveContains(searchText)
            return typeMatch && searchMatch
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Currently equipped section
                if let equipped = draftBuild.item(in: slot) {
                    Section("CURRENTLY EQUIPPED") {
                        if let weapon = gameData.weaponBy(id: equipped.itemId) {
                            WeaponPickerRow(weapon: weapon, isSelected: true) {
                                unequipSlot()
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        } else if let armor = gameData.armorBy(id: equipped.itemId) {
                            ArmorPickerRow(armor: armor, isSelected: true) {
                                unequipSlot()
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available weapons
                if canEquipWeapon && !filteredWeapons.isEmpty {
                    Section("WEAPONS") {
                        ForEach(filteredWeapons) { weapon in
                            WeaponPickerRow(weapon: weapon, isSelected: false) {
                                equipWeapon(weapon)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }

                // Available armor
                if canEquipArmor && !filteredArmors.isEmpty {
                    Section("ARMOR (\(slot.displayName.uppercased()))") {
                        ForEach(filteredArmors) { armor in
                            ArmorPickerRow(armor: armor, isSelected: false) {
                                equipArmor(armor)
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
        }
    }

    func unequipSlot() {
        draftBuild.equippedItems.removeAll { $0.slot == slot }
        gameData.saveBuild(draftBuild)
    }

    func equipWeapon(_ weapon: Weapon) {
        // Remove any existing item in this slot
        draftBuild.equippedItems.removeAll { $0.slot == slot }

        // If two-handed weapon, remove offHand item
        if weapon.weaponType.isTwoHanded {
            draftBuild.equippedItems.removeAll { $0.slot == .offHand }
        }

        // Equip new weapon
        draftBuild.equippedItems.append(EquippedItem(
            itemId: weapon.id,
            slot: slot,
            isWeapon: true
        ))

        gameData.saveBuild(draftBuild)
        dismiss()
    }

    func equipArmor(_ armor: Armor) {
        // Remove any existing item in this slot
        draftBuild.equippedItems.removeAll { $0.slot == slot }

        // Handle ring slot - alternate between ring1 and ring2
        var actualSlot = slot
        if slot == .ring1 || slot == .ring2 {
            if draftBuild.item(in: .ring1) != nil && draftBuild.item(in: .ring2) != nil {
                // Both rings full, replace ring1
                draftBuild.equippedItems.removeAll { $0.slot == .ring1 }
                actualSlot = .ring1
            } else if draftBuild.item(in: .ring1) != nil {
                actualSlot = .ring2
            }
        }

        draftBuild.equippedItems.append(EquippedItem(
            itemId: armor.id,
            slot: actualSlot,
            isWeapon: false
        ))

        gameData.saveBuild(draftBuild)
        dismiss()
    }
}

struct WeaponPickerRow: View {
    let weapon: Weapon
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weapon.name)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: weapon.rarity.color))
                    HStack {
                        Text(weapon.weaponType.displayName)
                        Text("Lvl \(weapon.requirements.level)")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(weapon.damage + " dmg")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    Text(weapon.aps + " APS")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "e07020"))
                        .padding(.leading, 8)
                }
            }
        }
    }
}

struct ArmorPickerRow: View {
    let armor: Armor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(armor.name)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: armor.rarity.color))
                    HStack {
                        Text(armor.armorType.displayName)
                        Text("Lvl \(armor.requirements.level)")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }

                Spacer()

                Text(armor.defense + " def")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "60a5fa"))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "e07020"))
                        .padding(.leading, 8)
                }
            }
        }
    }
}

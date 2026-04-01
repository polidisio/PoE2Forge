import SwiftUI

struct GearView: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedWeaponType: WeaponType? = nil
    @State private var selectedArmorType: ArmorType? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tabs
                Picker("Gear Type", selection: $selectedTab) {
                    Text("Weapons").tag(0)
                    Text("Armor").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    weaponsView
                } else {
                    armorView
                }
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Gear")
            .searchable(text: $searchText, prompt: "Search gear...")
        }
    }
    
    var weaponsView: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: selectedWeaponType == nil) {
                        selectedWeaponType = nil
                    }
                    ForEach(WeaponType.allCases, id: \.self) { type in
                        FilterChip(title: type.displayName, isSelected: selectedWeaponType == type) {
                            selectedWeaponType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(hex: "1a1a24"))
            
            List {
                ForEach(filteredWeapons) { weapon in
                    WeaponRow(weapon: weapon)
                        .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
    
    var filteredWeapons: [Weapon] {
        var weapons = gameData.weapons
        
        if let type = selectedWeaponType {
            weapons = weapons.filter { $0.weaponType == type }
        }
        
        if !searchText.isEmpty {
            weapons = weapons.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return weapons
    }
    
    var armorView: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: selectedArmorType == nil) {
                        selectedArmorType = nil
                    }
                    ForEach(ArmorType.allCases, id: \.self) { type in
                        FilterChip(title: type.displayName, isSelected: selectedArmorType == type) {
                            selectedArmorType = type
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(hex: "1a1a24"))
            
            List {
                ForEach(filteredArmors) { armor in
                    ArmorRow(armor: armor)
                        .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
    
    var filteredArmors: [Armor] {
        var armors = gameData.armors
        
        if let type = selectedArmorType {
            armors = armors.filter { $0.armorType == type }
        }
        
        if !searchText.isEmpty {
            armors = armors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return armors
    }
}

struct WeaponRow: View {
    let weapon: Weapon
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: weaponIcon)
                .font(.title2)
                .foregroundColor(Color(hex: weapon.rarity.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(weapon.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(weapon.weaponType.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Lvl \(weapon.requirements.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(weapon.damage)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(weapon.aps + " APS")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    var weaponIcon: String {
        switch weapon.weaponType {
        case .oneHandSword, .twoHandSword: return "sword"
        case .oneHandAxe, .twoHandAxe: return "axe"
        case .bow: return "figure.archery"
        case .dagger, .claw: return "hand.point.up.left"
        case .staff, .warstaff: return "staff"
        case .wand: return "wand.and.rays"
        default: return "shield"
        }
    }
}

struct ArmorRow: View {
    let armor: Armor
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: armorIcon)
                .font(.title2)
                .foregroundColor(Color(hex: armor.rarity.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(armor.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(armor.armorType.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Lvl \(armor.requirements.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Text(armor.defense + " DEF")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "60a5fa"))
        }
        .padding(.vertical, 8)
    }
    
    var armorIcon: String {
        switch armor.armorType {
        case .helmet: return "person.fill"
        case .bodyArmor: return "tshirt"
        case .gloves: return "hand.raised"
        case .boots: return "shoeprints.fill"
        case .shield: return "shield.fill"
        case .ring: return "circle.circle"
        case .amulet: return "lanyardcard"
        case .belt: return "minus"
        }
    }
}

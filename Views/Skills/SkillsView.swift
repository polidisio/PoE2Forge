import SwiftUI

struct SkillsView: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var searchText = ""
    @State private var selectedType: GemType? = nil
    @State private var selectedGem: SkillGem? = nil
    
    var filteredGems: [SkillGem] {
        var gems = gameData.skillGems
        
        if let type = selectedType {
            gems = gems.filter { $0.gemType == type }
        }
        
        if !searchText.isEmpty {
            gems = gems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return gems
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }
                        ForEach(GemType.allCases, id: \.self) { type in
                            FilterChip(title: type.displayName, isSelected: selectedType == type) {
                                selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(hex: "1a1a24"))
                
                // Skills list
                List {
                    ForEach(filteredGems) { gem in
                        SkillRow(gem: gem)
                            .listRowBackground(Color(hex: "1a1a24"))
                            .onTapGesture {
                                selectedGem = gem
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Skills")
            .searchable(text: $searchText, prompt: "Search skills...")
            .sheet(item: $selectedGem) { gem in
                SkillDetailView(gem: gem)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: "e07020") : Color(hex: "2f2f40"))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
    }
}

struct SkillRow: View {
    let gem: SkillGem
    
    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Circle()
                .fill(damageTypeColor)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: gemIcon)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(gem.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(gem.gemType.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let dmg = gem.damageType {
                        Text(dmg.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(damageTypeColor)
                    }
                }
            }
            
            Spacer()
            
            Text(gem.cost)
                .font(.caption)
                .foregroundColor(.gray)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    var damageTypeColor: Color {
        switch gem.damageType {
        case .fire: return .red
        case .cold: return .cyan
        case .lightning: return .yellow
        case .chaos: return .purple
        case .physical: return .orange
        default: return .gray
        }
    }
    
    var gemIcon: String {
        switch gem.gemType {
        case .attack: return "sword"
        case .spell: return "sparkles"
        case .movement: return "figure.run"
        case .aura, .buff: return "shield"
        case .minion: return "person.3"
        default: return "circle.fill"
        }
    }
}

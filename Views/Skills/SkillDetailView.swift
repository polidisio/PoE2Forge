import SwiftUI

struct SkillDetailView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let gem: SkillGem
    
    var supports: [SupportGem] {
        gameData.supportsFor(gemType: gem.gemType)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 16) {
                        Circle()
                            .fill(damageTypeColor)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Image(systemName: gemIcon)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(gem.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Text(gem.gemType.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "2f2f40"))
                                    .cornerRadius(8)
                                
                                if let dmg = gem.damageType {
                                    Text(dmg.rawValue.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(damageTypeColor.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        Text(gem.description)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    
                    // Base Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Base Stats")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        ForEach(Array(gem.baseStats.keys.sorted()), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(gem.baseStats[key] ?? "")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        HStack {
                            Text("Cost")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(gem.cost)
                                .foregroundColor(Color(hex: "60a5fa"))
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(gem.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(hex: "2f2f40"))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    
                    // Compatible Supports
                    if !supports.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Compatible Supports")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                            
                            ForEach(supports) { support in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: "e07020"))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(support.name)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    if let dmg = support.damageMultiplier {
                                        Text(dmg)
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "22c55e"))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Skill Details")
            .navigationBarTitleDisplayMode(.inline)
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            height = y + rowHeight
        }
    }
}

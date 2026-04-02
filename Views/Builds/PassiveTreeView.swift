import SwiftUI

struct PassiveTreeView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var build: Build

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var selectedNode: PassiveSkillNode?
    @State private var searchText = ""

    // Initial offset to center the tree
    @State private var initialOffset: CGSize = CGSize(width: -350, height: -400)

    var passiveBonus: PassiveBonus {
        gameData.calculatePassiveBonus(for: build)
    }

    var allocatedCount: Int {
        build.passiveTree.allocatedNodes.count
    }

    var filteredNodes: [PassiveSkillNode] {
        if searchText.isEmpty {
            return gameData.passiveSkills
        }
        return gameData.passiveSkills.filter { node in
            node.name.localizedCaseInsensitiveContains(searchText) ||
            node.stats.keys.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()

                // Search bar
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search nodes...", text: $searchText)
                            .foregroundColor(.white)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Scrollable canvas
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        ZStack {
                            // Draw connections first (behind nodes)
                            ConnectionsView(
                                nodes: filteredNodes,
                                allocatedNodes: build.passiveTree.allocatedNodes
                            )
                            .frame(width: 700, height: 900)

                            // Draw nodes
                            ForEach(filteredNodes) { node in
                                let isAllocated = gameData.passiveNodeIsAllocated(node.id, in: build)
                                let canAllocate = gameData.passiveNodeCanAllocate(node.id, in: build)

                                NodeView(
                                    node: node,
                                    isAllocated: isAllocated,
                                    canAllocate: canAllocate,
                                    isSelected: selectedNode?.id == node.id
                                )
                                .position(
                                    x: node.position.x + 50,
                                    y: node.position.y + 50
                                )
                                .onTapGesture {
                                    if isAllocated || canAllocate {
                                        selectedNode = node
                                    } else if !isAllocated && !canAllocate {
                                        // Show locked message
                                        let _ = print("Node \(node.name) requires connecting path")
                                    }
                                }
                            }
                        }
                        .frame(width: 700, height: 900)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(0.3, min(2.0, value))
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    }

                    // Stats overlay at bottom
                    PassiveStatsOverlay(bonus: passiveBonus, allocatedCount: allocatedCount)
                }
            }
            .navigationTitle("Passive Tree")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        gameData.saveBuild(build)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        build.passiveTree = PassiveTree()
                    }
                    .foregroundColor(.red)
                }
            }
            .sheet(item: $selectedNode) { node in
                NodeDetailSheet(
                    node: node,
                    isAllocated: build.passiveTree.isAllocated(node.id),
                    canAllocate: gameData.passiveNodeCanAllocate(node.id, in: build),
                    onToggle: {
                        toggleNode(node.id)
                    },
                    onDismiss: {
                        selectedNode = nil
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    func toggleNode(_ nodeId: String) {
        guard gameData.passiveNodeCanAllocate(nodeId, in: build) else { return }

        // If unallocated and not start node, check if connected to allocated
        if !build.passiveTree.isAllocated(nodeId) {
            guard let node = gameData.passiveSkillBy(id: nodeId) else { return }
            if node.type != .start {
                // Can only allocate if connected to existing allocation
                let connected = build.passiveTree.isConnectedToStart(nodeId, allNodes: gameData.passiveSkills)
                if !connected { return }
            }
        }

        build.passiveTree.toggleNode(nodeId)
        selectedNode = nil
    }
}

struct ConnectionsView: View {
    let nodes: [PassiveSkillNode]
    let allocatedNodes: Set<String>

    var body: some View {
        Canvas { context, size in
            for node in nodes {
                let startX = node.position.x + 100
                let startY = node.position.y + 100

                for connectionId in node.connections {
                    guard let connectedNode = nodes.first(where: { $0.id == connectionId }) else { continue }

                    let endX = connectedNode.position.x + 100
                    let endY = connectedNode.position.y + 100

                    let isActive = allocatedNodes.contains(node.id) && allocatedNodes.contains(connectionId)

                    var path = Path()
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: endX, y: endY))

                    context.stroke(
                        path,
                        with: .color(isActive ? Color(hex: "e07020") : Color(hex: "3a3a4a")),
                        lineWidth: isActive ? 4 : 2
                    )
                }
            }
        }
    }
}

struct NodeView: View {
    let node: PassiveSkillNode
    let isAllocated: Bool
    let canAllocate: Bool
    var isSelected: Bool = false

    var nodeColor: Color {
        if isAllocated {
            return Color(hex: "e07020")
        } else if canAllocate {
            return Color(hex: "8888ff")
        } else {
            return Color(hex: "3a3a4a")
        }
    }

    var nodeSize: CGFloat {
        switch node.type {
        case .start: return 40
        case .minor: return 28
        case .notable: return 36
        case .keystone: return 44
        }
    }

    var body: some View {
        ZStack {
            // Outer glow for selected
            if isSelected {
                Circle()
                    .stroke(Color(hex: "e07020").opacity(0.5), lineWidth: 8)
                    .frame(width: nodeSize + 20, height: nodeSize + 20)
            }

            // Outer ring
            Circle()
                .stroke(nodeColor, lineWidth: node.type == .keystone ? 4 : 3)
                .frame(width: nodeSize + 8, height: nodeSize + 8)

            // Inner fill
            Circle()
                .fill(isAllocated ? Color(hex: "e07020") : Color(hex: "1a1a24"))
                .frame(width: nodeSize, height: nodeSize)

            // Icon or letter
            if node.type == .start {
                Text(node.name.prefix(1))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            } else if node.type == .keystone {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: node.rarityColor))
            } else {
                Text("\(node.getPrimaryStat().1)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: node.rarityColor))
            }
        }
        .shadow(color: isAllocated ? Color(hex: "e07020").opacity(0.5) : .clear, radius: 8)
    }
}

struct NodeDetailSheet: View {
    let node: PassiveSkillNode
    let isAllocated: Bool
    let canAllocate: Bool
    let onToggle: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Node header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(node.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(node.type.displayName)
                            .font(.caption)
                            .foregroundColor(Color(hex: node.rarityColor))
                    }

                    Spacer()

                    // Status badge
                    Text(isAllocated ? "Allocated" : (canAllocate ? "Available" : "Locked"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(hex: "1a1a24"))
                .cornerRadius(12)

                // Stats section
                VStack(alignment: .leading, spacing: 12) {
                    Text("STATS")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if node.stats.isEmpty {
                        Text("No stats")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(Array(node.stats.keys.sorted()), id: \.self) { key in
                            if let value = node.stats[key] {
                                let isPercent = key == "percent" && value == 1
                                let displayValue = isPercent ? "%" : "+\(value)"
                                let statName = formatStatName(key)

                                HStack {
                                    Circle()
                                        .fill(Color(hex: "e07020"))
                                        .frame(width: 6, height: 6)

                                    Text(statName)
                                        .foregroundColor(.white)

                                    Spacer()

                                    Text(displayValue)
                                        .fontWeight(.bold)
                                        .foregroundColor(isPercent ? Color(hex: "22c55e") : Color(hex: "e07020"))
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(hex: "1a1a24"))
                .cornerRadius(12)

                // Connections info
                VStack(alignment: .leading, spacing: 12) {
                    Text("CONNECTIONS")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(node.connections.count) connected nodes")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(hex: "1a1a24"))
                .cornerRadius(12)

                Spacer()

                // Action button
                if canAllocate || isAllocated {
                    Button(action: onToggle) {
                        Text(isAllocated ? "Deallocate" : "Allocate")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAllocated ? Color.red.opacity(0.8) : Color(hex: "e07020"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Text("Allocate nearby nodes to unlock this one")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Node Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onDismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
        }
    }

    var statusColor: Color {
        if isAllocated {
            return Color(hex: "22c55e")
        } else if canAllocate {
            return Color(hex: "3b82f6")
        } else {
            return Color(hex: "6b7280")
        }
    }

    func formatStatName(_ key: String) -> String {
        switch key {
        case "strength": return "Strength"
        case "dexterity": return "Dexterity"
        case "intelligence": return "Intelligence"
        case "meleeDamage": return "Melee Damage"
        case "projectileDamage": return "Projectile Damage"
        case "spellDamage": return "Spell Damage"
        case "elementalDamage": return "Elemental Damage"
        case "armor": return "Armor"
        case "evasion": return "Evasion"
        case "minionDamage": return "Minion Damage"
        case "minionLife": return "Minion Life"
        case "maxMana": return "Maximum Mana"
        case "castSpeed": return "Cast Speed"
        case "attackSpeed": return "Attack Speed"
        case "lifeOnHit": return "Life on Hit"
        case "dodgeChance": return "Dodge Chance"
        case "chainCount": return "Chain"
        case "projectileSpeed": return "Projectile Speed"
        case "critMultiplier": return "Crit Multiplier"
        case "elementalPenetration": return "Elemental Penetration"
        case "bowDamage": return "Bow Damage"
        case "movementSpeed": return "Movement Speed"
        case "overpowerDamage": return "Overpower Damage"
        default: return key.capitalized
        }
    }
}

struct PassiveStatsOverlay: View {
    let bonus: PassiveBonus
    let allocatedCount: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("\(allocatedCount) Points Allocated")
                .font(.caption)
                .foregroundColor(.gray)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if bonus.strength > 0 {
                        StatChip(icon: "figure.strengthtraining.traditional", value: "+\(bonus.strength) STR", color: .red)
                    }
                    if bonus.dexterity > 0 {
                        StatChip(icon: "figure.agility", value: "+\(bonus.dexterity) DEX", color: .green)
                    }
                    if bonus.intelligence > 0 {
                        StatChip(icon: "brain", value: "+\(bonus.intelligence) INT", color: .blue)
                    }
                    if bonus.meleeDamage > 0 {
                        StatChip(icon: "sword", value: "+\(bonus.meleeDamage) Melee", color: .orange)
                    }
                    if bonus.spellDamage > 0 {
                        StatChip(icon: "sparkles", value: "+\(bonus.spellDamage) Spell", color: .purple)
                    }
                    if bonus.armor > 0 {
                        StatChip(icon: "shield.fill", value: "+\(bonus.armor) Armor", color: .gray)
                    }
                    if bonus.evasion > 0 {
                        StatChip(icon: "eye", value: "+\(bonus.evasion) Evasion", color: .green)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(hex: "1a1a24").opacity(0.95))
    }
}

struct StatChip: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: "2f2f40"))
        .cornerRadius(8)
    }
}

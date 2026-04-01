import SwiftUI

struct PassiveTreeView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var build: Build

    @State private var scale: CGFloat = 0.6
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var passiveBonus: PassiveBonus {
        gameData.calculatePassiveBonus(for: build)
    }

    var allocatedCount: Int {
        build.passiveTree.allocatedNodes.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()

                // Scrollable canvas
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    ZStack {
                        // Draw connections first (behind nodes)
                        ConnectionsView(
                            nodes: gameData.passiveSkills,
                            allocatedNodes: build.passiveTree.allocatedNodes
                        )
                        .frame(width: 1000, height: 1200)

                        // Draw nodes
                        ForEach(gameData.passiveSkills) { node in
                            let isAllocated = gameData.passiveNodeIsAllocated(node.id, in: build)
                            let canAllocate = gameData.passiveNodeCanAllocate(node.id, in: build)

                            NodeView(
                                node: node,
                                isAllocated: isAllocated,
                                canAllocate: canAllocate
                            )
                            .position(
                                x: node.position.x + 100,
                                y: node.position.y + 100
                            )
                            .onTapGesture {
                                toggleNode(node.id)
                            }
                        }
                    }
                    .frame(width: 1000, height: 1200)
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
                VStack {
                    Spacer()
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

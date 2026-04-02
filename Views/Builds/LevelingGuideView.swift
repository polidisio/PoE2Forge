import SwiftUI

struct LevelingGuideView: View {
    let build: Build

    var currentLevel: Int {
        build.characterLevel
    }

    var currentAct: Int {
        // Approximate act based on level
        if currentLevel <= 15 { return 1 }
        if currentLevel <= 28 { return 2 }
        if currentLevel <= 45 { return 3 }
        if currentLevel <= 50 { return 4 }
        return 5
    }

    var entriesUpToCurrentLevel: [LevelingGuideEntry] {
        LevelingGuide.entriesForLevel(currentLevel)
    }

    var nextMilestone: LevelingGuideEntry? {
        LevelingGuide.nextMilestone(afterLevel: currentLevel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current status
                    VStack(spacing: 8) {
                        Text("LEVEL \(currentLevel)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "e07020"))

                        Text("Act \(currentAct)")
                            .font(.headline)
                            .foregroundColor(.gray)

                        if let next = nextMilestone {
                            Text("\(next.level - currentLevel) levels until next milestone")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // Next milestone
                    if let next = nextMilestone {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("NEXT MILESTONE")
                                .font(.caption)
                                .foregroundColor(.gray)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(next.title)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(next.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                if !next.suggestedNodes.isEmpty {
                                    HStack {
                                        Image(systemName: "circle.hexagongrid")
                                            .foregroundColor(Color(hex: "e07020"))
                                        Text("\(next.suggestedNodes.count) passive nodes suggested")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }

                                if !next.notes.isEmpty {
                                    Text(next.notes)
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                        .padding(.top, 4)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                    }

                    // Progress timeline
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROGRESS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        ForEach(entriesUpToCurrentLevel) { entry in
                            LevelingGuideEntryRow(entry: entry, isCompleted: true)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // All milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ALL MILESTONES")
                            .font(.caption)
                            .foregroundColor(.gray)

                        ForEach(LevelingGuide.defaultGuide) { entry in
                            LevelingGuideEntryRow(
                                entry: entry,
                                isCompleted: entry.level <= currentLevel
                            )
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Leveling Guide")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LevelingGuideEntryRow: View {
    let entry: LevelingGuideEntry
    let isCompleted: Bool

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay {
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isCompleted ? .white : .gray)

                        Text("Level \(entry.level)")
                            .font(.caption2)
                            .foregroundColor(Color(hex: "e07020"))
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.description)
                        .font(.caption)
                        .foregroundColor(.gray)

                    if !entry.suggestedNodes.isEmpty {
                        Text("Suggested Nodes:")
                            .font(.caption)
                            .foregroundColor(.white)
                        ForEach(entry.suggestedNodes, id: \.self) { node in
                            Text("• \(node)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    if !entry.notes.isEmpty {
                        Text(entry.notes)
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .padding(.top, 4)
                    }
                }
                .padding(.leading, 32)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

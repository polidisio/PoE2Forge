import SwiftUI

struct SkillSocketView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var build: Build

    @State private var selectedSkillId: String?
    @State private var showingSupportPicker = false

    var skills: [SkillGem] {
        build.skillIds.compactMap { gameData.skillBy(id: $0) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Tap a skill to add support gems")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ForEach(skills) { skill in
                    let socket = build.socketFor(skill.id)
                    SkillSocketRow(
                        skill: skill,
                        socket: socket,
                        isSelected: selectedSkillId == skill.id,
                        onTap: {
                            selectedSkillId = selectedSkillId == skill.id ? nil : skill.id
                        },
                        onAddSupport: {
                            selectedSkillId = skill.id
                            showingSupportPicker = true
                        },
                        onRemoveSupport: { supportId in
                            var updatedSocket = socket
                            updatedSocket.supportGemIds.removeAll { $0 == supportId }
                            build.updateSocket(for: skill.id, with: updatedSocket)
                        }
                    )
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Socket Gems")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        gameData.saveBuild(build)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            .sheet(isPresented: $showingSupportPicker) {
                if let skillId = selectedSkillId {
                    SupportGemPickerView(
                        skillId: skillId,
                        build: $build
                    )
                }
            }
        }
    }
}

struct SkillSocketRow: View {
    let skill: SkillGem
    let socket: SkillSocket
    let isSelected: Bool
    let onTap: () -> Void
    let onAddSupport: () -> Void
    let onRemoveSupport: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    Circle()
                        .fill(gemTypeColor(skill.gemType))
                        .frame(width: 10, height: 10)

                    Text(skill.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    if !socket.supportGemIds.isEmpty {
                        Text("\(socket.supportGemIds.count) supports")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }

            // Socketed supports
            if isSelected {
                VStack(alignment: .leading, spacing: 8) {
                    // Existing supports
                    ForEach(socket.supportGemIds, id: \.self) { supportId in
                        if let support = getSupport(id: supportId) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text(support.name)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                if let mult = support.damageMultiplier {
                                    Text(mult)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "22c55e"))
                                }
                                Button {
                                    onRemoveSupport(supportId)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    // Add support button
                    Button(action: onAddSupport) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color(hex: "e07020"))
                            Text("Add Support Gem")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "e07020"))
                        }
                    }
                    .padding(.top, 4)

                    // Damage preview
                    if !socket.supportGemIds.isEmpty {
                        let multiplier = socket.damageMultiplier(gameData: GameDataService.shared)
                        HStack {
                            Text("Damage Multiplier:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("x\(String(format: "%.2f", multiplier))")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "22c55e"))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding(.vertical, 4)
    }

    func gemTypeColor(_ type: GemType) -> Color {
        switch type {
        case .attack: return .red
        case .spell: return .blue
        case .movement: return .green
        case .buff, .aura: return .yellow
        case .minion: return .purple
        case .curse, .debuff: return .orange
        case .totem: return .cyan
        }
    }

    func getSupport(id: String) -> SupportGem? {
        GameDataService.shared.supportGems.first { $0.id == id }
    }
}

struct SupportGemPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let skillId: String
    @Binding var build: Build

    @State private var searchText = ""

    var skill: SkillGem? {
        gameData.skillBy(id: skillId)
    }

    var compatibleSupports: [SupportGem] {
        guard let skill = skill else { return [] }
        return gameData.supportGems.filter { support in
            support.supportedTypes.contains(skill.gemType) ||
            support.supportedTypes.contains(.spell) && skill.gemType == .spell ||
            support.supportedTypes.contains(.attack) && skill.gemType == .attack
        }
    }

    var alreadySocketed: [String] {
        build.socketFor(skillId).supportGemIds
    }

    var filteredSupports: [SupportGem] {
        if searchText.isEmpty {
            return compatibleSupports
        }
        return compatibleSupports.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Select support gems compatible with \(skill?.name ?? "skill")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ForEach(filteredSupports) { support in
                    let isSelected = alreadySocketed.contains(support.id)
                    Button {
                        toggleSupport(support)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(support.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(support.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }

                            Spacer()

                            if let mult = support.damageMultiplier {
                                Text(mult)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "2f2f40"))
                                    .cornerRadius(4)
                                    .foregroundColor(Color(hex: "22c55e"))
                            }

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "e07020"))
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Select Support")
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

    func toggleSupport(_ support: SupportGem) {
        var socket = build.socketFor(skillId)

        if socket.supportGemIds.contains(support.id) {
            socket.supportGemIds.removeAll { $0 == support.id }
        } else {
            socket.supportGemIds.append(support.id)
        }

        build.updateSocket(for: skillId, with: socket)
    }
}

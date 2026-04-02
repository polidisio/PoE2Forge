import SwiftUI

struct FlaskView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var build: Build

    @State private var showingFlaskPicker = false
    @State private var selectedFlaskSlot: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Flask slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FLASK SETS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        // Active flask set
                        let flaskSet = build.activeFlaskSet

                        ForEach(0..<5, id: \.self) { index in
                            let flask = index < flaskSet.flasks.count ? flaskSet.flasks[index] : nil
                            FlaskSlotRow(
                                slotIndex: index,
                                flask: flask,
                                flaskData: flask.flatMap { gameData.flaskDataBy(id: $0.flaskDataId) },
                                onTap: {
                                    selectedFlaskSlot = index
                                    showingFlaskPicker = true
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Flask summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACTIVE BUFFS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        let flaskSet = build.activeFlaskSet
                        let allModifiers = flaskSet.flasks.compactMap { flask -> [FlaskModifier]? in
                            guard let data = gameData.flaskDataBy(id: flask.flaskDataId) else { return nil }
                            return data.modifiers
                        }.flatMap { $0 }

                        if allModifiers.isEmpty {
                            Text("No flasks equipped")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(allModifiers, id: \.id) { mod in
                                HStack {
                                    Text(mod.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(mod.value)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "22c55e"))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Flasks")
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
            .sheet(isPresented: $showingFlaskPicker) {
                FlaskPickerView(
                    slotIndex: selectedFlaskSlot,
                    build: $build
                )
            }
        }
    }
}

struct FlaskSlotRow: View {
    let slotIndex: Int
    let flask: EquippedFlask?
    let flaskData: FlaskData?
    let onTap: () -> Void

    var flaskIcon: String {
        guard let data = flaskData else { return "flask" }
        switch data.flaskType {
        case .life: return "heart.fill"
        case .mana: return "brain.head.profile"
        case .hybrid: return "waveform.path.ecg"
        case .utility: return "bolt.fill"
        }
    }

    var flaskColor: Color {
        guard let data = flaskData else { return .gray }
        switch data.flaskType {
        case .life: return .red
        case .mana: return .blue
        case .hybrid: return .purple
        case .utility: return .yellow
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Flask icon
                Image(systemName: flaskIcon)
                    .font(.title2)
                    .foregroundColor(flaskData != nil ? flaskColor : .gray)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "2a2a40"))
                    .cornerRadius(8)

                // Flask info
                VStack(alignment: .leading, spacing: 2) {
                    if let data = flaskData {
                        Text(data.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: data.rarityColor))
                    } else {
                        Text("Empty Slot \(slotIndex + 1)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .italic()
                    }

                    if let data = flaskData {
                        Text(data.modifiers.first?.value ?? "")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}

struct FlaskPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let slotIndex: Int
    @Binding var build: Build

    @State private var searchText = ""
    @State private var selectedType: FlaskType? = nil

    var filteredFlasks: [FlaskData] {
        gameData.flaskData.filter { flask in
            let typeMatch = selectedType == nil || flask.flaskType == selectedType
            let searchMatch = searchText.isEmpty || flask.name.localizedCaseInsensitiveContains(searchText)
            return typeMatch && searchMatch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FlaskFilterChip(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }
                        FlaskFilterChip(title: "Life", isSelected: selectedType == .life) {
                            selectedType = .life
                        }
                        FlaskFilterChip(title: "Mana", isSelected: selectedType == .mana) {
                            selectedType = .mana
                        }
                        FlaskFilterChip(title: "Hybrid", isSelected: selectedType == .hybrid) {
                            selectedType = .hybrid
                        }
                        FlaskFilterChip(title: "Utility", isSelected: selectedType == .utility) {
                            selectedType = .utility
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(hex: "1a1a24"))

                // Flask list
                List {
                    // Clear slot option
                    Button {
                        clearFlaskSlot()
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                            Text("Clear Slot")
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))

                    ForEach(filteredFlasks) { flask in
                        FlaskDataRow(flask: flask) {
                            equipFlask(flask)
                        }
                        .listRowBackground(Color(hex: "1a1a24"))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Select Flask")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
        }
    }

    func equipFlask(_ flaskData: FlaskData) {
        var flaskSet = build.activeFlaskSet
        let equippedFlask = EquippedFlask(flaskDataId: flaskData.id)
        flaskSet.updateFlask(at: slotIndex, with: equippedFlask)

        // Update or add flask set
        if build.flaskSets.isEmpty {
            build.flaskSets = [flaskSet]
        } else {
            build.flaskSets[0] = flaskSet
        }

        gameData.saveBuild(build)
        dismiss()
    }

    func clearFlaskSlot() {
        var flaskSet = build.activeFlaskSet
        if slotIndex < flaskSet.flasks.count {
            flaskSet.flasks.remove(at: slotIndex)
        }

        if !build.flaskSets.isEmpty {
            build.flaskSets[0] = flaskSet
        }

        gameData.saveBuild(build)
        dismiss()
    }
}

struct FlaskDataRow: View {
    let flask: FlaskData
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flask.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: flask.rarityColor))

                    Text(flask.modifiers.first?.value ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(flask.flaskType.displayName)
                        .font(.caption2)
                        .foregroundColor(.gray)

                    if flask.unique {
                        Text("Unique")
                            .font(.caption2)
                            .foregroundColor(Color(hex: "af6028"))
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct FlaskFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: "e07020") : Color(hex: "2a2a40"))
                .foregroundColor(.white)
                .cornerRadius(16)
        }
    }
}

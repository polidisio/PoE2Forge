import SwiftUI

struct BuildEditorView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    
    var build: Build?
    
    @State private var name: String = ""
    @State private var selectedClassId: String? = nil
    @State private var selectedSkills: [String] = []
    @State private var selectedGear: [String] = []
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false
    @State private var showingSkillPicker = false
    @State private var showingGearPicker = false
    
    init(build: Build?) {
        self.build = build
        if let build = build {
            _name = State(initialValue: build.name)
            _selectedClassId = State(initialValue: build.forClass)
            _selectedSkills = State(initialValue: build.skills)
            _selectedGear = State(initialValue: build.gear)
            _notes = State(initialValue: build.notes)
            _isFavorite = State(initialValue: build.isFavorite)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Build Name", text: $name)
                        .foregroundColor(.white)
                } header: {
                    Text("Name")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    Picker("Class", selection: $selectedClassId) {
                        Text("Any Class").tag(nil as String?)
                        ForEach(gameData.classes) { cls in
                            Text(cls.name).tag(cls.id as String?)
                        }
                    }
                    .foregroundColor(.white)
                } header: {
                    Text("Recommended Class")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    Button(action: { showingSkillPicker = true }) {
                        HStack {
                            Text("\(selectedSkills.count) skills selected")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Skills")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    Button(action: { showingGearPicker = true }) {
                        HStack {
                            Text("\(selectedGear.count) items selected")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Gear")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.white)
                } header: {
                    Text("Notes")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                        .tint(Color(hex: "e07020"))
                        .foregroundColor(.white)
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                if build != nil {
                    Section {
                        Button(role: .destructive) {
                            if let build = build {
                                gameData.deleteBuild(build)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Build")
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(build == nil ? "New Build" : "Edit Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBuild()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingSkillPicker) {
                SkillPickerView(selectedSkills: $selectedSkills)
            }
            .sheet(isPresented: $showingGearPicker) {
                GearPickerView(selectedGear: $selectedGear)
            }
        }
    }
    
    func saveBuild() {
        let newBuild = Build(
            id: build?.id ?? UUID(),
            name: name,
            forClass: selectedClassId,
            skills: selectedSkills,
            gear: selectedGear,
            notes: notes,
            createdAt: build?.createdAt ?? Date(),
            isFavorite: isFavorite
        )
        gameData.saveBuild(newBuild)
    }
}

struct SkillPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var selectedSkills: [String]
    @State private var searchText = ""
    
    var filteredGems: [SkillGem] {
        if searchText.isEmpty {
            return gameData.skillGems
        }
        return gameData.skillGems.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredGems) { gem in
                    HStack {
                        Text(gem.name)
                            .foregroundColor(.white)
                        Spacer()
                        if selectedSkills.contains(gem.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "e07020"))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedSkills.contains(gem.id) {
                            selectedSkills.removeAll { $0 == gem.id }
                        } else {
                            selectedSkills.append(gem.id)
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Select Skills")
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
}

struct GearPickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @Binding var selectedGear: [String]
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var filteredWeapons: [Weapon] {
        if searchText.isEmpty { return gameData.weapons }
        return gameData.weapons.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredArmors: [Armor] {
        if searchText.isEmpty { return gameData.armors }
        return gameData.armors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Type", selection: $selectedTab) {
                    Text("Weapons").tag(0)
                    Text("Armor").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    if selectedTab == 0 {
                        ForEach(filteredWeapons) { weapon in
                            HStack {
                                Text(weapon.name)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedGear.contains(weapon.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "e07020"))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleGear(weapon.id)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    } else {
                        ForEach(filteredArmors) { armor in
                            HStack {
                                Text(armor.name)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedGear.contains(armor.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "e07020"))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleGear(armor.id)
                            }
                            .listRowBackground(Color(hex: "1a1a24"))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Select Gear")
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
    
    func toggleGear(_ id: String) {
        if selectedGear.contains(id) {
            selectedGear.removeAll { $0 == id }
        } else {
            selectedGear.append(id)
        }
    }
}

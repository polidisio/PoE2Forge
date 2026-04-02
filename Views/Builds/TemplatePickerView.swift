import SwiftUI

struct TemplatePickerView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let onSelect: (BuildTemplate) -> Void

    @State private var searchText = ""
    @State private var selectedCategory: String = "All"

    var categories: [String] {
        var cats = Set<String>()
        cats.insert("All")
        for template in BuildTemplate.defaultTemplates {
            if let cls = gameData.classBy(id: template.characterClass) {
                cats.insert(cls.name)
            }
        }
        return Array(cats).sorted()
    }

    var filteredTemplates: [BuildTemplate] {
        BuildTemplate.defaultTemplates.filter { template in
            let matchesSearch = searchText.isEmpty ||
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText)

            let matchesCategory: Bool
            if selectedCategory == "All" {
                matchesCategory = true
            } else if let cls = gameData.classBy(id: template.characterClass) {
                matchesCategory = cls.name == selectedCategory
            } else {
                matchesCategory = false
            }

            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategory == category ? Color(hex: "e07020") : Color(hex: "2a2a40"))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(hex: "1a1a24"))

                // Template list
                List {
                    ForEach(filteredTemplates) { template in
                        TemplateRow(template: template) {
                            onSelect(template)
                        }
                        .listRowBackground(Color(hex: "1a1a24"))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("League Start Templates")
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
}

struct TemplateRow: View {
    @EnvironmentObject var gameData: GameDataService
    let template: BuildTemplate
    let onSelect: () -> Void

    var className: String {
        if let cls = gameData.classBy(id: template.characterClass) {
            return cls.name
        }
        return "Unknown"
    }

    var skillNames: [String] {
        template.skillIds.compactMap { gameData.skillBy(id: $0)?.name }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(className)
                            .font(.caption)
                            .foregroundColor(Color(hex: "e07020"))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Level \(template.recommendedLevel)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                // Skills preview
                if !skillNames.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(skillNames.prefix(3), id: \.self) { skillName in
                            Text(skillName)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "2a2a40"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        if skillNames.count > 3 {
                            Text("+\(skillNames.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

import SwiftUI

struct BuildsListView: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var showingNewBuild = false
    @State private var selectedBuild: Build? = nil
    @State private var showingImport = false
    @State private var showingExport = false
    @State private var exportText = ""
    @State private var importText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()

                if gameData.builds.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No Builds Yet")
                            .font(.title2)
                            .foregroundColor(.white)

                        Text("Create your first build to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Button(action: { showingNewBuild = true }) {
                            Label("New Build", systemImage: "plus")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "e07020"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    List {
                        ForEach(gameData.builds) { build in
                            BuildRow(build: build)
                                .listRowBackground(Color(hex: "1a1a24"))
                                .onTapGesture {
                                    selectedBuild = build
                                }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                gameData.deleteBuild(gameData.builds[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Builds")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingImport = true }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(Color(hex: "e07020"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewBuild = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "e07020"))
                    }
                }
            }
            .sheet(isPresented: $showingNewBuild) {
                BuildEditorView(build: nil)
            }
            .sheet(isPresented: $showingImport) {
                ImportBuildView()
            }
            .navigationDestination(item: $selectedBuild) { build in
                BuildDetailView(build: build)
            }
        }
    }
}

struct BuildRow: View {
    @EnvironmentObject var gameData: GameDataService
    let build: Build
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(build.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if build.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 8) {
                    if let classId = build.forClass, let cls = gameData.classBy(id: classId) {
                        Text(cls.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "2f2f40"))
                            .cornerRadius(4)
                    }
                    
                    Text("\(build.skillIds.count) skills")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(build.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Import Build View
struct ImportBuildView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    @State private var importCode = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Paste your build code below")
                    .font(.headline)
                    .foregroundColor(.white)

                TextEditor(text: $importCode)
                    .frame(height: 200)
                    .padding(8)
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }

                Button(action: importBuild) {
                    Text("Import Build")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "e07020"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Text("Or paste a PoE2Forge export code")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Import Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
        }
    }

    func importBuild() {
        // Try to parse as PoE2Forge share code
        if let build = PoBExportService.parseShareCode(importCode.trimmingCharacters(in: .whitespacesAndNewlines)) {
            gameData.saveBuild(build)
            dismiss()
            return
        }

        // Try to parse as PoB-style export
        if let build = PoBExportService.importBuild(importCode, gameData: gameData) {
            gameData.saveBuild(build)
            dismiss()
            return
        }

        errorMessage = "Invalid build code. Please check and try again."
    }
}

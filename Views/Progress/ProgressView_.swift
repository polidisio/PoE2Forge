import SwiftUI

// MARK: - Selected Act Wrapper
struct SelectedActItem: Identifiable {
    var id: String { "\(run.id.uuidString)-\(act)" }
    let run: Run
    let act: Int
}

struct ProgressView_: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var showingNewRun = false
    @State private var selectedRun: Run? = nil
    @State private var selectedAct: SelectedActItem? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()

                if gameData.runs.isEmpty {
                    EmptyRunsView(onAddRun: { showingNewRun = true })
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats cards
                            StatsCardsRow(gameData: gameData)

                            // Active campaigns
                            if !gameData.activeRuns().isEmpty {
                                ActiveCampaignsSection(
                                    runs: gameData.activeRuns(),
                                    onRunTap: { selectedRun = $0 },
                                    onActTap: { run, act in selectedAct = SelectedActItem(run: run, act: act) }
                                )
                            }

                            // Recent runs
                            RecentRunsSection(
                                runs: gameData.runs,
                                onRunTap: { selectedRun = $0 }
                            )
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewRun = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "e07020"))
                    }
                }
            }
            .sheet(isPresented: $showingNewRun) {
                RunEditorView(run: nil)
            }
            .sheet(item: $selectedRun) { run in
                RunDetailView(run: run)
            }
            .sheet(item: $selectedAct) { item in
                ActEditorView(run: item.run, act: item.act)
            }
        }
    }
}

// MARK: - Empty State
struct EmptyRunsView: View {
    let onAddRun: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Runs Tracked")
                .font(.title2)
                .foregroundColor(.white)

            Text("Log your campaign progress through the 10 acts")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onAddRun) {
                Label("Start New Campaign", systemImage: "plus")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "e07020"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Stats Cards
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
    }
}

struct StatsCardsRow: View {
    @ObservedObject var gameData: GameDataService

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Campaigns",
                value: "\(gameData.runs.count)",
                icon: "figure.run",
                color: .blue
            )
            StatCard(
                title: "Completed",
                value: "\(Int(gameData.completionRate))%",
                icon: "checkmark.circle",
                color: .green
            )
            StatCard(
                title: "Deaths",
                value: "\(gameData.totalDeaths)",
                icon: "heart.slash",
                color: .red
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Active Campaigns
struct ActiveCampaignsSection: View {
    let runs: [Run]
    let onRunTap: (Run) -> Void
    let onActTap: (Run, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVE CAMPAIGNS")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)

            ForEach(runs) { run in
                CampaignCard(run: run, onTap: { onRunTap(run) }, onActTap: { act in onActTap(run, act) })
            }
        }
    }
}

// MARK: - Campaign Card
struct CampaignCard: View {
    let run: Run
    let onTap: () -> Void
    let onActTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(run.buildName.isEmpty ? "Unnamed Campaign" : run.buildName)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Act \(run.currentAct) - \(run.completedActs)/10 completed")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }

            // Act flow
            ActFlowView(run: run, onActTap: onActTap)
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Act Flow
struct ActFlowView: View {
    let run: Run
    let onActTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { act in
                let progress = run.actProgress(act)
                Button {
                    onActTap(act)
                } label: {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(progress.completed ? Color.green : (progress.deaths > 0 ? Color.orange : Color.gray.opacity(0.3)))
                            .frame(width: 24, height: 24)
                            .overlay {
                                if progress.completed {
                                    Image(systemName: "checkmark")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                } else if progress.deaths > 0 {
                                    Text("\(progress.deaths)")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }

                        Text("\(act)")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Recent Runs
struct RecentRunsSection: View {
    let runs: [Run]
    let onRunTap: (Run) -> Void

    var sortedRuns: [Run] {
        runs.sorted { ($0.lastPlayedDate ?? $0.createdAt) > ($1.lastPlayedDate ?? $1.createdAt) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALL CAMPAIGNS")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)

            ForEach(sortedRuns.prefix(10)) { run in
                RunRow(run: run)
                    .onTapGesture {
                        onRunTap(run)
                    }
            }
        }
    }
}

// MARK: - Run Row
struct RunRow: View {
    let run: Run

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(run.isCompleted ? Color.green : Color.orange)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: run.isCompleted ? "checkmark" : "figure.run")
                        .foregroundColor(.white)
                        .font(.caption)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(run.buildName.isEmpty ? "Unnamed Campaign" : run.buildName)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("\(run.completedActs)/10 acts")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if run.totalDeaths > 0 {
                        Text("\(run.totalDeaths) deaths")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let lastPlayed = run.lastPlayedDate {
                    Text(lastPlayed.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Text(run.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "1a1a24"))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Run Detail View
struct RunDetailView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let run: Run

    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Build info
                    if let buildId = run.buildId, let build = gameData.buildBy(id: buildId) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LINKED BUILD")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(build.name)
                                .font(.headline)
                                .foregroundColor(Color(hex: "e07020"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Act progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACT PROGRESS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        ForEach(1...10, id: \.self) { act in
                            let progress = run.actProgress(act)
                            ActProgressRow(act: act, progress: progress)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Notes
                    if !run.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(run.notes)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Delete button
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Campaign")
                            Spacer()
                        }
                        .padding()
                        .background(Color(hex: "2a1a1a"))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(run.buildName.isEmpty ? "Campaign" : run.buildName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            .alert("Delete Campaign?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    gameData.deleteRun(run)
                    dismiss()
                }
            } message: {
                Text("This will permanently delete this campaign and all its act progress.")
            }
        }
    }
}

// MARK: - Act Progress Row
struct ActProgressRow: View {
    let act: Int
    let progress: ActProgress

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(progress.completed ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay {
                    Text("\(act)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(progress.completed ? .white : .gray)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(Run.actNames[act] ?? "Act \(act)")
                    .font(.subheadline)
                    .foregroundColor(progress.completed ? .white : .gray)

                if progress.completed {
                    if let date = progress.completedDate {
                        Text("Completed \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            if progress.deaths > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "heart.slash")
                        .font(.caption)
                    Text("\(progress.deaths)")
                        .font(.caption)
                }
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Act Editor View
struct ActEditorView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let run: Run
    let act: Int

    @State private var completed: Bool
    @State private var deaths: Int
    @State private var notes: String

    init(run: Run, act: Int) {
        self.run = run
        self.act = act
        let progress = run.actProgress(act)
        _completed = State(initialValue: progress.completed)
        _deaths = State(initialValue: progress.deaths)
        _notes = State(initialValue: progress.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(run.actName(act))
                        .font(.headline)
                        .foregroundColor(.white)
                } header: {
                    Text("Act \(act)")
                }
                .listRowBackground(Color(hex: "1a1a24"))

                Section {
                    Toggle("Completed", isOn: $completed)
                        .tint(Color(hex: "e07020"))
                        .foregroundColor(.white)

                    Stepper("Deaths: \(deaths)", value: $deaths, in: 0...999)
                        .foregroundColor(.white)
                } header: {
                    Text("Progress")
                }
                .listRowBackground(Color(hex: "1a1a24"))

                Section {
                    TextField("Notes (boss strategies, gear notes...)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.white)
                } header: {
                    Text("Notes")
                }
                .listRowBackground(Color(hex: "1a1a24"))
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Act \(act)")
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
                        saveActProgress()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
        }
    }

    func saveActProgress() {
        var updatedRun = run
        let progress = ActProgress(
            act: act,
            completed: completed,
            deaths: deaths,
            notes: notes,
            completedDate: completed ? Date() : nil
        )
        updatedRun.updateAct(act, progress: progress)
        gameData.saveRun(updatedRun)
    }
}

// MARK: - Run Editor View
struct RunEditorView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss

    var run: Run?

    @State private var buildName: String = ""
    @State private var selectedBuildId: UUID?
    @State private var notes: String = ""

    init(run: Run?) {
        self.run = run
        if let run = run {
            _buildName = State(initialValue: run.buildName)
            _selectedBuildId = State(initialValue: run.buildId)
            _notes = State(initialValue: run.notes)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Campaign Name", text: $buildName)
                        .foregroundColor(.white)

                    Picker("Linked Build", selection: $selectedBuildId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(gameData.builds) { build in
                            Text(build.name).tag(Optional(build.id))
                        }
                    }
                    .foregroundColor(.white)
                } header: {
                    Text("Campaign Info")
                }
                .listRowBackground(Color(hex: "1a1a24"))

                Section {
                    TextField("Initial Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(.white)
                } header: {
                    Text("Notes")
                }
                .listRowBackground(Color(hex: "1a1a24"))

                if run != nil {
                    Section {
                        Button(role: .destructive) {
                            if let run = run {
                                gameData.deleteRun(run)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Campaign")
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(run == nil ? "New Campaign" : "Edit Campaign")
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
                        saveRun()
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
        }
    }

    func saveRun() {
        let newRun = Run(
            id: run?.id ?? UUID(),
            buildId: selectedBuildId,
            buildName: buildName,
            notes: notes,
            createdAt: run?.createdAt ?? Date()
        )
        // Preserve existing act progress if editing
        if let existingRun = run {
            var updatedRun = newRun
            updatedRun.acts = existingRun.acts
            gameData.saveRun(updatedRun)
        } else {
            gameData.saveRun(newRun)
        }
    }
}

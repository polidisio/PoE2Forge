import SwiftUI

struct ProgressView_: View {
    @EnvironmentObject var gameData: GameDataService
    @State private var showingNewRun = false
    @State private var selectedRun: Run? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()
                
                if gameData.runs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Runs Tracked")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Log your first run to track progress")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: { showingNewRun = true }) {
                            Label("Log Run", systemImage: "plus")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color(hex: "e07020"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats cards
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Runs",
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
                            
                            // Recent runs
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Runs")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(gameData.runs.sorted(by: { $0.date > $1.date }).prefix(10)) { run in
                                    RunRow(run: run)
                                        .onTapGesture {
                                            selectedRun = run
                                        }
                                }
                            }
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
                RunEditorView(run: run)
            }
        }
    }
}

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

struct RunRow: View {
    @EnvironmentObject var gameData: GameDataService
    let run: Run
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(run.completed ? Color.green : Color.orange)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: run.completed ? "checkmark" : "xmark")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(run.buildName.isEmpty ? "Unnamed Run" : run.buildName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("Act \(run.act)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if run.deaths > 0 {
                        Text("\(run.deaths) deaths")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(run.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
                
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

struct RunEditorView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    
    var run: Run?
    
    @State private var buildName: String = ""
    @State private var act: Int = 1
    @State private var completed: Bool = false
    @State private var deaths: Int = 0
    @State private var notes: String = ""
    
    init(run: Run?) {
        self.run = run
        if let run = run {
            _buildName = State(initialValue: run.buildName)
            _act = State(initialValue: run.act)
            _completed = State(initialValue: run.completed)
            _deaths = State(initialValue: run.deaths)
            _notes = State(initialValue: run.notes)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Build Name", text: $buildName)
                        .foregroundColor(.white)
                    
                    Picker("Act", selection: $act) {
                        ForEach(1...10, id: \.self) { a in
                            Text("Act \(a)").tag(a)
                        }
                    }
                    .foregroundColor(.white)
                } header: {
                    Text("Run Info")
                }
                .listRowBackground(Color(hex: "1a1a24"))
                
                Section {
                    Toggle("Completed", isOn: $completed)
                        .tint(Color(hex: "e07020"))
                        .foregroundColor(.white)
                    
                    Stepper("Deaths: \(deaths)", value: $deaths, in: 0...99)
                        .foregroundColor(.white)
                } header: {
                    Text("Result")
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
                                Text("Delete Run")
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "1a1a24"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0a0a0f"))
            .navigationTitle(run == nil ? "Log Run" : "Edit Run")
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
            buildName: buildName,
            act: act,
            completed: completed,
            deaths: deaths,
            notes: notes,
            date: run?.date ?? Date()
        )
        gameData.saveRun(newRun)
    }
}

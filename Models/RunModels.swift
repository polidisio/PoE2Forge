import Foundation

// MARK: - Act Progress
struct ActProgress: Codable, Identifiable {
    var id: Int { act }
    let act: Int
    var completed: Bool
    var deaths: Int
    var notes: String
    var completedDate: Date?

    init(act: Int, completed: Bool = false, deaths: Int = 0, notes: String = "", completedDate: Date? = nil) {
        self.act = act
        self.completed = completed
        self.deaths = deaths
        self.notes = notes
        self.completedDate = completedDate
    }
}

// MARK: - Run (Campaign Run)
struct Run: Codable, Identifiable {
    let id: UUID
    var buildId: UUID?
    var buildName: String
    var acts: [Int: ActProgress]  // Act 1-10 progress
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), buildId: UUID? = nil, buildName: String = "", notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.buildId = buildId
        self.buildName = buildName
        self.acts = [:]
        self.notes = notes
        self.createdAt = createdAt
    }

    // MARK: - Act Accessors
    func actProgress(_ act: Int) -> ActProgress {
        acts[act] ?? ActProgress(act: act)
    }

    mutating func updateAct(_ act: Int, progress: ActProgress) {
        acts[act] = progress
    }

    // MARK: - Computed Properties
    var completedActs: Int {
        acts.values.filter { $0.completed }.count
    }

    var totalDeaths: Int {
        acts.values.reduce(0) { $0 + $1.deaths }
    }

    var isCompleted: Bool {
        completedActs == 10
    }

    var currentAct: Int {
        for i in 1...10 {
            if !(acts[i]?.completed ?? false) {
                return i
            }
        }
        return 10
    }

    var lastPlayedDate: Date? {
        acts.values
            .compactMap { $0.completedDate }
            .sorted()
            .last
    }

    // MARK: - Act Names
    static let actNames: [Int: String] = [
        1: "The Twilight Strand",
        2: "The Coast",
        3: "The Mud Flats",
        4: "The Fellshrine Ruins",
        5: "The Crypt",
        6: "The Docks",
        7: "The Broken Bridge",
        8: "The Warehouse",
        9: "The Tunnel",
        10: "The Apex"
    ]

    func actName(_ act: Int) -> String {
        Run.actNames[act] ?? "Act \(act)"
    }
}

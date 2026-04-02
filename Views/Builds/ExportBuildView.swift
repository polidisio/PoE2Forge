import SwiftUI

struct ExportBuildView: View {
    @EnvironmentObject var gameData: GameDataService
    @Environment(\.dismiss) var dismiss
    let build: Build

    @State private var exportText = ""
    @State private var shareCode = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Share Code section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SHARE CODE")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text(shareCode)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "2a2a40"))
                            .cornerRadius(8)
                            .foregroundColor(.white)

                        Button(action: copyShareCode) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Code")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "e07020"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    // Text Export section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TEXT EXPORT")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text(exportText)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "2a2a40"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .frame(height: 300)

                        Button(action: copyExportText) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Text")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "2a2a40"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(hex: "1a1a24"))
                    .cornerRadius(16)

                    Text("Share the code or text with friends to let them import your build.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(Color(hex: "0a0a0f"))
            .navigationTitle("Export Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "e07020"))
                }
            }
            .onAppear {
                generateExports()
            }
        }
    }

    func generateExports() {
        exportText = PoBExportService.exportBuild(build, gameData: gameData)
        shareCode = PoBExportService.generateShareCode(build)
    }

    func copyShareCode() {
        UIPasteboard.general.string = shareCode
    }

    func copyExportText() {
        UIPasteboard.general.string = exportText
    }
}

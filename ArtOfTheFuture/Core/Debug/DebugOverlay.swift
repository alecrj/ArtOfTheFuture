import SwiftUI

struct DebugOverlay: View {
    @StateObject private var debugService = DebugService.shared
    @State private var selectedCategory: LogCategory?
    @State private var selectedLevel: LogLevel?

    var filteredLogs: [DebugLog] {
        var logs = debugService.logs
        if let cat = selectedCategory {
            logs = logs.filter { $0.category == cat }
        }
        if let lvl = selectedLevel {
            logs = logs.filter { $0.level == lvl }
        }
        return logs.reversed()
    }

    var body: some View {
        NavigationView {
            VStack {
                // Category filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(LogCategory.allCases, id: \.self) { cat in
                            Button(cat.rawValue) {
                                selectedCategory = (selectedCategory == cat ? nil : cat)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .tint(selectedCategory == cat ? .blue : .gray)
                        }
                    }
                    .padding(.horizontal)
                }

                // Logs list
                List(filteredLogs) { log in
                    LogRowView(log: log)
                }
            }
            .navigationTitle("Debug Console")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") { debugService.clearLogs() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { debugService.toggleDebugOverlay() }
                }
            }
        }
    }
}

struct LogRowView: View {
    let log: DebugLog
    private var timeFmt: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.level.emoji)
                Text(log.category.rawValue).font(.caption)
                Spacer()
                Text(timeFmt.string(from: log.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(log.message).font(.footnote)
            Text("\(log.file):\(log.line)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

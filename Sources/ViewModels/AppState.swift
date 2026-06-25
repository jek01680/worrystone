import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    // MARK: - Persistence keys
    private enum Key {
        static let hasLaunched    = "ws_hasLaunched"
        static let selectedStone  = "ws_selectedStone"
        static let totalRubs      = "ws_totalRubs"
        static let lastQuoteDate  = "ws_lastQuoteDate"
    }

    // MARK: - Published state
    @Published var selectedStone: StoneType?
    @Published var rubIntensity: Double   // 0 … 1
    @Published var currentQuote: Quote
    @Published var showingQuote: Bool = false
    @Published var isFirstLaunch: Bool

    private(set) var totalRubs: Int

    // MARK: - Init
    init() {
        let defaults = UserDefaults.standard

        let hasLaunched = defaults.bool(forKey: Key.hasLaunched)
        isFirstLaunch = !hasLaunched

        if let raw = defaults.string(forKey: Key.selectedStone),
           let stone = StoneType(rawValue: raw) {
            selectedStone = stone
        }

        totalRubs     = defaults.integer(forKey: Key.totalRubs)
        rubIntensity  = min(Double(totalRubs) / 600.0, 1.0)
        currentQuote  = worryStoneQuotes.randomElement()!
    }

    // MARK: - Actions
    func completeUnboxing(stone: StoneType) {
        selectedStone = stone
        isFirstLaunch = false
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Key.hasLaunched)
        defaults.set(stone.rawValue, forKey: Key.selectedStone)
    }

    func recordRub(distance: Double) {
        let increment = distance / 40.0
        totalRubs += 1
        rubIntensity = min(rubIntensity + increment * 0.003, 1.0)
        UserDefaults.standard.set(totalRubs, forKey: Key.totalRubs)

        // Show a quote every 15 rub-events
        if totalRubs % 15 == 0 {
            showNewQuote()
        }
    }

    func showNewQuote() {
        currentQuote = worryStoneQuotes.randomElement()!
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showingQuote = true
        }
        Task {
            try? await Task.sleep(for: .seconds(5))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.4)) {
                    showingQuote = false
                }
            }
        }
    }

    func dismissQuote() {
        withAnimation(.easeOut(duration: 0.3)) {
            showingQuote = false
        }
    }

    // Called after user watches an ad to re-draw a stone
    func resetForReroll() {
        selectedStone  = nil
        rubIntensity   = 0
        totalRubs      = 0
        isFirstLaunch  = true
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Key.hasLaunched)
        defaults.removeObject(forKey: Key.selectedStone)
        defaults.removeObject(forKey: Key.totalRubs)
    }
}

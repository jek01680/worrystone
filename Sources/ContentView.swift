import SwiftUI

struct ContentView: View {
    @StateObject private var state = AppState()

    var body: some View {
        Group {
            if state.isFirstLaunch {
                UnboxingView()
                    .transition(.opacity)
            } else if let stone = state.selectedStone {
                StoneRubView(stone: stone)
                    .transition(.opacity)
            }
        }
        .environmentObject(state)
        .animation(.easeInOut(duration: 0.5), value: state.isFirstLaunch)
    }
}

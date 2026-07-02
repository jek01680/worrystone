import SwiftUI

struct StoneRubView: View {
    let stone: StoneType
    @EnvironmentObject private var state: AppState
    @State private var showMenu = false
    @State private var hintOpacity: Double = 1

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer()
                stoneScene
                hintLabel
                Spacer()
                bottomArea
            }
        }
        .confirmationDialog("워리스톤", isPresented: $showMenu, titleVisibility: .visible) {
            Button("새 돌 뽑기") {
                // TODO: show rewarded ad before calling resetForReroll()
                state.resetForReroll()
            }
            Button("취소", role: .cancel) {}
        }
    }

    // MARK: Sub-views

    private var background: some View {
        LinearGradient(
            colors: stone.backgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Text(stone.displayName)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(stone.accentColor.opacity(0.75))
            Spacer()
            Button { showMenu = true } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(stone.accentColor.opacity(0.55))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    private var stoneScene: some View {
        StoneSceneView(
            stoneType: stone,
            rubIntensity: $state.rubIntensity,
            onRub: { dist in
                state.recordRub(distance: dist)
                if hintOpacity > 0 {
                    withAnimation(.easeOut(duration: 0.6)) { hintOpacity = 0 }
                }
            }
        )
        .frame(width: 310, height: 310)
    }

    private var hintLabel: some View {
        Text("문질러 보세요")
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(stone.accentColor.opacity(0.45))
            .opacity(hintOpacity)
            .padding(.top, 12)
            .animation(.easeOut(duration: 0.5), value: hintOpacity)
    }

    private var bottomArea: some View {
        Group {
            if state.showingQuote {
                QuoteCard(quote: state.currentQuote, stone: stone)
                    .padding(.horizontal, 24)
                    .onTapGesture { state.dismissQuote() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Button { state.showNewQuote() } label: {
                    Label("오늘의 문구", systemImage: "quote.bubble")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(stone.accentColor.opacity(0.75))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(stone.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                .transition(.opacity)
            }
        }
        .padding(.bottom, 48)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: state.showingQuote)
    }
}

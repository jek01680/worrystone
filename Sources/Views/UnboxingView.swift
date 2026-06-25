import SwiftUI

struct UnboxingView: View {
    @EnvironmentObject private var state: AppState

    // Each launch picks a random stone — user never chooses
    @State private var assigned: StoneType = StoneType.allCases.randomElement()!

    // Animation states
    @State private var phase: Phase = .idle
    @State private var lidY: CGFloat   = 0
    @State private var lidAlpha: Double = 1
    @State private var stoneScale: CGFloat = 0
    @State private var stoneAlpha: Double  = 0
    @State private var glowScale: CGFloat  = 0
    @State private var infoVisible: Bool   = false
    @State private var boxBounce: CGFloat  = 0

    private enum Phase { case idle, opening, revealing, done }

    var body: some View {
        ZStack {
            darkBackground
            starField

            VStack(spacing: 0) {
                titleText
                    .opacity(phase == .idle ? 1 : 0)
                    .animation(.easeOut(duration: 0.4), value: phase)
                    .padding(.top, 60)

                Spacer()

                ZStack {
                    glow
                    if phase != .revealing && phase != .done {
                        box
                    }
                    if phase == .revealing || phase == .done {
                        stonePreview
                    }
                }
                .frame(height: 320)

                Spacer()

                bottomInfo
                    .opacity(infoVisible ? 1 : 0)
                    .offset(y: infoVisible ? 0 : 30)
                    .animation(.spring(response: 0.55, dampingFraction: 0.75), value: infoVisible)
                    .padding(.bottom, 60)
            }
        }
        .onAppear { startBoxBounce() }
    }

    // MARK: - Sub-views

    private var darkBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.10, green: 0.09, blue: 0.18),
                     Color(red: 0.06, green: 0.05, blue: 0.12)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var starField: some View {
        GeometryReader { geo in
            ForEach(0..<28, id: \.self) { i in
                let seed = Double(i) * 137.508
                let x = (sin(seed) * 0.5 + 0.5) * geo.size.width
                let y = (cos(seed * 1.3) * 0.5 + 0.5) * geo.size.height * 0.65
                let size = CGFloat(i % 3 == 0 ? 3 : i % 2 == 0 ? 2 : 1.5)
                let alpha = 0.10 + 0.30 * (sin(seed * 0.7) * 0.5 + 0.5)

                Circle()
                    .fill(Color.white.opacity(alpha))
                    .frame(width: size, height: size)
                    .position(x: x, y: y)
            }
        }
        .allowsHitTesting(false)
    }

    private var titleText: some View {
        VStack(spacing: 10) {
            Text("당신만의 워리스톤")
                .font(.system(size: 24, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.90))
            Text("상자를 열어 확인해 보세요")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
        }
    }

    private var box: some View {
        BoxView(lidY: lidY, lidAlpha: lidAlpha)
            .offset(y: boxBounce)
            .onTapGesture { if phase == .idle { openBox() } }
    }

    private var glow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [assigned.accentColor.opacity(0.55), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 130
                )
            )
            .frame(width: 260, height: 260)
            .blur(radius: 28)
            .scaleEffect(glowScale)
            .allowsHitTesting(false)
    }

    private var stonePreview: some View {
        StoneSceneView(
            stoneType: assigned,
            rubIntensity: .constant(0.12),
            onRub: nil
        )
        .frame(width: 280, height: 280)
        .scaleEffect(stoneScale)
        .opacity(stoneAlpha)
        .allowsHitTesting(false)
    }

    private var bottomInfo: some View {
        VStack(spacing: 18) {
            Text(assigned.displayName)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Text(assigned.description)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 44)

            Button {
                withAnimation(.easeInOut(duration: 0.45)) {
                    state.completeUnboxing(stone: assigned)
                }
            } label: {
                Text("문질러보기")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 16)
                    .background(assigned.accentColor)
                    .clipShape(Capsule())
                    .shadow(color: assigned.accentColor.opacity(0.50), radius: 14, x: 0, y: 5)
            }
        }
    }

    // MARK: - Animation

    private func startBoxBounce() {
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            boxBounce = -8
        }
    }

    private func openBox() {
        phase = .opening

        // 1. Lid rises & fades
        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
            lidY = -140
        }
        withAnimation(.easeIn(duration: 0.35).delay(0.25)) {
            lidAlpha = 0
        }

        // 2. Stone appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            phase = .revealing
            withAnimation(.spring(response: 0.75, dampingFraction: 0.62)) {
                stoneScale = 1.0
                stoneAlpha = 1.0
                glowScale  = 1.0
            }
        }

        // 3. Info panel slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            phase = .done
            infoVisible = true
        }
    }
}

// MARK: - Gift Box

private struct BoxView: View {
    let lidY: CGFloat
    let lidAlpha: Double

    var body: some View {
        ZStack(alignment: .center) {
            // Body
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(boxGradient)
                .frame(width: 170, height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(red: 0.78, green: 0.68, blue: 0.52).opacity(0.55), lineWidth: 1)
                )
                .overlay(verticalRibbon)
                .offset(y: 25)

            // Lid
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(lidGradient)
                    .frame(width: 182, height: 46)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(red: 0.78, green: 0.68, blue: 0.52).opacity(0.55), lineWidth: 1)
                    )
                    .overlay(horizontalRibbon)
                bow
            }
            .offset(y: -88 + lidY)
            .opacity(lidAlpha)
        }
    }

    private var boxGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.55, green: 0.44, blue: 0.33),
                     Color(red: 0.42, green: 0.34, blue: 0.25)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var lidGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.64, green: 0.53, blue: 0.40),
                     Color(red: 0.48, green: 0.39, blue: 0.28)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private var verticalRibbon: some View {
        Rectangle()
            .fill(Color(red: 0.84, green: 0.57, blue: 0.30).opacity(0.85))
            .frame(width: 5, height: 150)
    }

    private var horizontalRibbon: some View {
        Rectangle()
            .fill(Color(red: 0.84, green: 0.57, blue: 0.30).opacity(0.85))
            .frame(width: 182, height: 5)
    }

    private var bow: some View {
        // Simple SwiftUI bow using two rounded shapes
        ZStack {
            Ellipse()
                .fill(Color(red: 0.95, green: 0.38, blue: 0.38))
                .frame(width: 30, height: 18)
                .offset(x: -12, y: -4)
                .rotationEffect(.degrees(-30))
            Ellipse()
                .fill(Color(red: 0.95, green: 0.38, blue: 0.38))
                .frame(width: 30, height: 18)
                .offset(x: 12, y: -4)
                .rotationEffect(.degrees(30))
            Circle()
                .fill(Color(red: 0.88, green: 0.25, blue: 0.25))
                .frame(width: 12, height: 12)
        }
        .offset(y: -2)
    }
}

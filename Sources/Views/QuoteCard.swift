import SwiftUI

struct QuoteCard: View {
    let quote: Quote
    let stone: StoneType

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "quote.opening")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(stone.accentColor.opacity(0.55))

            Text(quote.text)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(stone == .obsidian ? .white.opacity(0.85) : .primary.opacity(0.80))
                .multilineTextAlignment(.leading)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: stone.accentColor.opacity(0.18), radius: 14, x: 0, y: 5)
    }
}

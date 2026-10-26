import SwiftUI

public struct TraitChip: View {
    private let text: String
    private let systemImage: String?
    private let tint: Color

    public init(_ text: String, systemImage: String? = nil, tint: Color = .secondary) {
        self.text = text
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        HStack(spacing: Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(tint)
        .padding(.horizontal, Spacing.s + 2)
        .padding(.vertical, Spacing.xs + 2)
        .background(tint.opacity(0.12), in: .rect(cornerRadius: Radius.chip))
    }
}

#Preview {
    HStack {
        TraitChip("Femelle", systemImage: "heart")
        TraitChip("92 %", tint: .like)
    }
}

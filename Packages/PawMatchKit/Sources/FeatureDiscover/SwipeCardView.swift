import SwiftUI
import Domain
import DesignSystem
import Fixtures

/// Draggable card. Swipe right = like, left = pass (physical directions, also in RTL languages,
/// as users learned this convention from other apps). VoiceOver users get the same actions
/// through accessibility actions instead of the gesture.
struct SwipeCardView: View {
    let candidate: ScoredAnimal
    let onDecision: (SwipeDecision) -> Void
    let onShowDetails: () -> Void

    @State private var offset: CGSize = .zero
    private let decisionThreshold: CGFloat = 120

    private var animal: Animal { candidate.animal }

    var body: some View {
        AnimalPhotoView(animal: animal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) { infoPanel }
            .overlay(alignment: .top) { decisionStamp }
            .clipShape(.rect(cornerRadius: Radius.card))
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
            .offset(x: offset.width, y: offset.height * 0.2)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .gesture(dragGesture)
            .onTapGesture(perform: onShowDetails)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(named: Strings.like) { onDecision(.like) }
            .accessibilityAction(named: Strings.pass) { onDecision(.pass) }
            .accessibilityAction(named: Strings.details, onShowDetails)
    }

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(animal.name)
                    .font(.largeTitle.bold())
                Text(AnimalFormatter.age(of: animal))
                    .font(.title3)
                Spacer()
                TraitChip(AnimalFormatter.compatibilityScore(candidate.score), systemImage: "heart.fill", tint: .white)
            }
            if let distance = candidate.distanceMeters {
                Label(
                    Strings.distance(AnimalFormatter.distance(meters: distance)),
                    systemImage: "location.fill"
                )
                .font(.subheadline)
            }
            HStack(spacing: Spacing.s) {
                ForEach(candidate.score.highlights.prefix(2), id: \.self) { reason in
                    TraitChip(reason.localizedTitle, systemImage: "checkmark", tint: .white)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
        )
    }

    @ViewBuilder
    private var decisionStamp: some View {
        let progress = min(abs(offset.width) / decisionThreshold, 1)
        if offset.width != 0 {
            let isLike = offset.width > 0
            Image(systemName: isLike ? "heart.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white, isLike ? Color.like : Color.pass)
                .opacity(progress)
                .padding(.top, Spacing.xl)
                .accessibilityHidden(true)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { offset = $0.translation }
            .onEnded { value in
                if value.translation.width > decisionThreshold {
                    fling(.like)
                } else if value.translation.width < -decisionThreshold {
                    fling(.pass)
                } else {
                    withAnimation(.spring) { offset = .zero }
                }
            }
    }

    private func fling(_ decision: SwipeDecision) {
        withAnimation(.easeOut(duration: 0.2)) {
            offset.width = decision == .like ? 800 : -800
        } completion: {
            onDecision(decision)
        }
    }
}

#Preview {
    SwipeCardView(
        candidate: ScoredAnimal(
            animal: SampleData.animals[1],
            score: CompatibilityScorer().score(SampleData.animals[1], for: SampleData.profile),
            distanceMeters: 3_200
        ),
        onDecision: { _ in },
        onShowDetails: {}
    )
    .padding()
}

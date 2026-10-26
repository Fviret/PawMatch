import SwiftUI
import Domain
import DesignSystem

/// Shown after a like. Legal information depends on the *market*, not on the language.
struct MatchConfirmationView: View {
    let match: Match
    let market: MarketConfiguration
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.l) {
            AnimalPhotoView(animal: match.animal)
                .frame(width: 120, height: 120)
                .clipShape(.circle)

            Text(Strings.matchTitle)
                .font(.title.bold())

            Text(Strings.matchMessage(shelter: match.animal.shelter.name, animal: match.animal.name))
                .multilineTextAlignment(.center)

            if market.coolingOffPeriodDays > 0 {
                Label(Strings.coolingOff(days: market.coolingOffPeriodDays), systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(action: onContinue) {
                Text(Strings.matchContinue)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(Spacing.l)
        .presentationDetents([.medium, .large])
    }
}

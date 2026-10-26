import SwiftUI
import Domain
import DesignSystem
import FeatureAnimalDetail

public struct MatchesView: View {
    private let viewModel: MatchesViewModel

    public init(viewModel: MatchesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(Strings.title)
                .navigationDestination(for: Match.self) { match in
                    AnimalDetailView(animal: match.animal)
                }
                // `.task` re-runs each time the tab appears, so new likes show up.
                .task { await viewModel.load() }
                .refreshable { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .failed:
            ContentUnavailableView(Strings.errorTitle, systemImage: "exclamationmark.triangle")
        case .loaded where viewModel.matches.isEmpty:
            ContentUnavailableView(
                Strings.emptyTitle,
                systemImage: "heart",
                description: Text(Strings.emptyMessage)
            )
        case .loaded:
            List {
                Section {
                    ForEach(viewModel.matches) { match in
                        NavigationLink(value: match) {
                            MatchRow(match: match)
                        }
                    }
                } header: {
                    Text(Strings.count(viewModel.matches.count))
                }
            }
        }
    }
}

private struct MatchRow: View {
    let match: Match

    var body: some View {
        HStack(spacing: Spacing.m) {
            AnimalPhotoView(animal: match.animal)
                .frame(width: 56, height: 56)
                .clipShape(.circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(match.animal.name)
                    .font(.headline)
                Text(match.animal.shelter.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Strings.requestedOn(match.createdAt.formatted(date: .abbreviated, time: .omitted)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: Spacing.s)

            TraitChip(Strings.status(match.status), tint: match.status.tint)
        }
        .accessibilityElement(children: .combine)
    }
}

private extension MatchStatus {
    var tint: Color {
        switch self {
        case .pending: .warning
        case .accepted: .like
        case .declined: .secondary
        case .adopted: .blue
        }
    }
}

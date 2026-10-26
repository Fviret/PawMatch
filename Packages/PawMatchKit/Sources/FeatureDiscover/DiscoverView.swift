import SwiftUI
import Domain
import DesignSystem
import FeatureAnimalDetail

public struct DiscoverView: View {
    @Bindable private var viewModel: DiscoverViewModel
    @State private var selectedCandidate: ScoredAnimal?

    public init(viewModel: DiscoverViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(Strings.title)
                .sheet(item: $selectedCandidate) { candidate in
                    NavigationStack {
                        AnimalDetailView(
                            animal: candidate.animal,
                            score: candidate.score,
                            distanceMeters: candidate.distanceMeters
                        )
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(Strings.close) { selectedCandidate = nil }
                            }
                        }
                    }
                }
                .sheet(item: $viewModel.lastMatch) { match in
                    MatchConfirmationView(match: match, market: viewModel.market) {
                        viewModel.lastMatch = nil
                    }
                }
                .task {
                    if viewModel.state == .idle { await viewModel.load() }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView(Strings.loading)
        case .failed:
            ContentUnavailableView {
                Label(Strings.errorTitle, systemImage: "exclamationmark.triangle")
            } actions: {
                Button(Strings.retry) { Task { await viewModel.load() } }
                    .buttonStyle(.borderedProminent)
            }
        case .loaded:
            if let top = viewModel.deck.first {
                deck(top: top)
            } else {
                ContentUnavailableView(
                    Strings.emptyTitle,
                    systemImage: "pawprint",
                    description: Text(Strings.emptyMessage)
                )
            }
        }
    }

    private func deck(top: ScoredAnimal) -> some View {
        VStack(spacing: Spacing.l) {
            ZStack {
                // Only the top 3 cards are rendered; the first one is drawn last (on top).
                let visible = Array(viewModel.deck.prefix(3).enumerated())
                ForEach(visible.reversed(), id: \.element.id) { depth, candidate in
                    SwipeCardView(
                        candidate: candidate,
                        onDecision: { decide($0, on: candidate) },
                        onShowDetails: { selectedCandidate = candidate }
                    )
                    .scaleEffect(1 - CGFloat(depth) * 0.04)
                    .offset(y: CGFloat(depth) * 12)
                    .allowsHitTesting(depth == 0)
                    .accessibilityHidden(depth != 0)
                }
            }
            .padding(.horizontal, Spacing.m)

            actionBar(for: top)
        }
        .padding(.vertical, Spacing.m)
    }

    private func actionBar(for candidate: ScoredAnimal) -> some View {
        HStack(spacing: Spacing.xl) {
            CircleActionButton(systemImage: "xmark", tint: .pass, label: Strings.pass) {
                decide(.pass, on: candidate)
            }
            CircleActionButton(systemImage: "info", tint: .blue, label: Strings.details, size: 48) {
                selectedCandidate = candidate
            }
            CircleActionButton(systemImage: "heart.fill", tint: .like, label: Strings.like) {
                decide(.like, on: candidate)
            }
        }
    }

    private func decide(_ decision: SwipeDecision, on candidate: ScoredAnimal) {
        Task {
            await viewModel.decide(decision, on: candidate)
        }
    }
}

private struct CircleActionButton: View {
    let systemImage: String
    let tint: Color
    let label: String
    var size: CGFloat = 64
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(.background, in: .circle)
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
        }
        .accessibilityLabel(label)
    }
}

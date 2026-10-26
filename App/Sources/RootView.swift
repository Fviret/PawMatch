import SwiftUI
import FeatureDiscover
import FeatureMatches

struct RootView: View {
    @State private var discover: DiscoverViewModel
    @State private var matches: MatchesViewModel

    init(container: AppContainer) {
        _discover = State(initialValue: container.makeDiscoverViewModel())
        _matches = State(initialValue: container.makeMatchesViewModel())
    }

    var body: some View {
        TabView {
            DiscoverView(viewModel: discover)
                .tabItem { Label(String(localized: "tab.discover"), systemImage: "pawprint.fill") }
            MatchesView(viewModel: matches)
                .tabItem { Label(String(localized: "tab.matches"), systemImage: "heart.fill") }
        }
    }
}

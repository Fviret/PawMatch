import SwiftUI

@main
struct PawMatchApp: App {
    private let container = AppContainer(environment: .current)

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}

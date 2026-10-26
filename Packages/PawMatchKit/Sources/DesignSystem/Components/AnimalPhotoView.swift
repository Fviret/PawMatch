import SwiftUI
import Domain

/// First photo of the animal, or a species-themed placeholder.
public struct AnimalPhotoView: View {
    private let animal: Animal

    public init(animal: Animal) {
        self.animal = animal
    }

    public var body: some View {
        Group {
            if let url = animal.photoURLs.first {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .accessibilityLabel(Strings.photoAccessibilityLabel(animal.name))
    }

    private var placeholder: some View {
        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: animal.species.symbolName)
                    .resizable()
                    .scaledToFit()
                    .padding(Spacing.xl * 1.5)
                    .foregroundStyle(.white.opacity(0.85))
            }
    }

    private var gradient: [Color] {
        switch animal.species {
        case .dog: [.orange, .pink]
        case .cat: [.purple, .indigo]
        case .rabbit: [.mint, .teal]
        case .other: [.gray, .blue]
        }
    }
}

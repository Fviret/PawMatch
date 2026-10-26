import SwiftUI
import Domain
import DesignSystem
import Fixtures

/// Full profile of an animal. Stateless: callers pass what they already have,
/// so the screen is reusable from Discover (with a score) and Matches (without).
public struct AnimalDetailView: View {
    private let animal: Animal
    private let score: CompatibilityScore?
    private let distanceMeters: Double?

    public init(animal: Animal, score: CompatibilityScore? = nil, distanceMeters: Double? = nil) {
        self.animal = animal
        self.score = score
        self.distanceMeters = distanceMeters
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                AnimalPhotoView(animal: animal)
                    .frame(height: 340)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(alignment: .leading, spacing: Spacing.l) {
                    header
                    if let score { compatibilitySection(score) }
                    section(Strings.sectionAbout) {
                        Text(animal.story)
                    }
                    healthSection
                    shelterSection
                }
                .padding(.horizontal, Spacing.m)
            }
            .padding(.bottom, Spacing.xl)
        }
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(animal.name)
                .font(.largeTitle.bold())
            Text(animal.breedName ?? Strings.mixedBreed)
                .font(.title3)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    TraitChip(animal.species.localizedName, systemImage: animal.species.symbolName)
                    TraitChip(AnimalFormatter.age(of: animal), systemImage: "birthday.cake")
                    TraitChip(animal.sex.localizedName)
                    TraitChip(animal.size.localizedName, systemImage: "ruler")
                    if let weight = animal.weightKilograms {
                        TraitChip(AnimalFormatter.weight(kilograms: weight), systemImage: "scalemass")
                    }
                    TraitChip(animal.energyLevel.localizedName, systemImage: "bolt.heart")
                    if let distanceMeters {
                        TraitChip(AnimalFormatter.distance(meters: distanceMeters), systemImage: "location")
                    }
                }
            }
        }
    }

    private func compatibilitySection(_ score: CompatibilityScore) -> some View {
        section(Strings.sectionCompatibility) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                TraitChip(AnimalFormatter.compatibilityScore(score), systemImage: "heart.fill", tint: .like)
                ForEach(score.highlights, id: \.self) { reason in
                    Label(reason.localizedTitle, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color.like)
                }
                ForEach(score.warnings, id: \.self) { reason in
                    Label(reason.localizedTitle, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.warning)
                }
            }
        }
    }

    private var healthSection: some View {
        section(Strings.sectionHealth) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                healthRow(Strings.healthNeutered, isDone: animal.health.isNeutered)
                healthRow(Strings.healthVaccinated, isDone: animal.health.isVaccinated)
                healthRow(Strings.healthIdentified, isDone: animal.health.isIdentified)
            }
        }
    }

    private func healthRow(_ title: String, isDone: Bool) -> some View {
        Label(title, systemImage: isDone ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isDone ? Color.primary : Color.secondary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityValue(isDone ? Strings.yes : Strings.no)
    }

    private var shelterSection: some View {
        section(Strings.sectionShelter) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(animal.shelter.name).font(.headline)
                Text(Strings.shelterLocation(
                    city: animal.shelter.city,
                    country: AnimalFormatter.countryName(regionCode: animal.shelter.regionCode)
                ))
                .foregroundStyle(.secondary)
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

#Preview {
    NavigationStack {
        AnimalDetailView(
            animal: SampleData.animals[0],
            score: CompatibilityScorer().score(SampleData.animals[0], for: SampleData.profile),
            distanceMeters: 12_400
        )
    }
}

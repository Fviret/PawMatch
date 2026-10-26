# Architecture de PawMatch

> Nom de code provisoire. Il est défini à un seul endroit (`project.yml` et `InfoPlist.xcstrings`).

## 1. Les questions qu'on s'est posées

| Question | Décision | Pourquoi |
|---|---|---|
| UIKit ou SwiftUI ? | **SwiftUI, iOS 17+** | `@Observable`, `ContentUnavailableView`, String Catalogs. iOS 17 couvre plus de 90 % du parc. |
| Un seul target ou des modules ? | **Package Swift local découpé en modules** | Le compilateur impose les dépendances (une feature *ne peut pas* importer la couche réseau), la compilation est incrémentale et chaque module se teste seul. |
| Quel pattern de présentation ? | **MVVM + use cases** | C'est simple et natif SwiftUI, et c'est testable sans UI. TCA serait plus puissant mais demande une dépendance et une courbe d'apprentissage qui ne se justifient pas encore. |
| Où vit la logique métier ? | **`Domain`, en Swift pur** | Le score de compatibilité est l'actif de l'app : il doit pouvoir être testé, et un jour exécuté côté serveur. |
| Comment injecter les dépendances ? | **À la main, via un *composition root* (`AppContainer`)** | Pas de framework, pas de magie : on lit qui dépend de quoi. On pourra passer à un framework plus tard si le graphe grossit. |
| `.xcodeproj` versionné ? | **Non, généré par XcodeGen** (`project.yml`) | Plus de conflits de merge sur le `project.pbxproj`. |
| Concurrence ? | **Swift 6, mode strict** | Les data races sont détectées à la compilation. Les repositories en mémoire sont des `actor`. |

## 2. Modules

```
App (PawMatch)            ← composition root : choisit les implémentations concrètes
 ├── FeatureDiscover      ← deck de swipe, confirmation de match
 ├── FeatureMatches       ← liste des demandes d'adoption
 │     └── FeatureAnimalDetail  ← fiche animal (partagée)
 ├── DesignSystem         ← tokens, composants, formatage localisé
 ├── DataAccess           ← in-memory, client REST, DTO
 ├── Fixtures             ← données de démo/preview/test
 └── Domain               ← entités, protocoles de repository, use cases, scoring
```

**Règle d'or : les flèches pointent vers `Domain`.** `Domain` n'importe ni SwiftUI ni la couche réseau. Les features n'importent jamais `DataAccess` : elles ne voient que des protocoles.

Pour ajouter une feature (ex. `FeatureOnboarding`) :
1. créer `Sources/FeatureOnboarding/` avec ses `Strings.swift` et `Resources/Localizable.xcstrings` ;
2. la déclarer dans `Package.swift` (dépendances : `Domain`, `DesignSystem`) ;
3. ajouter une fabrique dans `AppContainer` et l'ajouter dans `project.yml`.

## 3. Localisation

- **String Catalogs (`.xcstrings`)**, un par module, dans `Resources/`. Chaque module embarque ses propres traductions (`bundle: .module`). Une feature peut donc être déplacée ou supprimée sans laisser de clés orphelines.
- **Clés sémantiques** (`discover.match.title`) plutôt que du texte source. On peut retoucher le texte anglais sans casser les traductions.
- **Accès typé** via un `enum Strings` par module. Une faute de frappe dans une clé ne peut se trouver qu'à un seul endroit, à côté du catalogue.
- **Jamais de concaténation** : les variables sont dans la phrase (`%1$@`, `%2$@`), ce qui permet au traducteur de réordonner les mots.
- **Pluriels** gérés par le catalogue (`one`/`other`, et `few`/`many` automatiquement pour le polonais, le russe, l'arabe, etc.).
- **Commentaire obligatoire** pour chaque clé, à destination des traducteurs.
- **Formulations neutres en genre** (« Énergie élevée » plutôt que « Très actif·ve ») : les animaux sont mâles ou femelles.
- **Unités et formats** : `Measurement` et `FormatStyle` (km/mi, kg/lb, dates, %). Rien n'est formaté à la main.
- **Langue de développement : anglais**, avec traductions FR et ES. Un utilisateur italien verra donc l'app en anglais (fallback), pas en français.
- **Contenu ≠ UI** : l'histoire d'un animal ou le nom d'une race viennent du backend, qui les localise grâce au header `Accept-Language` envoyé par `APIClient`.
- **CI** : `scripts/check_localizations.py` échoue s'il manque une traduction, un commentaire, ou si une clé est obsolète.

Pour ajouter une langue : ouvrir n'importe quel catalogue dans Xcode, cliquer sur **+**, choisir la langue, puis traduire (ou exporter en XLIFF : *Product ▸ Export Localizations*). Il faut ensuite l'ajouter à `CFBundleLocalizations` dans `project.yml` et au `DEFAULT_LANGUAGES` du script.

## 4. National ≠ international ≠ langue

Ce sont trois axes indépendants, et le code les sépare :

| Axe | Porté par | Exemple |
|---|---|---|
| **Langue** | `Locale.preferredLanguages`, String Catalogs | Un hispanophone à Lyon voit l'app en espagnol… |
| **Format régional** | `Locale.current` + `FormatStyle` | …avec des km et des dates au format de ses réglages… |
| **Marché (règles légales et métier)** | `MarketConfiguration` | …mais soumis au délai de réflexion **français** de 7 jours. |

## 5. Lancer le projet

```bash
brew install xcodegen
xcodegen generate
open PawMatch.xcodeproj
```

Tests (Swift Testing, sur simulateur) :

```bash
cd Packages/PawMatchKit && xcodebuild test -scheme PawMatchKit-Package -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Vérifier les traductions :

```bash
python3 scripts/check_localizations.py
```

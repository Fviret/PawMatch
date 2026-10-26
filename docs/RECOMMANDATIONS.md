# Recommandations pour un déploiement national puis international

Classées par moment où il faut les décider. Plus une décision arrive tard, plus elle coûte cher.

## À décider maintenant (avant d'écrire plus de code)

1. **Concevoir le backend multi-pays dès le départ.** Chaque refuge, animal et utilisateur porte un `region_code`. Les dates sont en UTC (ISO 8601) et les quantités en unités SI. L'API reçoit `Accept-Language` et renvoie le contenu dans la meilleure langue disponible. Le contrat est esquissé dans `DataAccess/Remote`.
2. **Servir les règles de marché par le backend.** `MarketConfiguration` est aujourd'hui statique ; la servir en *remote config* permet d'ouvrir un pays (Belgique, Suisse, Québec…) sans passer par l'App Store.
3. **Faire valider le cadre légal par un juriste**, pays par pays. En France, cela couvre le certificat d'engagement et le délai de 7 jours (loi du 30/11/2021), l'identification I-CAD, le RGPD (données de localisation et du foyer), ainsi que les CGU et le rôle des refuges.
4. **Ne pas prendre « SPA » comme modèle.** Le domaine parle de `Shelter`, ce qui permet d'accueillir la SPA, les associations locales, les fourrières et les refuges étrangers. Les partenariats (et la marque « SPA », qui est protégée) relèvent du business, pas du code.
5. **Fixer la langue pivot à l'anglais** pour les traductions, avec le français maintenu par l'équipe. Les agences de traduction travaillent mieux depuis l'anglais.

## À mettre en place très tôt

6. **Utiliser une plateforme de traduction** (Lokalise, Crowdin, Phrase) branchée sur les `.xcstrings`/XLIFF, avec le script de vérification en CI. Les traducteurs ne touchent pas au repo.
7. **Traduire le contenu des refuges.** Les histoires des animaux sont écrites en français ; il faut prévoir une traduction automatique côté serveur, marquée comme telle dans l'UI, avec la possibilité pour le refuge de corriger.
8. **Prévoir la mise en page RTL** (arabe, hébreu) : utiliser `leading`/`trailing` partout, jamais `left`/`right` (déjà respecté). On peut tester avec le scheme *Right-to-Left Pseudolanguage* et l'argument `-AppleTextDirection YES`.
9. **Tester avec des pseudo-langues** (*Double-Length*, *Accented*) dans le scheme, pour repérer les textes tronqués : l'allemand est environ 30 % plus long que l'anglais.
10. **Générer automatiquement les captures App Store par langue**, via un test UI qui lance l'environnement `.demo` (les données de démo sont déjà en place).
11. **Maintenir trois environnements** (dev / staging / prod) via des `.xcconfig`, et lire `AppEnvironment.current` depuis l'`Info.plist`.

## À prévoir dans la feuille de route

12. **Créer un onboarding qui remplit `AdopterProfile`** (logement, enfants, animaux, rythme de vie). C'est lui qui donne du sens au score.
13. **Déplacer le score côté serveur** à terme : on peut l'améliorer (pondérations, apprentissage) sans mise à jour de l'app. `CompatibilityScorer` est pur, donc facile à porter.
14. **Construire une app ou un back-office pour les refuges** (publier un animal, accepter une demande) : c'est l'autre moitié du marché.
15. **Ajouter la messagerie adoptant ↔ refuge**, les notifications push (localisées côté serveur) et la prise de rendez-vous.
16. **Traiter l'accessibilité comme une exigence.** Le swipe a déjà des actions VoiceOver équivalentes et les tailles de police respectent Dynamic Type. À ajouter : un audit VoiceOver et le contraste du texte sur les photos.
17. **Mettre en place l'analytics et le monitoring** (taux de like, taux d'adoption par marché, crashs), en respectant le consentement RGPD.
18. **Ajouter SwiftLint/SwiftFormat et une CI** (GitHub Actions ou Xcode Cloud) : `xcodegen generate`, build, tests, `check_localizations.py`.

# Math Runner Implementation Plan

**Goal:** Livrer le prototype jouable demandé, testé et documenté.
**Architecture:** Règles pures, scènes réutilisables, contrôleur de niveau et HUD.
**Tech Stack:** Godot 4.6.3, GDScript, tests SceneTree sans dépendance.
**Spec:** docs/superpowers/specs/2026-11-09-math-runner-design.md

## Contraintes
Prototype fonctionnel avant tout effet visuel ; distinguer headless et graphique.
Exécuter directement les étapes autorisées par la mission, sans validation
intermédiaire supplémentaire. Dépôt neuf isolé sur feat/godot-math-runner.

## Points de revue
Calcul borné ; rangée résolue une seule fois ; tirs rapides ; pause et perte de
focus relâchant les touches ; fin de niveau avec rangées encore à l'écran.

## Étapes
1. [ ] Écrire les tests de calcul, constater l'échec, implémenter
   `MathRules.apply(value: int, operation: String, operand: int) -> int` ; tester
   +5, ×2, +10, soustraction, division, bornes et ordre ; commit.
2. [ ] Écrire les tests de scènes réelles, constater l'absence du jeu, implémenter
   Player, Projectile, MathTarget, LevelDirector et Main. Vérifier le mouvement,
   les tirs, les choix exclusifs, vies, victoire et accélération ; commit.
3. [ ] Ajouter et vérifier pause/reprise, redémarrage, clavier et tactile natif.
   Valider import propre et exécution longue headless.
4. [ ] Documenter PC, préparation Android et environnement ; ajouter CI headless
   reproductible ; vérifier l'ensemble, committer et pousser si dépôt identifié.

## Exécution
L'agent réalise les étapes dans cette session. La destination GitHub est demandée
en parallèle et n'empêche pas de développer/tester le projet localement.


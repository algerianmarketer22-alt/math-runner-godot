# État de validation — 9 novembre 2026

## Environnement cloud

- Godot **4.6.3.stable.official.7d41c59c4**, binaire standard déjà installé.
- Projet neuf dans `/workspace/math-runner`, branche `feat/godot-math-runner`.
- Le dossier utilisateur système est protégé ; `tools/test.sh` place données,
  configuration et cache XDG dans des répertoires temporaires accessibles.
- OpenJDK 21 présent ; Android demande la préparation JDK 17 / SDK documentée.
- Aucun SDK Android, ADB ni modèle d'export installé pendant cette mission.

## Résultats

Commande : `bash tools/test.sh` (code de sortie 0).

| Vérification | Résultat |
| --- | --- |
| Calculs, ordre, division entière, bornes | 12 vérifications, 0 échec |
| Scènes, commandes clavier, tir automatique, collisions, états | 20 vérifications, 0 échec |
| Événements tactiles, deux doigts, pause/reprise/rejouer | 9 vérifications, 0 échec |
| Partie pilotée via actions clavier et vraie boucle physique | Victoire, 18/18 rangées, charge 285, 3 vies, 2793 images |
| Exécution du jeu sans intervention | 4200 images à pas fixe de 1/60 s, aucune erreur |
| Syntaxe Bash et `git diff --check` | Aucune erreur |
| Export du pack de ressources Linux `.pck` | Création sans erreur, puis 4200 images headless depuis le pack |

La revue indépendante a détecté une panne des boutons UI au doigt causée par
`emulate_mouse_from_touch=false`. Le nouveau test tactile a reproduit trois
échecs (Pause, reprise après focus, Rejouer), puis zéro après correction.
Les deux boutons de déplacement restent des TouchScreenButton natifs.

Les prérequis Android ont été comparés à la documentation officielle Godot 4.6,
et l'URL de somme SHA-512 du binaire CI 4.6.3 a été vérifiée.

## Limites explicites

Les événements tactiles sont injectés dans un viewport headless. **Aucun test
graphique ou sur téléphone réel n'a été effectué.** Aucun export exécutable PC
ni APK n'a été construit ; les préréglages et les instructions les préparent.
Le workflow GitHub Actions est fourni, mais n'a pas encore tourné sur GitHub.

## Sauvegarde GitHub

La création du dépôt privé `math-runner-godot` a été tentée avec `gh repo create`,
puis l'API REST `POST /user/repos`. Les deux ont été refusées par les droits de
la connexion GitHub (`Resource not accessible by integration`, HTTP 403).
Ce refus provenait des droits de création de la connexion GitHub. L'utilisateur
a ensuite créé et fourni le dépôt vide :
https://github.com/algerianmarketer22-alt/math-runner-godot.
Les commits du prototype et de sa documentation sont envoyés sur sa branche
`main`. Le workflow GitHub Actions peut alors exécuter les tests à chaque push.

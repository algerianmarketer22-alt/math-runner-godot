# Math Runner

Prototype 2D **Godot 4.6.3 / GDScript**, sans dépendance ni asset externe.
Le personnage avance automatiquement et **tire automatiquement**. Le joueur se
déplace uniquement de gauche à droite pour choisir ses cibles mathématiques.

## Jouer immédiatement sur téléphone

Ouvrir **[Math Runner dans le navigateur](https://math-runner-mobile-algerianmarketer.vercel.app/)**
avec un navigateur récent, en portrait. Attendre la fin du téléchargement initial
du moteur, puis maintenir les boutons **<** ou **>** en bas de l'écran pour bouger.
Le tir est automatique. Aucune installation de Godot ni d'APK n'est nécessaire.
Après un changement d'application, toucher **Reprendre**.

L'export Web et l'hébergement sont documentés dans [docs/web.md](docs/web.md).

## Jouer sur PC

1. Installer [Godot 4.6.3 standard](https://godotengine.org/download/archive/4.6.3-stable/)
   (la version .NET n'est pas nécessaire).
2. Cloner ce dépôt, puis importer `project.godot` dans Godot.
3. Appuyer sur **F6** pour la scène ouverte ou **F5** pour le projet.

Depuis un terminal, à la racine du projet :

```sh
godot --editor --path .
godot --path .
```

Sous Windows, remplacer `godot` par le chemin du fichier `.exe` téléchargé.
Sous macOS : `/Applications/Godot.app/Contents/MacOS/Godot --path .`.
Utiliser `godot4` si votre installation porte ce nom.

| Action | Contrôle |
| --- | --- |
| Gauche / droite | Flèches, A/D ou Q/D |
| Tir | Automatique, aucune touche |
| Pause / reprise | P, Échap ou bouton Pause |
| Rejouer | R ou bouton Rejouer en fin de partie |
| Afficher les commandes tactiles sur PC | T |

Sur mobile, deux boutons tactiles gauche/droite apparaissent automatiquement.
Ce sont des `TouchScreenButton` natifs, associés aux mêmes actions que le clavier.
Une perte de focus met le jeu en pause et relâche les commandes ; reprendre avec
le bouton. Format portrait, mise à l'échelle proportionnelle avec bandes selon
le rapport de l'écran. Les contrôles restent dans les limites du canevas.

## Règles du premier niveau

- Charge initiale **10**, **3 vies**, **18 rangées** de deux ou trois choix.
- Un tir touche une cible : son opération s'applique immédiatement, puis toutes
  les autres cibles de cette rangée disparaissent. Une seule opération par rangée.
- Bonus : **+5, +10, ×2**. Malus : **−5, −10, ÷2** (arrondi à l'entier inférieur).
- Charge bornée de **0 à 999 999**. Ex. 10 → +5 → 15 → ×2 → 30.
- Une rangée qui franchit la ligne du bas sans être touchée coûte une vie.
- À zéro vie : défaite. Survivre aux 18 rangées : niveau terminé.
- Objectif secondaire : finir avec au moins **200** de charge.
- Le défilement passe de **140 à 242 px/s** ; l'intervalle entre rangées passe de
  **3,2 à 2,095 s**. Niveau déterministe d'environ 47 secondes avec le pilote de test.

Choisir +10 ou ×2 dépend de la charge actuelle. Comme le tir est automatique,
le déplacement constitue la visée : anticipez les rangées et évitez de rester
sous un malus. Il n'y a pas encore de combat ennemi, son, animation ou particule.

## Tests automatisés

Pré-requis : Godot 4.6.3, Bash et les outils système standard (`grep`, `mktemp`).

```sh
bash tools/test.sh
# Ou si le binaire porte un autre nom :
GODOT_BIN=/chemin/vers/godot bash tools/test.sh
```

Le script prépare des dossiers XDG temporaires pour fonctionner même quand le
dossier utilisateur du cloud est protégé. Il échoue aussi si Godot imprime une
erreur GDScript sans renvoyer un code de sortie non nul.

Commandes individuelles, y compris sous PowerShell :

```sh
godot --headless --path . --script res://tests/test_rules.gd
godot --headless --path . --script res://tests/test_game.gd
godot --headless --path . --script res://tests/test_touch.gd
godot --headless --fixed-fps 60 --path . --script res://tests/test_level.gd
godot --headless --fixed-fps 60 --path . --quit-after 4200
```

`test_rules.gd` vérifie les calculs et leurs limites ; `test_game.gd` instancie les
scènes réelles et vérifie les commandes, collisions balayées, choix exclusifs,
vies, états et progression. `test_touch.gd` injecte des événements tactiles dans
le viewport pour vérifier deux doigts, relâchement, pause, reprise et redémarrage.
`test_level.gd` pilote une partie complète via les
actions clavier dans la boucle physique réelle, sans modifier le score.
Le dernier lancement laisse tourner le jeu sans intervention pendant 70 secondes
simulées. La CI reprend ces tests avec le binaire officiel et sa somme SHA-512.

**Validation :** tests Godot headless, puis rendu WebGL et déplacements tactiles,
pause et reprise dans Chromium avec émulation mobile Pixel 7. Les tests du
navigateur utilisent le vrai export Web du jeu. Aucun téléphone physique, APK
ni export PC autonome n'a été testé.
Un pack de ressources `.pck` a été produit et exécuté en headless ; il ne constitue
pas un exécutable autonome. Voir [le relevé de validation](docs/validation.md).

## Structure

```text
project.godot             Configuration et scène de départ
scenes/                  Main, Player, Projectile, MathTarget
scripts/main.gd          Orchestration, collisions, vies et états
scripts/player.gd        Déplacement latéral et tir automatique
scripts/projectile.gd    Vitesse et dessin du tir
scripts/math_target.gd   Opération, limites et dessin de cible
scripts/math_rules.gd    Calculs purs et charge bornée
scripts/level_director.gd Motifs des 18 rangées et difficulté
scripts/hud.gd           Interface et commandes tactiles
tests/                   Calculs, scènes et partie complète
tools/test.sh            Suite headless pour PC/cloud/CI
export_presets.cfg       Préréglages Linux, Windows, Android et Web
docs/                    Plan, conception et préparation Android
```

Les collisions utilisent un segment vertical entre l'ancienne et la nouvelle
position du projectile ; un tir rapide ne traverse pas une cible. Aucune physique
3D ni extension native n'est nécessaire. Les identifiants `.gd.uid` sont versionnés,
le cache `.godot/` est régénéré localement et reste ignoré.

## Exports PC et Android

Installer dans **Éditeur → Gérer les modèles d'export** les modèles **4.6.3**,
puis utiliser **Projet → Exporter**. Les préréglages sont fournis ; créer les
dossiers de destination avant un export en ligne de commande :

```sh
mkdir -p build/linux build/windows build/android
godot --headless --path . --export-release Linux build/linux/math-runner.x86_64
godot --headless --path . --export-release Windows build/windows/math-runner.exe
```

La préparation Android (JDK, SDK, clé debug, APK et vérifications sur appareil)
est détaillée dans [docs/android.md](docs/android.md).

## GitHub

Les commits locaux conservent les étapes fonctionnelles. Si la connexion GitHub
ne permet pas de créer un dépôt, créer un dépôt **vide** dans GitHub puis lancer :

```sh
git remote add origin https://github.com/VOTRE_COMPTE/math-runner-godot.git
git push -u origin HEAD
```

Ne pas ajouter de README distant au préalable pour éviter deux historiques
indépendants. Aucun fichier de clé de signature ne doit être committé.

# Math Runner — prototype minimal

Demande : Godot 4, GDScript, personnage qui avance et tire sur des cibles
mathématiques, bonus, malus, stratégie, difficulté progressive, clavier et
préparation tactile, tests headless, documentation PC/Android et sauvegarde GitHub.

Choix de réalisation proposés par l'agent : vue verticale portrait 720 × 1080,
avancée automatique représentée par le défilement de la piste, déplacement latéral
continu devant trois couloirs et tir manuel vers le haut. Une vue de plateforme
ajouterait la gravité et le saut sans servir la mécanique mathématique ; un
déplacement libre demanderait des règles de visée supplémentaires.

Charge initiale 10, trois vies, 18 rangées. Un tir choisit une cible et annule les
autres de sa rangée. Opérations +5, +10, ×2, −5, −10 et ÷2 (entier inférieur).
Charge bornée entre 0 et 999999. Une rangée entièrement manquée coûte une vie.
Trois échecs terminent la partie ; survivre aux 18 rangées termine le niveau.
Objectif secondaire : charge finale ≥ 200. Le choix +10/×2 dépend de la charge
actuelle. Les premières rangées introduisent les opérations, puis vitesse et
fréquence augmentent de façon déterministe. Aucun compte ni service externe.

Scènes : Main, Player, Projectile, MathTarget ; scripts séparés pour les règles
pures et la progression. Collisions de tirs calculées sur le segment parcouru
dans chaque pas physique pour éviter de traverser les cibles à grande vitesse.
Interface française, pause, redémarrage, boutons tactiles natifs multitouch.
Pas d'animations, de particules ni d'assets externes dans cette première version.

Validation : calculs isolés puis scènes réelles dans SceneTree headless, dont
collisions, sélection unique, défaite, victoire, progression et contrôles. Une
exécution headless ne constitue pas une validation graphique ni sur Android.
Pas de dépôt distant identifié initialement : construire et committer localement,
puis pousser uniquement vers la destination indiquée par l'utilisateur.


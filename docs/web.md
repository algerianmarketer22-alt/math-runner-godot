# Version Web mobile

Objectif : tester le même projet Godot sur téléphone via un lien HTTPS, sans APK.
Export Compatibility, sans threads ni extensions natives : aucune exigence de
SharedArrayBuffer ni de headers d'isolation cross-origin sur l'hébergement.

## Étapes de livraison

- [x] Installer et vérifier les modèles d'export officiels Godot 4.6.3.
- [x] Exporter le préréglage Web vers `build/web/index.html`.
- [x] Vérifier le chargement WebGL et les interactions tactiles dans Chromium
  avec émulation mobile ; aucune validation sur téléphone physique revendiquée.
- [x] Ajouter une compilation reproductible et un artefact via GitHub Actions.
- [x] Publier sur Vercel et vérifier l'URL HTTPS résultante.

URL : https://math-runner-mobile-algerianmarketer.vercel.app/

## Export local

Installer les modèles d'export **4.6.3**, puis :

```sh
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
python3 -m http.server 8000 --directory build/web
```

Ouvrir http://localhost:8000/ (ouvrir directement le fichier HTML ne fonctionne
pas). Garder `.html`, `.js`, `.wasm` et `.pck` ensemble sur le serveur.
Le premier chargement télécharge le moteur WebAssembly et peut prendre du temps.
Le moteur représente environ **36 Mio** avant compression HTTP.
Sur téléphone, utiliser un navigateur récent en portrait. Tir automatique ;
maintenir les flèches tactiles du bas pour se déplacer. Le bouton Pause permet
aussi de reprendre après avoir changé d'application.

## Publication

Le workflow `web.yml` compile le projet, lance les tests headless puis conserve le
dossier Web comme artefact téléchargeable. Les modèles sont téléchargés depuis la
release officielle et vérifiés avec SHA-512. Les exports ne sont pas committés.
Vercel utilise `vercel.json` et `bash tools/export_web.sh` pour exporter et servir
le jeu. Le script récupère automatiquement le moteur et ses modèles si absents.
Le premier déploiement de production a été créé depuis les fichiers du commit
`4c1fd3eee7f272db3e3e4d7693029557270edb79`, sans connexion Git Vercel : cette
connexion n'est pas installée sur le compte. Un push GitHub construit l'artefact
Web en CI, mais **ne republie pas automatiquement Vercel**. Pour les mises à jour,
redéployer le projet Vercel `math-runner-mobile-algerianmarketer22` avec la CLI
Vercel (`vercel --prod`) ou avec les outils de déploiement connectés, ou installer
la connexion GitHub dans Vercel pour activer les déploiements sur push.
GitHub Pages a d'abord été envisagé, mais son activation a été refusée par les
droits de la connexion GitHub (HTTP 403).

## Vérification dans le navigateur

Test automatisé optionnel : Python, Playwright, Pillow et Chromium. Le navigateur
simule un Pixel 7. Le test charge le vrai WebAssembly, vérifie le personnage dans
le rendu et injecte des gestes tactiles pour gauche, droite, pause et reprise.
Les captures d'écran vont dans `/tmp/math-runner-web-check`.

```sh
python tests/test_web.py http://localhost:8000/
# Ou contre l'hébergement réel :
python tests/test_web.py https://math-runner-mobile-algerianmarketer.vercel.app/
```

La détection tactile utilise `DisplayServer.is_touchscreen_available()` en plus
du type de plateforme : un navigateur mobile n'est pas un export Android natif.
Les libellés des boutons utilisent des caractères inclus dans la police embarquée.

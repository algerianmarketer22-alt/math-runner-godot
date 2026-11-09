# Préparer un export Android

Le prototype utilise le moteur standard et le renderer Compatibility. Il ne
nécessite pas de C#, de plugin Android ni de permission Internet.

## Environnement à installer

1. Godot **4.6.3 standard** et les **modèles d'export 4.6.3** exactement correspondants.
2. **OpenJDK 17** (vérifier `java -version`).
3. Le SDK Android, via Android Studio ou les outils en ligne de commande.
   Pour Godot 4.6 : Android SDK Platform **35**, Build-Tools **35.0.1**,
   Platform-Tools **35.0.0 ou plus récents**, Command-line Tools, CMake
   **3.10.2.4988404** et NDK **r28b (28.1.13356709)** selon les prérequis Godot.
   Le prototype emploie les modèles précompilés standard.
4. Accepter les licences avec `sdkmanager --licenses`.

Consulter les [prérequis Android de Godot 4.6](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html)
avant installation : les versions doivent correspondre au moteur effectivement
utilisé. Ne pas recopier la configuration d'une autre version de Godot.

Exemple de composants SDK :

```sh
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.1" \
  "cmake;3.10.2.4988404" "ndk;28.1.13356709"
```

Dans **Éditeur → Paramètres de l'éditeur → Export → Android**, renseigner
**Java SDK Path** et **Android SDK Path** vers les installations de votre machine.
Ces chemins sont des réglages locaux, ils ne sont pas dans le dépôt.

## Premier APK debug

Le préréglage `Android` exporte en portrait, avec le package
`org.mathrunner.prototype`, version `0.1.0`, architecture `arm64-v8a`.
Remplacer l'identifiant de package par le vôtre avant publication.

Créer une clé de debug locale si nécessaire :

```sh
keytool -genkeypair -v -keystore /chemin/prive/debug.keystore \
  -storepass android -alias androiddebugkey -keypass android \
  -dname "CN=Android Debug,O=Android,C=US" \
  -keyalg RSA -keysize 2048 -validity 10000
```

Renseigner cette clé dans les paramètres d'export Android de l'éditeur
(Debug Keystore, utilisateur `androiddebugkey`, mot de passe `android`). Les clés
et `export_credentials.cfg` sont ignorés par Git. Le mot de passe ci-dessus est
celui de la clé debug conventionnelle, **jamais une clé de production**.

```sh
mkdir -p build/android
godot --headless --path . --export-debug Android build/android/math-runner.apk
adb devices
adb install -r build/android/math-runner.apk
```

Activer le débogage USB et autoriser la machine sur le téléphone. Sur un émulateur
x86_64, activer aussi l'architecture x86_64 dans le préréglage ; elle est désactivée
par défaut pour limiter la taille d'un APK de téléphone ARM64.

Pour un AAB de publication, installer le modèle de compilation Android depuis
Godot, activer Gradle, choisir AAB et configurer une vraie clé release privée.
La publication Google Play reste une étape séparée.

## Vérifications sur appareil restant à faire

- Lancement en portrait et interface lisible sur différentes tailles d'écran.
- Gauche/droite maintenus, relâchement, deux doigts, reprise après changement d'app.
- Pause/reprise, redémarrage, bonus/malus et fin du niveau.
- Fluidité, chauffe et consommation sur un appareil Android réel.

Dans le cloud utilisé pour développer, Godot 4.6.3 est présent ; le SDK Android,
ADB et les modèles d'export ne sont pas installés. L'export Android est préparé
et documenté ; **aucun APK n'a été produit ni testé**.

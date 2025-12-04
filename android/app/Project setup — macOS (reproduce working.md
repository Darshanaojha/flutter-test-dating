# Project setup — macOS (reproduce working machine environment)

## Goal

Reproduce the exact development environment from the source Mac so this project builds and runs identically on another Mac.

Key versions from the working machine

- Flutter: 3.32.4 (stable)
- Dart: 3.8.1
- Java: 17.0.12 (project requires Java 17)
- Android SDK: platform tools + platforms (Android 33/35 compatible)
- NDK: 27.0.12077973 (pinned in android/app/build.gradle.kts)
- CocoaPods: recommended 1.16.2
- Xcode: required for iOS (install latest compatible for your macOS)
- Note: Keep pubspec.lock in repo to lock package versions.

Overview (high level)

1. Install Homebrew, Git, Android Studio (or SDK tools), Xcode and CocoaPods.
2. Install Java 17 and set JAVA_HOME to it.
3. Install Flutter (use FVM to pin 3.32.4).
4. Install Android SDK components including the exact NDK.
5. Clone repo, create local.properties, run flutter pub get & pod install.
6. Add signing files locally (key.properties, keystore) if needed.
7. Run app using fvm flutter run (or flutter if not using FVM).

## Step A — Capture current working values (optional)

Run these on the working Mac and save outputs (already captured):

- flutter --version -> Flutter 3.32.4
- flutter doctor -v -> saved
- java --version -> java 17.0.12
- Inspect android/app/build.gradle.kts for ndkVersion (27.0.12077973)

## Step B — Install system deps (on new Mac)

1. Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Git & optional tools

```bash
brew install git
brew install --cask visual-studio-code  # optional
```

3. Java 17 (required)

```bash
brew install openjdk@17
# Set JAVA_HOME (add to ~/.zshrc or ~/.bash_profile)
echo 'export JAVA_HOME="$(/usr/libexec/java_home -v17)"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
java -version   # should show 17.x
```

Important: the project compiles with Java 17. If Android Studio provides a different JDK, configure flutter to use your JDK:

```bash
flutter config --jdk-dir="$JAVA_HOME"
```

4. Android Studio / Android SDK

- Recommended: install Android Studio (includes SDK Manager / emulator).

```bash
brew install --cask android-studio
```

- Then open Android Studio → SDK Manager → install:
  - Android SDK Platform-Tools
  - Android SDK Platform for API 33 and API 35 (match compileSdk if needed)
  - Android SDK Build-Tools (e.g. 33.0.2 or 35.0.0 to match your config)
  - Android NDK 27.0.12077973 (install exact version)
  - Android SDK Command-line Tools (needed for sdkmanager)

Alternatively install via sdkmanager (see Step C).

5. Environment vars (add to ~/.zshrc)

```bash
echo 'export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"' >> ~/.zshrc
echo 'export ANDROID_HOME="$ANDROID_SDK_ROOT"' >> ~/.zshrc
echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

6. Install NDK and SDK components (using sdkmanager)

```bash
# ensure ANDROID_SDK_ROOT is set
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
sdkmanager --sdk_root="$ANDROID_SDK_ROOT" "platform-tools" "platforms;android-33" "platforms;android-35" "build-tools;33.0.2" "build-tools;35.0.0" "ndk;27.0.12077973" "cmdline-tools;latest"
```

7. Accept Android licenses

```bash
yes | sdkmanager --licenses --sdk_root="$ANDROID_SDK_ROOT"
# or
flutter doctor --android-licenses
```

8. Xcode (for iOS)

- Install from App Store or developer.apple.com.
- Then run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

If you can't install Xcode (CI or headless), iOS builds will not work — Android will.

9. CocoaPods (iOS)

```bash
# install recommended CocoaPods version
sudo gem install cocoapods -v 1.16.2
pod setup
```

On Apple Silicon, you may need:

```bash
sudo gem install ffi
arch -x86_64 pod install
```

## Step C — Install Flutter (FVM recommended) and tools

FVM will pin Flutter to 3.32.4 for reproducibility.

1. Install FVM:

```bash
dart pub global activate fvm
```

2. Install the exact Flutter SDK version used on the working machine:

```bash
fvm install 3.32.4
fvm use 3.32.4 --global
# Use fvm flutter <command> or configure your IDE to use FVM Flutter path.
```

3. Verify:

```bash
fvm flutter --version   # should show Flutter 3.32.4 and Dart 3.8.1
fvm flutter doctor -v
```

## Step D — Clone repo & local steps

1. Clone and fetch packages:

```bash
git clone <repo-url>
cd dating_flutter_app
# Use fvm for all flutter commands:
fvm flutter clean
fvm flutter pub get
```

2. Create android/local.properties (if absent — do NOT commit)

```bash
echo "sdk.dir=${HOME}/Library/Android/sdk" > android/local.properties
```

3. iOS pods:

```bash
cd ios
# On Intel mac:
pod install --repo-update
# On
```

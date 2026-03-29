# AIthespire

## Private, offline AI chat powered by Ollama (no cloud, no tracking)

![Flutter Analyze](https://img.shields.io/badge/flutter-analyze-blue)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

## Screenshots

> Add screenshots here once available.

## Installation

### Android APK

1. Build the app:
   ```bash
   flutter build apk --release
   ```
2. Install on device:
   ```bash
   flutter install
   ```

### Windows MSI

1. Build the app:
   ```bash
   flutter build windows --release
   ```
2. Package to MSIX (requires `msix`):
   ```bash
   dart pub global activate msix
   msix create --package-name=com.aithespire.app --output=build/ai_thespire.msix
   ```

## Build from source

```bash
flutter pub get && dart run build_runner build
```

## Links

- Ollama library: https://ollama.com/library
- Termux: https://termux.com/


# Flutter Build Configuration

This document contains the verified build configuration settings for the E-Receipt mobile application.

**Last Updated:** November 6, 2025
**Flutter Version:** 3.35.7
**Dart SDK:** >=3.0.0 <4.0.0

---

## Android Configuration

### Gradle & Build Tools Versions

#### Gradle Wrapper
**File:** `android/gradle/wrapper/gradle-wrapper.properties`
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```
**Version:** Gradle 8.9

#### Plugin Versions
**File:** `android/settings.gradle`
```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }
    settings.ext.flutterSdkPath = flutterSdkPath()

    includeBuild("${settings.ext.flutterSdkPath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.2" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}

include ":app"
```

**Key Versions:**
- **Android Gradle Plugin (AGP):** 8.7.2
- **Kotlin:** 2.1.0
- **Flutter Plugin Loader:** 1.0.0

#### Root build.gradle
**File:** `android/build.gradle`
```groovy
allprojects {
    repositories {
        maven { url '../local-repo' }
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

**Important Notes:**
- ✅ No `buildscript` block (deprecated approach)
- ✅ Plugin versions declared in `settings.gradle` instead
- ✅ Includes `../local-repo` for custom dependencies

#### App-level build.gradle
**File:** `android/app/build.gradle`
```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// ... (local properties code)

android {
    namespace "com.ereceipt.app"
    compileSdk 36

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.ereceipt.app"
        minSdkVersion flutter.minSdkVersion
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {}
```

**Key Settings:**
- **compileSdk:** 36
- **targetSdk:** 34
- **Java Version:** 1.8
- **Kotlin JVM Target:** 1.8
- **Namespace:** com.ereceipt.app

---

## iOS Configuration

### iOS Deployment Target
**File:** `ios/Podfile`
```ruby
platform :ios, '12.0'
```
**Minimum iOS Version:** 12.0

### Xcode Settings
**Recommended Xcode Version:** 15.0 or higher

---

## Flutter Dependencies

### Critical Plugin Versions
**File:** `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Image & File Pickers
  image_picker: ^1.0.4
  file_picker: ^8.0.0  # ⚠️ Must be >= 8.0.0 for AGP 8.7.2 compatibility

  # Permissions
  permission_handler: ^11.0.1

  # Storage
  shared_preferences: ^2.2.2

  # HTTP
  http: ^1.1.0

  # State Management
  provider: ^6.0.5

  # UI
  cupertino_icons: ^1.0.2
  flutter_spinkit: ^5.2.0

  # Utilities
  intl: ^0.18.1
```

**Critical Note:**
- `file_picker` must be **version 8.0.0 or higher** to avoid v1 embedding issues with AGP 8.x+
- Older versions (6.x) use deprecated `PluginRegistry.Registrar` API that causes build failures

---

## Compatibility Matrix

| Component | Version | Required For |
|-----------|---------|--------------|
| Flutter | 3.35.7 | Latest features |
| Gradle | 8.9 | AGP 8.7.2 |
| Android Gradle Plugin | 8.7.2 | Kotlin 2.1.0 |
| Kotlin | 2.1.0 | AGP 8.7.2 compatibility |
| compileSdk | 36 | Latest Android APIs |
| targetSdk | 34 | Play Store requirement |
| file_picker | 8.0.0+ | AGP 8.x+ compatibility |

---

## Common Build Issues & Solutions

### Issue 1: BaseVariant API Error
**Error:**
```
com/android/build/gradle/api/BaseVariant
```

**Solution:**
- Upgrade Kotlin to 2.0.20 or higher
- Older Kotlin versions use deprecated BaseVariant API

### Issue 2: file_picker Build Failure
**Error:**
```
error: cannot find symbol
PluginRegistry.Registrar
```

**Solution:**
- Upgrade file_picker to version 8.0.0 or higher
- Version 6.x uses v1 embedding which is removed in AGP 8.x

### Issue 3: Gradle Version Mismatch
**Error:**
```
Minimum supported Gradle version is 8.9. Current version is X.X
```

**Solution:**
- Update `gradle-wrapper.properties` to use Gradle 8.9:
  ```properties
  distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
  ```

### Issue 4: compileSdk Too Low
**Error:**
```
Dependency requires libraries to compile against version 36 or later
```

**Solution:**
- Update `android/app/build.gradle`:
  ```groovy
  android {
      compileSdk 36
  }
  ```

---

## Build Commands

### Clean Build
```bash
# Clean Flutter build artifacts
flutter clean

# Clean Gradle cache (if needed)
rm -rf ~/.gradle/caches
rm -rf android/.gradle
rm -rf build

# Get dependencies
flutter pub get

# Build and run
flutter run -d <device-id>
```

### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Cache Management

### When to Clear Gradle Cache
Clear Gradle cache if you encounter:
- Build cache corruption errors
- FileExistsException errors
- Persistent "cannot find symbol" errors after version upgrades

```bash
# Clear all Gradle caches
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon
rm -rf ~/.gradle/wrapper

# Clear project-specific cache
rm -rf android/.gradle
rm -rf build
```

---

## SDK Requirements

### Android SDK Components
Install the following via Android Studio SDK Manager:
- Android SDK Platform 36
- Android SDK Build-Tools 34.0.0 or higher
- Android Emulator
- Intel x86 Emulator Accelerator (HAXM) or Android Emulator Hypervisor Driver

### iOS SDK Components (macOS only)
- Xcode 15.0+
- CocoaPods 1.11.0+
- iOS Simulator

---

## Verified Configuration History

### November 6, 2025
- **Configuration:** Gradle 8.9 + AGP 8.7.2 + Kotlin 2.1.0
- **Status:** ✅ Working
- **Build Time:** ~95 seconds
- **Issues Resolved:** BaseVariant API deprecation, file_picker compatibility

### Previous Issues (Resolved)
1. AGP 8.1.0 + Kotlin 1.8.10 → BaseVariant errors
2. AGP 8.3.0 + Kotlin 2.0.20 → Gradle cache corruption
3. file_picker 6.2.1 → v1 embedding deprecation errors

---

## Migration Notes

### From Older Configurations
If upgrading from an older configuration:

1. **Backup your current configuration**
   ```bash
   git commit -am "Backup before build config upgrade"
   ```

2. **Update Gradle wrapper**
   ```bash
   cd android
   ./gradlew wrapper --gradle-version 8.9
   ```

3. **Update plugin versions in settings.gradle**
   - AGP: 8.7.2
   - Kotlin: 2.1.0

4. **Remove buildscript block from build.gradle**
   - Delete the entire `buildscript` block
   - Plugin versions now managed in `settings.gradle`

5. **Update compileSdk to 36**
   - Edit `android/app/build.gradle`

6. **Update dependencies**
   ```bash
   flutter pub upgrade
   ```

7. **Clean and rebuild**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## Troubleshooting Checklist

- [ ] Flutter version is 3.35.7 or compatible
- [ ] Gradle version is 8.9
- [ ] AGP version is 8.7.2
- [ ] Kotlin version is 2.1.0
- [ ] compileSdk is 36
- [ ] file_picker is >= 8.0.0
- [ ] No `buildscript` block in root build.gradle
- [ ] Plugin versions declared in settings.gradle
- [ ] Gradle caches cleared if errors persist
- [ ] Android SDK Platform 36 installed

---

## References

- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/macos#android-setup)
- [Android Gradle Plugin Release Notes](https://developer.android.com/studio/releases/gradle-plugin)
- [Kotlin Releases](https://kotlinlang.org/docs/releases.html)
- [Gradle Releases](https://gradle.org/releases/)

---

**Generated:** 2025-11-06
**Verified Working:** ✅ Yes
**Last Tested:** Flutter 3.35.7 on macOS with Android Emulator

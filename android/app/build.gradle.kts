plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.mantoujun12.astrbot_go"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.github.mantoujun12.astrbot_go"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Runtime images and instance data must never enter Android cloud backup;
        // the launcher only persists small configuration files.
        minSdk = 28
        // shortcut: final targetSdk is pinned at the P0 milestone (see docs/P0_VERIFICATION.md)
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        // PRoot and its loader will ship as jniLibs and must be extracted to
        // nativeLibraryDir to stay executable (see docs/ARCHITECTURE.md).
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // P0 harness only: stream-decompress the .tar.zst base image (zstd-jni
    // ships a linux/aarch64 native; AGP does not package the jar's
    // desktop-layout natives, so src/main/jniLibs/arm64-v8a carries a copy of
    // libzstd-jni-1.5.7-28.so taken from that jar) and extract the tar with
    // correct symlink/hardlink/long-name/permission handling.
    implementation("com.github.luben:zstd-jni:1.5.7-28")
    implementation("org.apache.commons:commons-compress:1.28.0")
}

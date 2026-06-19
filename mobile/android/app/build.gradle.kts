import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "28.2.13676358"
    namespace = "com.example.bloomly"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Required by flutter_local_notifications (uses java.time APIs).
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.bloomly"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
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
}

flutter {
    source = "../.."
}

// Dev convenience: tunnel localhost:8000 on every attached device/emulator back
// to this machine (`adb reverse`), so debug builds reach the local backend with
// plain `flutter run` — no manual tunnel, no --dart-define. Best-effort: a
// missing adb or device never fails the build.
val backendPort = 8000
val adbPath: String = run {
    val props = Properties()
    val localProperties = rootProject.file("local.properties")
    if (localProperties.exists()) localProperties.inputStream().use { props.load(it) }
    val sdkDir = props.getProperty("sdk.dir") ?: System.getenv("ANDROID_HOME")
    val exe = if (System.getProperty("os.name").lowercase().contains("win")) ".exe" else ""
    if (sdkDir != null) "$sdkDir/platform-tools/adb$exe" else "adb"
}
val adbReverse = tasks.register("adbReverse") {
    doLast {
        runCatching {
            val devices = ProcessBuilder(adbPath, "devices").start()
                .inputStream.bufferedReader().readText()
                .lines().drop(1)
                .mapNotNull { line ->
                    val parts = line.trim().split(Regex("\\s+"))
                    if (parts.size >= 2 && parts[1] == "device") parts[0] else null
                }
            devices.forEach { serial ->
                ProcessBuilder(adbPath, "-s", serial, "reverse", "tcp:$backendPort", "tcp:$backendPort")
                    .start().waitFor()
            }
        }.onFailure { logger.warn("adbReverse skipped: ${it.message}") }
    }
}
tasks.whenTaskAdded {
    // `flutter run` builds via assembleDebug (it installs with its own adb);
    // installDebug covers direct Gradle/Android Studio native installs.
    if (name == "assembleDebug" || name == "installDebug") dependsOn(adbReverse)
}

dependencies {
    // Backports java.time for flutter_local_notifications on older Android.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun signingValue(name: String, envName: String): String? =
    (keystoreProperties[name] as? String)?.takeIf { it.isNotBlank() }
        ?: System.getenv(envName)?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "WARGAME_UPLOAD_STORE_FILE")
val hasReleaseSigningConfig =
    !releaseStoreFile.isNullOrBlank() &&
        !signingValue("storePassword", "WARGAME_UPLOAD_STORE_PASSWORD").isNullOrBlank() &&
        !signingValue("keyAlias", "WARGAME_UPLOAD_KEY_ALIAS").isNullOrBlank() &&
        !signingValue("keyPassword", "WARGAME_UPLOAD_KEY_PASSWORD").isNullOrBlank()

fun requireReleaseSigningValue(name: String, envName: String): String =
    signingValue(name, envName)
        ?: error("Missing release signing value '$name'. Configure client/android/key.properties or env $envName.")

android {
    namespace = "com.woisol.wargametab"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.woisol.wargametab"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningConfig) {
                keyAlias = requireReleaseSigningValue("keyAlias", "WARGAME_UPLOAD_KEY_ALIAS")
                keyPassword = requireReleaseSigningValue("keyPassword", "WARGAME_UPLOAD_KEY_PASSWORD")
                storeFile = rootProject.file(requireReleaseSigningValue("storeFile", "WARGAME_UPLOAD_STORE_FILE"))
                storePassword = requireReleaseSigningValue("storePassword", "WARGAME_UPLOAD_STORE_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigningConfig) "release" else "debug",
            )
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
    implementation(files("libs/xms-wearable-lib_1.4_release.aar"))
}

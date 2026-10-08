plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val isTestPackage = providers.gradleProperty("takimakiTest").orNull == "true"
val signingStore = System.getenv("TAKIMAKI_KEYSTORE")

android {
    namespace = "hu.takimaki.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = if (isTestPackage) "hu.takimaki.test" else "hu.takimaki.app"
        manifestPlaceholders["appLabel"] = if (isTestPackage) "Takimaki Teszt" else "Takimaki"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingStore != null) {
            create("persistentRelease") {
                storeFile = file(signingStore)
                storePassword = System.getenv("TAKIMAKI_STORE_PASSWORD")
                keyAlias = System.getenv("TAKIMAKI_KEY_ALIAS") ?: "takimaki-test"
                keyPassword = System.getenv("TAKIMAKI_KEY_PASSWORD") ?: storePassword
            }
        }
    }
    buildTypes {
        release {
            signingConfig = if (signingStore != null) signingConfigs.getByName("persistentRelease") else null
        }
    }
}

flutter {
    source = "../.."
}

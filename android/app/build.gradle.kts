import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // A Flutter pluginnak ezek után kell jönnie
    id("dev.flutter.flutter-gradle-plugin")
}

// --- key.properties beolvasása a projekt GYÖKERÉBŐL (android/key.properties) ---
val keyPropsFile = rootProject.file("key.properties")
val keyProps = Properties()
if (keyPropsFile.exists()) {
    keyProps.load(FileInputStream(keyPropsFile))
}

android {
    namespace = "com.example.takimaki_full"

    // Ezeket a Flutter plugin tölti be
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.takimaki_full"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    // --- RELEASE aláírás beállítása ---
    signingConfigs {
        create("release") {
            if (keyPropsFile.exists()) {
                val sf = keyProps["storeFile"] as String
                val sp = keyProps["storePassword"] as String
                val ka = keyProps["keyAlias"] as String
                val kp = keyProps["keyPassword"] as String

                storeFile = file(sf)
                storePassword = sp
                keyAlias = ka
                keyPassword = kp
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("debug") {
            // debughoz nem kell aláírás
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ide jöhetnek extra függőségek, ha kellenek
}

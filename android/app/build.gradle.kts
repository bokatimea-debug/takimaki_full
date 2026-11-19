import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") apply false
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val isTestPackage = providers.gradleProperty("takimakiTest").orNull == "true"
val signingStore = System.getenv("TAKIMAKI_KEYSTORE")
val localSigning = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) propertiesFile.inputStream().use(::load)
}
val localSigningStore = localSigning.getProperty("storeFile")

android {
    namespace = "hu.takimaki.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = if (isTestPackage) "hu.takimaki.test" else "hu.takimaki.app"
        manifestPlaceholders["appLabel"] = if (isTestPackage) "Takimaki Teszt" else "Takimaki"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingStore != null || localSigningStore != null) {
            create("persistentRelease") {
                storeFile = if (signingStore != null) file(signingStore) else rootProject.file(localSigningStore)
                storePassword = System.getenv("TAKIMAKI_STORE_PASSWORD") ?: localSigning.getProperty("storePassword")
                keyAlias = System.getenv("TAKIMAKI_KEY_ALIAS") ?: localSigning.getProperty("keyAlias") ?: "takimaki-test"
                keyPassword = System.getenv("TAKIMAKI_KEY_PASSWORD") ?: localSigning.getProperty("keyPassword") ?: storePassword
            }
        }
    }
    buildTypes {
        release {
            signingConfig = if (signingStore != null || localSigningStore != null) signingConfigs.getByName("persistentRelease") else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

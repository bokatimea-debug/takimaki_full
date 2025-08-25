import java.util.Properties
import java.io.FileInputStream

// --- key.properties beolvasása a gyökér/android mappából ---
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("android/key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("android/key.properties nem található (release aláíráshoz kell).")
}

android {
    // ...

    signingConfigs {
        create("release") {
            // Minden értéket a key.properties-ből veszünk
            storeFile = file(keystoreProperties["storeFile"] as String)   // -> "takimaki.keystore"
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // ...
}


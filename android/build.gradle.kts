allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    configurations.configureEach {
        resolutionStrategy.force(
            "org.jetbrains.kotlin:kotlin-stdlib:2.2.21",
            "androidx.activity:activity-ktx:1.12.4",
            "androidx.activity:activity:1.12.4",
            "androidx.annotation:annotation:1.9.1",
            "androidx.core:core:1.18.0",
            "androidx.core:core-ktx:1.18.0",
            "androidx.fragment:fragment:1.7.1",
            "androidx.lifecycle:lifecycle-runtime-ktx:2.7.0",
            "androidx.lifecycle:lifecycle-runtime:2.7.0",
            "androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0",
            "androidx.lifecycle:lifecycle-viewmodel:2.7.0",
            "androidx.lifecycle:lifecycle-livedata-core-ktx:2.7.0",
            "androidx.lifecycle:lifecycle-livedata-core:2.7.0",
            "androidx.savedstate:savedstate:1.2.1",
            "androidx.savedstate:savedstate-ktx:1.2.1",
            )
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

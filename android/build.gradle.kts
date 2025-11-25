// android/build.gradle.kts
// This block defines the path to the Google Services plugin and Kotlin dependencies.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Must include the Android Gradle Plugin (AGP) and the Google Services Plugin
        // NOTE: Use the version numbers compatible with your project (these are modern versions)
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20")
        classpath("com.google.gms:google-services:4.4.0") // ✅ Add Google Services classpath
    }
}

// All projects will use these repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Existing custom build directory definition (kept as requested by your original code)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // This is correct for ensuring project dependencies are evaluated
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
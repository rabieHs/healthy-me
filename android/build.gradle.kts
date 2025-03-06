// Bloc buildscript pour les dépendances de build
buildscript {
    repositories {
        google()  // Déjà présent
        mavenCentral()  // Déjà présent
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'  // Déjà présent ou à adapter
        classpath 'com.google.gms:google-services:4.3.15'  // Ligne à ajouter
    }
}

// Configuration existante
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration personnalisée pour les répertoires de build
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
apply plugin: 'com.google.gms.google-services'
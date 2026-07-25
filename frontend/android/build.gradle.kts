allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        androidExtension?.compileSdkVersion(36)
    }
    plugins.withId("com.android.application") {
        val androidExtension = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        androidExtension?.compileSdkVersion(36)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

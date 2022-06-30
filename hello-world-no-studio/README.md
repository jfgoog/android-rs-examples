# Hello World app in Rust, without using Android studio

## One-time setup

### Android SDK and Gradle

* Install Java
* Install Android command-line tools.
* Use the SDK manager to install the SDK and NDK.
```
sdkmanager 'platforms;android-32'
sdkmanager 'ndk;24.0.8215888'
```
* Install Gradle
* See [download.sh](./download.sh) and [env.sh](./env.sh) for what I did on a Mac.

### Rust

* [Install Rust](https://www.rust-lang.org/tools/install).
* Add Android targets to
  Rust: `rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android`

## Gradle setup

Refer to [Android Studio docs](https://developer.android.com/studio/build) for what the gradle files are supposed to look like.

* `echo no | gradle init --type basic --dsl groovy --project-name HelloWorld`
* [settings.gradle](settings.gradle)
```groovy
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "HelloWorld"
include ':app'
```
* [build.gradle](build.gradle)
```groovy
plugins {
    id 'com.android.application' version '7.1.0' apply false
    id 'com.android.library' version '7.1.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.5.30' apply false
    id 'org.mozilla.rust-android-gradle.rust-android' version '0.9.2' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```
* [app/build.gradle](app/build.gradle)
```groovy
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    id 'org.mozilla.rust-android-gradle.rust-android'
}

android {
    compileSdk 32
    defaultConfig {
        applicationId "com.example.helloworld"
        minSdk 21
        targetSdk 32
        versionCode 1
        versionName "1.0"
    }
    ndkVersion '24.0.8215888'
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.4.1'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.3'
}

cargo {
    module = "src/main/rust"
    libname = "rust"
    targets = ["arm", "x86", "x86_64", "arm64"]
}

afterEvaluate {
    // The `cargoBuild` task isn't available until after evaluation.
    android.applicationVariants.all { variant ->
        def productFlavor = ""
        variant.productFlavors.each {
            productFlavor += "${it.name.capitalize()}"
        }
        def buildType = "${variant.buildType.name.capitalize()}"
        tasks["generate${productFlavor}${buildType}Assets"].dependsOn(tasks["cargoBuild"])
    }
}
```

## App code

You will need 4 files in app/src/main:
* [AndroidManifest.xml](app/src/main/AndroidManifest.xml)
* [java/com/example/helloworld/MainActivity.kt](app/src/main/java/com/example/helloworld/MainActivity.kt)
* [res/layout/activity_main.xml](app/src/main/res/layout/activity_main.xml)
* [res/layout/styles.xml](app/src/main/res/layout/styles.xml)

## Rust Code

Exactly the same as https://github.com/jfgoog/android-rs-examples/blob/main/hello-world-android-studio/README.md#rust-setup

## Build and run

* `./gradlew installDebug`
* `adb shell am start -n com.example.helloworld/.MainActivity`
* For a more clever way to run the app that wakes up and unlocks the device, see run.sh

## Credits and acknowledgments

* https://developer.okta.com/blog/2018/08/10/basic-android-without-an-ide

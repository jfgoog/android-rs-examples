# Creating a Rust library and calling it from Java/Kotlin

## One-time setup

### Android Studio

* Install [Android Studio](https://developer.android.com/studio).
* Open the [SDK manager](https://developer.android.com/studio/intro/update#sdk-manager) in Android Studio, and [install the NDK](https://developer.android.com/studio/projects/install-ndk).
* Open Preferences > Plugins in Android Studio, and install the [Rust plugin](https://plugins.jetbrains.com/plugin/8182-rust).

### Rust

* [Install Rust](https://www.rust-lang.org/tools/install).
* Add Android targets to Rust: `rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android`

## Android project setup

* Create a new project with the "Empty Activity" template, following the [tutorial](https://developer.android.com/training/basics/firstapp/creating-project) on how to create your first Android app.
* Edit `activity_main.xml`. Set the ID of the text box to `txtHello`
* Edit `MainActivity.kt`. The `MainActivity` class should be:
```kotlin
class MainActivity : AppCompatActivity() {
    private external fun greeting(): String
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val textView: TextView = findViewById(R.id.txtHello)
        textView.text = greeting()
    }
    companion object {
        init {
            System.loadLibrary("rust")
        }
    }
}
```

## Rust setup

* In the project's `app/src/main` directory, `cargo new --lib rust`
* Add the following to Cargo.toml:
```toml
[dependencies]
[target.'cfg(target_os="android")'.dependencies]
jni = { version = "0.9", default-features = false }

[lib]
name = "rust"
crate-type = ["dylib"]
```
* Create `.cargo/config.toml`, with the appropriate path to the NDK (For example, on MacOS it is /Users/<username>/Library/Android/sdk/ndk/<version>):
```toml
[target.aarch64-linux-android]
linker = "<path to NDK>/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android26-clang"

[target.armv7-linux-androideabi]
linker = "<path to NDK>/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi26-clang"

[target.i686-linux-android]
linker = "<path to NDK>/toolchains/llvm/prebuilt/darwin-x86_64/bin/i686-linux-android26-clang"
```
* Edit `src/lib.rs` as follows, changing `com_example_hellorust` in the function name to match the package name in MainActivity.kt:
```rust
#[cfg(target_os = "android")]
#[allow(non_snake_case)]
pub mod android {
    extern crate jni;
    use self::jni::JNIEnv;
    use self::jni::objects::JClass;
    use self::jni::sys::jstring;
    use std::ffi::CString;
    #[no_mangle]
    pub unsafe extern fn Java_com_example_hellorust_MainActivity_greeting(env: JNIEnv, _: JClass) -> jstring {
        let world_ptr = CString::new("Hello 🦀").unwrap();
        let output = env.new_string(world_ptr.to_str().unwrap()).expect("Couldn't create java string!");
        output.into_inner()
    }
```

## Gradle setup

* Edit the top-level `build.gradle` file.
  * Add to the `repositories` section: `maven { url "https://plugins.gradle.org/m2/" }`
  * Add to the `dependencies` section: `classpath 'org.mozilla.rust-android-gradle:plugin:0.9.0'`
* Edit `app/build.gradle`.
  * Add to `plugins`: `id 'org.mozilla.rust-android-gradle.rust-android'`
  * Add at the end:
```groovy
cargo {
    module = "src/main/rust"
    libname = "rust"
    targets = ["arm", "x86", "arm64"]
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
  
## Credits and acknowledgments

* [Rust for NDK development](https://medium.com/geekculture/the-following-are-examples-to-render-fractal-images-in-android-bitmap-with-rust-22a9fb5d648b) and https://github.com/hoangpq/rust-ndk-example/
* [Running Rust on Android](https://blog.svgames.pl/article/running-rust-on-android)
* https://github.com/mozilla/rust-android-gradle

## Diff

After creating a new Android Studio project, running `cargo new --lib rust`, and creating `.cargo/config.toml`, here are the diffs:
```diff
--- HelloRustBase/app/build.gradle	2021-11-03 11:26:31.000000000 -0500
+++ HelloRust/app/build.gradle	2021-11-03 11:26:41.000000000 -0500
@@ -1,6 +1,7 @@
 plugins {
     id 'com.android.application'
     id 'kotlin-android'
+    id 'org.mozilla.rust-android-gradle.rust-android'
 }

 android {
@@ -41,3 +42,21 @@
     androidTestImplementation 'androidx.test.ext:junit:1.1.3'
     androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
 }
+
+cargo {
+    module = "src/main/rust"
+    libname = "rust"
+    targets = ["arm", "x86", "arm64"]
+}
+
+afterEvaluate {
+    // The `cargoBuild` task isn't available until after evaluation.
+    android.applicationVariants.all { variant ->
+        def productFlavor = ""
+        variant.productFlavors.each {
+            productFlavor += "${it.name.capitalize()}"
+        }
+        def buildType = "${variant.buildType.name.capitalize()}"
+        tasks["generate${productFlavor}${buildType}Assets"].dependsOn(tasks["cargoBuild"])
+    }
+}
--- HelloRustBase/app/src/main/java/com/example/HelloRust/MainActivity.kt	2021-11-03 11:27:22.000000000 -0500
+++ HelloRust/app/src/main/java/com/example/HelloRust/MainActivity.kt	2021-11-03 11:27:08.000000000 -0500
@@ -2,10 +2,19 @@

 import androidx.appcompat.app.AppCompatActivity
 import android.os.Bundle
+import android.widget.TextView

 class MainActivity : AppCompatActivity() {
+    private external fun greeting(): String
     override fun onCreate(savedInstanceState: Bundle?) {
         super.onCreate(savedInstanceState)
         setContentView(R.layout.activity_main)
+        val textView: TextView = findViewById(R.id.txtHello)
+        textView.text = greeting()
+    }
+    companion object {
+        init {
+            System.loadLibrary("rust")
+        }
     }
 }
--- HelloRustBase/app/src/main/res/layout/activity_main.xml	2021-11-03 11:07:34.000000000 -0500
+++ HelloRust/app/src/main/res/layout/activity_main.xml	2021-11-02 10:50:54.000000000 -0500
@@ -7,6 +7,7 @@
     tools:context=".MainActivity">

     <TextView
+        android:id="@+id/txtHello"
         android:layout_width="wrap_content"
         android:layout_height="wrap_content"
         android:text="Hello World!"
--- HelloRustBase/app/src/main/rust/Cargo.toml	2021-11-03 11:22:29.000000000 -0500
+++ HelloRust/app/src/main/rust/Cargo.toml	2021-11-02 11:02:07.000000000 -0500
@@ -3,6 +3,10 @@
 version = "0.1.0"
 edition = "2021"

-# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
-
 [dependencies]
+[target.'cfg(target_os="android")'.dependencies]
+jni = { version = "0.9", default-features = false }
+
+[lib]
+name = "rust"
+crate-type = ["dylib"]
--- HelloRustBase/app/src/main/rust/src/lib.rs	2021-11-03 11:22:29.000000000 -0500
+++ HelloRust/app/src/main/rust/src/lib.rs	2021-11-02 11:24:30.000000000 -0500
@@ -1,8 +1,15 @@
-#[cfg(test)]
-mod tests {
-    #[test]
-    fn it_works() {
-        let result = 2 + 2;
-        assert_eq!(result, 4);
+#[cfg(target_os = "android")]
+#[allow(non_snake_case)]
+pub mod android {
+    extern crate jni;
+    use self::jni::JNIEnv;
+    use self::jni::objects::JClass;
+    use self::jni::sys::jstring;
+    use std::ffi::CString;
+    #[no_mangle]
+    pub unsafe extern fn Java_com_example_HelloRust_MainActivity_greeting(env: JNIEnv, _: JClass) -> jstring {
+        let world_ptr = CString::new("Hello 🦀").unwrap();
+        let output = env.new_string(world_ptr.to_str().unwrap()).expect("Couldn't create java string!");
+        output.into_inner()
     }
 }
--- HelloRustBase/build.gradle	2021-11-03 11:07:33.000000000 -0500
+++ HelloRust/build.gradle	2021-11-03 10:52:55.000000000 -0500
@@ -3,10 +3,12 @@
     repositories {
         google()
         mavenCentral()
+        maven { url "https://plugins.gradle.org/m2/" }
     }
     dependencies {
         classpath "com.android.tools.build:gradle:7.0.3"
         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.5.31"
+        classpath 'org.mozilla.rust-android-gradle:plugin:0.9.0'

         // NOTE: Do not place your application dependencies here; they belong
         // in the individual module build.gradle files
```

This was generated with:
    
```
diff -rqN HelloRustBase HelloRust | egrep -v '/.gradle/|/.idea/|/app/src/main/rust/target|/app/build/|/build/linker-wrapper/|/.git/|.gitignore|.cargo|Cargo.lock|gradle-wrapper.properties' | awk '{print $2}' | cut -d'/' -f2- | xargs -I{} diff -uwN HelloRustBase/{} HelloRust/{}
```

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

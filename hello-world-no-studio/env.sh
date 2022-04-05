#!/bin/sh
PREBUILT=/Users/jamesfarrell/src/android-rs-examples/hello-world-no-studio/prebuilt
export JAVA_HOME=${PREBUILT}/jdk-18.jdk/Contents/Home
export ANDROID_HOME=${PREBUILT}/android_sdk
alias sdkmanager="${PREBUILT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}"
alias gradle=${PREBUILT}/gradle-7.4.2/bin/gradle

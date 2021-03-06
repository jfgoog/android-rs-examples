#!/bin/sh
PREBUILT=$PWD/prebuilt
case $(uname -s) in
  Linux) export JAVA_HOME=${PREBUILT}/jdk-18 ;;
  Darwin) export JAVA_HOME=${PREBUILT}/jdk-18.jdk/Contents/Home ;;
esac
export ANDROID_HOME=${PREBUILT}/android_sdk
alias sdkmanager="${PREBUILT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}"
alias gradle=${PREBUILT}/gradle-7.4.2/bin/gradle
export ANDROID_SERIAL=17051FDEE000A1
export RUST_ANDROID_GRADLE_PYTHON_COMMAND=/usr/bin/python3

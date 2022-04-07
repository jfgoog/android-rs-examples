#!/bin/sh

set -e
set -x

PREBUILT=$PWD/prebuilt

if [[ -e ${PREBUILT} ]]; then
  echo "${PREBUILT} already exists."
  exit 1
fi

mkdir -p ${PREBUILT}
cd ${PREBUILT}

# Download pages:
# https://www.oracle.com/java/technologies/downloads/
# https://developer.android.com/studio/#downloads
case $(uname -s) in
  Linux)
    JDK_URL=https://download.oracle.com/java/18/latest/jdk-18_linux-x64_bin.tar.gz
    CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip
    export JAVA_HOME=${PREBUILT}/jdk-18
    ;;
  Darwin)
    CMDLINE_TOOLS_URL=https://dl.google.com/android/repository/commandlinetools-mac-8092744_latest.zip
    export JAVA_HOME=${PREBUILT}/jdk-18.jdk/Contents/Home
    case $(uname -m) in
      x86_64) JDK_URL=https://download.oracle.com/java/18/latest/jdk-18_macos-x64_bin.tar.gz ;;
      arm64) JDK_URL=https://download.oracle.com/java/18/latest/jdk-18_macos-aarch64_bin.tar.gz ;;
    esac
    ;;
  *)
    echo "Unrecognized OS $(uname -s)"
    exit 1
    ;;
esac

curl -s -o jdk.tar.gz ${JDK_URL}
tar zxf jdk.tar.gz
rm -f jdk.tar.gz

curl -s -o commandlinetools.zip ${CMDLINE_TOOLS_URL}
unzip -qq commandlinetools.zip
rm -f commandlinetools.zip

export ANDROID_HOME=${PREBUILT}/android_sdk
alias sdkmanager="${PREBUILT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}"

yes | sdkmanager 'platforms;android-32'
sdkmanager 'ndk;24.0.8215888'

# Download page: https://gradle.org/releases/
curl -s -O -L https://services.gradle.org/distributions/gradle-7.4.2-bin.zip
unzip -qq gradle-7.4.2-bin.zip
rm -f gradle-7.4.2-bin.zip

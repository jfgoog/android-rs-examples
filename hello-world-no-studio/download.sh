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

curl -s -O https://download.oracle.com/java/18/latest/jdk-18_macos-aarch64_bin.tar.gz
tar zxf jdk-18_macos-aarch64_bin.tar.gz
rm -f jdk-18_macos-aarch64_bin.tar.gz

curl -s -O https://dl.google.com/android/repository/commandlinetools-mac-8092744_latest.zip
unzip -qq commandlinetools-mac-8092744_latest.zip
rm -f commandlinetools-mac-8092744_latest.zip

export JAVA_HOME=${PREBUILT}/jdk-18.jdk/Contents/Home
export ANDROID_HOME=${PREBUILT}/android_sdk
alias sdkmanager="${PREBUILT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}"

yes | sdkmanager 'platforms;android-32'
sdkmanager 'ndk;24.0.8215888'

curl -s -O -L https://services.gradle.org/distributions/gradle-7.4.2-bin.zip
unzip -qq gradle-7.4.2-bin.zip
rm -f gradle-7.4.2-bin.zip

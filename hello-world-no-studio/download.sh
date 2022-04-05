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

curl -O https://download.oracle.com/java/18/latest/jdk-18_macos-aarch64_bin.tar.gz
tar zxf jdk-18_macos-aarch64_bin.tar.gz

curl -O https://dl.google.com/android/repository/commandlinetools-mac-8092744_latest.zip
unzip commandlinetools-mac-8092744_latest.zip

export JAVA_HOME=${PREBUILT}/jdk-18.jdk/Contents/Home
export ANDROID_HOME=${PREBUILT}/android_sdk
alias sdkmanager="${PREBUILT}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME}"

yes | sdkmanager 'platforms;android-32'

curl -O -L https://services.gradle.org/distributions/gradle-7.4.2-bin.zip
unzip gradle-7.4.2-bin.zip
#!/bin/sh

adb shell input keyevent 224
sleep 1
adb shell input keyevent 82
adb shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
adb shell am start -n com.example.helloworld/.MainActivity

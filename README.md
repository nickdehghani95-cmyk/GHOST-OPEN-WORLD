# Nick AI Gamer
Android app prototype for Poco X7 Pro (Android 16), landscape-first UI inspired by the supplied red/black reference image.

## Build
Run `gradle :app:assembleDebug` with JDK 17 and Android SDK 35.
APK output: `app/build/outputs/apk/debug/app-debug.apk`.

## Current status
This first build is a UI prototype. Chat replies are explicitly marked as not connected; image generation and secure admin/user management require a separately hosted backend and provider credentials. Do not put API keys in the Android app or repository.

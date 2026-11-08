# Jaý Tap

Jaý Tap is a Flutter real estate app for browsing properties in Turkmenistan. It includes search and map views, property details, favorites, profiles, and chat.

## Official links

- Website: [jaytap.com.tm](https://jaytap.com.tm/)
- Android: [Google Play](https://play.google.com/store/apps/details?id=com.gurbanov.jaytap)
- iPhone: [App Store](https://apps.apple.com/app/id6751713059)

The application ID and iOS bundle ID are both `com.gurbanov.jaytap`. There is currently no validated GitHub APK release; use the official store listings to install the app.

## Development

Use Flutter 3.47.8 or a compatible newer SDK, Dart 3.13, and JDK 17. Android and iOS builds also need their respective platform toolchains. The app talks to the live Jaý Tap backend and uses Firebase messaging; use appropriate test accounts when exercising authentication, chat, or listing changes.

```sh
git clone https://github.com/Dadebay/JayTap.git
cd JayTap
flutter pub get --enforce-lockfile
flutter run
```

Quality checks:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
```

## Build and signing

For an Android distribution build, create an ignored `android/key.properties` from [`android/key.properties.example`](android/key.properties.example). Keep the keystore and passwords outside this repository. Use the signing key registered for this app in Google Play; an unrelated or upload-only key may not update a Play-installed copy.

```sh
flutter build appbundle --release
flutter build apk --release
```

Without `android/key.properties`, the release variant is unsigned and is suitable only for compilation checks. Do not distribute it. iOS distribution requires the owner's Apple signing setup and App Store Connect access. CI builds iOS without code signing.

## Release status

Source version is `1.0.0+1`; confirm the current store version and increment the build numbers before submitting an update. Smoke-test authentication, search, maps, chat, notifications, and upgrades on physical devices. Review the Google Play and App Store privacy declarations against the app's actual use of phone number, location, messages, and Firebase before publishing.

No GitHub Release is published until a correctly signed APK is verified against the Play app signing certificate and tested on a device. The iOS download is available through the App Store link above.

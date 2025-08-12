#!/bin/bash
flutter clean
rm pubspec.lock
cd io
rm -rf Pods
rm -rf Podfile.lock
pod deintegrate
pod cache clean --all
flutter pub get
pod setup
pod install
cd ..
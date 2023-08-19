#!/bin/bash

# navigate to the root directory of the Flutter project
version=$(grep "version:" ../pubspec.yaml | awk '{print $2}')

flutter build appbundle --no-tree-shake-icons &&
cp -R ../build/app/outputs/bundle/release/app-release.aab ~/Downloads/LaBanPhongThuy-"$version".aab

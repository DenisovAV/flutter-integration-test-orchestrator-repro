#!/usr/bin/env bash
# Builds the app with the integration test entry point, installs it with
# Android Test Orchestrator 1.6.1, and runs the suite through the orchestrator,
# the same way device farms (Firebase Test Lab, Google Cloud DDP) invoke it.
set -euo pipefail
cd "$(dirname "$0")"
ORCH=1.6.1; SERVICES=1.6.0
flutter build apk --debug -t integration_test/app_test.dart
(cd android && ./gradlew -q app:assembleDebugAndroidTest)
mkdir -p build/orchestrator
for a in "androidx/test/orchestrator/$ORCH/orchestrator-$ORCH.apk" "androidx/test/services/test-services/$SERVICES/test-services-$SERVICES.apk"; do
  f="build/orchestrator/$(basename "$a")"
  [ -f "$f" ] || curl -sSfL -o "$f" "https://dl.google.com/android/maven2/$a"
done
adb install -r -g "build/orchestrator/orchestrator-$ORCH.apk"
adb install -r -g "build/orchestrator/test-services-$SERVICES.apk"
adb install -r -g build/app/outputs/flutter-apk/app-debug.apk
adb install -r -g build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
adb shell 'CLASSPATH=$(pm path androidx.test.services) app_process / \
  androidx.test.services.shellexecutor.ShellMain am instrument -r -w \
  -e targetInstrumentation com.example.orchestrator_repro.test/androidx.test.runner.AndroidJUnitRunner \
  -e clearPackageData true \
  androidx.test.orchestrator/.AndroidTestOrchestrator' | tee build/orchestrator/result.txt

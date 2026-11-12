# integration_test + Android Test Orchestrator: passing suite reported as FAILURES

Minimal reproduction for https://github.com/flutter/flutter/issues/196423.

A plain `integration_test` suite with three passing `testWidgets` cases, hosted by
the standard `FlutterTestRunner`, run through Android Test Orchestrator:

```text
FAILURES!!!
Tests found: 1, Tests run: 3,  Failures: 0
```

Every test passes, but the run fails because the orchestrator discovers one
JUnit test (`MainActivityTest`) while three are executed. Device farms that
use the orchestrator (Firebase Test Lab, Google Cloud Developer Device Platform)
then mark the whole run as failed.

## Project

Created with `flutter create --empty`, then:

- `integration_test/app_test.dart`: three trivial passing tests.
- `android/app/src/androidTest/java/.../MainActivityTest.java`: the standard
  `@RunWith(FlutterTestRunner.class)` host from the integration_test README.
- `android/app/build.gradle.kts`: `AndroidJUnitRunner`, orchestrator 1.6.1,
  test-services 1.6.0.
- `android/app/src/debug/AndroidManifest.xml`: `<queries>` for the orchestrator
  and test-services packages (Android 11+ package visibility; without it the
  orchestrator cannot start the runner at all and reports `OK (0 tests)`).

## Run

With one emulator or device connected:

```sh
./run_with_orchestrator.sh
```

The script builds the app with the test entry point and the instrumentation
APK, installs them with the orchestrator, and runs:

```sh
adb shell 'CLASSPATH=$(pm path androidx.test.services) app_process / \
  androidx.test.services.shellexecutor.ShellMain am instrument -r -w \
  -e targetInstrumentation com.example.orchestrator_repro.test/androidx.test.runner.AndroidJUnitRunner \
  -e clearPackageData true \
  androidx.test.orchestrator/.AndroidTestOrchestrator'
```

Each test reports a passing status. Without the orchestrator the same APKs
report `OK (3 tests)`:

```sh
adb shell am instrument -w -r com.example.orchestrator_repro.test/androidx.test.runner.AndroidJUnitRunner
```

## Environment

- Flutter 3.47.7 (stable), Dart 3.13.5
- Android emulator, API 37, arm64 (macOS host)
- androidx.test orchestrator 1.6.1, test-services 1.6.0

Full output of the orchestrator run: `orchestrator-result-api37.txt`.
Verified from a fresh clone, on a freshly booted emulator, twice.

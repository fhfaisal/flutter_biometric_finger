## 0.0.1

* Initial release of the flutter_biometric_finger Android USB scanner plugin.
* Wraps the native `libNBBiometrics.so` and AbeTree Java SDK with a simple Flutter interface.
* Support for initializing the scanner, capturing images, and generating ISO templates.
* **Important:** SDK dependencies are downloaded remotely during the Gradle build to comply with pub.dev limits.
* Added documentation for Android 11+ `allowNativeHeapPointerTagging` requirements.

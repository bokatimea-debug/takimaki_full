# Takimaki Teszt 1.0.5+6

User authorized the new signing key and separate install on 2026-10-04.
Package: hu.takimaki.test. Label: Takimaki Teszt.
Original hu.takimaki.app remains installed with its own local data. This test app starts with separate local data. No automatic data migration.

The corrected, previously compiled unsigned APK was recovered from the saved checkpoint. Its SHA-256 was checked before packaging. Only the Android binary manifest changed: package, label, app-specific permission and both provider authorities. MainActivity remains the fully qualified hu.takimaki.app.MainActivity. All DEX, Dart native libraries, resources, icon and other assets are byte-identical to the tested build. The reproducible packaging script is included.

The APK passes apksigner v2/v3 verification and zipalign 16KB-native/4-byte alignment checks. Package/version/launch activity and collision-free provider authorities checked with aapt. Prior 110 automated tests apply to the unchanged app code. This signed package has not been run on a physical phone.

For a future full source build set Gradle property takimakiTest=true. Supply TAKIMAKI_KEYSTORE, TAKIMAKI_STORE_PASSWORD, TAKIMAKI_KEY_ALIAS=takimaki-test and optional TAKIMAKI_KEY_PASSWORD through the build environment. No key supplied means unsigned, never a silently regenerated debug key.
Keep the separate signing backup private and use the SAME key for every update of hu.takimaki.test. The original hu.takimaki.app signing key remains unavailable.

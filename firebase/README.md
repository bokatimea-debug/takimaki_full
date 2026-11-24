# Firebase backend

Firebase project: `takimaki`  
Android application: `hu.takimaki.app` (`Takimaki`)  
Firestore location: `europe-west3` (Frankfurt)  

Enabled products:

- Cloud Firestore
- Firebase Authentication with anonymous sign-in

The `google-services.json` file downloaded from Firebase Console belongs in
`android/app/google-services.json`. It is intentionally ignored by Git.

Firebase Storage has not been provisioned yet. A production-mode bucket in
`europe-west3` was requested in the existing Firebase project, but the console
returned an unknown error before creating it. Do not store customer or provider
images in Firestore as Base64 as a substitute.

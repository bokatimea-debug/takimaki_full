# Firebase backend

Firebase project: `takimaki`  
Android application: `hu.takimaki.app` (`Takimaki`)  
Firestore location: `europe-west3` (Frankfurt)  

Enabled products:

- Cloud Firestore
- Firebase Authentication with anonymous sign-in

The `google-services.json` file downloaded from Firebase Console belongs in
`android/app/google-services.json`. It is intentionally ignored by Git.

Firebase Storage is provisioned in `europe-west3` as
`takimaki.firebasestorage.app`, initially in production mode (deny by default).
The repository's `firebase/storage.rules` must be published to enable the
participant-only image upload paths. Do not store customer or provider images
in Firestore as Base64 as a substitute.

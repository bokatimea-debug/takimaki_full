# Firebase backend

Firebase project: `takimaki`  
Android test application: `hu.takimaki.test` (`Takimaki Teszt`)  
Firestore location: `europe-west3` (Frankfurt)  

Enabled products:

- Cloud Firestore
- Firebase Authentication with anonymous sign-in and 30-day automatic cleanup

The `google-services.json` file downloaded from Firebase Console belongs in
`android/app/google-services.json`. It is intentionally ignored by Git.

Firebase Storage is not available on the current Spark plan: the Firebase
console requires a Blaze upgrade before a Storage bucket can be created.
Do not store customer or provider images in Firestore as Base64 as a substitute.

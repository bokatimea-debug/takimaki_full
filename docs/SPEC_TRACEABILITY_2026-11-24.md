# Takimaki – specifikációkövetés (2026-11-24)

| Specifikációs terület | Állapot | Ellenőrzés / korlát |
|---|---|---|
| Szerepkörök, belépés, profil | Implementált | Widgetteszt és navigációs tesztek; élő Firebase Auth nincs hitelesítve ebben a környezetben |
| Szolgáltatáskatalógus, keresés, ajánlat és megrendelés | Implementált | Űrlap- és elérhetőségi tesztek sikeresek |
| Expressz rendelés | Implementált | Látható megnevezés: „Expressz rendelés – Azonnali segítség 1–3 órán belül” |
| Megrendelő/szolgáltató naptár | Implementált | UI tesztelt; iOS rendszer-naptár integráció nincs fizikai iPhone-on ellenőrizve |
| Chat, képküldés | Implementált kódszinten | Résztvevő-alapú Firestore/Storage szabályok és feltöltési hibaállapot; éles Firebase teszt hiányzik |
| Push értesítés | Részben implementált | FCM és szerveres újraütemezés éles projektben nincs ellenőrizve |
| Értékelés, hibajegy | Részben implementált | Szerveroldali 72 órás szabály és admin-feldolgozás nincs éles Functions-környezetben hitelesítve |
| Apartmantakarítás | Implementált UI és adattárolási réteg | Általános/nagytakarítás, szobás checklist, kötelező képek, referenciafotó, jóváhagyás/javításkérés; élő Storage hitelesítés szükséges |
| Airbnb / Booking közvetlen kapcsolat | Nem kész, külső partneri hozzáférést igényel | Az iCal nem közvetlen fiókkapcsolat; nincs partner API/OAuth és nincs azt szimuláló funkció |
| Akadémia | Részben implementált | UI és helyi folyamat van; hiteles, Cloud Functions-alapú vizsgapontozás, admin CMS, teljes EN és statisztika nincs hitelesítve |
| Google Maps címjavaslat | Nem éles | Android manifestben helyőrző API-kulcs van; nincs google-services konfiguráció a tárolóban |
| Firebase | Konfiguráció nem ellenőrizhető | Nincs `.firebaserc`, Android `google-services.json` vagy iOS `GoogleService-Info.plist`; a távoli projekt és deployolt szabályok nem olvashatók ebből a környezetből |
| Aláírt APK | Nem kész | Az eredeti kulcs helyben érvényes, de Actions titkok nincsenek konfigurálva; debug APK épül |
| Android debug APK | Ellenőrzött build után átadható | A legutóbbi teljes teszt és build artefaktumot kell használni |

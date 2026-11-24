# Takimaki – tesztelési jegyzőkönyv (2026-11-24)

Vizsgált ág: `codex/professional-finalization-20261124`

## Sikeresen elvégzett ellenőrzések

| Ellenőrzés | Eredmény |
|---|---|
| Flutter statikus elemzés | Sikeres a `0c77e72` és a `cfd43b9` ág-builden. |
| Flutter unit- és widgettesztek | Sikeres. Ide tartozik az új Expressz rendelés megnevezés tesztje, a rendelési folyamat, navigáció, cset, profil, értékelés és akadémia meglévő tesztjei. |
| Reszponzív UI-regresszió | Sikeres 320×640 nagyított szöveggel, 360×740 és 412×892 méreten. A teszt kivételeket és túlcsordulást is ellenőriz. |
| Vizuális ellenőrzőképek | Elkészültek 16 fő képernyőhöz, továbbá űrlap-, billentyűzet-, szolgáltatásválasztó- és navigációs állapotokhoz. Mintavételben ellenőrizve: megrendelői főoldal, új megrendelés, beállítások, cset. |
| Debug Android APK | Sikeresen felépült a `0c77e72` commitból. SHA-256: `3fc4a5d7e6b6095d6a511b89dd036ee9a7e1e4af318354715c2ceb6e0fc9d534`. |
| Tesztaláíró kulcs helyi ellenőrzése | A korábbi kulcs a munkakörnyezetben megvan és érvényes; új kulcs nem készült. |

## Teljes képernyőellenőrzés – utolsó optimalizált kódfuttatás

| Ellenőrzés | Eredmény |
|---|---|
| Statikus elemzés | Sikeres a `869de6d` kódverzió buildjén. |
| Teljes Flutter tesztcsomag | Sikeres: 185 teszt. |
| Képernyő-regresszió | 28 éles képernyő × 3 kijelzőállapot: 84 ellenőrzés, túlcsordulás nélkül. |
| Interakciós regresszió | Rendelési űrlap, profilmentés, szolgáltatás-szerkesztés, törlés megerősítése, cset billentyűzettel és navigációs elérés sikeres. |
| Előtte/utána képek | A `main` alapág és az optimalizált ág azonos képernyőteszttel készült; az összevethető PNG-k külön GitHub Actions artefaktumban vannak. |

Az APK csak a futó Actions build sikeres befejezése után tekinthető az utolsó kódverzióhoz tartozónak.

## Nem végrehajtható ebben a környezetben

- Valódi Android/iOS készülékes telepítés, teljes érintéses folyamat és akkumulátor/memória profilozás.
- Éles Firebase Auth, Firestore, Storage, Functions és FCM kommunikáció: a meglévő `takimaki` projekt, Frankfurt Firestore, anonim Auth, Storage bucket és Storage-szabályok ellenőrizve, de a privát alkalmazáskonfiguráció és éles Functions-deploy még nincs itt.
- Airbnb és Booking.com hivatalos partneri OAuth/API kapcsolat.
- Aláírt teszt-APK: a kulcs megvan, de a GitHub Actions titokbeállításokhoz nincs jogosultság.

## Debug APK korlátja

A debug APK telepíthető teszteléshez, de nem helyettesíti a meglévő tartós
tesztkulccsal aláírt kiadást. Firebase-konfiguráció nélkül az alkalmazás
helyi, offline visszaesési módba lép; ez nem bizonyítja a többtelefonos
adatkommunikációt.

## Készülékes teljesítménymérés előkészítése

- A nyitóképernyő utánra került az FCM-tokenkérés, így a hálózati push-regisztráció nem blokkolja az első képkockát.
- A debug build `takimaki.performance` naplója kiírja a `first_frame_ms` értéket. Ezt valódi Android-készüléken, hidegindításokból kell rögzíteni; ebben a környezetben nincs csatlakoztatott telefon, ezért nincs kitalált mérési érték.

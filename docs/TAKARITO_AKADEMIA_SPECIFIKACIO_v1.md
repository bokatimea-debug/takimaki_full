# Takimaki Takarító Akadémia – v1.0

## Cél és hozzáférés

Ingyenes, magyar nyelvű (a tartalommodellben bővíthető angolra) apartmantakarítási oktatás a Takimaki Flutter alkalmazáson belül. Vendégként, regisztráció és bejelentkezés nélkül is elérhető. A vendég előrehaladása helyben, alkalmazás-újraindítást túlélve tárolódik, és a felhasználó törölheti. Regisztrált Firebase-felhasználónál a modul-előrehaladás és a vizsgakísérlet is Firestore-ba kerül.

Az Akadémia nem feltétele a regisztrációnak vagy munkavállalásnak, és nem állít ki szakmai képesítést.

## Belépési pontok

- Szerepválasztón harmadik, türkiz „Takarító Akadémia” kártya: „Tanulás indítása”. Nem indít regisztrációt.
- Megrendelői és szolgáltatói profil fejlécéből is elérhető.
- Az Akadémia útvonala: `/academy`.

## Megjelenés

Az alkalmazás meglévő türkiz–narancssárga rendszere, kompakt lekerekített kártyái és mobilra optimalizált méretei maradnak. A leckék a meglévő, saját szolgáltatási illusztrációk és egységes Material ikonok kombinációját használják. A felület nem módosítja az eredeti Takimaki logót, kabalát, szerepválasztási és rendelési funkciókat.

## Oktatási modulok

1. Professzionális takarítás alapjai – higiénia, színkódolt kendők, sorrend, biztonság.
2. Fürdőszoba – WC, zuhanyzó, vízkő, fertőtlenítés, bekészítések.
3. Konyha – munkapult, gépek, edények, zsírtalanítás.
4. Hálószoba – ágyneműcsere, szállodai ágyazás, ellenőrzés.
5. Nappali és előszoba – portalanítás, kanapé, elektronika, padlók.
6. Mosás és textíliák – válogatás, mosás, szárítás, foltok, tárolás.
7. Teljes vendégváltási takarítás – munkasorrend és végellenőrzés.
8. Fotós minőségellenőrzés – referencia- és ellenőrzőfotó, hibajelentés.
9. Speciális esetek – erős szennyeződés, penészgyanú, testnedvek, kártevők, sérülések.
10. Vendégfogadás előkészítése – bekészítések, esztétika, műszaki alapellenőrzés, lezárás.

Minden modul tartalmaz tényleges bevezetőt, eszközlistát, lépésről-lépésre útmutatót, tipikus hibákat, biztonsági figyelmeztetéseket, ellenőrzőlistát és három gyakorlókérdést. A gyakorlás azonnal megmutatja a helyes választ és rövid magyarázatot; nem számít bele a vizsgába.

## Vizsga

- 20 kérdés, modulonként két kérdés, válasz- és kérdéssorrend keverve.
- Egy kérdés látszik egyszerre; van számláló, vékony előrehaladási sáv, vissza és következő.
- Nincs időkorlát, díj vagy ismétlési korlát.
- Eredmény: `helyes / 20 × 100`, egész százalék.
- Osztályzat: 90–100 = 5 Jeles; 80–89 = 4 Jó; 60–79 = 3 Közepes; 40–59 = 2 Elégséges; 0–39 = 1 Elégtelen.
- A 4-es és 5-ös sikeres: az eredményoldal a meglévő szerepválasztóhoz vezető ingyenes regisztrációs gombot mutatja.
- A 3-as vagy rosszabb eredmény ismétlést ajánl, megmutatja a hibás kérdések helyes megoldását, és azonnal újraindítható.

## Firebase adatmodell és védelem

Publikus, csak olvasható tartalomkollekciók: `academy_modules`, `academy_lessons`, `academy_questions`.

Felhasználói kollekciók: `academy_progress/{uid}` és `academy_exam_attempts/{attemptId}`. A kliens vizsgakísérlete `client_pending_verification` forrásjelöléssel kerül fel. Hivatalos profiljelvény vagy hitelesített eredmény csak Cloud Function/admin ellenőrzés után hozható létre; a kliens által küldött pontszám nem hiteles adat.

## Kiadási ellenőrzőlista

1. Vendégként a 10 modul, 30 gyakorlókérdés és 20 kérdéses vizsga elérhető.
2. A 0/20, 8/20, 12/20, 16/20, 18/20 és 20/20 osztályzathatárai helyesek.
3. Az előrehaladás újraindítás után megmarad és törölhető.
4. Firebase esetén a felhasználó csak saját előrehaladását és kísérletét olvassa.
5. Meglévő rendelési, profil- és navigációs folyamatok nem sérülnek.
6. `flutter analyze`, tesztek és Android teszt-APK build végrehajtandó kiadás előtt.

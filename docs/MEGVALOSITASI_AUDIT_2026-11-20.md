# Takimaki – megvalósítási audit

Átvizsgálva: 2026-11-20.  Forrás: `Takimaki_teljes_specifikacio.txt`,
`TAKARITO_AKADEMIA_SPECIFIKACIO_v1.md` és a tényleges Flutter-forrás.

## Kész vagy nagyrészt kész

- Két szerep, szerepváltás, szolgáltatáskatalógus, ajánlatkérés, ajánlat,
  munka- és csetképernyők.
- Belső munka-naptár, készülék saját naptárának választható kapcsolata,
  helyi ütközésellenőrzés, helyi értesítési lista, értékelés és hibajegy.
- Profil, város, elérhetőség, saját profilkép helyi mentése.
- Takarító Akadémia: 10 lecke, 30 gyakorlókérdés, 20 kérdéses vizsga,
  helyi előrehaladás és eredmények.
- Firestore és anonim Firebase Auth alapbekötés; profil-, megkeresés-,
  ajánlat- és munkaadatokhoz részleges szinkron.

## Részben kész – lezárandó

| Tétel | Tényleges állapot | Elvégzendő |
|---|---|---|
| Reszponzív felület | Több oldal javult, de a Beállítások és egyes hosszú űrlapok kis kijelzőn még levágnak műveleteket. | Közös kompakt, SafeArea-s elrendezés és 360×740 / 320×640 ellenőrzés. |
| Firebase piactér | Írások és alap profil-szinkron van, de nem teljes több készülékes munkafolyamat. | Minden piactéri rekord, cset, státusz és jogosultság szerveroldali véglegesítése. |
| Akadémia Firebase | Előrehaladás/kísérlet kliensről menthető. | Cloud Functiones hivatalos vizsgaértékelés, csak tulajdonosi olvasás, tartalomverziózás és angol fordítás. |
| Készüléknaptár | Android készüléknaptár választható. | Valódi készülékes ellenőrzés, iOS-oldali naptárkezelés. |
| Értesítések | Helyi lista és Android-os ütemezési alap van. | Valódi FCM push, háttérkézbesítés és szerveres újraütemezés. |
| Értékelések/hibajegyek | Felület és helyi szabályok megvannak. | Szerveroldali 72 órás zárolás, rejtett értékelések, egyediség, admin-feldolgozás és heti AI-jelentés. |
| Fizetés és SMS | Csak felület / tesztlogika. | Éles Play-fizetés és valódi SMS/OTP szolgáltató bekötése. |
| Profilképek | Készüléken tartós helyi mentés van. | Firebase Storage feltöltés, letöltési URL, jogosultságok és több készülékes megjelenés. |

## Nem valósult meg

- Ingatlanonként szerkeszthető apartmantakarítási checklist, szobákra bontva.
- Minden kötelező checklistponthoz fotós bizonyíték és távoli tárolás.
- Referenciafotók, ellenőrzőfotók, tulajdonosi jóváhagyás és javításkérés.
- A takarító saját eszköz/szer hozásának jelölése.
- Külön általános és nagytakarítási munkafolyamat az apartmantakarításban.
- Airbnb- és Booking.com-naptár összekötése. A jelenlegi naptár kizárólag a
  telefon saját, írható naptára; nincs ICS/iCal-import vagy külső szolgáltatói kapcsolat.
- Üzenethez valódi, távoli képfeltöltés.
- Firebase Storage nincs beállítva; a jelenlegi Firebase-projekt Storage bucketje
  a repository dokumentáció szerint még nem használható.
- Adminfelület az oktatási tartalom, fotók, kérdések, publikálás és anonimizált
  tanulási statisztikák kezelésére.
- Magyar–angol nyelvváltás a teljes Akadémiához.

## Végrehajtási sorrend

1. Kijelzőre illesztés és az aktuális Akadémia-javítások lezárása.
2. Apartmantakarítási munkalap: ingatlan, helyiség, checklist, eszközök és
   általános/nagytakarítás.
3. Fotós minőségellenőrzés, tulajdonosi jóváhagyás és javításkérés.
4. Firebase Storage, Firestore-jogosultságok és szerveroldali értékelés.
5. Külső iCal/ICS naptárkapcsolatok (Airbnb/Booking), FCM, admin és lokalizáció.
6. Automatikus tesztek, Android APK build és készülékes tesztlista.

Ez az audit nem minősít késznek olyan külső integrációt, amelyhez jelenleg nincs
valós hitelesítő adat, Storage bucket vagy szolgáltatói hozzáférés.

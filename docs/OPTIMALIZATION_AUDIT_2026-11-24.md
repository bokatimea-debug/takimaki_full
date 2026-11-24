# Takimaki – professzionális véglegesítési audit

Ág: `codex/professional-finalization-20261124`  
Kiinduló commit: `ceb2e19`  
Átvizsgálás kezdete: 2026-11-24

## Tényszerű kiinduló állapot

- A korábbi GitHub Actions futás az elemzést, Flutter-teszteket és Android
  release APK-fordítást sikerrel végrehajtotta.
- A helyi fejlesztői környezetben nincs Flutter SDK/emulátor, ezért itt csak
  forrás- és szerveroldali ellenőrzés végezhető; minden változtatás után a
  távoli Android build kötelező.
- Fizikai Android/iOS-készülékes teszt, telepített Firebase szabályok,
  Storage bucket és Airbnb/Booking partneri API-hozzáférés nem igazolt.

## Feltárt hibák és javítási állapot

| Terület | Tény | Állapot |
|---|---|---|
| Távoli cset | A `chats/{id}/messages` alkönyvtárra nem volt Firestore-szabály, ezért a cset két telefon között megtagadhatta az olvasást/írást. | Javítás alatt ezen az ágon. |
| Cset jogosultság | Egy chat résztvevői kliensoldali frissítéssel módosíthatók voltak. | Javítás alatt: a résztvevőlista változatlan. |
| Fotóbiztonság | A takarítási bizonyítékok tárolási szabálya csak a feltöltőnek adott hozzáférést; a tulajdonos/partner nem kapott biztos olvasási jogot. | Javítás alatt: rendelési résztvevő alapú olvasás. |
| Marketplace | A helyi visszaesés és a Firestore rekordok párhuzamosan élnek; a teljes, szerveroldali tranzakciós rendelési folyamat nincs lezárva. | Külső Firebase-telepítés és végponti teszt szükséges. |
| Airbnb/Booking | A korábbi iCal-képernyő nem teljesíti a közvetlen fiók-összekötés követelményét. | Nem tekinthető késznek; hivatalos partneri OAuth/API szükséges. |
| Push, SMS, fizetés | Nem igazolt éles integráció. | Nem kész. |
| iOS/natív naptár | Nincs iOS készülékes ellenőrzés. | Nem kész. |

## Kötelező végellenőrzés

1. Flutter elemzés, teljes tesztcsomag és release APK-fordítás a jelen ágról.
2. Firebase szabályok és Cloud Functions telepítése tesztprojektbe, két külön
   fiókkal: megkeresés, ajánlat, elfogadás, cset, fotó, értékelés és hibajegy.
3. Android fizikai készülék: 360×740, billentyűzetes űrlap, kép feltöltés,
   értesítés és frissítés az előző Takimaki Teszt változatról.
4. iOS készülék: indítás, naptárengedély, biztonságos területek és cset.

E dokumentum nem minősít késznek külső vagy fizikai teszt nélkül maradt
funkciót.

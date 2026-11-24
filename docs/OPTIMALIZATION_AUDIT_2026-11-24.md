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
| Távoli cset | A `chats/{id}/messages` alkönyvtárra nem volt Firestore-szabály, ezért a cset két telefon között megtagadhatta az olvasást/írást. | Javítva ezen az ágon: csak a chat két résztvevője olvashat/írhat, a küldő azonosítója kötelező. Firebase-telepítéses ellenőrzés még szükséges. |
| Cset jogosultság | Egy chat résztvevői kliensoldali frissítéssel módosíthatók voltak. | Javítva: a résztvevőlista változatlan. |
| Cset duplikáció / offline állapot | A saját távoli üzenet eltérő szerverazonosítóval visszaérkezve megduplázódhatott, hálózati hibánál pedig nem volt visszajelzés. | Javítva ezen az ágon: közös kliens/szerver üzenetazonosító és egyértelmű helyi mentési jelzés. |
| Fotóbiztonság | A takarítási bizonyítékok tárolási szabálya csak a feltöltőnek adott hozzáférést; a tulajdonos/partner nem kapott biztos olvasási jogot. | Javítva: rendelési résztvevő alapú olvasás, képfájl- és méretkorláttal. Firebase-telepítéses ellenőrzés még szükséges. |
| Kiadási kulcs | A teszt-APK aláíró kulcsa és a hozzá tartozó jelszófájl követett Git-fájl volt. | Javítva az ágon: a fájlok kikerültek a GitHub-forrásból, a build kizárólag GitHub Actions titkokból használhatja őket. A korábbi Git-előzmény miatt a meglévő kulcs cseréje kötelező a kiadás előtt. |
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
5. GitHub Actions titkok: `TAKIMAKI_KEYSTORE_B64`, `TAKIMAKI_STORE_PASSWORD`,
   `TAKIMAKI_KEY_ALIAS`, `TAKIMAKI_KEY_PASSWORD`. Ezek nélkül az új, aláírt
   teszt-APK build szándékosan leáll, nem készül debug-kulccsal félrevezető release.

E dokumentum nem minősít késznek külső vagy fizikai teszt nélkül maradt
funkciót.

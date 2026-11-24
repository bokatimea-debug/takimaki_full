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
- A meglévő Firebase-projekt azonosítója `takimaki`; Firestore régiója
  `europe-west3`, az anonim belépés engedélyezett. A kiadási Android-csomag
  (`hu.takimaki.app`) ehhez a projekthez regisztrálva van. A privát
  `google-services.json` még nincs a buildtitkok között, ezért az éles
  Firestore/Functions-kapcsolat APK-ból még nem hitelesíthető.
- A Google Maps konzol ebben a munkakörnyezetben nem volt elérhető. A kulcs
  forrás helyett privát buildtitokként használható, de létrehozása és Android
  alkalmazásra/szignóra korlátozása még szükséges.
- A Firebase Storage production bucket sikeresen létrejött `europe-west3`
  régióban, neve `takimaki.firebasestorage.app`. A tároló szabályai még
  közzétételre várnak, ezért a képfeltöltést nem tekintjük késznek.
- A korábbi tesztaláíró kulcs a munkakörnyezetben még megvan és a kulcs
  érvényessége ellenőrizhető volt, de már nincs követve Gitben. GitHub CLI
  hitelesítés és titokkezelési jogosultság nincs, ezért a szükséges Actions
  titkokat innen nem lehet beállítani.

## Feltárt hibák és javítási állapot

| Terület | Tény | Állapot |
|---|---|---|
| Távoli cset | A `chats/{id}/messages` alkönyvtárra nem volt Firestore-szabály, ezért a cset két telefon között megtagadhatta az olvasást/írást. | Javítva ezen az ágon: csak a chat két résztvevője olvashat/írhat, a küldő azonosítója kötelező. Firebase-telepítéses ellenőrzés még szükséges. |
| Cset jogosultság | Egy chat résztvevői kliensoldali frissítéssel módosíthatók voltak. | Javítva: a résztvevőlista változatlan. |
| Cset létrehozás | Egy kliens korlátlan résztvevőlistás chatet hozhatott volna létre. | Javítva: új cset pontosan két, eltérő résztvevőt tartalmazhat; a létrehozó csak egyikük lehet. |
| Cset duplikáció / offline állapot | A saját távoli üzenet eltérő szerverazonosítóval visszaérkezve megduplázódhatott, hálózati hibánál pedig nem volt visszajelzés. | Javítva ezen az ágon: közös kliens/szerver üzenetazonosító és egyértelmű helyi mentési jelzés. |
| Fotóbiztonság | A takarítási bizonyítékok tárolási szabálya csak a feltöltőnek adott hozzáférést; a tulajdonos/partner nem kapott biztos olvasási jogot. | Javítva: rendelési résztvevő alapú olvasás, képfájl- és méretkorláttal. Firebase-telepítéses ellenőrzés még szükséges. |
| Cset-média jogosultság | A cset-képnél az írási szabály indokolatlanul engedte volna a meglévő fájl módosítását vagy törlését. | Javítva: résztvevő csak új, saját képfájlt tölthet fel; módosítás és törlés tiltott. |
| Kiadási kulcs | A teszt-APK aláíró kulcsa és a hozzá tartozó jelszófájl követett Git-fájl volt. | Javítva az ágon: a fájlok kikerültek a GitHub-forrásból, a build kizárólag GitHub Actions titkokból használhatja őket. A korábbi Git-előzmény miatt a meglévő kulcs cseréje kötelező a kiadás előtt. |
| Marketplace | A helyi visszaesés és a Firestore rekordok párhuzamosan élnek; a teljes, szerveroldali tranzakciós rendelési folyamat nincs lezárva. | Külső Firebase-telepítés és végponti teszt szükséges. |
| Airbnb/Booking | A korábbi iCal-alapú beolvasó nem teljesíti a közvetlen fiók-összekötés követelményét. | Letiltva; közvetlen, szerveroldali partneri API-hozzáférés szükséges. |
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
6. A debug APK külön buildként készül, ehhez nincs szükség kiadási kulcsra.
7. A CI a widgetes képernyőtesztek közben 320–412 px szélességű vizuális
   ellenőrzőképeket is készít és külön letölthető leletként tárol. Ez nem
   helyettesíti a fizikai készülékes ellenőrzést.

E dokumentum nem minősít késznek külső vagy fizikai teszt nélkül maradt
funkciót.

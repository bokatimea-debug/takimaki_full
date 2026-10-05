# Takimaki – aktuális fejlesztési forrás

A jelenlegi 1.0.8 (9) Android tesztverzió teljes forrása a `Takimaki_1.0.8_FEJLESZTES_NEM_APK.zip` fájlban található, a `codex/takimaki-108` ágon. A ZIP forráskódot tartalmaz, nem APK-t. A gyökérben található korábbi `lib/`, `android/` stb. könyvtárak történeti állapotot őriznek; a jelenlegi build a ZIP-et bontja ki és abból dolgozik.

Az APK és az ellenőrzés eredménye a `v1.0.8-test` tesztkiadáshoz kerül. A `Takimaki_teljes_specifikacio.txt` tartalmazza a jóváhagyott működést és a hiányzó szerveres részeket.

A GitHub Actions `Takimaki development verification` munkafolyamata a checkpointból futtat Flutter-elemzést, regressziós teszteket és Android-fordítást. Az előállított APK helyben, a korábbi privát tesztkulccsal lesz aláírva; a privát kulcs nem kerül a repóba.

Helyi előkészítés Flutter 3.35.7 és Java 17 mellett:

```bash
unzip Takimaki_1.0.8_FEJLESZTES_NEM_APK.zip -d current
cd current/takimaki_full
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --reporter expanded
ORG_GRADLE_PROJECT_takimakiTest=true flutter build apk --release --build-name=1.0.8 --build-number=9
```

A release APK-t alá kell írni a megőrzött `takimaki-test` kulccsal. A csomag azonosítója `hu.takimaki.test`; az 1.0.7 tesztverziót frissíti, a régi `hu.takimaki.app` alkalmazást nem.

Az app jelenleg helyi SharedPreferences tesztadatokat használ. Valódi, külön telefonok közötti adatkezeléshez, chathez és pushhoz backend szükséges. A privát hibajegyek AI-os feldolgozása és heti adminjelentése szerveroldali AI-hozzáférés nélkül nincs bekötve. A 30 perces időpontpuffer nem útvonalbecslés. A naptár és a háttérértesítések tényleges telefonos ellenőrzése még szükséges.

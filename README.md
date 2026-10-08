# Aktuális dokumentáció

A teljes összevont követelményrendszer: [Takimaki teljes specifikáció](docs/Takimaki_teljes_specifikacio.txt). A legújabb döntések ebben szerepelnek; az alábbi 1.0.4-es leírás történeti kiadási jegyzet. Az aktuális kiadás 1.0.7+8, eredményei a verification/STATUS_107.txt fájlban találhatók.

# Takimaki

Flutter Android-alkalmazás. A projekt verziója: **1.0.4+5**.

## Az 1.0.4 javításai

- Azonos kezdőmagasságú, közös felépítésű profilszerkesztők. A fénykép mellett a keresztnév szerepel; név és telefonszám itt nem szerkeszthető.
- Mindkét profilban szerkeszthető bemutatkozás és kereshető városválasztó. A szolgáltató időbeosztása megmaradt; a mentett város a szolgáltatói névjegyen és az új szolgáltatásnál is látható.
- Mindkét szerkesztőből elérhető, megerősítést kérő fióktörlés, három naptári hónapos újraregisztrációs figyelmeztetéssel. A helyi telefonszám-korlátozás megmarad további törlések után is.
- Az új szolgáltatás teljes kitölthető felülete és a Mentés egyetlen görgethető űrlapon található. A hibás kötelező mezőhöz a felület odagörget; az ármező fókuszt kap.
- Teljes szélességű szolgáltatásválasztó, a szolgáltatáshoz illő ikonokkal. A részletes árlisták és az egyedi napok megmaradtak.

## Javítások

- Egységes türkiz–sárga színkészlet a közös témában.
- Kompakt profil-, szolgáltatás- és előfizetési képernyők, a rendszer navigációs sávját figyelembe vevő gombelhelyezéssel.
- Görgethető űrlapok, nagyított betűméret és nyitott billentyűzet kezelése.
- Regisztrációs gombok közvetlenül a kitöltendő tartalom után.
- A profilkép bájtjainak tartós tárolása; az ideiglenes képfájl törlése után is betölthető kép.
- Csetpartnerhez tartozó fénykép és név mentése, hiányzó partnerfotónál monogram.
- Natív adaptív és kör alakú Android-indítóikon.

A jóváhagyott kezdőképernyő, kabalakép és szerepválasztó forrása változatlan.

## Fordítás

Az ellenőrzött környezet Flutter 3.35.7 / Dart 3.9.2, JDK 17, Android SDK 36, Build Tools 36.0.0 és NDK 28.2.13676358. A projekt Gradle wrappert használ. A géphez tartozó SDK-útvonalakat a helyi `android/local.properties` fájlban kell megadni.

```sh
flutter pub get
flutter test --no-pub --reporter expanded
flutter build apk --release --no-pub --build-name=1.0.4 --build-number=5
```

Az APK helye: `build/app/outputs/flutter-apk/app-release.apk`.

A meglévő telepítés frissítéséhez az eredeti aláírókulcs szükséges. A forráscsomag nem tartalmaz privát kulcsot. A referenciatanúsítvány SHA-256 lenyomata:

`4a0dba4355f719b0aadf3c8dc5fc2e54bbbfa769817b6f7959315b0b18ba6073`

## Ellenőrzés és folytatás

A képernyőtesztek 360 × 740, 412 × 892 és 320 × 640 méreten futnak, az utóbbin 1,3-szoros betűmérettel. Külön ellenőrzések vizsgálják a teljes gombok láthatóságát, a görgethetőséget, a billentyűzetet, a fotók megőrzését, a kitöltött profilok igazítását, a város mentését, a törlést és az űrlap hibás mezőinek láthatóságát. A kiadás tényleges teszteredményeit a csomag ellenőrzési naplói rögzítik.

Az 1.0.4 ellenőrzésekor **95/95 teszt sikerült**. A városválasztó utolsó igazítása után annak célzott, 320 × 640 méretű, nagyított szöveges és nyitott billentyűzetes tesztje ismét sikerült. A hosszú űrlap ellenőrzése tíz egyedi dátummal és hét ársávval vizsgálta a hiányzó ármező automatikus megjelenítését. A statikus elemzés nulla hibát, egy korábban is meglévő figyelmeztetést és harminc információs jelzést adott.

A `TAKIMAKI_CAPTURE` környezeti változóval képernyőképek menthetők; a `FLUTTER_ROOT` a Flutter SDK könyvtárára mutasson. A képernyőképek Flutter widgettesztekből származnak, nem fizikai telefonról.

A meglévő helyi tesztadat-kezelés és tesztelői előfizetési működés megmaradt. A jelen módosítás felületi és helyi adatmegőrzési javítás; nem vezet be új fizetési vagy távoli háttérszolgáltatást.

A három hónapos korlátozás jelenleg az alkalmazás helyi adatai között tárolódik. Az alkalmazásadatok törlése vagy másik készülék esetén érvényes korlátozáshoz szerveroldali nyilvántartás szükséges. A városválasztó gyakori városokat kínál, és más település neve is megadható.

A következő munkamenet előtt olvasd el az `AGENTS.md` fájlt. A tesztelt forrást és a kiadott APK-t mindig tartósan mentsd el az átadás előtt.

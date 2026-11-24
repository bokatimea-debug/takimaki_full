# Takimaki – képernyőszintű UI/UX audit (2026-11-24)

## Ellenőrzési módszer

Minden felsorolt éles képernyő Flutter widgettesztben futott 360×740, 412×892 és 320×640 dp méretben; az utolsó méret 130%-os rendszerbetűmérettel. A teszt RenderFlex-túlcsordulást, elérhetetlen alsó műveletet és billentyűzet alá kerülő csetmezőt is ellenőriz. A képernyőképek a GitHub Actions `Takimaki_UI_Before_1.0.26` és `Takimaki_UI_Check_1.0.26` artefaktumaiban vannak.

## Közös és megrendelői képernyők

| Képernyő | Ellenőrzés | Talált probléma | Javítás / állapot |
|---|---|---|---|
| Szerepválasztó | 3 méret, nagy betű | Kártyák kilógtak 360 és 320 dp-n | Magasság a rendelkezésre álló helyhez igazítva; javítva |
| Megrendelő profil | 3 méret, alsó műveletek | Expressz név régi SOS-szöveget használt | `Expressz rendelés` és `Azonnali segítség 1–3 órán belül`; javítva |
| Új rendelés | 3 méret, teljes űrlap | Hosszú űrlap alsó része kockázatos volt | Görgetés és hibahelyre ugrás tesztelve; rendben |
| Rendeléseim, ajánlataim, részletek | 3 méret | Nem talált túlcsordulás | Rendben |
| Üzenetek és beszélgetés | 3 méret, billentyűzet | Csatolmány és billentyűzet miatti elvesző beviteli kockázat | Kamera/galéria művelet, feltöltési hibaállapot és billentyűzet feletti beviteli mező; javítva |
| Naptár, készüléknaptár-kapcsolat | 3 méret | Nem talált túlcsordulás | UI rendben; iOS natív naptár valós készülékes ellenőrzése még szükséges |
| Beállítások, értesítések, profil szerkesztése | 3 méret, nagy betű | Törlési művelet elérhetősége ellenőrzendő volt | Utolsó művelet és mentés görgetéssel elérhető; rendben |
| Térképes címválasztó | 3 méret | A nem konfigurált Google Maps helyén félrevezető ál-térkép volt | Átlátható kézi címbevitel és pontos konfigurációs üzenet; javítva |
| Foglalási fiókok | 3 méret | Régi iCal-felület közvetlen kapcsolatnak látszhatott | A kapcsolat „hamarosan” jelölésű; nem állít közvetlen összekötést; javítva |
| Hibajegyek | 3 méret | Nem talált túlcsordulás | UI rendben; szerveroldali 72 órás lezárás külön külső függőség |

## Szolgáltatói képernyők

| Képernyő | Ellenőrzés | Talált probléma | Javítás / állapot |
|---|---|---|---|
| Szolgáltatói profil és szerkesztő | 3 méret, nagy betű | Nem talált túlcsordulás | Mentés és alsó vezérlők tesztelve |
| Szolgáltatások / új szolgáltatás | 3 méret, hosszú űrlap | Hosszú űrlapon hibamező elveszhetett | Görgetés, kategória, ár és dátummezők elérhetősége tesztelve |
| Kérések, ajánlatok, munkák | 3 méret | Nem talált túlcsordulás | Rendben |
| Szolgáltatói naptár | 3 méret, nagy betű | Dátumcellák 320 dp-n kilógtak | Csak a cellaszám nem skálázódik; javítva |
| Munkaértesítések | 3 méret | Nem talált túlcsordulás | Rendben |
| Akadémia | 3 méret | Nem talált túlcsordulás | UI rendben; hiteles szerveroldali vizsgaértékelés nincs élesítve |
| Szolgáltatói beállítás | 3 méret, nagy betű | Alsó rész 320 dp-n levágódott | Görgethető, minimális magasságú elrendezés; javítva |

## Apartmantakarítás

| Elem | Talált probléma | Javítás / állapot |
|---|---|---|
| Munkalap fejléce | Cím és szerkesztés egy sorban kis szélességen szorult | A szerkesztés külön sorba került |
| Takarítástípus | A hosszú „Általános vendégváltási takarítás” kiválasztott felirat túlcsordult | Rövid, egy soros kiválasztott címke; teljes név a listában megmaradt |
| Referenciafotó sora | Nagy betűméretnél a leírás és gomb ütközhetett | Keskeny nézetben egymás alá rendeződik |
| Tulajdonosi státusz és döntések | Hosszú státusz és két gomb kilóghatott | Tördelhető státusz, keskeny nézetben függőleges gombok |

## Kizárás

A kódban maradt régi, nem routolt demó/előd képernyők nem részei a kiadott navigációnak. Nem töröltem őket, mert meglévő funkciót nem szabad eltávolítani; kiadás előtt ezek routolását vagy archiválását külön kell eldönteni.

import 'package:flutter/material.dart';

class AcademyQuestion {
  const AcademyQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class AcademyModule {
  const AcademyModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.introduction,
    required this.tools,
    required this.steps,
    required this.mistakes,
    required this.safety,
    required this.checklist,
    required this.questions,
  });
  final int id;
  final String title;
  final String subtitle;
  final int duration;
  final IconData icon;
  final String introduction;
  final List<String> tools;
  final List<String> steps;
  final List<String> mistakes;
  final List<String> safety;
  final List<String> checklist;
  final List<AcademyQuestion> questions;
}

AcademyQuestion q(String question, List<String> options, int correct, String why) =>
    AcademyQuestion(question: question, options: options, correctIndex: correct, explanation: why);

final academyModules = <AcademyModule>[
  AcademyModule(
    id: 1, title: 'Alapismeretek', subtitle: 'Higiénia, tisztítószerek, eszközök', duration: 10,
    icon: Icons.cleaning_services_rounded,
    introduction: 'A professzionális takarítás biztonságos, higiénikus és következetes munka. A tisztítás eltávolítja a szennyeződést, a fertőtlenítés pedig a címke szerinti szerrel és behatási idővel csökkenti a kórokozókat.',
    tools: ['Mikroszálas kendők', 'WC-kendő', 'Szivacs és kefe', 'Porszívó és felmosó', 'Védőkesztyű', 'Szemeteszsák'],
    steps: ['Nézd át az ingatlan állapotát.', 'Gyűjtsd össze a hulladékot és a használt textíliákat.', 'A tisztítószert a címke szerint hagyd hatni.', 'Felülről lefelé, tisztábbtól a szennyezettebb felé haladj.', 'Porszívózz, moss fel, készíts be, majd ellenőrizz.'],
    mistakes: ['Ugyanaz a kendő a WC-hez és a konyhához.', 'Tisztítószerek találomra keverése.', 'A behatási idő kihagyása.'],
    safety: ['Ne keverj tisztítószereket.', 'Klórtartalmú szert savas vagy ammóniás szerrel soha ne keverj.', 'Szellőztess és viselj kesztyűt.'],
    checklist: ['Eszközök rendben', 'Kendők elkülönítve', 'Megfelelő szer kiválasztva', 'Munkaterület biztonságos'],
    questions: [
      q('Szabad különböző tisztítószereket találomra összekeverni?', ['Igen', 'Nem', 'Csak kis mennyiségben'], 1, 'Nem. Veszélyes reakció és gáz is képződhet.'),
      q('Mi a helyes portalanítási irány?', ['Felülről lefelé', 'Alulról felfelé', 'Véletlenszerűen'], 0, 'Így nem hullik por a már letisztított felületre.'),
      q('Használható ugyanaz a kendő a WC-hez és a konyhához?', ['Igen', 'Csak fertőtlenítés után', 'Nem'], 2, 'Külön kendő kell a keresztszennyeződés elkerülésére.'),
    ],
  ),
  AcademyModule(
    id: 2, title: 'Fürdőszoba', subtitle: 'WC, zuhanyzó, vízkő, fertőtlenítés', duration: 12,
    icon: Icons.bathtub_rounded,
    introduction: 'A fürdőszoba a higiénia szempontjából kiemelt terület. Használj elkülönített eszközöket, és mindig nézd át a teljes helyiséget.',
    tools: ['Piros WC-kendő', 'Sárga fürdőszobai kendő', 'WC-kefe', 'Felülethez való vízkőoldó', 'Üvegtisztító'],
    steps: ['Ellenőrizd az állapotot, gyűjtsd össze a textíliákat és ürítsd a szemetest.', 'Távolítsd el a hajszálakat.', 'Tisztítsd a WC belsejét, ülőkét, fedelet, külső felületet és öblítőgombot.', 'Tisztítsd a zuhanyt vagy kádat, a mosdót, csaptelepet és tükröt.', 'Porszívózz, moss fel, majd készíts be WC-papírt, szappant és törölközőt.'],
    mistakes: ['Vízköves csaptelep', 'Hajszál a zuhanyzóban', 'Foltos tükör', 'Hiányzó WC-papír'],
    safety: ['Természetes kőre savas vízkőoldót ne használj automatikusan.', 'A fertőtlenítő behatási idejét tartsd be.', 'A WC-hez kizárólag kijelölt eszközöket használj.'],
    checklist: ['Nincs hajszál', 'Tiszta, szagtalan WC', 'Csíkmentes tükör', 'Bekészítések kint vannak'],
    questions: [
      q('Miért kell eltávolítani a hajszálakat?', ['Csak a látvány miatt', 'A higiénia és tisztaság miatt', 'Nem szükséges'], 1, 'A látható hajszál a vendég számára egyértelmű tisztasági hiba.'),
      q('Használható bármilyen vízkőoldó természetes kövön?', ['Igen', 'Nem', 'Csak meleg vízzel'], 1, 'A savas szer károsíthatja az érzékeny kőfelületet.'),
      q('Mit kell ellenőrizni a fürdőszoba végén?', ['Csak a padlót', 'A teljes tisztaságot és a bekészítéseket', 'Csak a WC-t'], 1, 'Minden felület, a szag és a bekészítések is számítanak.'),
    ],
  ),
  AcademyModule(
    id: 3, title: 'Konyha', subtitle: 'Gépek, edények, zsírtalanítás', duration: 12,
    icon: Icons.kitchen_rounded,
    introduction: 'A tiszta, rendezett konyha vendégélmény és élelmiszer-higiéniai alap. A munkapulttól a gépekig minden könnyen hozzáférhető felületet ellenőrizz.',
    tools: ['Konyhai zsíroldó', 'Zöld kendő', 'Mosogatószer', 'Szivacs', 'Szemeteszsák'],
    steps: ['Gyűjtsd össze az edényeket, ellenőrizd az ételmaradékokat és ürítsd a szemetest.', 'Tisztítsd a mosogatót, csaptelepet, munkapultot és asztalt.', 'Ellenőrizd a hűtőt, mikrohullámú sütőt, főzőlapot, sütőt, kávéfőzőt és vízforralót.', 'Nézd át a poharakat és evőeszközöket; sérülést vagy hiányt jelents.', 'Készíts be a tulajdonos előírása szerint.'],
    mistakes: ['Morzsás fiók', 'Zsíros főzőlap', 'Koszos mikrohullámú sütő', 'Foltos pohár'],
    safety: ['Elektromos alkatrészt ne áztass el.', 'A gépeket a gyártói előírás szerint tisztítsd.', 'Élelmiszerrel érintkező felületnél csak megfelelő szert használj.'],
    checklist: ['Munkapult zsírtalanítva', 'Gépek ellenőrizve', 'Edények tiszták', 'Bekészítések feltöltve'],
    questions: [
      q('Kell ellenőrizni a mikrohullámú sütőt?', ['Igen', 'Nem', 'Csak kérésre'], 0, 'A vendégváltási ellenőrzés része.'),
      q('Miért kell megvizsgálni az edényeket?', ['Csak a darabszám miatt', 'Tisztaságuk és épségük miatt', 'Nem kell'], 1, 'Foltos vagy sérült edény nem maradhat észrevétlen.'),
      q('Ki határozza meg a bekészítéseket?', ['A tulajdonos', 'A vendég', 'A takarító tetszőlegesen'], 0, 'Az ingatlan saját előírása a mérvadó.'),
    ],
  ),
  AcademyModule(
    id: 4, title: 'Hálószoba', subtitle: 'Ágyneműcsere, szállodai ágyazás', duration: 10,
    icon: Icons.bed_rounded,
    introduction: 'A rendezett ágy a vendég első benyomásának egyik legfontosabb része. Az elrendezés kövesse az ingatlan referenciafotóját.',
    tools: ['Tiszta ágynemű', 'Tiszta párnahuzatok', 'Mikroszálas kendő', 'Porszívó'],
    steps: ['Vedd le a használt ágyneműt.', 'Ellenőrizd a matracot, matracvédőt, párnákat és takarókat.', 'Húzd fel a tiszta lepedőt és huzatokat.', 'Igazítsd szimmetrikusan a takarót és párnákat.', 'Portalanítsd az éjjeliszekrényt, lámpákat, kapcsolókat és ellenőrizd az ágy alját.'],
    mistakes: ['Foltos párnahuzat', 'Rosszul felhúzott lepedő', 'Poros éjjeliszekrény'],
    safety: ['Csak biztonságosan hozzáférhető ágy alatti területet tisztíts.', 'Sérült textíliát jelents, ne rejtsd el.'],
    checklist: ['Tiszta ágynemű', 'Szimmetrikus ágy', 'Nincs hajszál', 'Éjjeliszekrény tiszta'],
    questions: [
      q('Mit kell ellenőrizni ágyazás előtt?', ['A matracot és textíliákat', 'Csak a függönyt', 'Csak a lámpát'], 0, 'A tiszta ágynemű csak tiszta, hibátlan alapra kerülhet.'),
      q('Maradhat foltos párnahuzat?', ['Igen', 'Nem', 'Ha hátul van'], 1, 'Nem, minden textíliának tisztának kell lennie.'),
      q('Miért fontos a referenciafotó?', ['Egységes elrendezés miatt', 'Csak díszítés', 'Nem fontos'], 0, 'Az ingatlan elvárt vendégfogadási képe látszik rajta.'),
    ],
  ),
  AcademyModule(
    id: 5, title: 'Nappali', subtitle: 'Portalanítás, bútorok, padlók', duration: 8,
    icon: Icons.weekend_rounded,
    introduction: 'A nappaliban a rendezett bútorok, pormentes felületek és tiszta padló együtt adják a friss, vendégfogadó összképet.',
    tools: ['Kék kendő', 'Porszívó', 'Padlóhoz való tisztítószer', 'Képernyőhöz való kendő'],
    steps: ['Felülről lefelé portalaníts: polcok, lámpák, bútorok, asztalok, párkányok.', 'Távolítsd el a morzsát, rendezd a párnákat és takarókat.', 'Ellenőrizd a távirányítót, kapcsolókat és elektronikai eszközök külső felületét.', 'Porszívózz, ellenőrizd a szegélyeket, majd szükség szerint moss fel.'],
    mistakes: ['Morzsa a kanapéban', 'Poros polc', 'Foltos asztal', 'Elmozdult dekoráció'],
    safety: ['Elektronikát csak megfelelő módszerrel tisztíts.', 'Padlóanyaghoz való szert használj.'],
    checklist: ['Felületek pormentesek', 'Kanapé rendezett', 'Kapcsolók tiszták', 'Padló tiszta'],
    questions: [
      q('Kell ellenőrizni a kanapé réseit?', ['Igen', 'Nem', 'Csak hétvégén'], 0, 'Morzsa és szemét gyakran ott marad.'),
      q('Mivel tisztítjuk az érzékeny képernyőt?', ['Bármilyen súrolóval', 'A gyártó által engedélyezett módon', 'Vizes felmosóval'], 1, 'A képernyő károsodását így kerülheted el.'),
      q('Mikor történjen a padló tisztítása?', ['A felületek takarítása után', 'Előtte', 'Bármikor'], 0, 'A felületekről leeső por így nem szennyezi vissza a padlót.'),
    ],
  ),
  AcademyModule(
    id: 6, title: 'Textíliák', subtitle: 'Mosás, folteltávolítás, tárolás', duration: 10,
    icon: Icons.dry_cleaning_rounded,
    introduction: 'A tiszta textília csak akkor higiénikus, ha megfelelően válogatva, kimosva, teljesen megszárítva és védetten tárolva van.',
    tools: ['Mosószer', 'Mosási címke', 'Szennyeszsák', 'Szárító vagy szárítóállvány'],
    steps: ['Különítsd el a használt és tiszta textíliákat.', 'Olvasd el a címkét, válogass szín és anyag szerint.', 'Válassz megfelelő programot és adagolj helyesen.', 'Ne terheld túl a mosógépet.', 'Teljes száradás után száraz, zárt vagy védett helyen tárold.'],
    mistakes: ['Nedvesen elrakott textília', 'Túl sok mosószer', 'Nem megfelelő hőmérséklet'],
    safety: ['Erős foltot anyagkompatibilisen kezelj.', 'Érzékeny anyagot ne dörzsölj erősen.', 'Tartós foltot vagy sérülést jelents.'],
    checklist: ['Címkék ellenőrizve', 'Textíliák teljesen szárazak', 'Tiszta és használt elkülönítve', 'Tárolás higiénikus'],
    questions: [
      q('Mi alapján választjuk a mosási programot?', ['A kezelési címke alapján', 'Mindig ugyanazt', 'A szín alapján'], 0, 'Az anyag és gyártói előírás a döntő.'),
      q('Elrakható nedves ágynemű?', ['Igen', 'Nem', 'Csak zsákban'], 1, 'Nedvesen szag és mikrobiális szaporodás alakulhat ki.'),
      q('Szabad túlterhelni a mosógépet?', ['Igen', 'Nem', 'Csak törölközővel'], 1, 'A túlterhelés rontja a tisztítás minőségét.'),
    ],
  ),
  AcademyModule(
    id: 7, title: 'Vendégváltás', subtitle: 'Teljes apartmantakarítási folyamat', duration: 12,
    icon: Icons.swap_horiz_rounded,
    introduction: 'A vendégváltási takarítás célja, hogy az apartman minden pontja tiszta, feltöltött és a következő vendég számára kész legyen.',
    tools: ['Ingatlan checklist', 'Takarítóeszközök', 'Textíliák', 'Bekészítések', 'Telefon dokumentáláshoz'],
    steps: ['Ellenőrizd a megrendelést, ingatlan-specifikus checklistet és eszközöket.', 'Dokumentáld a jelentős rendellenességeket.', 'Gyűjtsd össze a hulladékot és használt textíliát, szellőztess biztonságosan.', 'Kezdd a konyha előkészítésével és a fürdőszobai szerek hatóidejével.', 'Rendezd a hálót és nappalit, majd fejezd be a konyhát, fürdőt és padlókat.', 'Készíts be és végezz teljes végellenőrzést.'],
    mistakes: ['Ingatlan saját checklistjének kihagyása', 'Bejelentetlen sérülés', 'Hiányos textília vagy bekészítés'],
    safety: ['A sorrend igazítható, de a higiéniai elkülönítés nem hagyható el.', 'Ismeretlen veszély esetén állj meg és jelents.'],
    checklist: ['Minden helyiség tiszta', 'Nincs szemét', 'Textíliák kihelyezve', 'Bekészítések rendben', 'Sérülések jelentve'],
    questions: [
      q('Mit ellenőrzünk érkezéskor?', ['Az ingatlan állapotát és a megrendelést', 'Csak az időjárást', 'Csak a díjat'], 0, 'Ez adja a teljes munka alapját.'),
      q('Miért kell követni a checklistet?', ['A hiányzó feladatok elkerülésére', 'Csak adminisztráció', 'Nem kell'], 0, 'Az ingatlan egyedi elvárásait rögzíti.'),
      q('Mi történik a végén?', ['Teljes ellenőrzés és munkalezárás', 'Azonnali távozás', 'Új takarítás kezdése'], 0, 'Csak ellenőrzött munkát szabad lezárni.'),
    ],
  ),
  AcademyModule(
    id: 8, title: 'Minőségellenőrzés', subtitle: 'Fotók, hibák, végső ellenőrzés', duration: 10,
    icon: Icons.photo_camera_outlined,
    introduction: 'A referenciafotó megmutatja az elvárt állapotot. Az ellenőrzőfotóval bizonyítható a munka állapota és gyorsabban kezelhető a javítási kérés.',
    tools: ['Telefon vagy kamera', 'Ingatlan referenciafotói', 'Checklist'],
    steps: ['Nézd meg a referenciafotót.', 'Készíts éles, jól megvilágított képet a releváns területről.', 'Lehetőleg a referencia nézőpontját kövesd.', 'Dokumentáld a sérülést, hiányt, makacs foltot vagy hibát.', 'Töltsd fel a kötelező fotókat, ellenőrizd a checklistet és zárd le a munkát.'],
    mistakes: ['Homályos fotó', 'Nem látszik a releváns terület', 'Felesleges személyes adat a képen'],
    safety: ['Személyes adatot ne fényképezz feleslegesen.', 'A tulajdonos javítást kérhet; ezt dokumentáltan kezeld.'],
    checklist: ['Referencia követve', 'Fotók élesek', 'Hibák jelentve', 'Kötelező képek feltöltve'],
    questions: [
      q('Milyen a jó ellenőrzőfotó?', ['Éles és összehasonlítható', 'Sötét és távoli', 'Bármilyen'], 0, 'A releváns területnek jól látszania kell.'),
      q('Kell jelenteni a sérüléseket?', ['Igen', 'Nem', 'Csak ha nagy'], 0, 'A sérülést fotóval és rövid leírással rögzítsd.'),
      q('Kérhet a tulajdonos javítást?', ['Igen', 'Nem', 'Csak vendég'], 0, 'A minőségellenőrzés része a javítási visszajelzés.'),
    ],
  ),
  AcademyModule(
    id: 9, title: 'Speciális esetek', subtitle: 'Veszélyes helyzetek, jelentés', duration: 10,
    icon: Icons.warning_amber_rounded,
    introduction: 'A takarító biztonsága elsőbbséget élvez. A szokásos vendégváltást meghaladó vagy bizonytalan helyzetet dokumentálni és jelenteni kell.',
    tools: ['Védőkesztyű', 'Telefon dokumentáláshoz', 'Kapcsolattartó elérhetősége'],
    steps: ['Erős szennyeződést dokumentálj.', 'Nagy kiterjedésű vagy bizonytalan penészgyanút jelents.', 'Vér vagy testnedv esetén fokozott óvatossággal járj el.', 'Kártevőgyanút dokumentálj és jelents.', 'Sérülést fotóval és rövid leírással rögzíts.'],
    mistakes: ['Veszélyes szennyeződés önálló, képzettség nélküli kezelése', 'Kártevőgyanú elhallgatása', 'Törött tárgy elrejtése'],
    safety: ['Megfelelő felszerelés vagy képzettség nélkül ne vállald a veszélyes szennyeződést.', 'Visszatérő penészt ne próbálj szakszerűtlenül eltávolítani.'],
    checklist: ['Rendellenesség dokumentálva', 'Kapcsolattartó értesítve', 'Biztonságos állapot fenntartva'],
    questions: [
      q('Mit teszünk veszélyes szennyeződésnél?', ['Megállunk és intézkedést kérünk', 'Bármilyen szerrel eltávolítjuk', 'Figyelmen kívül hagyjuk'], 0, 'A biztonság az első.'),
      q('Jelenteni kell a kártevőgyanút?', ['Igen', 'Nem', 'Csak vendégnek'], 0, 'A gyors dokumentálás segít a megfelelő intézkedésben.'),
      q('Dokumentálni kell a törött tárgyakat?', ['Igen', 'Nem', 'Csak ha új'], 0, 'Fotó és rövid leírás szükséges.'),
    ],
  ),
  AcademyModule(
    id: 10, title: 'Vendégfogadás', subtitle: 'Bekészítések, esztétika, lezárás', duration: 8,
    icon: Icons.key_rounded,
    introduction: 'Az utolsó ellenőrzés teszi az apartmant valóban vendégfogadásra késszé: tisztaság, esztétika, bekészítések és biztonságos lezárás.',
    tools: ['Ingatlan bekészítési lista', 'Tiszta textíliák', 'Ellenőrzőfotó eszköze'],
    steps: ['Töltsd fel a tulajdonos által meghatározott fogyóeszközöket.', 'Nézd meg az ágyakat, párnákat, függönyöket, tükröket és bútorokat.', 'Biztonságosan ellenőrizd az előírt berendezéseket.', 'Hibát jelents, szakképzettséget igénylő javítást ne végezz.', 'Ellenőrizd a kulcsokat, ajtókat, ablakokat, készíts zárófotót és zárd le a munkát.'],
    mistakes: ['Hiányzó bekészítés', 'Nyitva maradt ablak', 'Kulcs rossz helyen', 'Bejelentetlen műszaki hiba'],
    safety: ['Csak biztonságosan ellenőrizhető berendezést vizsgálj.', 'Javítást ne végezz szakképzettség nélkül.'],
    checklist: ['Bekészítések rendben', 'Lakás esztétikus', 'Ajtók és ablakok ellenőrizve', 'Zárófotó elkészült'],
    questions: [
      q('Ki határozza meg a bekészítéseket?', ['A tulajdonos', 'A takarító tetszőlegesen', 'A vendég'], 0, 'Az ingatlan beállításai a mérvadók.'),
      q('Ellenőrizni kell a kulcsok elhelyezését?', ['Igen', 'Nem', 'Csak nagy lakásnál'], 0, 'A biztonságos átadás része.'),
      q('Mi a munka utolsó lépése?', ['Végső ellenőrzés és lezárás', 'Azonnali távozás', 'Új feladat kezdése'], 0, 'A lezárás előtt az egész apartmant nézd át.'),
    ],
  ),
];

const academyExam = <AcademyQuestion>[
  AcademyQuestion(question: 'Miért kell külön kendőt használni a WC-hez?', options: ['Mert gyorsabb', 'A keresztszennyeződés elkerülése miatt', 'Mert szebb'], correctIndex: 1, explanation: 'A külön eszköz megakadályozza a kórokozók átvitelét.'),
  AcademyQuestion(question: 'Szabad klórtartalmú szert savas vízkőoldóval összekeverni?', options: ['Igen', 'Csak hideg vízben', 'Nem, veszélyes gáz képződhet'], correctIndex: 2, explanation: 'Soha ne keverj ilyen szereket.'),
  AcademyQuestion(question: 'Mit kell ellenőrizni a zuhanyzó tisztítása után?', options: ['Csak a csaptelepet', 'A teljes felületet, hajszálakat és lerakódásokat', 'Csak a padlót'], correctIndex: 1, explanation: 'A teljes zuhanyzó legyen tiszta és hajszálmentes.'),
  AcademyQuestion(question: 'Használható minden felületen ugyanaz a vízkőoldó?', options: ['Igen', 'Nem, figyelembe kell venni az anyagot', 'Csak forró vízzel'], correctIndex: 1, explanation: 'Az érzékeny felület károsodhat.'),
  AcademyQuestion(question: 'Mit kell ellenőrizni a konyhai gépeknél?', options: ['Csak a külsőt', 'A tisztaságot és biztonságosan ellenőrizhető állapotot', 'Semmit'], correctIndex: 1, explanation: 'A vendég által használt gépek tisztasága fontos.'),
  AcademyQuestion(question: 'Mit teszel, ha több pohár hiányzik?', options: ['Nem foglalkozom vele', 'Jelentem a hiányt', 'Másik apartmanból hozok'], correctIndex: 1, explanation: 'A hiányt dokumentálni kell.'),
  AcademyQuestion(question: 'Mi az első teendő tiszta ágynemű felhúzása előtt?', options: ['Matrac és textília ellenőrzése', 'Függöny behúzása', 'Világítás lekapcsolása'], correctIndex: 0, explanation: 'Csak tiszta, hibátlan alapra kerülhet az ágynemű.'),
  AcademyQuestion(question: 'Milyen a vendégfogadásra előkészített ágy?', options: ['Tiszta, rendezett, előírt elrendezésű', 'Csak legyen takaró', 'Mindegy'], correctIndex: 0, explanation: 'A referenciafotó szerinti rendezett összkép kell.'),
  AcademyQuestion(question: 'Milyen irányban célszerű portalanítani?', options: ['Alulról felfelé', 'Felülről lefelé', 'Véletlenszerűen'], correctIndex: 1, explanation: 'Így nem porozod vissza a felületeket.'),
  AcademyQuestion(question: 'Mit kell ellenőrizni a kanapénál?', options: ['Csak a színét', 'Párnákat, morzsákat és foltokat', 'Csak a méretét'], correctIndex: 1, explanation: 'A kanapé réseiben is maradhat szennyeződés.'),
  AcademyQuestion(question: 'Mi alapján választjuk a mosási hőmérsékletet?', options: ['Mindig a legmagasabbat', 'A kezelési címke alapján', 'Mindig 30 °C-ot'], correctIndex: 1, explanation: 'A címke védi az anyagot és meghatározza a programot.'),
  AcademyQuestion(question: 'Miért nem szabad nedves textíliát elrakni?', options: ['Mert nehezebb', 'Szag és mikrobiális szaporodás alakulhat ki', 'Mert gyűrődik'], correctIndex: 1, explanation: 'Csak teljesen száraz textíliát tárolj.'),
  AcademyQuestion(question: 'Mit ellenőrizel vendégváltás kezdetekor?', options: ['Ingatlan állapotát és a megrendelést', 'Csak az időjárást', 'Csak a díjat'], correctIndex: 0, explanation: 'Ez alapján végzed el a feladatot.'),
  AcademyQuestion(question: 'Mikor zárható le a takarítás?', options: ['Amikor a takarító elfáradt', 'Minden kötelező feladat és ellenőrzés után', 'Ha elfogyott a szer'], correctIndex: 1, explanation: 'Csak teljes ellenőrzés után zárható le.'),
  AcademyQuestion(question: 'Milyen legyen az ellenőrzőfotó?', options: ['Homályos', 'Éles, megvilágított és összehasonlítható', 'Bármilyen'], correctIndex: 1, explanation: 'A releváns területnek jól látszania kell.'),
  AcademyQuestion(question: 'Mit teszel sérült bútor esetén?', options: ['Elrejtem', 'Dokumentálom és jelentem', 'Kidobom'], correctIndex: 1, explanation: 'Fotóval és rövid leírással jelentsd.'),
  AcademyQuestion(question: 'Mit teszel veszélyes, ismeretlen szennyeződésnél?', options: ['Bármilyen szerrel eltávolítom', 'Megállok, dokumentálok és intézkedést kérek', 'Figyelmen kívül hagyom'], correctIndex: 1, explanation: 'A takarító biztonsága az első.'),
  AcademyQuestion(question: 'Mit kell tenni kártevőgyanúnál?', options: ['Jelenteni kell', 'Titokban tartani', 'Illatosítót használni'], correctIndex: 0, explanation: 'A problémát dokumentálni és jelenteni kell.'),
  AcademyQuestion(question: 'Ki határozza meg a kötelező bekészítéseket?', options: ['A takarító', 'A tulajdonos', 'A korábbi vendég'], correctIndex: 1, explanation: 'Az ingatlan beállításai az irányadók.'),
  AcademyQuestion(question: 'Mit kell ellenőrizni a munka végén?', options: ['Csak a bejárati ajtót', 'Csak az ágyakat', 'A teljes apartmant és lezárási előírásokat'], correctIndex: 2, explanation: 'A teljes körű végellenőrzés elengedhetetlen.'),
];

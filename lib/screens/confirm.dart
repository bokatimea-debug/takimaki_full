import 'package:flutter/material.dart'; import '../models.dart';
class ConfirmScreen extends StatelessWidget { final OfferRequest request; final CandidateOffer offer;
  const ConfirmScreen({super.key, required this.request, required this.offer});
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Foglalás megerősítése")), body: Padding(padding: EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text("Szolgáltató: ${offer.provider.name}", style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)), SizedBox(height:8),
      Text("Szolgáltatás kezdete: ${request.formattedTime}"), Text("Cím: Budapest, ${request.district}. ker., ${request.street}"),
      SizedBox(height:12), Text("Végösszeg: ${offer.priceHuf} Ft", style: TextStyle(fontSize:16)), SizedBox(height:24),
      FilledButton.icon(icon: Icon(Icons.check_circle), label: Text("Foglalás véglegesítése"), onPressed: (){ showDialog(context: context, builder: (_)=> const AlertDialog(
        title: Text("Sikeres foglalás"), content: Text("A foglalás rögzítésre került (demó). Fizetés közvetlenül a szolgáltatónak."))); }),
      Spacer(), Text("Megjegyzés: In-app chat a 2. fázisban.", style: TextStyle(color: Color(0xFF666666))),
    ]))); }
}

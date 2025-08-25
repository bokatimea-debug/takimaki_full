import 'package:flutter/material.dart'; import '../models.dart'; import '../mock_data.dart'; import 'confirm.dart';
class OffersScreen extends StatefulWidget { final OfferRequest request; const OffersScreen({super.key, required this.request}); @override State<OffersScreen> createState()=>_OffersScreenState(); }
class _OffersScreenState extends State<OffersScreen> {
  late final List<ProviderProfile> candidates; final Map<String,TextEditingController> priceCtrls={};
  @override void initState(){ super.initState(); candidates=filterProviders(widget.request.serviceId, widget.request.district);
    for(final p in candidates){ priceCtrls[p.id]=TextEditingController(text: _suggestedPrice(p).toString()); } }
  int _suggestedPrice(ProviderProfile p){ int base=12000; if(["deep_cleaning","post_renovation"].contains(widget.request.serviceId)) base+=8000;
    if(["plumbing","electricity","gas"].contains(widget.request.serviceId)) base+=6000; base+=(p.ratingAvg*500).toInt(); if(!p.allBudapest) base+=1000; return base; }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Beérkezett ajánlatok")),
    body: candidates.isEmpty? Center(child: Text("Nincs elérhető szolgáltató a megadott időben.")) :
    ListView.builder(itemCount: candidates.length, itemBuilder:(context,i){ final p=candidates[i]; final ctrl=priceCtrls[p.id]!;
      return Card(margin: EdgeInsets.all(12), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Row(children:[ CircleAvatar(child: Text(p.name.substring(0,1))), SizedBox(width:12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(p.name, style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)), Text("⭐ ${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount}) • Válaszidő ~ ${p.avgResponse.inMinutes} perc"),
        ])) ]),
        SizedBox(height:12),
        Row(children:[ Expanded(child: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Ár (HUF)", border: OutlineInputBorder()))),
          SizedBox(width:12), FilledButton(onPressed: (){ final price=int.tryParse(ctrl.text)??_suggestedPrice(p);
            final offer=CandidateOffer(provider: p, priceHuf: price, message: "Készek vagyunk a munkára.");
            Navigator.push(context, MaterialPageRoute(builder: (_)=>ConfirmScreen(request: widget.request, offer: offer))); }, child: Text("Véglegesítés")) ]),
      ]))); })); }
}

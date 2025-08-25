import 'package:flutter/material.dart'; import '../models.dart'; import '../utils.dart';
class ProfileScreen extends StatefulWidget { final UserRole role; const ProfileScreen({super.key, required this.role}); @override State<ProfileScreen> createState()=>_ProfileScreenState(); }
class _ProfileScreenState extends State<ProfileScreen> {
  bool active=true; int negativePoints=0; int consecutiveNoShows=0; int oneStarCount=0; bool subscriptionActive=false;
  @override Widget build(BuildContext context){ final suspended=_suspensionReason()!=null; return Padding(padding: EdgeInsets.all(16), child: ListView(children:[
    ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text(widget.role==UserRole.customer? "Megrendelő profil":"Szolgáltató profil"),
      subtitle: Text(active? "Aktív":"Inaktív"), trailing: Switch(value: active, onChanged:(v)=>setState(()=>active=v))),
    Divider(), if(widget.role==UserRole.provider) _providerControls() else _customerControls(), Divider(),
    ListTile(leading: Icon(Icons.workspace_premium, color: takimakiOrange), title: Text("Előfizetés (Google Play): 3000 Ft/hó"),
      subtitle: Text(subscriptionActive? "Aktív":"Inaktív"), trailing: ElevatedButton(onPressed:()=>setState(()=>subscriptionActive=!subscriptionActive), child: Text(subscriptionActive? "Leállítás":"Aktiválás"))),
    SizedBox(height:12),
    if(suspended) Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(12)),
      child: Text(_suspensionReason()!, style: TextStyle(color: Colors.red))) else Text("Felfüggesztés: nincs", style: TextStyle(color: Colors.grey.shade700)),
  ])); }
  Widget _customerControls(){ return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
    Text("Megrendelő beállítások", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)),
    SizedBox(height:8), Text("A megrendelő profilt nem lehet felfüggeszteni/kizárni.", style: TextStyle(color: Colors.grey.shade700)),
  ]); }
  Widget _providerControls(){ return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
    Text("Szolgáltató státusz & szabályok", style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)), SizedBox(height:8),
    Row(children:[ Expanded(child: _numberTile("Negatív pontok", negativePoints, onPlus: ()=>setState(()=>negativePoints++), onMinus: ()=>setState(()=>negativePoints=(negativePoints-1).clamp(0,999)))),
      SizedBox(width:12), Expanded(child: _numberTile("Egymást követő no-show", consecutiveNoShows, onPlus: ()=>setState(()=>consecutiveNoShows++), onMinus: ()=>setState(()=>consecutiveNoShows=(consecutiveNoShows-1).clamp(0,99)))) ]),
    SizedBox(height:12), _numberTile("1★ értékelések száma", oneStarCount, onPlus: ()=>setState(()=>oneStarCount++), onMinus: ()=>setState(()=>oneStarCount=(oneStarCount-1).clamp(0,999))),
    SizedBox(height:8), Text("Szabályok: 10 pont → 14 nap felfüggesztés; 2× no-show → 14 nap felfüggesztés; 5× 1★ → felfüggesztés.", style: TextStyle(color: Colors.grey.shade700)),
  ]); }
  String? _suspensionReason(){ if(consecutiveNoShows>=2) return "2 egymást követő no-show → 14 nap felfüggesztés";
    if(oneStarCount>=5) return "5 darab 1★ értékelés után automatikus felfüggesztés"; if(negativePoints>=10) return "10 negatív pont → 14 nap felfüggesztés"; return null; }
  Widget _numberTile(String label,int value,{required VoidCallback onPlus, required VoidCallback onMinus}){ return Container(padding: EdgeInsets.all(12),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(label, style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height:8),
      Row(children:[ IconButton(onPressed:onMinus, icon: Icon(Icons.remove_circle_outline)), Text("$value", style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
        IconButton(onPressed:onPlus, icon: Icon(Icons.add_circle_outline)), ]), ])); }
}

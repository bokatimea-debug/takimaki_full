import 'dart:convert'; import 'package:flutter/material.dart'; import 'package:flutter/services.dart' show rootBundle;
import '../utils.dart'; import '../models.dart'; import 'offers.dart';
class SearchScreen extends StatefulWidget { final UserRole role; const SearchScreen({super.key, required this.role}); @override State<SearchScreen> createState()=>_SearchScreenState(); }
class _SearchScreenState extends State<SearchScreen> {
  List<Map<String,dynamic>> services=[]; String? selectedServiceId; int selectedDistrict=13; final TextEditingController streetCtrl=TextEditingController(); DateTime? startAt;
  @override void initState(){ super.initState(); _loadServices(); }
  Future<void> _loadServices() async { final raw=await rootBundle.loadString('assets/services.json'); final data=json.decode(raw);
    setState((){ services=(data['services'] as List).cast<Map<String,dynamic>>(); selectedServiceId=services.first['id'];}); }
  Future<void> _pickDateTime() async { final now=DateTime.now(); final date=await showDatePicker(context: context, firstDate: now, lastDate: now.add(Duration(days:120)), initialDate: now);
    if(date==null) return; final time=await showTimePicker(context: context, initialTime: TimeOfDay.now()); if(time==null) return;
    setState(()=> startAt=DateTime(date.year,date.month,date.day,time.hour,time.minute)); }
  @override Widget build(BuildContext context){ return Padding(padding: EdgeInsets.all(16), child: ListView(children:[
    SizedBox(height:8), Text("Szolgáltatás", style: TextStyle(color: Colors.grey.shade700)), SizedBox(height:6),
    if (services.isEmpty) LinearProgressIndicator() else DropdownButtonFormField<String>(value: selectedServiceId, onChanged:(v)=>setState(()=>selectedServiceId=v),
      items: services.map((s)=>DropdownMenuItem(value:s['id'], child: Text(s['label']))).toList() ),
    SizedBox(height:16), Text("Kerület", style: TextStyle(color: Colors.grey.shade700)), SizedBox(height:6),
    DropdownButtonFormField<int>( value: selectedDistrict, onChanged:(v)=>setState(()=>selectedDistrict=v??13),
      items: budapestDistricts.map((d)=>DropdownMenuItem(value:d, child: Text(districtLabel(d)))).toList() ),
    SizedBox(height:16), Text("Utca", style: TextStyle(color: Colors.grey.shade700)), SizedBox(height:6),
    TextField(controller: streetCtrl, decoration: InputDecoration(border: OutlineInputBorder(), hintText: "pl. Váci út 12.")),
    SizedBox(height:16), Text("Kezdés időpontja", style: TextStyle(color: Colors.grey.shade700)), SizedBox(height:6),
    Row(children:[ Expanded(child: Text(startAt==null? "nincs kiválasztva" : startAt.toString().substring(0,16))),
      FilledButton(onPressed: _pickDateTime, child: Text("Választás")), ]),
    SizedBox(height:24),
    FilledButton.icon(icon: Icon(Icons.send), label: Text("Ajánlatkérés"), onPressed: (){
      if(selectedServiceId==null || startAt==null || streetCtrl.text.trim().isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tölts ki minden mezőt!"))); return; }
      final req=OfferRequest(serviceId: selectedServiceId!, district: selectedDistrict, street: streetCtrl.text.trim(), startAt: startAt!);
      Navigator.push(context, MaterialPageRoute(builder: (_)=>OffersScreen(request: req)));
    }),
  ])); }
}

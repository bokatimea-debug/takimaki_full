import 'package:flutter/material.dart'; import '../models.dart'; import '../utils.dart';
class RoleSelectScreen extends StatelessWidget { const RoleSelectScreen({super.key});
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Szerepkör választás")), body: Padding(padding: EdgeInsets.all(16),
    child: Column(children:[ _tile(context,UserRole.customer,Icons.person_search,"Megrendelő","Keresés és rendelés"), SizedBox(height:16),
      _tile(context,UserRole.provider,Icons.engineering,"Szolgáltató","Profil és szabályok"), ]))); }
  Widget _tile(BuildContext context, UserRole role, IconData icon, String title, String subtitle){ return InkWell(onTap: ()=>Navigator.pushReplacementNamed(context,'/home',arguments: role),
    child: Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: takimakiTurquoise,width:1.2)),
      child: Row(children:[ Icon(icon,size:36,color: takimakiTurquoise), SizedBox(width:16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children:[
        Text(title,style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)), Text(subtitle), ])), Icon(Icons.chevron_right) ]))); }
}

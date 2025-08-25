import 'package:flutter/material.dart'; import '../utils.dart';
class OnboardingScreen extends StatelessWidget { const OnboardingScreen({super.key});
  @override Widget build(BuildContext context){ return Scaffold(body: SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: const[
    Icon(Icons.cleaning_services,size:96,color: takimakiOrange), SizedBox(height:16), Text("Takimaki",style: TextStyle(fontSize:28,fontWeight: FontWeight.bold)),
    SizedBox(height:8), Text("Gyors ajánlatok, megbízható szakik – Budapest",textAlign: TextAlign.center),
  ]))), floatingActionButton: FloatingActionButton.extended(onPressed: ()=>Navigator.pushReplacementNamed(context,'/role'),label: Text("Tovább"),icon: Icon(Icons.arrow_forward))); }
}

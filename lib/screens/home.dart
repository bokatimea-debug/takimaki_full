import 'package:flutter/material.dart'; import '../models.dart'; import 'search.dart'; import 'profile.dart';
class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab; UserRole role=UserRole.customer;
  @override void initState(){ super.initState(); _tab=TabController(length:2,vsync:this); }
  @override void didChangeDependencies(){ super.didChangeDependencies(); final arg=ModalRoute.of(context)?.settings.arguments; if(arg is UserRole) role=arg; }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text("Takimaki"), bottom: TabBar(controller:_tab,tabs: const[
    Tab(icon: Icon(Icons.search),text:"Keresés"), Tab(icon: Icon(Icons.person),text:"Profil") ])),
    body: TabBarView(controller:_tab, children:[ SearchScreen(role: role), ProfileScreen(role: role) ])); }
}

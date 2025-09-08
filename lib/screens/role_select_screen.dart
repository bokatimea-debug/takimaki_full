import "package:flutter/material.dart";

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szerepválasztó")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: InkWell(
                onTap: ()=> Navigator.pushReplacementNamed(context, "/register_provider"),
                child: Card(
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.home_repair_service, size: 48),
                      SizedBox(height: 12),
                      Text("Szolgáltatást kínálok", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  )),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: ()=> Navigator.pushReplacementNamed(context, "/register_customer"),
                child: Card(
                  child: Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shopping_bag, size: 48),
                      SizedBox(height: 12),
                      Text("Szolgáltatást rendelek", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

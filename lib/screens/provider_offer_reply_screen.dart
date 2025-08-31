import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});
  @override
  State<ProviderOfferReplyScreen> createState() => _State();
}

class _State extends State<ProviderOfferReplyScreen> {
  late final Map<String, dynamic> data;
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final args = ModalRoute.of(context)?.settings.arguments;
      data = (args is Map<String, dynamic>) ? args : <String, dynamic>{};
      setState(() {
        _priceCtrl.text = (data["suggested_price"] ?? "").toString();
      });
    });
  }

  String _fmtTh(int v) {
    final s = v.toString();
    final buf = <String>[];
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      buf.insert(0, s[idx]);
      if (i % 3 == 2 && idx != 0) buf.insert(0, " ");
    }
    return buf.join();
  }

  Future<void> _send() async {
    final priceRaw = int.tryParse(_priceCtrl.text.replaceAll(" ", ""));
    if (priceRaw == null || priceRaw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adj meg érvényes árat."))
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("provider_requests") ?? "[]";
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((e)=> e["id"] == data["id"]);
    if (idx >= 0) {
      list[idx]["status"] = "offered";
      list[idx]["offered_price"] = priceRaw;
      list[idx]["note"] = _noteCtrl.text.trim();
      await prefs.setString("provider_requests", json.encode(list));
    }
    if (!mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ajánlat elküldve"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlat küldése")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(data["service"] ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(data["address"] ?? ""),
            Text("${data["date"] ?? ""}  ${data["time"] ?? ""}"),
            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ajánlott ár (Ft)"),
              onChanged: (v){
                final num = int.tryParse(v.replaceAll(" ", ""));
                if (num != null) {
                  final t = _fmtTh(num);
                  _priceCtrl.value = TextEditingValue(
                    text: t,
                    selection: TextSelection.collapsed(offset: t.length),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: "Megjegyzés (opcionális)"),
            ),
            const Spacer(),
            FilledButton(onPressed: _send, child: const Text("Ajánlat elküldése")),
          ],
        ),
      ),
    );
  }
}

import "dart:convert";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});
  @override
  State<ProviderOfferReplyScreen> createState() => _ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _priceCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  Map<String, dynamic>? _req;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) setState(()=> _req = args);
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
    final raw = _priceCtrl.text.replaceAll(" ", "");
    final price = int.tryParse(raw);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adj meg érvényes árat (Ft).")));
      return;
    }
    if (_req == null) return;

    final p = await SharedPreferences.getInstance();
    final key = "provider_requests";
    final list = (json.decode(p.getString(key) ?? "[]") as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((e)=> e["id"] == _req!["id"]);
    if (idx >= 0) {
      list[idx]["status"] = "offered";
      list[idx]["offered_price"] = price;
      list[idx]["offered_price_fmt"] = _fmtTh(price);
      list[idx]["note"] = _noteCtrl.text.trim();
      await p.setString(key, json.encode(list));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ajánlat elküldve")));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final r = _req;
    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlat küldése")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: r == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(r["service"] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${r["customer"] ?? ""} • ${r["address"] ?? ""} • ${r["date"] ?? ""} ${r["time"] ?? ""}"),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Ajánlott ár (Ft)"),
                  onChanged: (v){
                    final n = int.tryParse(v.replaceAll(" ",""));
                    if (n != null) {
                      final txt = _fmtTh(n);
                      _priceCtrl.value = TextEditingValue(text: txt, selection: TextSelection.collapsed(offset: txt.length));
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
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

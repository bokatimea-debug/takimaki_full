import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "dart:convert";
import "../services/local_marketplace_store.dart";
import "../services/sanctions_store.dart";

class ProviderOfferReplyScreen extends StatefulWidget {
  const ProviderOfferReplyScreen({super.key});
  @override
  State<ProviderOfferReplyScreen> createState() => _State();
}

class _State extends State<ProviderOfferReplyScreen> {
  Map<String, dynamic> data = <String, dynamic>{};
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        data = args is Map
            ? Map<String, dynamic>.from(args)
            : <String, dynamic>{};
        _priceCtrl.text = (data["suggested_price"] ?? "").toString();
      });
    });
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
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
    if (await SanctionsStore.isProviderSuspended()) {
      final until = await SanctionsStore.providerSuspendedUntil();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "A szolgáltatói fiók ${until?.toLocal().toString().split(' ').first ?? ''}-ig fel van függesztve.",
          ),
        ),
      );
      return;
    }
    final allowed = await LocalMarketplaceStore.canProviderSendOffer();
    if (!allowed) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Előfizetés szükséges"),
          content: const Text(
            "Az első elfogadott megrendelés ingyenes. További ajánlatok küldéséhez 3 000 Ft/hó szolgáltatói előfizetés szükséges.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/subscriptions");
              },
              child: const Text("Előfizetések"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Rendben"),
            ),
          ],
        ),
      );
      return;
    }
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
    await LocalMarketplaceStore.sendOffer(
      request: data,
      price: priceRaw,
      note: _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
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

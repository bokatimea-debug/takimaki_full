import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class ProviderOfferReplyScreen extends StatefulWidget {
  final String? requestId; final Map<String, dynamic>? initial;
  const ProviderOfferReplyScreen({super.key, this.requestId, this.initial});
  @override State<ProviderOfferReplyScreen> createState()=>_ProviderOfferReplyScreenState();
}

class _ProviderOfferReplyScreenState extends State<ProviderOfferReplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override void initState() {
    super.initState();
    final m = widget.initial ?? {};
    if (m["suggestedPrice"] != null) _priceCtrl.text = "${m["suggestedPrice"]}";
    if (m["note"] != null) _noteCtrl.text = m["note"].toString();
  }
  @override void dispose(){ _priceCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final requests = FirebaseFirestore.instance.collection("requests");
    final title = (widget.initial?["serviceName"] as String?) ?? "Ajánlat küldése";
    final whenStr = (widget.initial?["whenStr"] as String?) ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Ajánlat küldése")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (whenStr.isNotEmpty) ...[ const SizedBox(height: 4), Text(whenStr), ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ajánlott ár (Ft)"),
              validator: (v)=> (v==null || int.tryParse(v)==null) ? "Adj meg számot" : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl, maxLines: 3,
              decoration: const InputDecoration(labelText: "Megjegyzés"),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context, {"ok": false}), child: const Text("Mégse"))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final offer = {
                    "price": int.parse(_priceCtrl.text),
                    "note": _noteCtrl.text.trim(),
                    "sentAt": FieldValue.serverTimestamp(),
                    "providerId": uid,
                  };
                  await requests.doc(widget.requestId).collection("offers").doc(uid).set(offer, SetOptions(merge: true));
                  if (mounted) Navigator.pop(context, {"ok": true});
                },
                child: const Text("Ajánlat küldése"),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

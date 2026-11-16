import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:takimaki_full/services/cleaning_checklist.dart';
import 'package:takimaki_full/services/local_marketplace_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Default checklist has 42 tasks and requires room photos', () {
    final tasks = CleaningChecklist.defaults();
    expect(tasks.length, 42);
    expect(tasks.where((task) => task['photoRequired'] == true).length, 5);
    for (final task in tasks) {
      task['done'] = true;
    }
    expect(CleaningChecklist.canComplete(tasks), isFalse);
  });

  test('A correction replaces the evidence and preserves the old photo', () async {
    final order = jsonEncode([
      {
        'id': 'job',
        'status': 'Teljesítve',
        'cleaning_checklist': [
          {'label': 'Fürdő', 'done': true, 'photo': 'old'},
        ],
      },
    ]);
    SharedPreferences.setMockInitialValues({
      'customer_orders': order,
      'provider_orders': order,
    });
    await LocalMarketplaceStore.reviewCleaning(
      'job', correctionIndex: 0, note: 'Az üveg még foltos.',
    );
    var current = (await LocalMarketplaceStore.providerOrders()).single;
    final tasks = CleaningChecklist.tasks(current['cleaning_checklist']);
    expect(current['status'], 'Teljesítve');
    expect(current['cleaning_quality'], 'Javítás szükséges');
    expect((current['cleaning_history'] as List).single['photo'], 'old');
    tasks.single['done'] = true;
    await expectLater(
      LocalMarketplaceStore.saveChecklist('job', tasks), throwsStateError,
    );
    tasks.single['photo'] = 'new';
    await LocalMarketplaceStore.saveChecklist('job', tasks);
    current = (await LocalMarketplaceStore.customerOrders()).single;
    expect(current['cleaning_quality'], 'Újraellenőrzésre vár');
    await LocalMarketplaceStore.reviewCleaning('job');
    expect((await LocalMarketplaceStore.providerOrders()).single['cleaning_quality'],
        'Elfogadva');
  });
}

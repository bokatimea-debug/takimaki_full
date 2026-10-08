import '../services/workflow_store.dart';

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../utils/profile_photo_loader.dart";
import "../services/local_marketplace_store.dart";
import "../services/local_chat_store.dart";
import "../services/sanctions_store.dart";
import "../theme.dart";
import "../widgets/branded_background.dart";

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});
  @override
  State<CustomerProfileScreen> createState() => _S();
}

class _S extends State<CustomerProfileScreen> {
  ImageProvider? _photo;
  String _name = "";
  String _bio = "";
  int _success = 0;
  double _rating = 0;
  int _ticketCount = 0;
  int _unreadNoticeCount = 0;
  int _unreadMessageCount = 0;
  int _unreadOfferCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await WorkflowStore.refreshRatingSummary('customer');
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny(role: 'customer');
    final tickets = await WorkflowStore.ownTickets('customer');
    final unreadNotices = await WorkflowStore.unreadNotificationCount(
      'customer',
    );
    final unreadMessages = await LocalChatStore.unreadCount('customer');
    final unreadOffers = await WorkflowStore.unreadCountByTitle(
      'customer',
      'Új ajánlat érkezett',
    );
    final first =
        prefs.getString("customer_first_name") ??
        prefs.getString("registration_first_name") ??
        "";
    final last =
        prefs.getString("customer_last_name") ??
        prefs.getString("registration_last_name") ??
        "";
    if (!mounted) return;
    setState(() {
      _photo = p;
      _name = [last, first].where((e) => e.trim().isNotEmpty).join(" ");
      _bio = prefs.getString("customer_bio") ?? "";
      _success = prefs.getInt("customer_success_count") ?? 0;
      _rating = prefs.getDouble("customer_rating") ?? 0;
      _ticketCount = tickets.length;
      _unreadNoticeCount = unreadNotices;
      _unreadMessageCount = unreadMessages;
      _unreadOfferCount = unreadOffers;
    });
  }

  Future<void> _newOrder() async {
    if (await SanctionsStore.isCustomerSuspended()) {
      final until = await SanctionsStore.customerSuspendedUntil();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Fiók felfüggesztve"),
          content: Text(
            "Késői lemondások miatt ${until?.toLocal().toString().split(' ').first ?? ''}-ig nem adhatsz le új rendelést.",
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Rendben"),
            ),
          ],
        ),
      );
      return;
    }
    final allowed = await LocalMarketplaceStore.canCustomerCreateOrder();
    if (!mounted) return;
    if (allowed) {
      Navigator.pushNamed(context, "/customer/search");
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Előfizetés szükséges"),
        content: const Text(
          "A 3 hónapos ingyenes időszak lejárt. Új rendeléshez 3 000 Ft/hó megrendelői előfizetés szükséges.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscriptions');
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
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Megrendelő profil'),
      actions: [
        IconButton(
          tooltip: 'Értesítések',
          onPressed: () async {
            await Navigator.pushNamed(context, '/work_notifications');
            await _load();
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                _unreadNoticeCount > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: _unreadNoticeCount > 0 ? Colors.red : takiTealDark,
              ),
              if (_unreadNoticeCount > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: _Badge(count: _unreadNoticeCount),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Beállítások',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          tooltip: 'Szerepváltás',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/role_select',
            (route) => false,
          ),
          icon: const Icon(Icons.swap_horiz),
        ),
      ],
    ),
    body: BrandedBackground(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: takiProfileGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: takiTeal.withValues(alpha: .18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: ProfileAvatar(
                                background: _photo,
                                radius: 30,
                                childWhenEmpty: const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: takiNavy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name.isEmpty ? 'Megrendelő' : _name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (_bio.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _CustomerStat(
                                icon: Icons.star_rounded,
                                value: _rating == 0
                                    ? '–'
                                    : _rating.toStringAsFixed(1),
                                label: 'értékelés',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/customer/orders',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _CustomerStat(
                                icon: Icons.check_circle_outline,
                                value: '$_success',
                                label: 'sikeres rendelés',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/customer/orders',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _CustomerStat(
                                icon: Icons.report_outlined,
                                value: '$_ticketCount',
                                label: 'hibajegy',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/problem_tickets',
                                  arguments: 'customer',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: takiOrange,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: _newOrder,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 28, color: takiNavy),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Új rendelés',
                                    style: TextStyle(
                                      color: takiNavy,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Mondd el, miben kérsz segítséget',
                                    style: TextStyle(
                                      color: takiNavy,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: takiNavy,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Megrendelői eszközök',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: takiNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.calendar_month_outlined,
                            title: 'Naptár',
                            color: const Color(0xFF8ADFD6),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/calendar',
                              arguments: 'customer',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.receipt_long_outlined,
                            title: 'Rendeléseim',
                            badgeCount: _unreadOfferCount,
                            color: const Color(0xFFFFD76A),
                            onTap: () async {
                              await WorkflowStore.markNotificationsReadByTitle(
                                'customer',
                                'Új ajánlat érkezett',
                              );
                              if (!context.mounted) return;
                              await Navigator.pushNamed(
                                context,
                                '/customer/orders',
                              );
                              await _load();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Üzenetek',
                            badgeCount: _unreadMessageCount,
                            color: const Color(0xFF8ADFD6),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/customer/messages',
                              );
                              await _load();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MenuCard(
                            icon: Icons.person_outline_rounded,
                            title: 'Profil szerkesztése',
                            color: const Color(0xFFFFD76A),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/customer/edit_profile',
                              );
                              await _load();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CustomerStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;
  const _CustomerStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .16),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: takiOrange),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MenuCard extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;
  const _MenuCard({
    this.compact = false,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: compact ? 56 : 94),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: compact
              ? Row(
                  children: [
                    Icon(icon, color: takiNavy, size: 25),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: takiNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: takiNavy,
                      size: 20,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(icon, color: takiNavy, size: 25),
                            if (badgeCount > 0)
                              Positioned(
                                right: -10,
                                top: -9,
                                child: _Badge(count: badgeCount),
                              ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: takiNavy,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      title,
                      style: const TextStyle(
                        color: takiNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    alignment: Alignment.center,
    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    child: Text(
      count > 9 ? '9+' : '$count',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

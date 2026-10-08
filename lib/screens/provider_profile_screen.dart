import '../services/workflow_store.dart';
import '../services/local_marketplace_store.dart';
import '../services/local_chat_store.dart';

import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../utils/profile_photo_loader.dart";
import "../theme.dart";
import "../widgets/branded_background.dart";

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  @override
  State<ProviderProfileScreen> createState() => _S();
}

class _S extends State<ProviderProfileScreen> {
  ImageProvider? _photo;
  int _success = 0;
  String _name = "";
  String _bio = "";
  double _rating = 0;
  int _ticketCount = 0;
  int _newRequestCount = 0;
  int _unreadNoticeCount = 0;
  int _unreadWorkCount = 0;
  int _unreadMessageCount = 0;
  List<String> _services = [];
  String _availability = "09:00–18:00";
  String _city = 'Budapest';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await WorkflowStore.refreshRatingSummary('provider');
    final prefs = await SharedPreferences.getInstance();
    final p = await ProfilePhotoLoader.loadAny(role: 'provider');
    final tickets = await WorkflowStore.ownTickets('provider');
    final requests = await LocalMarketplaceStore.providerRequests();
    final unreadNotices = await WorkflowStore.unreadNotificationCount(
      'provider',
    );
    final unreadWorks = await WorkflowStore.unreadAcceptedWorkCount('provider');
    final unreadMessages = await LocalChatStore.unreadCount('provider');
    if (!mounted) return;
    setState(() {
      _photo = p;
      _success = prefs.getInt("provider_success_count") ?? 0;
      final first =
          prefs.getString("provider_first_name") ??
          prefs.getString("customer_first_name") ??
          prefs.getString("registration_first_name") ??
          "";
      final last =
          prefs.getString("provider_last_name") ??
          prefs.getString("customer_last_name") ??
          prefs.getString("registration_last_name") ??
          "";
      _name = [last, first].where((e) => e.trim().isNotEmpty).join(" ");
      _bio = prefs.getString("provider_bio") ?? "";
      _city =
          prefs.getString('provider_city') ??
          prefs.getString('profile_city') ??
          'Budapest';
      _rating = prefs.getDouble("provider_rating") ?? 0;
      _ticketCount = tickets.length;
      _newRequestCount = requests
          .where((request) => request['status'] != 'accepted')
          .length;
      _unreadNoticeCount = unreadNotices;
      _unreadWorkCount = unreadWorks;
      _unreadMessageCount = unreadMessages;
      final rawServices = prefs.getString("provider_services") ?? "[]";
      try {
        final decoded = (json.decode(rawServices) as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _services = decoded
            .map((item) => item["name"]?.toString() ?? "")
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
      } catch (_) {
        _services = [];
      }
      final from = prefs.getString("provider_wd_from") ?? "09:00";
      final to = prefs.getString("provider_wd_to") ?? "18:00";
      _availability = "$from–$to";
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Szolgáltató profil'),
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
                  right: -5,
                  top: -5,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadNoticeCount > 9 ? '9+' : '$_unreadNoticeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
                                    _name.isEmpty ? 'Szolgáltató' : _name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _services.isEmpty
                                        ? 'Add meg a szolgáltatásaidat'
                                        : _services.take(2).join(' • '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (_bio.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      _bio,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          '$_city • $_availability',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _ProviderStat(
                                icon: Icons.star_rounded,
                                value: _success < 5 || _rating == 0
                                    ? '–'
                                    : _rating.toStringAsFixed(1),
                                label: 'értékelés',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/provider/all_orders',
                                  arguments: 'reviews',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProviderStat(
                                icon: Icons.verified_outlined,
                                value: '$_success',
                                label: 'sikeres munka',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/provider/all_orders',
                                  arguments: 'completed',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProviderStat(
                                icon: Icons.report_outlined,
                                value: '$_ticketCount',
                                label: 'hibajegy',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/problem_tickets',
                                  arguments: 'provider',
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
                      borderRadius: BorderRadius.circular(20),
                      onTap: () =>
                          Navigator.pushNamed(context, '/provider/requests'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.notifications_active_outlined,
                                  size: 28,
                                  color: _newRequestCount > 0
                                      ? Colors.red
                                      : takiNavy,
                                ),
                                if (_newRequestCount > 0)
                                  Positioned(
                                    right: -10,
                                    top: -9,
                                    child: _RedBadge(
                                      count: _newRequestCount,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Megrendelések',
                                    style: TextStyle(
                                      color: takiNavy,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _newRequestCount > 0
                                        ? '$_newRequestCount új megrendelés vár válaszra'
                                        : 'Nincs megválaszolatlan megrendelés',
                                    style: const TextStyle(
                                      color: takiNavy,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
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
                    'Szolgáltatói eszközök',
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
                          child: _ProviderMenu(
                            icon: Icons.calendar_month_outlined,
                            title: 'Naptár',
                            color: const Color(0xFF8ADFD6),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/calendar',
                              arguments: 'provider',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProviderMenu(
                            icon: Icons.design_services_outlined,
                            title: 'Szolgáltatásaim',
                            color: const Color(0xFFFFD76A),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/provider/services',
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
                          child: _ProviderMenu(
                            icon: Icons.assignment_outlined,
                            title: 'Munkáim',
                            badgeCount: _unreadWorkCount,
                            color: const Color(0xFF8ADFD6),
                            onTap: () async {
                              await WorkflowStore.markNotificationsReadByTitle(
                                'provider',
                                'Új elfogadott munka',
                              );
                              if (!context.mounted) return;
                              await Navigator.pushNamed(
                                context,
                                '/provider/all_orders',
                              );
                              await _load();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ProviderMenu(
                            icon: Icons.chat_bubble_outline,
                            title: 'Üzenetek',
                            badgeCount: _unreadMessageCount,
                            color: const Color(0xFFFFD76A),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/provider/messages',
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
                          child: _ProviderMenu(
                            icon: Icons.person_outline,
                            title: 'Profil szerkesztése',
                            color: const Color(0xFF8ADFD6),
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                '/provider/edit_profile',
                              );
                              await _load();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox.shrink()),
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

class _ProviderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;
  const _ProviderStat({
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

class _ProviderMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;
  const _ProviderMenu({
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
        constraints: const BoxConstraints(minHeight: 94),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
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
                          child: _RedBadge(count: badgeCount),
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

class _RedBadge extends StatelessWidget {
  final int count;
  const _RedBadge({required this.count});
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

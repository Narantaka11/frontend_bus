import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/service/route_service.dart';
import '../../core/service/session_manager.dart';
import '../../core/service/trip_service.dart';
import '../../widgets/upcoming_journey_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../booking/bus_selection_screen.dart';
import '../profile/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // ================= USER =================
  String _userName = '';

  // ================= DATE =================
  DateTime _selectedDate = DateTime.now();

  String get formattedDate =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ================= ROUTES =================
  List<Map<String, dynamic>> _routes = [];
  List<String> _origins = [];
  List<String> _destinations = [];

  String? _from;
  String? _to;
  String? _routeId;

  // ================= UPCOMING TRIPS =================
  List<Map<String, dynamic>> _upcomingTrips = [];

  bool get _canSearch =>
      _from != null && _to != null && _from != _to && _routeId != null;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRoutes();
    _loadUpcomingTrips();
  }

  // ================= LOAD USER =================
  Future<void> _loadUser() async {
    final name = await SessionManager.getUserName();
    if (!mounted) return;
    setState(() {
      _userName = name ?? 'Pengguna';
    });
  }

  // ================= LOAD ROUTES =================
  Future<void> _loadRoutes() async {
    try {
      final data = await RouteService.getPublicRoutes();

      final origins =
          data.map((e) => e['origin'] as String).toSet().toList();
      final destinations =
          data.map((e) => e['destination'] as String).toSet().toList();

      if (!mounted) return;
      setState(() {
        _routes = data;
        _origins = origins;
        _destinations = destinations;
      });
    } catch (e) {
      debugPrint('GAGAL LOAD ROUTE: $e');
    }
  }

  // ================= LOAD UPCOMING TRIPS =================
  Future<void> _loadUpcomingTrips() async {
    try {
      final trips = await TripService.getUpcomingTrips();

      if (!mounted) return;
      setState(() {
        _upcomingTrips = trips;
      });
    } catch (e) {
      debugPrint('UPCOMING ERROR: $e');
    }
  }

  // ================= FIND ROUTE ID =================
  void _findRouteId() {
    final match = _routes.firstWhere(
      (r) => r['origin'] == _from && r['destination'] == _to,
      orElse: () => {},
    );

    setState(() {
      _routeId = match.isNotEmpty ? match['id'] : null;
    });
  }

  // ================= SWAP ROUTE =================
  void _swapRoute() {
    if (_from == null || _to == null) return;
    setState(() {
      final temp = _from;
      _from = _to;
      _to = temp;
      _findRouteId();
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              _searchCard(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Segera Berangkat',
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 12),
              _upcomingJourney(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);

          switch (index) {
            case 0:
              // Home (sudah di sini)
              break;
            case 1:
              // Bus → kembali ke Home (search card)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pilih rute dan tanggal lalu tekan "Cari Bus"'),
                ),
              );
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pilih rute dan tanggal lalu tekan "Cari Bus"'),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  // ================= UPCOMING JOURNEY WIDGET =================
  Widget _upcomingJourney() {

    if (_upcomingTrips.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Belum ada perjalanan terdekat'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _upcomingTrips.length,
      itemBuilder: (context, index) {
        final trip = _upcomingTrips[index];
        final busName = trip['bus']?['name'] ?? '-';
        final from = trip['route']?['origin'] ?? '-';
        final to = trip['route']?['destination'] ?? '-';
        final departureTime = trip['departureTime'] ?? '';


        return UpcomingJourneyCard(
        index: index + 1,
        busName: busName,
        origin: from,
        destination: to,
        departureTime: departureTime,
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orange200,
            child: const Icon(Icons.person, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo $_userName!',
                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                ),
                Text(
                  'Mau ke mana hari ini?',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          _iconBox(Icons.notifications_outlined),
        ],
      ),
    );
  }

  // ================= SEARCH CARD =================
  Widget _searchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.brown900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _dropdown('Kota Asal', _origins, _from, (v) {
              setState(() {
                _from = v;
                _findRouteId();
              });
            }),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _swapRoute,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.orangeButton,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.swap_vert,
                    color: AppColors.white, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            _dropdown('Kota Tujuan', _destinations, _to, (v) {
              setState(() {
                _to = v;
                _findRouteId();
              });
            }),
            const SizedBox(height: 20),
            _dateSelector(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSearch
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusSelectionScreen(
                              routeId: _routeId!,
                              date: formattedDate,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Cari Bus',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.brownFont),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DROPDOWN =================
  Widget _dropdown(
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    final safeValue = items.contains(value) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: safeValue,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ================= DATE SELECTOR =================
  Widget _dateSelector() {
    return Row(
      children: [
        _dateChip(
          'Hari ini',
          isSelected: _isSameDay(_selectedDate, DateTime.now()),
          onTap: () => setState(() => _selectedDate = DateTime.now()),
        ),
        const SizedBox(width: 12),
        _dateChip(
          'Besok',
          isSelected: _isSameDay(
            _selectedDate,
            DateTime.now().add(const Duration(days: 1)),
          ),
          onTap: () => setState(() =>
              _selectedDate = DateTime.now().add(const Duration(days: 1))),
        ),
        const SizedBox(width: 12),
        _dateChip(
          'Tanggal lain',
          isSelected: false,
          onTap: _pickOtherDate,
        ),
      ],
    );
  }

  Widget _dateChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.white),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.brownFont : AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickOtherDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ================= ICON BOX =================
  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.textDark),
    );
  }
}

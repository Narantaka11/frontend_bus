import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/service/route_service.dart';
import '../../core/service/session_manager.dart';

import '../../widgets/upcoming_journey_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../booking/bus_selection_screen.dart';
import '../booking/booking_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/service/booking_service.dart';

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
      if (!mounted) return;

      setState(() {
        _routes = data;
        // Populate origins only initially
        _origins = data.map((e) => e['origin'] as String).toSet().toList();
        _origins.sort(); // Optional: Sort alphabetically
      });
    } catch (e) {
      debugPrint('GAGAL LOAD ROUTE: $e');
    }
  }

  // ================= LOAD UPCOMING TRIPS =================
  Future<void> _loadUpcomingTrips() async {
    try {
      final bookings = await BookingService.getUpcomingBookings();

      if (!mounted) return;
      setState(() {
        _upcomingTrips = bookings.map((b) {
          // Safely cast trip to Map<String, dynamic>
          final rawTrip = b['trip'];
          final Map<String, dynamic> trip = (rawTrip is Map)
              ? rawTrip.map((k, v) => MapEntry(k.toString(), v))
              : <String, dynamic>{};

          return <String, dynamic>{
            ...trip,
            'bookingId': b['id'],
            'status': b['status'],
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('UPCOMING ERROR: $e');
    }
  }

  // ================= FILTER DESTINATIONS =================
  void _updateDestinations(String? origin) {
    if (origin == null) {
      setState(() {
        _destinations = [];
        _to = null;
      });
      return;
    }

    final availableDestinations = _routes
        .where((r) => r['origin'] == origin)
        .map((r) => r['destination'] as String)
        .toSet()
        .toList();

    availableDestinations.sort();

    setState(() {
      _destinations = availableDestinations;
      // Reset _to if it's no longer valid
      if (_to != null && !availableDestinations.contains(_to)) {
        _to = null;
      }
      _findRouteId();
    });
  }

  // ================= FIND ROUTE ID =================
  void _findRouteId() {
    if (_from == null || _to == null) {
      _routeId = null;
      return;
    }

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

    // Check if the swap is valid (i.e. if the new origin supports the new destination)
    // For strict logic:
    // 1. Set new From = old To
    // 2. Update destinations for new From
    // 3. Set new To = old From (only if valid)

    final newFrom = _to;
    final newTo = _from;

    setState(() {
      _from = newFrom;
      _updateDestinations(newFrom);

      if (_destinations.contains(newTo)) {
        _to = newTo;
      } else {
        _to = null;
      }
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
                child: Text('Segera Berangkat', style: AppTextStyles.h3),
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
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
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

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BookingDetailScreen(bookingId: trip['bookingId']),
              ),
            );

            // If result is true (returned from pop), refresh the list
            if (result == true) {
              _loadUpcomingTrips();
            }
          },
          child: UpcomingJourneyCard(
            index: index + 1,
            busName: busName,
            origin: from,
            destination: to,
            departureTime: departureTime,
          ),
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
                Text('Mau ke mana hari ini?', style: AppTextStyles.caption),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.brown900,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            // FROM & TO Inputs with Swap Button
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    _dropdown('Boarding From', _origins, _from, (v) {
                      setState(() {
                        _from = v;
                        _updateDestinations(v);
                      });
                    }),
                    const SizedBox(height: 16),
                    _dropdown('Where are you going?', _destinations, _to, (v) {
                      setState(() {
                        _to = v;
                        _findRouteId();
                      });
                    }),
                  ],
                ),
                Positioned(
                  right: 24, // Positioned slightly to the right
                  child: GestureDetector(
                    onTap: _swapRoute,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.orange400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_vert,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Selection
            _dateSelector(),
            const SizedBox(height: 24),

            // Find Buses Button
            SizedBox(
              width: double.infinity,
              height: 56, // Fixed height for button
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
                  foregroundColor: AppColors.brown900,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Find Buses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown900,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3), // Light beige color for input
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          hint: Text(
            hint,
            style: TextStyle(
              color: AppColors.brown900.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
          icon: const SizedBox(), // Hide default icon
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      color: AppColors.brown900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ================= DATE SELECTOR =================
  Widget _dateSelector() {
    return Row(
      children: [
        _dateChip(
          'Today',
          isSelected: _isSameDay(_selectedDate, DateTime.now()),
          onTap: () => setState(() => _selectedDate = DateTime.now()),
        ),
        const SizedBox(width: 12),
        _dateChip(
          'Tomorrow',
          isSelected: _isSameDay(
            _selectedDate,
            DateTime.now().add(const Duration(days: 1)),
          ),
          onTap: () => setState(
            () => _selectedDate = DateTime.now().add(const Duration(days: 1)),
          ),
        ),
        const SizedBox(width: 12),
        _dateChip(
          'Other',
          icon: Icons.calendar_month_outlined,
          isSelected:
              !_isSameDay(_selectedDate, DateTime.now()) &&
              !_isSameDay(
                _selectedDate,
                DateTime.now().add(const Duration(days: 1)),
              ),
          onTap: _pickOtherDate,
        ),
      ],
    );
  }

  Widget _dateChip(
    String label, {
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brown800 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.brown700, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.brown900),
    );
  }
}

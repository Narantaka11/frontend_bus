import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/service/route_service.dart';
import '../../core/service/trip_service.dart';
import 'seat_selection_screen.dart';

class BusSelectionScreen extends StatefulWidget {
  final String routeId;
  final String date;

  const BusSelectionScreen({
    super.key,
    required this.routeId,
    required this.date,
  });

  @override
  State<BusSelectionScreen> createState() => _BusSelectionScreenState();
}

class _BusSelectionScreenState extends State<BusSelectionScreen> {
  int _currentNavIndex = 1;

  Map<String, dynamic>? _selectedRoute;
  Future<List<dynamic>>? _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load Route Details (for Header)
    final route = await RouteService.getRouteById(widget.routeId);
    if (!mounted) return;

    setState(() {
      _selectedRoute = route;
      // 2. Load Trips
      _tripsFuture = TripService.getTripsByRoute(widget.routeId, widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Redesigned Route Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.brown900,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Bus Icon
                  const Icon(
                    Icons.directions_bus_filled,
                    color: AppColors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 24),

                  // Route (Origin <-> Destination)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedRoute?['origin'] ?? 'Origin',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.orange400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _selectedRoute?['destination'] ?? 'Dest',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        formatDate(widget.date), // Using formatted date
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _selectedRoute == null
                  ? const Center(child: Text('Loading route info...'))
                  : FutureBuilder<List<dynamic>>(
                      future: _tripsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final trips = snapshot.data!;
                        if (trips.isEmpty) {
                          return const Center(
                            child: Text('No buses available'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            final bus = trip['bus'];

                            final departure = formatTime(trip['departureTime']);
                            final arrival = formatTime(trip['arrivalTime']);
                            final seatsLeft =
                                trip['availableSeats'] ?? bus['totalSeat'];
                            // Calculate duration (dummy calculation or from data)
                            // Assuming arrival > departure for sim
                            final duration = '45 Min';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildBusCard(
                                name: bus['name'],
                                busType: 'Executive', // Placeholder
                                seatConfig: 'A/C (2+2)', // Placeholder
                                departureTime: departure,
                                arrivalTime: arrival,
                                duration: duration,
                                price: 'IDR ${trip['price']}',
                                seatsLeft: seatsLeft,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SeatSelectionScreen(trip: trip),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
      ),
    );
  }

  // ================= BUS CARD =================
  Widget _buildBusCard({
    required String name,
    required String busType,
    required String seatConfig,
    required String departureTime,
    required String arrivalTime,
    required String duration,
    required String price,
    required int seatsLeft,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Section (Details)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, // e.g. DJAWA EXECUTIVE
                    style: AppTextStyles.h4.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seatConfig, // e.g. A/C (2+2)
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        departureTime,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 12,
                        height: 1,
                        color: AppColors.textGray,
                      ),
                      Text(
                        arrivalTime,
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$seatsLeft Seats left',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Right Section (Price & Info)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.orange600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _amenityIcon(Icons.wifi),
                    const SizedBox(width: 8),
                    _amenityIcon(Icons.electrical_services),
                    const SizedBox(width: 8),
                    _amenityIcon(Icons.chair),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amenityIcon(IconData icon) {
    return Icon(icon, size: 16, color: AppColors.textGray.withOpacity(0.6));
  }
}

/// ================= HELPERS =================

String formatTime(String iso) {
  final dt = DateTime.parse(iso).toLocal();
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String formatDate(String iso) {
  final dt = DateTime.parse(iso).toLocal();
  return '${dt.day}-${dt.month}-${dt.year}';
}

int countAvailableSeats(List seats) {
  return seats.where((s) => s['status'] == 'AVAILABLE').length;
}

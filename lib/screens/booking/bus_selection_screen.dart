import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/service/trip_service.dart';
import '../../core/service/route_service.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildRouteSummary(),
            const SizedBox(height: 20),

            /// ================= BUS LIST =================
            Expanded(
              child: _selectedRoute == null
                  ? const Center(child: Text('Please select route'))
                  : FutureBuilder<List<dynamic>>(
                      future: _tripsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              snapshot.error.toString(),
                              style:
                                  const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final trips = snapshot.data!;
                        if (trips.isEmpty) {
                          return const Center(
                              child: Text('No buses available'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            final bus = trip['bus'];

                            final departure =
                                formatTime(trip['departureTime']);
                            final arrival =
                                formatTime(trip['arrivalTime']);
                            final seatsLeft =
                                trip['availableSeats'] ?? bus['totalSeat'];


                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12),
                              child: _buildBusCard(
                                name: bus['name'],
                                totalSeat: bus['totalSeat'],
                                departureTime: departure,
                                arrivalTime: arrival,
                                price: 'IDR ${trip['price']}',
                                seatsLeft: seatsLeft,
                                seatsColor: seatsLeft > 5
                                    ? AppColors.success
                                    : AppColors.error,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SeatSelectionScreen(
                                              trip: trip),
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

  // ================= HEADER =================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orange200,
            child: Icon(Icons.person, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello!',
                    style:
                        AppTextStyles.h4.copyWith(fontSize: 16)),
                Text('Select your bus!',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          _iconBox(Icons.filter_list),
          const SizedBox(width: 12),
          _iconBox(Icons.notifications_outlined),
        ],
      ),
    );
  }

  // ================= ROUTE SUMMARY =================

  Widget _buildRouteSummary() {
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
            const Icon(Icons.directions_bus,
                size: 60, color: AppColors.white),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _routeSelector(
                  label:
                      _selectedRoute?['origin'] ?? 'From',
                ),
                const SizedBox(width: 12),
                const Icon(Icons.swap_horiz,
                    color: AppColors.orangeButton),
                const SizedBox(width: 12),
                _routeSelector(
                  label:
                      _selectedRoute?['destination'] ?? 'To',
                ),
              ],
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: _openRoutePicker,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedRoute == null
                      ? 'Tap to select route'
                      : formatDate(_selectedRoute!['createdAt']),
                  style:
                      const TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeSelector({required String label}) {
    return InkWell(
      onTap: _openRoutePicker,
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down,
              color: AppColors.white),
        ],
      ),
    );
  }

  // ================= ROUTE PICKER =================

  void _openRoutePicker() async {
    final routes = await RouteService.getPublicRoutes();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return ListTile(
              title: Text(
                  '${route['origin']} → ${route['destination']}'),
              subtitle:
                  Text('${route['distanceKm']} km'),
              onTap: () {
                setState(() {
                  _selectedRoute = route;
                  _tripsFuture =
                      TripService.getTripsByRoute(
                          route['id'],
                          widget.date);
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // ================= BUS CARD =================

  Widget _buildBusCard({
    required String name,
    required int totalSeat,
    required String departureTime,
    required String arrivalTime,
    required String price,
    required int seatsLeft,
    required Color seatsColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color:
                    AppColors.black.withOpacity(0.05),
                blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name,
                      style: AppTextStyles.h4
                          .copyWith(fontSize: 16)),
                ),
                Text(price, style: AppTextStyles.price),
              ],
            ),
            const SizedBox(height: 8),
            Text('Total $totalSeat Seats',
                style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$departureTime — $arrivalTime',
                    style: AppTextStyles.bodyMedium),
                const Spacer(),
                Text(
                  '$seatsLeft Seats left',
                  style: TextStyle(
                      color: seatsColor,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color:
                  AppColors.black.withOpacity(0.05),
              blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: AppColors.textDark),
    );
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

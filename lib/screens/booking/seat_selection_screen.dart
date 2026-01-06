import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../core/service/seat_service.dart';
import 'booking_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> trip;

  const SeatSelectionScreen({
    super.key,
    required this.trip,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  int _currentNavIndex = 1;
  String _selectedDeck = 'LOWER';

  /// seatCode yang dipilih user
  final List<String> _selectedSeats = [];

  /// seat dari backend
  late Future<List<Map<String, dynamic>>> _seatsFuture;

  @override
  void initState() {
    super.initState();

    /// AMBIL SEAT DARI BACKEND BERDASARKAN TRIP ID
    _seatsFuture = SeatService.getSeatsByTrip(widget.trip['id']);
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.trip['route'];
    final bus = widget.trip['bus'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _routeSummary(route),
            const SizedBox(height: 12),
            _busInfo(bus),
            const SizedBox(height: 20),

            /// ================= SEAT MAP =================
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _seatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final allSeats = snapshot.data ?? [];

                  if (allSeats.isEmpty) {
                    return const Center(child: Text('No seats available'));
                  }

                  final seats = _filterByDeck(allSeats);

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// SEAT GRID
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _cardDecoration(),
                              child: Column(
                                children: [
                                  _steeringWheel(),
                                  const SizedBox(height: 16),
                                  _seatGrid(seats),
                                  const SizedBox(height: 8),
                                  _deckLabel(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// LEGEND + DECK
                          Expanded(
                            child: Column(
                              children: [
                                _legend(),
                                const SizedBox(height: 12),
                                _deckToggle(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ================= CONTINUE =================
            if (_selectedSeats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailsScreen(
                            selectedSeats: _selectedSeats,
                            trip: widget.trip,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Continue (${_selectedSeats.length} seat)',
                      style: AppTextStyles.button,
                    ),
                  ),
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

  // ================= LOGIC =================

  List<Map<String, dynamic>> _filterByDeck(List<Map<String, dynamic>> seats) {
    return seats.where((seat) {
      final code = seat['seatCode'] as String;
      final row = code[0]; // A-H

      if (_selectedDeck == 'LOWER') {
        return ['A', 'B', 'C', 'D'].contains(row);
      } else {
        return ['E', 'F', 'G', 'H'].contains(row);
      }
    }).toList();
  }

  // ================= UI =================

  Widget _seatGrid(List<Map<String, dynamic>> seats) {
    return Column(
      children: List.generate(
        (seats.length / 4).ceil(),
        (row) {
          final rowSeats = seats.skip(row * 4).take(4).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rowSeats.map(_buildSeat).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeat(Map<String, dynamic> seat) {
    final seatCode = seat['seatCode'] as String;
    final isBooked = seat['isBooked'] == true;
    final isSelected = _selectedSeats.contains(seatCode);

    final color = isBooked
        ? AppColors.seatBooked
        : isSelected
            ? AppColors.seatSelected
            : AppColors.seatAvailable;

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                isSelected
                    ? _selectedSeats.remove(seatCode)
                    : _selectedSeats.add(seatCode);
              });
            },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          seatCode,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ================= SMALL UI =================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _iconBox(Icons.arrow_back),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello Nanda!',
                    style: AppTextStyles.h4.copyWith(fontSize: 16)),
                Text('Choose your seat!', style: AppTextStyles.caption),
              ],
            ),
          ),
          _iconBox(Icons.notifications_outlined),
        ],
      ),
    );
  }

  Widget _routeSummary(Map route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brown900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(route['origin'],
                style: AppTextStyles.h4.copyWith(color: AppColors.white)),
            const SizedBox(width: 12),
            const Icon(Icons.swap_horiz, color: AppColors.orangeButton),
            const SizedBox(width: 12),
            Text(route['destination'],
                style: AppTextStyles.h4.copyWith(color: AppColors.white)),
          ],
        ),
      ),
    );
  }

  Widget _busInfo(Map bus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus['name'],
                      style: AppTextStyles.h4.copyWith(fontSize: 16)),
                  Text('A/C Sleeper', style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(
              'IDR ${widget.trip['price']}',
              style: AppTextStyles.price.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _legendItem(AppColors.seatBooked, 'Booked'),
          const SizedBox(height: 8),
          _legendItem(AppColors.seatSelected, 'Your Seat'),
          const SizedBox(height: 8),
          _legendItem(AppColors.seatAvailable, 'Available'),
        ],
      ),
    );
  }

  Widget _deckToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _cardDecoration(border: true),
      child: Column(
        children: [
          _deckButton('LOWER'),
          const SizedBox(height: 4),
          _deckButton('UPPER'),
        ],
      ),
    );
  }

  Widget _deckButton(String deck) {
    final selected = _selectedDeck == deck;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeck = deck),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown900 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            deck,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _cardDecoration(),
      child: Icon(icon, color: AppColors.textDark),
    );
  }

  Widget _steeringWheel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.orange100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.album, color: AppColors.orangeButton),
    );
  }

  Widget _deckLabel() {
    return RotatedBox(
      quarterTurns: -1,
      child: Text(
        _selectedDeck,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({bool border = false}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: border ? Border.all(color: AppColors.textLight) : null,
      boxShadow: [
        BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10),
      ],
    );
  }
}

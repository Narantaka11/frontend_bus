import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../core/service/seat_service.dart';
import '../../core/service/route_service.dart';
import '../../core/service/booking_service.dart';
import 'booking_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final String? existingBookingId;
  final int? currentSeatCount;

  const SeatSelectionScreen({
    super.key,
    required this.trip,
    this.existingBookingId,
    this.currentSeatCount,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  int _currentNavIndex = 1;
  String _selectedDeck = 'LOWER';

  /// seatCode yang dipilih user
  final List<String> _selectedSeats = [];

  // Seat Data
  List<Map<String, dynamic>> _allSeats = [];
  bool _isLoadingSeats = true;

  // Boarding & Drop-off Points
  List<Map<String, dynamic>> _boardingPoints = [];
  List<Map<String, dynamic>> _dropPoints = [];
  String? _selectedBoardingPoint;
  String? _selectedDropPoint;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Fetch Seats
      final seats = await SeatService.getSeatsByTrip(widget.trip['id']);

      // 2. Fetch Terminals
      final terminals = await RouteService.getTerminals();

      final originCity = widget.trip['route']['origin'];
      final destCity = widget.trip['route']['destination'];

      if (!mounted) return;

      setState(() {
        _allSeats = seats;
        _isLoadingSeats = false;

        _boardingPoints = terminals
            .where((t) => t['city'] == originCity)
            .toList();
        _dropPoints = terminals.where((t) => t['city'] == destCity).toList();

        // Auto-select if only one option available
        if (_boardingPoints.length == 1) {
          _selectedBoardingPoint = _boardingPoints.first['name'];
        }
        if (_dropPoints.length == 1) {
          _selectedDropPoint = _dropPoints.first['name'];
        }
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _isLoadingSeats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.trip['route'];
    final bus = widget.trip['bus'];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER SECTION =================
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brown900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Top Row: Back Button (Custom)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppColors.brown900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Route Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                route['origin'],
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
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                route['destination'],
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '08th - Dec - 2024 | Sunday', // Hardcoded as per image
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bus Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bus['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'IDR ${widget.trip['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orange600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'A/C (2+2)',
                                style: const TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                '45 Min',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '9:00 AM - 9:45 AM',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '15 Seats left',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= SEAT MAP AREA =================
              Builder(
                builder: (context) {
                  if (_isLoadingSeats) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (_allSeats.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No seats available')),
                    );
                  }
                  final seats = _filterByDeck(_allSeats);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 20),
                      // Left Column: Seat Map
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  const Icon(
                                    Icons.incomplete_circle,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const [
                                  Text(
                                    "A",
                                    style: TextStyle(color: AppColors.textGray),
                                  ),
                                  Text(
                                    "B",
                                    style: TextStyle(color: AppColors.textGray),
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    "C",
                                    style: TextStyle(color: AppColors.textGray),
                                  ),
                                  Text(
                                    "D",
                                    style: TextStyle(color: AppColors.textGray),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _seatGrid(seats),
                              const SizedBox(height: 10),
                              Text(
                                _selectedDeck == 'LOWER'
                                    ? 'LOWER DECK'
                                    : 'UPPER DECK',
                                style: const TextStyle(
                                  color: AppColors.textGray,
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Column: Controls
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _legendItem(AppColors.black, 'Booked'),
                                  const SizedBox(height: 12),
                                  _legendItem(AppColors.orange400, 'Your Seat'),
                                  const SizedBox(height: 12),
                                  _legendItem(
                                    AppColors.seatAvailable,
                                    'Available',
                                  ),
                                  const SizedBox(height: 24),
                                  _deckButton('LOWER'),
                                  const SizedBox(height: 8),
                                  _deckButton('UPPER'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// ================= BOARDING & DROP POINTS =================
              _selectionPointCard(
                title: _selectedBoardingPoint ?? 'Select Boarding Point',
                icon: Icons.login,
                items: _boardingPoints,
                onSelected: (val) =>
                    setState(() => _selectedBoardingPoint = val),
              ),
              const SizedBox(height: 12),
              _selectionPointCard(
                title: _selectedDropPoint ?? 'Select Drop Point',
                icon: Icons.logout,
                items: _dropPoints,
                onSelected: (val) => setState(() => _selectedDropPoint = val),
              ),
              const SizedBox(height: 24),

              /// ================= BOOKING SUMMARY =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Seats',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _selectedSeats.isEmpty
                              ? '-'
                              : _selectedSeats.join(', '),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Fare',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'IDR ${_selectedSeats.length * widget.trip['price']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// ================= PROCEED BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _selectedSeats.isNotEmpty &&
                            _selectedBoardingPoint != null &&
                            _selectedDropPoint != null
                        ? () async {
                            // CHANGE SEAT MODE
                            if (widget.existingBookingId != null) {
                              if (_selectedSeats.length !=
                                  widget.currentSeatCount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select exactly ${widget.currentSeatCount} seats.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Changing seats...'),
                                  ),
                                );

                                await BookingService.changeBookingSeat(
                                  widget.existingBookingId!,
                                  _selectedSeats,
                                );

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Seats changed successfully!',
                                    ),
                                  ),
                                );
                                Navigator.pop(context, true);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to change seats: $e'),
                                  ),
                                );
                              }
                              return;
                            }

                            // NORMAL MODE
                            // Map codes to IDs
                            // Assuming backend returns 'id' field. If not, this will put nulls or crash.
                            // We use .firstWhere to find the matching seat object.
                            final selectedSeatIds = _selectedSeats.map((code) {
                              final seat = _allSeats.firstWhere(
                                (s) => s['seatCode'] == code,
                                orElse: () => {},
                              );
                              return seat['id'] as String? ??
                                  code; // Fallback to code if ID missing?
                              // Ideally fallback to code if ID missing, but API likely wants UUID.
                              // If ID is missing, we might have issues.
                            }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetailsScreen(
                                  trip: widget.trip,
                                  selectedSeats:
                                      _selectedSeats, // Display codes
                                  selectedSeatIds: selectedSeatIds, // API IDs
                                  boardingPoint: _selectedBoardingPoint!,
                                  dropPoint: _selectedDropPoint!,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      disabledBackgroundColor: AppColors.brown900.withOpacity(
                        0.5,
                      ),
                    ),
                    child: const Text(
                      'Proceed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
      ),
    );
  }

  Widget _selectionPointCard({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String> onSelected,
  }) {
    return GestureDetector(
      onTap: () {
        if (items.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No points available')));
          return;
        }
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Point',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...items.map((item) {
                    final name = item['name'] as String;
                    return ListTile(
                      title: Text(name),
                      onTap: () {
                        onSelected(name);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.black.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }

  // Helper method for Deck Buttons to keep code clean within new structure
  Widget _deckButton(String deck) {
    final selected = _selectedDeck == deck;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeck = deck),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brown900
              : Colors.transparent, // Active brown
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.textGray.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            deck,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC =================

  List<Map<String, dynamic>> _filterByDeck(List<Map<String, dynamic>> seats) {
    return seats.where((seat) {
      final code = seat['seatCode'] as String;
      final row = code[0]; // A-H

      // Dummy logic for lower/upper split based on row letters
      if (_selectedDeck == 'LOWER') {
        return [
          'A',
          'B',
          'C',
          'D',
          'E',
        ].contains(row); // Expanded range for demo
      } else {
        return ['F', 'G', 'H', 'I'].contains(row);
      }
    }).toList();
  }

  // ================= UI HELPERS =================

  Widget _seatGrid(List<Map<String, dynamic>> seats) {
    // Assuming 4 seats per row structure from backend
    return Column(
      children: List.generate((seats.length / 4).ceil(), (row) {
        final rowSeats = seats.skip(row * 4).take(4).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Left side (2 seats)
              if (rowSeats.isNotEmpty) _buildSeat(rowSeats[0]),
              if (rowSeats.length > 1) _buildSeat(rowSeats[1]),

              const SizedBox(width: 20), // Aisle
              // Right side (2 seats)
              if (rowSeats.length > 2) _buildSeat(rowSeats[2]),
              if (rowSeats.length > 3) _buildSeat(rowSeats[3]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSeat(Map<String, dynamic> seat) {
    final seatCode = seat['seatCode'] as String;
    final isBooked = seat['isBooked'] == true;
    final isSelected = _selectedSeats.contains(seatCode);

    Color color;
    if (isBooked) {
      color = AppColors.black; // Booked is black
    } else if (isSelected) {
      color = AppColors.orange400; // Selected is orange
    } else {
      color = AppColors.seatAvailable; // Available is gray/light
    }

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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
      ],
    );
  }
}

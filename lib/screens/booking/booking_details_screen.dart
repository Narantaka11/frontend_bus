import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'payment_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final List<String> selectedSeats; // Codes for display
  final List<String> selectedSeatIds; // IDs for API
  final String boardingPoint;
  final String dropPoint;

  const BookingDetailsScreen({
    super.key,
    required this.trip,
    required this.selectedSeats,
    required this.selectedSeatIds,
    required this.boardingPoint,
    required this.dropPoint,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int _currentNavIndex = 1;

  // Example for simple form handling of multiple passengers
  // In a real app, use Form/TextEditingControllers properly managed
  final List<Map<String, dynamic>> _passengerData = [];

  final TextEditingController _phoneController = TextEditingController(
    text: '19231382',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'shinta@gmail.coy',
  );

  @override
  void initState() {
    super.initState();
    // Initialize data for each selected seat
    for (var i = 0; i < widget.selectedSeats.length; i++) {
      _passengerData.add({
        'name': '',
        'age': '',
        'gender': 'Female', // Default
      });
    }
    // Pre-fill dummy data to match image if needed, or leave blank
    if (_passengerData.isNotEmpty) {
      _passengerData[0]['name'] = 'Nanda febriani';
      _passengerData[0]['age'] = '22';
    }
    if (_passengerData.length > 1) {
      _passengerData[1]['name'] = 'Shinta septiani';
      _passengerData[1]['age'] = '22';
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.trip['route'];

    return Scaffold(
      backgroundColor:
          AppColors.background, // Ensure we have a bg color or default white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER CARD =================
              // ================= HEADER CARD =================
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brown900,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Top Row: Back Button
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

                    // Main Info
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${route['origin']} - ${route['destination']}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'A/C (2+2)',
                                  style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTripDateTime(widget.trip),
                                  style: const TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.orange400,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${widget.boardingPoint} > ${widget.dropPoint}',
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right Bus Icon
                          const Icon(
                            Icons.directions_bus,
                            color: AppColors.white,
                            size: 80,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= TRAVELLER INFO =================
              _sectionContainer(
                title: 'Traveller Information',
                child: Column(
                  children: List.generate(
                    widget.selectedSeats.length,
                    (index) => _passengerForm(index),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ================= CONTACT INFO =================
              _sectionContainer(
                title: 'Contact Information',
                child: Column(
                  children: [
                    _inputField(controller: _phoneController),
                    const SizedBox(height: 12),
                    _inputField(controller: _emailController),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ================= BOOK NOW BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentMethodScreen(
                            trip: widget.trip,
                            selectedSeats:
                                widget.selectedSeats, // Display codes
                            selectedSeatIds: widget.selectedSeatIds, // API IDs
                            boardingPoint: widget.boardingPoint,
                            dropPoint: widget.dropPoint,
                            passengerData: _passengerData,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
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

  Widget _sectionContainer({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _passengerForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(
            'Passenger ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
        _inputField(
          hint: 'Name',
          initialValue: _passengerData[index]['name'],
          onChanged: (v) => _passengerData[index]['name'] = v,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _inputField(
                hint: 'Age',
                initialValue: _passengerData[index]['age'],
                onChanged: (v) => _passengerData[index]['age'] = v,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _genderCheckbox(index, 'Male'),
                  const SizedBox(width: 12),
                  _genderCheckbox(index, 'Female'),
                ],
              ),
            ),
          ],
        ),
        if (index < widget.selectedSeats.length - 1)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppColors.textGray),
          ),
      ],
    );
  }

  Widget _genderCheckbox(int index, String gender) {
    final isSelected = _passengerData[index]['gender'] == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _passengerData[index]['gender'] = gender;
        });
      },
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brown900 : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(gender, style: const TextStyle(color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _inputField({
    String? hint,
    String? initialValue,
    TextEditingController? controller,
    Function(String)? onChanged,
  }) {
    // If initialValue provided, careful not to conflict with controller if you add one later
    // For this simple mock, we use a stateless container wrapping a TextField if logic complex
    // Or just a styled Container simulating typical input look
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light gray bg
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller:
            controller ??
            (initialValue != null
                ? TextEditingController(text: initialValue)
                : null),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textGray),
        ),
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTripDateTime(Map<String, dynamic> trip) {
    try {
      final dep = DateTime.parse(trip['departureTime']).toLocal();
      final arr = DateTime.parse(trip['arrivalTime']).toLocal();

      final dateStr = '${dep.day}-${dep.month}-${dep.year}';
      final timeStr =
          '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')} - ${arr.hour.toString().padLeft(2, '0')}:${arr.minute.toString().padLeft(2, '0')}';

      return '$dateStr | $timeStr';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';

import '../../core/service/booking_service.dart';
import '../../core/service/payment_service.dart';
import 'booking_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final List<String> selectedSeats;
  final List<String> selectedSeatIds;
  final String boardingPoint;
  final String dropPoint;
  final List<Map<String, dynamic>> passengerData;

  const PaymentMethodScreen({
    super.key,
    required this.trip,
    required this.selectedSeats,
    required this.selectedSeatIds,
    required this.boardingPoint,
    required this.dropPoint,
    required this.passengerData,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final route = widget.trip['route'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= TOP HEADER (Brown) =================
              // ================= TOP HEADER (Brown) =================
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route['origin'] ?? 'Origin',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'A/C (2+2)',
                                  style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(widget.trip),
                                  style: const TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right Bus Icon
                          const Icon(
                            Icons.directions_bus,
                            color: AppColors.white,
                            size: 60,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CREDIT CARD FORM =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Credit Card Details',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Selection (Visual only for now)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textGray.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ), // Dashed in image, solid for simplicity or use package
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Payment\nMethod',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          // Icons (Placeholders)
                          _methodIcon(Colors.red, 'MC'),
                          const SizedBox(width: 8),
                          _methodIcon(Colors.blue, 'Visa'),
                          const SizedBox(width: 8),
                          _methodIcon(Colors.blueAccent, 'Amex'),
                          const SizedBox(width: 8),
                          _methodIcon(Colors.orange, 'Disc'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name on card
                    const Text(
                      'Name on card',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _inputField(_nameController),

                    const SizedBox(height: 16),

                    // Card number
                    const Text(
                      'Card number',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _inputField(_cardNumberController),

                    const SizedBox(height: 16),

                    // Expiration
                    const Text(
                      'Card expiration',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _dropdownButton('Month')),
                        const SizedBox(width: 16),
                        Expanded(child: _dropdownButton('Year')),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Security Code
                    const Text(
                      'Card Security Code',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _inputField(_cvvController)),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.help_outline,
                          color: AppColors.textGray,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ================= PAY NOW BUTTON =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brown900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Pay Now',
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
        currentIndex: 2, // Wallet/Payment tab conceptually
        onTap: (i) {}, // navigation logic if needed
      ),
    );
  }

  Widget _methodIcon(Color color, String text) {
    return Container(
      width: 32,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _dropdownButton(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: const TextStyle(color: AppColors.textGray)),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
        ],
      ),
    );
  }

  String _formatTime(Map<String, dynamic> trip) {
    try {
      final dep = DateTime.parse(trip['departureTime']).toLocal();
      final arr = DateTime.parse(trip['arrivalTime']).toLocal();
      return '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')} — ${arr.hour.toString().padLeft(2, '0')}:${arr.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00 — 00:00';
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      debugPrint('PAYMENT DEBUG: Starting Process');
      debugPrint('PAYMENT DEBUG: Trip ID: ${widget.trip['id']}');

      // 1. Create Booking
      final bookingRes = await BookingService.createBooking(
        tripId: widget.trip['id'],
        seatCodes: widget.selectedSeats,
        passengers: widget.passengerData,
      );

      debugPrint('PAYMENT DEBUG: Booking Response: $bookingRes');

      // Handle nested booking object if present (based on image 15)
      final bookingId = bookingRes['booking'] != null
          ? bookingRes['booking']['id']
          : bookingRes['id'];

      debugPrint('PAYMENT DEBUG: Booking ID: $bookingId');

      if (bookingId == null) {
        throw Exception(
          'Booking ID is null. Keys: ${bookingRes.keys.toList()}. Data: $bookingRes',
        );
      }

      // 2. Create Payment
      await PaymentService.createPayment(bookingId);

      if (!mounted) return;

      // 3. Navigate to Success Screen
      // In a real scenario, we might wait for a payment webhook or deep link return.
      // For now, we assume initiation = success or user completes it externally.
      if (!mounted) return;

      // We can also pass the redirectUrl to the success screen if needed,
      // but the requirement says "Payment Success Screen" appears.
      // Maybe we show the webview first?
      // Given the prompt "setelah klik button pay now akan muncul halaman success",
      // we'll navigate directly.
      // NOTE: Effectively skipping actual payment completion verification for this demo step.

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

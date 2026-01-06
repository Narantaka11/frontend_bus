import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_button.dart';
import 'traveller_info_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final List<String> selectedSeats;
  final Map<String,dynamic>trip;

  const BookingDetailsScreen({
    super.key,
    required this.selectedSeats,
    required this.trip,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  int _currentNavIndex = 1;
  String? _boardingPoint;
  String? _dropPoint;

  @override
  Widget build(BuildContext context) {
    final totalFare = widget.selectedSeats.length * 200000;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                        Text(
                          'Hello Nanda!',
                          style: AppTextStyles.h4.copyWith(fontSize: 16),
                        ),
                        Text(
                          'Confirm your booking',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  _iconBox(Icons.notifications_outlined),
                ],
              ),
            ),

            // ================= ROUTE SUMMARY =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brown900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Bogor',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.orangeButton,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Surabaya',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= BUS INFO =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perera Travels',
                            style: AppTextStyles.h4.copyWith(fontSize: 16),
                          ),
                          Text(
                            'A/C Sleeper (2+2)',
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            '9:00 AM — 9:45 AM',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'IDR 200,000',
                          style: AppTextStyles.price.copyWith(fontSize: 18),
                        ),
                        Text('45 Min', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _dropdownBox(
                      icon: Icons.location_on_outlined,
                      hint: 'Select Boarding Point',
                      value: _boardingPoint,
                      items: const ['Terminal A', 'Terminal B', 'Terminal C'],
                      onChanged: (v) => setState(() => _boardingPoint = v),
                    ),

                    const SizedBox(height: 16),

                    _dropdownBox(
                      icon: Icons.place_outlined,
                      hint: 'Select Drop Point',
                      value: _dropPoint,
                      items: const ['Terminal X', 'Terminal Y', 'Terminal Z'],
                      onChanged: (v) => setState(() => _dropPoint = v),
                    ),

                    const SizedBox(height: 24),

                    // ================= SUMMARY =================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Selected Seats'),
                              Text('Total Fare'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.selectedSeats.join(', '),
                                style: AppTextStyles.h4,
                              ),
                              Text(
                                'IDR ${totalFare.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},',
                                )}',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.brownFont,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Proceed',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TravellerInfoScreen(
                              selectedSeats: widget.selectedSeats,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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

  // ================= COMPONENTS =================

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: AppColors.textDark),
    );
  }

  Widget _dropdownBox({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brownFont),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(color: AppColors.textLight)),
              isExpanded: true,
              underline: const SizedBox(),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

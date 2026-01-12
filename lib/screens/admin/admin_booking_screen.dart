import 'package:flutter/material.dart';
import 'package:frontend_bus/core/service/booking_service.dart';
import '../../core/service/admin_service.dart';
import '../../core/service/session_manager.dart';
import '../../core/theme/app_text_styles.dart';

class AdminBookingScreen extends StatefulWidget {
  const AdminBookingScreen({super.key});

  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = AdminService.getBookings();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadBookings();
    });
  }

  // ===================== RESOLVER =====================

  String _resolveBookingStatus(Map b) {
    return (b['status'] ?? b['booking_status'] ?? 'PENDING')
        .toString()
        .toUpperCase();
  }

  String _resolvePaymentStatus(Map b) {
    return (b['payment']?['status'] ?? b['payment_status'] ?? 'PENDING')
        .toString()
        .toUpperCase();
  }

  String _resolveTotal(Map b) {
    final total =
        b['total_price'] ?? b['payment_amount'] ?? b['payment']?['amount'];
    return total != null ? total.toString() : '0';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ===================== ACTION =====================

  Future<void> _confirm(String id) async {
    setState(() => _isLoading = true);
    try {
      await AdminService.confirmBooking(id);
      await _refresh();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel(String id) async {
    setState(() => _isLoading = true);
    try {
      await BookingService.cancelBooking(id);
      await _refresh();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Bookings'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _bookingsFuture,
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

              final bookings = snapshot.data ?? [];

              if (bookings.isEmpty) {
                return const Center(child: Text('Tidak ada data booking'));
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final b = bookings[index];

                    final bookingStatus = _resolveBookingStatus(b);
                    final paymentStatus = _resolvePaymentStatus(b);
                    final total = _resolveTotal(b);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Booking #${b['id']}',
                                    style: AppTextStyles.h3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(bookingStatus),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    bookingStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _info('User', b['user']?['email'] ?? '-'),
                            _info(
                              'Trip',
                              '${b['trip']?['route']?['origin'] ?? '-'} → '
                              '${b['trip']?['route']?['destination'] ?? '-'}',
                            ),
                            _info('Status Pembayaran', paymentStatus),
                            _info('Total', 'Rp $total'),

                            const SizedBox(height: 12),

                            if (bookingStatus == 'PENDING')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : () => _confirm(
                                              b['id'].toString()),
                                      child: const Text('Confirm'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : () =>
                                              _cancel(b['id'].toString()),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // ===================== LOADING OVERLAY =====================
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/service/admin_service.dart';
import '../../core/service/session_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int _userCount = 0;
  int _bookingCount = 0;
  int _tripCount = 0;
  int _busCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        AdminService.getUsers(),
        AdminService.getBookings(),
        AdminService.getTrips(),
        AdminService.getBuses(),
      ]);

      if (mounted) {
        setState(() {
          _userCount = results[0].length;
          _bookingCount = results[1].length;
          _tripCount = results[2].length;
          _busCount = results[3].length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ringkasan Data', style: AppTextStyles.h2),
                    const SizedBox(height: 24),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          'Users',
                          _userCount.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Bookings',
                          _bookingCount.toString(),
                          Icons.book_online,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Trips',
                          _tripCount.toString(),
                          Icons.route,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Buses',
                          _busCount.toString(),
                          Icons.directions_bus,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Text('Menu Cepat', style: AppTextStyles.h2),
                    const SizedBox(height: 16),

                    _buildMenuTile(
                      'Kelola Bookings',
                      'Lihat dan kelola pesanan tiket',
                      Icons.list_alt,
                      () => Navigator.pushNamed(context, '/admin/bookings'),
                    ),
                    _buildMenuTile(
                      'Kelola Buses',
                      'Tambah atau ubah data armada bus',
                      Icons.bus_alert,
                      () => Navigator.pushNamed(context, '/admin/buses'),
                    ),
                    _buildMenuTile(
                      'Kelola Routes',
                      'Atur rute perjalanan bus',
                      Icons.map,
                      () => Navigator.pushNamed(context, '/admin/routes'),
                    ),
                    _buildMenuTile(
                      'Kelola User',
                      'Manajemen akun pengguna',
                      Icons.person_outline,
                      () => Navigator.pushNamed(context, '/admin/users'),
                    ),

                    const SizedBox(height: 8),

                    // ================= LOGOUT (PINDAH KE BAWAH) =================
                    _buildMenuTile(
                      'Logout',
                      'Keluar dari akun admin',
                      Icons.logout,
                      _handleLogout,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.h1.copyWith(color: AppColors.textDark),
              ),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.textLight.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.brownFont.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.brownFont),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGray),
      ),
    );
  }
}

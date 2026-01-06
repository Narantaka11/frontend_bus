import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/service/session_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _profileHeader(),
            const SizedBox(height: 24),
            _sectionTitle('Akun & Keamanan'),
            _menuItem('Pengaturan Akun', Icons.settings),
            _menuItem('Referral', Icons.people),
            _menuItem('Voucher Saya', Icons.confirmation_num),
            const SizedBox(height: 24),
            _sectionTitle('Umum'),
            _menuItem('Syarat & Ketentuan', Icons.description),
            _menuItem('Kebijakan Privasi', Icons.privacy_tip),
            _menuItem('Customer Service', Icons.support_agent),
            _menuItem(
              'Logout',
              Icons.logout,
              onTap: () async {
                await SessionManager.clearSession();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brown900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.orange200,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nanda Febriani', style: AppTextStyles.h4.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Verified Account', style: AppTextStyles.caption.copyWith(color: Colors.greenAccent)),
            ],
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _menuItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

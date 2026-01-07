import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/service/session_manager.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentNavIndex = 3;

  String _userName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SessionManager.getUserName();
    setState(() {
      _userName = name ?? 'Pengguna';
      _email = 'user@email.com';
    });
  }

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
            _menuItem(
              'Pengaturan Akun',
              Icons.settings,
              onTap: _openAccountSettings,
            ),
            _menuItem(
              'Referral',
              Icons.people,
              onTap: () => _showInfo(
                'Referral',
                'Gunakan kode REF123 untuk mengajak teman.',
              ),
            ),
            _menuItem(
              'Voucher Saya',
              Icons.confirmation_num,
              onTap: () => _showInfo(
                'Voucher',
                'Voucher Diskon 20%\nKode: BUS20',
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Umum'),
            _menuItem(
              'Syarat & Ketentuan',
              Icons.description,
              onTap: () => _showInfo(
                'Syarat & Ketentuan',
                'Ini adalah syarat dan ketentuan penggunaan aplikasi.',
              ),
            ),
            _menuItem(
              'Kebijakan Privasi',
              Icons.privacy_tip,
              onTap: () => _showInfo(
                'Kebijakan Privasi',
                'Data Anda aman dan tidak disalahgunakan.',
              ),
            ),
            _menuItem(
              'Customer Service',
              Icons.support_agent,
              onTap: () => _showInfo(
                'Customer Service',
                '📞 0812-3456-7890\n📧 cs@busticket.com\n📷 Instagram: @busticket',
              ),
            ),
            _menuItem(
              'Logout',
              Icons.logout,
              onTap: () async {
                await SessionManager.clearSession();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV BAR =====
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/bus');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/booking');
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }

  // ================= HEADER (CLICKABLE) =================
  Widget _profileHeader() {
    return GestureDetector(
      onTap: _showGroupInfo,
      child: Container(
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
                Text(
                  _userName,
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style:
                      AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verified Account',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= KELOMPOK =================
  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Data Kelompok', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            _memberTile('Shinta Febriyani', '19230010'),
            _memberTile('Muhammad Faiz', '19231481'),
            _memberTile('Hafid Buroiroh', '19230910'),
            _memberTile('Nanda Tri Septiani', '19231382'),
            _memberTile('Narantaka Wahyu', '19230528'),
          ],
        ),
      ),
    );
  }

  Widget _memberTile(String name, String nim) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.orange200,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text('NIM: $nim'),
    );
  }

  // ================= UI HELPERS =================
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

  void _showInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _openAccountSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AccountSettingsSheet(),
    );
  }
}

// ================= ACCOUNT SETTINGS (DUMMY) =================
class _AccountSettingsSheet extends StatefulWidget {
  const _AccountSettingsSheet();

  @override
  State<_AccountSettingsSheet> createState() => _AccountSettingsSheetState();
}

class _AccountSettingsSheetState extends State<_AccountSettingsSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(20)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengaturan Akun', style: AppTextStyles.h3),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            TextField(
              controller: _confirmController,
              obscureText: !_showPassword,
              decoration:
                  const InputDecoration(labelText: 'Konfirmasi Password'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_passwordController.text !=
                      _confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password tidak sama'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perubahan disimpan (dummy)'),
                    ),
                  );
                },
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

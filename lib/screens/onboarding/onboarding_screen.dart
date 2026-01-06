import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Selamat Datang di DJAWAKOENTJI',
      description:
          'Aplikasi untuk pemesanan bus yang mudah, jadwal, pembayaran, dan informasi perjalanan di Indonesia.',
      image: 'assets/images/bus_logo.png',
    ),
    _OnboardingData(
      title: 'Pilih Tempat Duduk Favorit Anda',
      description:
          'Pilih tempat duduk pilihan Anda dengan mudah dan nikmati perjalanan yang nyaman.',
      image: 'assets/images/bus_logo.png',
    ),
    _OnboardingData(
      title: 'Pembayaran Aman & Mudah',
      description:
          'Pembayaran aman dengan konfirmasi pemesanan instan.',
      image: 'assets/images/bus_logo.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // DOT INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? AppColors.brown900
                          : AppColors.textLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // GET STARTED BUTTON
              CustomButton(
                text: _currentPage == _pages.length - 1
                    ? 'Mulai'
                    : 'Selanjutnya',
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // CREATE ACCOUNT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar Sekarang',
                      style: AppTextStyles.link,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(_OnboardingData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // LOGO
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              data.image,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 48),

        Text(
          data.title,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            data.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brownFont,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String image;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

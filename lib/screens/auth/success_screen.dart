import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'login_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi sukses
              Image.asset(
                'assets/images/party_popper.png',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 48),

              Text(
                'Pendaftaran Berhasil!',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Kami telah mengirimkan email verifikasi. '
                  'Silakan cek kotak masuk email Anda dan ikuti instruksi '
                  'untuk memverifikasi akun.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brownFont,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Terima kasih telah mendaftar di aplikasi kami!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brownFont,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              CustomButton(
                text: 'Masuk ke Akun',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

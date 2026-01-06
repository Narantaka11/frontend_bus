import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/google_sign_in_button.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _keepSignedIn = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final data = await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );

      final token = data['token'];
      final userMap = data['user'];
      final userName = userMap['name'];
      await SessionManager.saveSession(token);
      await SessionManager.saveUserName(userName);
      print(data);
      print(data.runtimeType);
      print(data['user']);
      print(data['user'].runtimeType);


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      if (message.toLowerCase().contains('invalid')) {
        setState(() {
          _passwordError = 'Email atau Password salah';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Login', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Selamat datang kembali',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 32),
                // EMAIL
                CustomTextField(
                  label: 'Email Address',
                  hint: 'hello@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) {
                      setState(() {
                        _emailError = null;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan email dengan benar';
                    }
                    if (!value.contains('@')) {
                      return 'Masukkan email dengan benar';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // PASSWORD
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Lupa Password?',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: '••••••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      errorText: _passwordError,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan password dengan benar';
                        }
                        if (value.length < 6) {
                          return 'Password harus lebih dari 6 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // KEEP SIGNED IN
                Row(
                  children: [
                    Checkbox(
                      value: _keepSignedIn,
                      onChanged: (value) {
                        setState(() {
                          _keepSignedIn = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Tetap masuk',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.textLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('atau login dengan', style: AppTextStyles.caption),
                    ),
                    Expanded(child: Divider(color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
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
                        'Buat akun baru',
                        style: AppTextStyles.link,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

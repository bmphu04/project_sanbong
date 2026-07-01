import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'huy@fpt.edu.vn');
  final _passCtrl = TextEditingController(text: 'Password@123!');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.greenSoft,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      _showSnackBar('Đăng nhập thành công!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showSnackBar(auth.error ?? 'Đăng nhập thất bại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.sports_soccer, color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Đăng nhập', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Chào mừng bạn quay lại! Vui lòng đăng nhập để tiếp tục',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 32),
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildInput(controller: _emailCtrl, hint: 'Nhập email của bạn',
                    icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail, enabled: !_loading),
                const SizedBox(height: 18),
                _buildLabel('Mật khẩu'),
                const SizedBox(height: 8),
                _buildInput(controller: _passCtrl, hint: 'Nhập mật khẩu',
                    icon: Icons.lock_outline, obscure: _obscure,
                    enabled: !_loading, validator: _validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Quên mật khẩu?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Text('Đăng nhập'),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Hoặc đăng nhập với', style: TextStyle(fontSize: 12, color: AppColors.textHint))),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _socialButton(label: 'Google', icon: Icons.g_mobiledata,
                        color: const Color(0xFFEA4335), onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _socialButton(label: 'Facebook', icon: Icons.facebook,
                        color: const Color(0xFF1877F2), onTap: () {})),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: _loading ? null : () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Đăng ký ngay',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
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

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  Widget _buildInput({
    required TextEditingController controller,
    required String hint, required IconData icon,
    bool obscure = false, Widget? suffixIcon,
    TextInputType? keyboardType, String? Function(String?)? validator, bool enabled = true,
  }) =>
      Container(
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: TextFormField(
          controller: controller, obscureText: obscure, keyboardType: keyboardType,
          enabled: enabled, validator: validator, autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 20), suffixIcon: suffixIcon,
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
            errorBorder: InputBorder.none,
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger)),
          ),
        ),
      );

  Widget _socialButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      );
}

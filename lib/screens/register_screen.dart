import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;
  bool _loading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
    if (v.trim().length < 2) return 'Tên phải có ít nhất 2 ký tự';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v.trim())) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!RegExp(r'^\d{9,11}$').hasMatch(v.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
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

  Future<void> _handleRegister() async {
    if (!_agreed) {
      _showSnackBar('Vui lòng đồng ý với điều khoản dịch vụ', isError: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final message = await _authService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        phoneNumber: _phoneCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      _showSnackBar(message);

      // Chuyen sang man hinh OTP
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushNamed(context, '/otp', arguments: {
        'email': _emailCtrl.text.trim(),
        'fromRegister': true,
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar('Có lỗi xảy ra, vui lòng thử lại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Tạo tài khoản',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Vui lòng điền đầy đủ thông tin bên dưới',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      _buildLabel('Họ và tên'),
                      const SizedBox(height: 8),
                      _buildInput(controller: _nameCtrl, hint: 'Nhập họ và tên', icon: Icons.person_outline,
                          validator: _validateName, enabled: !_loading),
                      const SizedBox(height: 16),
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      _buildInput(controller: _emailCtrl, hint: 'Nhập email', icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress, validator: _validateEmail, enabled: !_loading),
                      const SizedBox(height: 16),
                      _buildLabel('Số điện thoại (tùy chọn)'),
                      const SizedBox(height: 8),
                      _buildInput(controller: _phoneCtrl, hint: 'Nhập số điện thoại', icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone, validator: _validatePhone, enabled: !_loading),
                      const SizedBox(height: 16),
                      _buildLabel('Mật khẩu'),
                      const SizedBox(height: 8),
                      _buildInput(controller: _passCtrl, hint: 'Tạo mật khẩu', icon: Icons.lock_outline,
                          obscure: _obscure, validator: _validatePassword, enabled: !_loading,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          )),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreed,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: _loading ? null : (v) => setState(() => _agreed = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text('Tôi đồng ý với ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text('Điều khoản dịch vụ',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ),
                                const Text(' và ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text('Chính sách bảo mật',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Đăng ký'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Đã có tài khoản? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: _loading ? null : () => Navigator.of(context).pop(),
                            child: const Text('Đăng nhập ngay',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        const Text('Đăng ký',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    ),
  );

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
}

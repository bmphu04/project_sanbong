import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/admin_daily_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  String _formatPrice(double p) {
    final s = p.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final userName = user?.name ?? 'Người dùng';
    final userEmail = user?.email ?? '';
    final walletBalance = user?.walletBalance ?? 0;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(initial, userName, userEmail, walletBalance),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (user != null) _buildUserStats(userName),
                    const SizedBox(height: 20),
                    _buildSettingsGroup(),
                    const SizedBox(height: 20),
                    if (auth.isAdmin) _buildAdminGroup(),
                    if (auth.isAdmin) const SizedBox(height: 20),
                    _buildOtherGroup(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String initial, String name, String email, double wallet) => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
    ),
    child: Row(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
          child: Center(
            child: Text(initial,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text(email,
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('${_formatPrice(wallet)}đ',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildUserStats(String name) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _StatItem(value: '0', label: 'Sân đã đặt', color: AppColors.primary),
          const _StatDivider(),
          _StatItem(value: '0.0', label: 'Đánh giá', color: AppColors.star),
          const _StatDivider(),
          _StatItem(value: _formatPrice(0), label: 'Điểm thưởng', color: AppColors.orange),
        ],
      ),
    ),
  );

  Widget _buildSettingsGroup() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _sectionTitle('Cài đặt'),
          _SettingItem(
            icon: Icons.notifications_outlined, iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
            title: 'Thông báo',
            subtitle: 'Bật/tắt thông báo',
            trailing: Switch(
              value: _notificationsEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.language, iconColor: AppColors.blue, iconBg: const Color(0xFFE3F2FD),
            title: 'Ngôn ngữ', subtitle: 'Tiếng Việt',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.shield_outlined, iconColor: AppColors.greenSoft, iconBg: const Color(0xFFE8F5E9),
            title: 'Bảo mật', subtitle: 'Đổi mật khẩu, xác thực 2 yếu tố',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.payment_outlined, iconColor: AppColors.orange, iconBg: const Color(0xFFFFF3E0),
            title: 'Phương thức thanh toán', subtitle: 'Thẻ, ví điện tử',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );

  Widget _buildAdminGroup() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _sectionTitle('Quản lý (Admin)'),
          _SettingItem(
            icon: Icons.calendar_month, iconColor: AppColors.danger, iconBg: AppColors.danger.withValues(alpha: 0.1),
            title: 'Lịch đặt hôm nay',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminDailyScreen()),
            ),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.bar_chart, iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
            title: 'Thống kê doanh thu',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
            onTap: () {},
          ),
        ],
      ),
    ),
  );

  Widget _buildOtherGroup() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _sectionTitle('Khác'),
          _SettingItem(
            icon: Icons.star_outline, iconColor: AppColors.star, iconBg: const Color(0xFFFFF8E1),
            title: 'Đánh giá ứng dụng',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.share_outlined, iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
            title: 'Chia sẻ ứng dụng',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.support_agent, iconColor: AppColors.blue, iconBg: const Color(0xFFE3F2FD),
            title: 'Hỗ trợ', subtitle: 'Liên hệ với chúng tôi',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
          const Divider(height: 1, color: AppColors.border, indent: 60),
          _SettingItem(
            icon: Icons.description_outlined, iconColor: AppColors.textSecondary, iconBg: const Color(0xFFEEEEEE),
            title: 'Điều khoản & Chính sách',
            trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );

  Widget _buildLogoutButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Đăng xuất'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary, letterSpacing: 0.5)),
    ),
  );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    ),
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: AppColors.border);
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, this.subtitle, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    ),
  );
}

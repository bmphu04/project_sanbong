import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 20),
                    _buildSettingsGroup(),
                    const SizedBox(height: 20),
                    _buildOtherGroup(context),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'nguyenvana@example.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Sửa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            _StatItem(value: '24', label: 'Sân đã đặt', color: AppColors.primary),
            _Divider(),
            _StatItem(value: '4.8', label: 'Đánh giá', color: AppColors.star),
            _Divider(),
            _StatItem(value: '1,250', label: 'Điểm thưởng', color: AppColors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _sectionTitle('Cài đặt'),
            _SettingItem(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primaryLight,
              title: 'Thông báo',
              subtitle: 'Bật/tắt thông báo',
              trailing: Switch(
                value: true,
                activeThumbColor: AppColors.primary,
                onChanged: (_) {},
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.language,
              iconColor: AppColors.blue,
              iconBg: const Color(0xFFE3F2FD),
              title: 'Ngôn ngữ',
              subtitle: 'Tiếng Việt',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.shield_outlined,
              iconColor: AppColors.greenSoft,
              iconBg: const Color(0xFFE8F5E9),
              title: 'Bảo mật',
              subtitle: 'Đổi mật khẩu, xác thực 2 yếu tố',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.payment_outlined,
              iconColor: AppColors.orange,
              iconBg: const Color(0xFFFFF3E0),
              title: 'Phương thức thanh toán',
              subtitle: 'Thẻ, ví điện tử',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherGroup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _sectionTitle('Khác'),
            _SettingItem(
              icon: Icons.star_outline,
              iconColor: AppColors.star,
              iconBg: const Color(0xFFFFF8E1),
              title: 'Đánh giá ứng dụng',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.share_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primaryLight,
              title: 'Chia sẻ ứng dụng',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.support_agent,
              iconColor: AppColors.blue,
              iconBg: const Color(0xFFE3F2FD),
              title: 'Hỗ trợ',
              subtitle: 'Liên hệ với chúng tôi',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
            const Divider(height: 1, color: AppColors.border, indent: 60),
            _SettingItem(
              icon: Icons.description_outlined,
              iconColor: AppColors.textSecondary,
              iconBg: const Color(0xFFEEEEEE),
              title: 'Điều khoản & Chính sách',
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Đăng xuất'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.border);
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
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
}
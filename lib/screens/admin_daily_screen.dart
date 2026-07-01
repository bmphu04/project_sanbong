import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api_exception.dart';
import '../models/booking.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';

class AdminDailyScreen extends StatefulWidget {
  const AdminDailyScreen({super.key});

  @override
  State<AdminDailyScreen> createState() => _AdminDailyScreenState();
}

class _AdminDailyScreenState extends State<AdminDailyScreen> {
  final _svc = AdminService();
  DateTime _selectedDate = DateTime.now();
  List<AdminBooking> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getDailyBookings(date: _selectedDate);
      setState(() { _bookings = list; _loading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'Không tải được dữ liệu'; _loading = false; });
    }
  }

  String _dateLabel(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Color _statusColor(int s) {
    switch (s) {
      case 1: return AppColors.greenSoft;
      case 2: return AppColors.danger;
      case 3: return AppColors.primary;
      default: return AppColors.orange;
    }
  }

  String _statusLabel(int s) {
    switch (s) {
      case 1: return 'Đã xác nhận';
      case 2: return 'Đã hủy';
      case 3: return 'Hoàn thành';
      default: return 'Chờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch trực ngày'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (d != null) {
                _selectedDate = d;
                _load();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _dateLabel(_selectedDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '${_bookings.length} vé',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (_bookings.isEmpty) {
      return const Center(
        child: Text('Không có đơn đặt sân nào trong ngày này', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    // Group by field
    final byField = <String, List<AdminBooking>>{};
    for (final b in _bookings) {
      final name = b.fieldInfo?.name ?? 'Sân bóng';
      byField.putIfAbsent(name, () => []).add(b);
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: byField.length,
        itemBuilder: (ctx, i) {
          final entry = byField.entries.elementAt(i);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              ...entry.value.map((b) => _buildItem(b)),
              if (i < byField.length - 1) const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(AdminBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.userInfo?.name ?? 'Khách hàng',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_hhmm(b.startTime)} - ${_hhmm(b.endTime)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  b.userInfo?.phone ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(b.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(b.status),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(b.status)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(b.finalPrice)}đ',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              Text(
                b.paymentMethod == 0 ? 'Tiền mặt' : 'Chuyển khoản',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _formatPrice(double p) {
    final s = p.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  bool _loading = true;
  String? _error;
  List<Booking> _bookings = [];
  String _cancellingId = '';

  final _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      final history = await _bookingService.getMyHistory();
      if (!mounted) return;
      setState(() { _bookings = history; _loading = false; });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Không thể tải lịch sử đặt sân'; _loading = false; });
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy đặt sân', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Bạn có chắc muốn hủy đặt sân này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Không', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hủy đặt'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancellingId = bookingId);
    try {
      final result = await _bookingService.cancelBooking(bookingId: bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadHistory();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Không thể hủy đặt sân'), backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16)),
      );
    } finally {
      if (mounted) setState(() => _cancellingId = '');
    }
  }

  String _formatPrice(double p) {
    final s = p.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed: return AppColors.greenSoft;
      case BookingStatus.pending:   return AppColors.orange;
      case BookingStatus.cancelled:  return AppColors.danger;
    }
  }

  Color _statusBg(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed: return AppColors.greenSoft.withValues(alpha: 0.12);
      case BookingStatus.pending:   return AppColors.orange.withValues(alpha: 0.12);
      case BookingStatus.cancelled: return AppColors.danger.withValues(alpha: 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? _buildError()
                      : _bookings.isEmpty
                          ? _buildEmpty()
                          : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lịch đặt của tôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(height: 4),
              Text('Xem và quản lý các đặt sân của bạn', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadHistory,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 56, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_busy, size: 64, color: AppColors.textHint),
        const SizedBox(height: 16),
        const Text('Chưa có lịch đặt sân nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Text('Hãy đặt sân để trải nghiệm dịch vụ', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
      ],
    ),
  );

  Widget _buildList() => RefreshIndicator(
    onRefresh: _loadHistory,
    color: AppColors.primary,
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _buildBookingCard(_bookings[i]),
    ),
  );

  Widget _buildBookingCard(Booking booking) {
    final isCancelling = _cancellingId == booking.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: booking.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.sports_soccer, color: booking.color, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.stadiumName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(booking.address,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusBg(booking.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(booking.status.label,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(booking.status))),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _infoChip(Icons.calendar_today_outlined, booking.dateLabel),
                    const SizedBox(width: 12),
                    _infoChip(Icons.access_time, booking.timeLabel),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoChip(Icons.payment_outlined, booking.paymentMethod.label),
                    const Spacer(),
                    Text('${_formatPrice(booking.price)}đ',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  if (booking.status == BookingStatus.pending)
                    Expanded(
                      child: TextButton(
                        onPressed: isCancelling ? null : () => _cancelBooking(booking.id),
                        child: isCancelling
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Hủy đặt sân', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (booking.status == BookingStatus.confirmed)
                    const Expanded(
                      child: TextButton(
                        onPressed: null,
                        child: Text('Đã xác nhận - Đến sân đúng giờ!',
                            style: TextStyle(color: AppColors.greenSoft, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ],
  );
}

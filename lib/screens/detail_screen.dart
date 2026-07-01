import 'package:flutter/material.dart';

import '../core/api_exception.dart';
import '../models/booking.dart';
import '../models/stadium.dart';
import '../services/booking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/amenity_chip.dart';

class DetailScreen extends StatefulWidget {
  final Stadium stadium;

  const DetailScreen({super.key, required this.stadium});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late DateTime _selectedDate;
  final Set<int> _selectedSlots = {};
  late List<DateTime> _dates;

  bool _loadingSlots = false;
  String? _slotsError;
  List<BusySlot> _busySlots = [];
  List<_SlotEntry> _slotEntries = [];
  bool _booking = false;

  final _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
    _selectedDate = _dates.first;
    _buildSlots();
    _loadBusySlots();
  }

  List<_SlotEntry> _generateSlotEntries() {
    // Sinh slot từ 06:00 - 22:00, mỗi slot 1.5h
    final entries = <_SlotEntry>[];
    for (int h = 6; h < 22; h++) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, 0);
      final end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, h, 0)
          .add(const Duration(minutes: 90));
      final label = '${h.toString().padLeft(2, '0')}:00 - ${(h + 1).toString().padLeft(2, '0')}:30';
      entries.add(_SlotEntry(start: start, end: end, label: label));
    }
    return entries;
  }

  void _buildSlots() {
    _slotEntries = _generateSlotEntries();
    _updateSlotAvailability();
  }

  void _updateSlotAvailability() {
    for (int i = 0; i < _slotEntries.length; i++) {
      final entry = _slotEntries[i];
      bool busy = false;
      for (final bs in _busySlots) {
        if (_overlaps(entry.start, entry.end, bs.startTime, bs.endTime)) {
          busy = true;
          break;
        }
      }
      _slotEntries[i] = _SlotEntry(
        start: entry.start,
        end: entry.end,
        label: entry.label,
        available: !busy,
      );
    }
  }

  bool _overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  Future<void> _loadBusySlots() async {
    setState(() { _loadingSlots = true; _slotsError = null; });
    try {
      final busy = await _bookingService.getBusySlots(
        fieldId: widget.stadium.id,
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() {
        _busySlots = busy;
        _loadingSlots = false;
      });
      _buildSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _slotsError = e.message; _loadingSlots = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _slotsError = 'Không thể tải lịch đặt'; _loadingSlots = false; });
    }
  }

  void _onDateSelected(DateTime d) {
    setState(() {
      _selectedDate = d;
      _selectedSlots.clear();
    });
    _loadBusySlots();
  }

  void _toggleSlot(int idx) {
    final slot = _slotEntries[idx];
    if (!slot.available) return;

    setState(() {
      if (_selectedSlots.contains(idx)) {
        _selectedSlots.remove(idx);
      } else {
        _selectedSlots.add(idx);
      }
    });
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

  double get _totalPrice {
    return widget.stadium.pricePerHour * 1.5 * _selectedSlots.length;
  }

  Future<void> _doBooking() async {
    if (_selectedSlots.isEmpty) return;

    final sortedIndexes = _selectedSlots.toList()..sort();
    final first = _slotEntries[sortedIndexes.first];
    final last = _slotEntries[sortedIndexes.last];

    final startTime = first.start;
    final endTime = last.end;

    setState(() => _booking = true);

    try {
      final created = await _bookingService.createBooking(
        fieldId: widget.stadium.id,
        startTime: startTime,
        endTime: endTime,
        paymentMethod: PaymentMethod.transfer,
      );

      if (!mounted) return;
      setState(() => _booking = false);

      // Neu thanh cong -> hien thi thanh cong
      _showBookingSuccessDialog(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Có lỗi xảy ra khi đặt sân'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showBookingSuccessDialog(CreatedBooking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.primary, size: 44),
              ),
              const SizedBox(height: 16),
              const Text('Đặt sân thành công!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Vui lòng thanh toán ${_formatPrice(booking.finalPrice)}đ trong 5 phút.',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Đồng ý', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[weekday - 1];
  }

  String _dateLabel(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final stadium = widget.stadium;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHero(stadium)),
                  SliverToBoxAdapter(child: _buildInfo(stadium)),
                  SliverToBoxAdapter(child: _buildAmenities(stadium)),
                  SliverToBoxAdapter(child: _buildDatePicker()),
                  SliverToBoxAdapter(child: _buildTimeSlots()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
            _buildFooter(stadium),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(Stadium stadium) => Stack(
    children: [
      Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [stadium.imageColor, stadium.imageColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _BigFieldPainter())),
            Positioned(
              right: -20, bottom: -10,
              child: Icon(Icons.sports_soccer, size: 180, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Positioned(
              left: 16, top: 16,
              child: _circleButton(Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
            ),
            Positioned(
              right: 16, top: 16,
              child: _circleButton(Icons.ios_share, onTap: () {}),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _circleButton(IconData icon, {required VoidCallback onTap}) => Material(
    color: Colors.white.withValues(alpha: 0.95),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 22, color: AppColors.textPrimary)),
    ),
  );

  Widget _buildInfo(Stadium stadium) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stadium.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(child: Text(stadium.address,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: Text(stadium.category,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.star),
                  const SizedBox(width: 4),
                  Text('${stadium.rating} (${stadium.reviewCount})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildAmenities(Stadium stadium) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tiện ích',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: stadium.amenities.map((a) => _amenityFromString(a)).toList(),
        ),
      ],
    ),
  );

  Widget _amenityFromString(String name) {
    IconData icon;
    switch (name) {
      case 'Giữ xe':    icon = Icons.local_parking; break;
      case 'Nước uống':  icon = Icons.local_drink; break;
      case 'Tủ đồ':     icon = Icons.lock_outline; break;
      case 'WiFi':       icon = Icons.wifi; break;
      case 'Căng tin':   icon = Icons.restaurant; break;
      default:           icon = Icons.check_circle_outline;
    }
    return AmenityChip(icon: icon, label: name);
  }

  Widget _buildDatePicker() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn ngày',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final d = _dates[i];
              final selected = d == _selectedDate;
              return GestureDetector(
                onTap: () => _onDateSelected(d),
                child: Container(
                  width: 58,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekdayLabel(d.weekday),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(d.day.toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(_dateLabel(d).substring(3),
                          style: TextStyle(fontSize: 11,
                              color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.textHint)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildTimeSlots() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Khung giờ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            if (_loadingSlots)
              const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 12),
        if (_slotsError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(child: Text(_slotsError!, style: const TextStyle(fontSize: 13, color: AppColors.danger))),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
            ),
            itemCount: _slotEntries.length,
            itemBuilder: (context, i) {
              final slot = _slotEntries[i];
              final selected = _selectedSlots.contains(i);
              return GestureDetector(
                onTap: () => _toggleSlot(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: !slot.available ? AppColors.background
                        : selected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: !slot.available ? AppColors.border
                          : selected ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(slot.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: !slot.available ? AppColors.textHint
                                : selected ? Colors.white : AppColors.textPrimary,
                            decoration: !slot.available ? TextDecoration.lineThrough : null)),
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );

  Widget _buildFooter(Stadium stadium) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text('${_formatPrice(_totalPrice)}đ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectedSlots.isEmpty || _booking ? null : _doBooking,
              icon: _booking
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.event_available, size: 18),
              label: Text(_booking ? 'Đang đặt...' : 'Đặt ngay'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SlotEntry {
  final DateTime start;
  final DateTime end;
  final String label;
  final bool available;

  const _SlotEntry({required this.start, required this.end, required this.label, this.available = true});
}

class _BigFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRect(Rect.fromLTWH(20, 30, size.width - 40, size.height - 60), paint);
    canvas.drawLine(Offset(size.width / 2, 30), Offset(size.width / 2, size.height - 30), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 22, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

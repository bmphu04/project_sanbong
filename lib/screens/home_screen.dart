import 'package:flutter/material.dart';

import '../models/stadium.dart';
import '../services/field_service.dart';
import '../theme/app_theme.dart';
import '../widgets/promo_banner.dart';
import '../widgets/stadium_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  bool _loading = true;
  String? _error;
  List<Stadium> _stadiums = [];

  final _fieldService = FieldService();

  final List<_Category> _categories = const [
    _Category('Tất cả', Icons.dashboard_outlined),
    _Category('Sân 5 người', Icons.sports_soccer),
    _Category('Sân 7 người', Icons.sports_soccer),
  ];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() { _loading = true; _error = null; });
    try {
      final fields = await _fieldService.getAllFields();
      if (!mounted) return;
      setState(() {
        _stadiums = fields.map((f) => f.asStadium()).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Fallback to mock data on error
      setState(() { _loading = false; });
    }
  }

  List<Stadium> get _filtered {
    if (_stadiums.isNotEmpty) {
      if (_selectedCategory == 0) return _stadiums;
      final cat = _categories[_selectedCategory].label;
      return _stadiums.where((s) => s.category == cat).toList();
    }
    // Fallback: filter mock data
    if (_selectedCategory == 0) return sampleStadiums;
    final cat = _categories[_selectedCategory].label;
    return sampleStadiums.where((s) => s.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchAndBanner()),
            SliverToBoxAdapter(child: _buildCategories()),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadFields, child: const Text('Thử lại')),
                    ],
                  ),
                ),
              )
            else ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sân gần đây',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('Xem tất cả',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => StadiumCard(stadium: items[index]),
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
    decoration: const BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vị trí của bạn', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text('TP. Hồ Chí Minh',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                ),
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSearchAndBanner() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sân bóng...', hintStyle: TextStyle(color: AppColors.textHint),
              prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const PromoBanner(),
      ],
    ),
  );

  Widget _buildCategories() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
    child: Row(
      children: List.generate(_categories.length, (i) {
        final cat = _categories[i];
        final selected = _selectedCategory == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _categories.length - 1 ? 0 : 10),
            child: Material(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedCategory = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(cat.icon, size: 22, color: selected ? Colors.white : AppColors.primary),
                      const SizedBox(height: 6),
                      Text(cat.label, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}

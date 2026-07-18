import 'package:flutter/material.dart';
import 'package:do_an/Theme/theme.dart';
import 'package:do_an/Screens/map_placeholder.dart';
import 'package:do_an/Screens/report_button.dart';
import 'package:do_an/Screens/hotline_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Biến trạng thái quản lý việc bật/tắt bản đồ nhiệt
  bool _isHeatmapMode = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Truyền biến chế độ vào MapPlaceholder
          MapPlaceholder(isHeatmapMode: _isHeatmapMode),
          _buildTopGradient(),
          _buildAppBar(context),
          _buildLayerToggle(), // Nút bật tắt bản đồ nhiệt nổi trên bản đồ
          _buildReportButton(),
        ],
      ),
    );
  }

  Widget _buildTopGradient() => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 120,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.textPrimaryColor.withValues(alpha: 0.4),
                AppTheme.textPrimaryColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),
      );

  Widget _buildAppBar(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildTitleColumn(),
              const Spacer(),
              _buildSOSButton(context),
              const SizedBox(width: 12),
              _buildStatusBadge(),
            ],
          ),
        ),
      );

  Widget _buildTitleColumn() => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('City Report', style: AppTheme.appBarTitle),
        ],
      );

  Widget _buildSOSButton(BuildContext context) => InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => HotlineSheet(),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('SOS',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _buildStatusBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.trafficGreen.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.trafficGreen.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.trafficGreen, shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Đang hoạt động',
                style: TextStyle(
                    color: AppTheme.trafficGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  // Widget nút tròn chuyển đổi chế độ Bản đồ nhiệt
  Widget _buildLayerToggle() => Positioned(
        top: 130,
        right: 16,
        child: FloatingActionButton.small(
          onPressed: () {
            setState(() {
              _isHeatmapMode = !_isHeatmapMode;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isHeatmapMode
                    ? 'Đã bật chế độ Bản đồ nhiệt mật độ'
                    : 'Đã chuyển về chế độ Đinh ghim sự cố'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: _isHeatmapMode ? Colors.orange : Colors.white,
          foregroundColor: _isHeatmapMode ? Colors.white : Colors.black87,
          child: Icon(_isHeatmapMode
              ? Icons.local_fire_department_rounded
              : Icons.layers_rounded),
        ),
      );

  Widget _buildReportButton() => const Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Center(child: ReportButton()),
      );
}

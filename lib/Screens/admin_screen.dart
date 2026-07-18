import 'package:flutter/material.dart';
import 'package:do_an/Models/report_model.dart';
import 'package:do_an/Models/user_model.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Stores/report_store.dart';
import 'package:do_an/Theme/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _store = ReportStore();
  final _auth = AuthStore();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.addListener(_onStoreChanged);
    _auth.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _store.removeListener(_onStoreChanged);
    _auth.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  // Báo cáo đang hoạt động (chưa xử lý)
  List<ReportModel> get _activeReports =>
      _store.reports.where((r) => r.status == 'active').toList();

  // Báo cáo đã xử lý xong
  List<ReportModel> get _resolvedReports =>
      _store.reports.where((r) => r.status == 'resolved').toList();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildAdminHeader(user),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.black54),
                onPressed: _confirmLogout,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryColor,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: 'Đang xảy ra (${_activeReports.length})'),
                Tab(text: 'Đã xử lý (${_resolvedReports.length})'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildReportList(_activeReports, showResolve: true),
            _buildReportList(_resolvedReports, showResolve: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(UserModel user) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF7C3AED), size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bảng quản trị',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                Text(user.name,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
            const Spacer(),
            _buildStatChip(
                '${_store.reports.length}', 'tổng', Colors.grey),
            const SizedBox(width: 8),
            _buildStatChip(
                '${_activeReports.length}', 'đang xảy ra', Colors.orange),
            const SizedBox(width: 8),
            _buildStatChip(
                '${_resolvedReports.length}', 'xong', Colors.green),
          ],
        ),
      );

  Widget _buildStatChip(String count, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      );

  Widget _buildReportList(List<ReportModel> reports,
      {required bool showResolve}) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Không có báo cáo nào',
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (_, i) => _AdminReportCard(
        report: reports[i],
        showResolve: showResolve,
        onResolve: () => _store.updateStatus(reports[i].id, 'resolved'),
        onDelete: () => _confirmDelete(reports[i]),
      ),
    );
  }

  void _confirmDelete(ReportModel report) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá báo cáo spam?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Báo cáo "${report.typeLabel}" sẽ bị xoá vĩnh viễn.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _store.deleteReport(report.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('Xoá spam'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AuthStore().logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

// ── Card báo cáo trong admin ───────────────────────────────────────────────
class _AdminReportCard extends StatelessWidget {
  final ReportModel report;
  final bool showResolve;
  final VoidCallback onResolve;
  final VoidCallback onDelete;

  const _AdminReportCard({
    required this.report,
    required this.showResolve,
    required this.onResolve,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: report.typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(report.typeIcon,
                      color: report.typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.typeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(_formatTime(report.createdAt),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _StatusTag(status: report.status),
              ],
            ),
          ),

          // Mô tả
          if (report.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(report.description,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
              ),
            ),

          // Toạ độ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  '${report.location.latitude.toStringAsFixed(5)}, '
                  '${report.location.longitude.toStringAsFixed(5)}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                // Nút xoá spam — luôn hiện
                _ActionButton(
                  label: 'Xoá spam',
                  icon: Icons.delete_rounded,
                  color: Colors.red,
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                // Nút đánh dấu đã xử lý — chỉ hiện ở tab "Đang xảy ra"
                if (showResolve)
                  _ActionButton(
                    label: 'Đã xử lý',
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                    onTap: onResolve,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      'resolved' => ('Đã xử lý', Colors.green, Icons.check_circle_rounded),
      _ => ('Đang xảy ra', Colors.orange, Icons.warning_amber_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
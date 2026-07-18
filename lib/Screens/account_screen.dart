import 'package:do_an/Screens/leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Stores/report_store.dart';
import 'package:do_an/Theme/theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = AuthStore();
  final _store = ReportStore();

  @override
  void initState() {
    super.initState();
    _auth.addListener(_refresh);
    _store.addListener(_refresh);
  }

  @override
  void dispose() {
    _auth.removeListener(_refresh);
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    final reports = _store.reports;
    final resolved = reports.where((r) => r.status == 'resolved').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(user.name, user.email),
            const SizedBox(height: 16),
            _buildPointsCard(user.points, reports.length, resolved),
            const SizedBox(height: 16),
            _buildMenuSection(),
            const SizedBox(height: 16),
            _buildLogoutButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(name,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(email,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 14, color: AppTheme.primaryColor),
                SizedBox(width: 6),
                Text('Người dùng',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(int points, int total, int resolved) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.white70, size: 18),
              SizedBox(width: 6),
              Text('Điểm thưởng tích lũy',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$points điểm',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            children: [
              _pointStat(Icons.flag_rounded, '$total', 'Báo cáo'),
              _divider(),
              _pointStat(Icons.check_circle_rounded, '$resolved', 'Đã xử lý'),
              _divider(),
              _pointStat(Icons.emoji_events_rounded,
                  '${(points / 100).floor()}', 'Cấp độ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pointStat(IconData icon, String value, String label) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3));

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _menuItem(
            icon: Icons.history_rounded,
            color: Colors.blue,
            label: 'Lịch sử báo cáo',
            subtitle: '${_store.reports.length} báo cáo',
            onTap: () {},
          ),
          _dividerLine(),
          // MENU MỚI THÊM VÀO ĐÂY
          _menuItem(
            icon: Icons.emoji_events_rounded,
            color: Colors.amber,
            label: 'Bảng xếp hạng Hiệp sĩ',
            subtitle: 'Xem ai đóng góp nhiều nhất',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              );
            },
          ),
          _dividerLine(),
          _menuItem(
            icon: Icons.location_on_rounded,
            color: Colors.orange,
            label: 'Khu vực của tôi',
            subtitle: 'TP. Hồ Chí Minh',
            onTap: () {},
          ),
          _dividerLine(),
          _menuItem(
            icon: Icons.notifications_rounded,
            color: Colors.purple,
            label: 'Thông báo',
            subtitle: 'Bật',
            onTap: () {},
          ),
          _dividerLine(),
          _menuItem(
            icon: Icons.help_outline_rounded,
            color: Colors.teal,
            label: 'Hướng dẫn sử dụng',
            subtitle: '',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      );

  Widget _dividerLine() =>
      Divider(height: 1, indent: 68, color: Colors.grey.shade100);

  Widget _buildLogoutButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      );

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _auth.logout();
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

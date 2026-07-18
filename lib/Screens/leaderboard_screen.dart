import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an/Theme/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title:
            const Text('Bảng xếp hạng đóng góp', style: AppTheme.appBarTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Đã có lỗi xảy ra khi tải dữ liệu'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu xếp hạng'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final name = userData['name'] as String? ?? 'Người dùng';
              final points = userData['points'] as int? ?? 0;
              final totalReports = userData['totalReports'] as int? ?? 0;
              final rank = index + 1;

              return _LeaderboardRow(
                rank: rank,
                name: name,
                points: points,
                totalReports: totalReports,
              );
            },
          );
        },
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final int totalReports;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.points,
    required this.totalReports,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định màu sắc và biểu tượng cho Top 3
    Color rankColor = Colors.grey.shade700;
    Widget rankWidget = Text(
      '$rank',
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: rankColor),
    );

    if (rank == 1) {
      rankColor = Colors.amber;
      rankWidget =
          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 24);
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
      rankWidget = Icon(Icons.emoji_events_rounded,
          color: Colors.grey.shade400, size: 22);
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
      rankWidget = Icon(Icons.emoji_events_rounded,
          color: Colors.brown.shade300, size: 20);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: rank <= 3
            ? Border.all(color: rankColor.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Center(child: rankWidget)),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: rankColor.withOpacity(0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                  color: rank == 1 ? Colors.amber.shade800 : rankColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã báo cáo: $totalReports sự cố',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.primaryColor),
              ),
              const Text(
                'điểm',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

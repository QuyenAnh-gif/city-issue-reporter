import 'dart:io';
import 'package:flutter/material.dart';
import 'package:do_an/Models/report_model.dart';
import 'package:do_an/Stores/report_store.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Theme/theme.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ReportStore();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Bảng tin đô thị', style: AppTheme.appBarTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final reports = store.reports;

          if (reports.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _FeedCard(report: reports[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Chưa có báo cáo nào quanh đây',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final ReportModel report;
  const _FeedCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthStore().currentUser?.id ?? '';
    final hasVoted = report.upvotedBy.contains(currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (report.description.isNotEmpty) _buildDescription(),
          if (report.imagePaths.isNotEmpty) _buildImages(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildLocationAndInteraction(context, currentUserId, hasVoted),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: report.typeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(report.typeIcon, color: report.typeColor, size: 22),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        _StatusBadge(status: report.status),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(report.description,
          style: const TextStyle(
              fontSize: 14, color: Colors.black87, height: 1.4)),
    );
  }

  Widget _buildImages() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: report.imagePaths.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: FileImage(File(report.imagePaths[index])),
                  fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationAndInteraction(
      BuildContext context, String currentUserId, bool hasVoted) {
    return Row(
      children: [
        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Nút Comment
        InkWell(
          onTap: () => _showCommentSheet(context, currentUserId),
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text('${report.comments.length}',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Nút Vote
        InkWell(
          onTap: () {
            if (currentUserId.isNotEmpty) {
              ReportStore().toggleUpvote(report.id, currentUserId);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: hasVoted
                  ? AppTheme.primaryColor.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                    hasVoted
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: hasVoted
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${report.upvotedBy.length}',
                    style: TextStyle(
                        color: hasVoted
                            ? AppTheme.primaryColor
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Khung chat bình luận
  void _showCommentSheet(BuildContext context, String currentUserId) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bình luận',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),

              // Danh sách bình luận
              if (report.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Chưa có bình luận nào. Hãy là người đầu tiên!'),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: report.comments.length,
                    itemBuilder: (context, index) {
                      final c = report.comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.2),
                          child: Text(c['userName'].toString()[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.primaryColor)),
                        ),
                        title: Text(c['userName'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(c['text'],
                            style: const TextStyle(fontSize: 14)),
                      );
                    },
                  ),
                ),

              // Khung nhập bình luận mới
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Nhập bình luận...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppTheme.primaryColor),
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty &&
                            currentUserId.isNotEmpty) {
                          final userName =
                              AuthStore().currentUser?.name ?? 'Người dùng';
                          ReportStore().addComment(report.id, currentUserId,
                              userName, commentController.text.trim());
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isResolved = status == 'resolved';
    final color = isResolved ? Colors.green : Colors.orange;
    final label = isResolved ? 'Đã xử lý' : 'Đang xảy ra';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

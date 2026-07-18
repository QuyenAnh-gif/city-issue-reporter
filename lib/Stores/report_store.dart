import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:do_an/Models/report_model.dart';

class ReportStore extends ChangeNotifier {
  static final ReportStore _instance = ReportStore._internal();
  factory ReportStore() => _instance;
  ReportStore._internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  final _firestore = FirebaseFirestore.instance;
  final List<ReportModel> _reports = [];
  StreamSubscription? _subscription;

  List<ReportModel> get reports => List.unmodifiable(_reports);

  List<ReportModel> get activeReports =>
      _reports.where((r) => r.status == 'active').toList();

  List<ReportModel> get resolvedReports =>
      _reports.where((r) => r.status == 'resolved').toList();

  List<ReportModel> getReportsByUser(String userId) =>
      _reports.where((r) => r.userId == userId).toList();

  void _startListening() {
    _subscription?.cancel();
    _subscription = _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _reports.clear();
      for (final doc in snapshot.docs) {
        try {
          _reports.add(ReportModel.fromFirestore(doc.data(), doc.id));
        } catch (e) {
          debugPrint('Lỗi parse report ${doc.id}: $e');
        }
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('Lỗi lắng nghe Firestore: $e');
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _reports.clear();
    notifyListeners();
  }

  Future<void> addReport(ReportModel report) async {
    try {
      await _firestore
          .collection('reports')
          .doc(report.id)
          .set(report.toFirestore());
    } catch (e) {
      debugPrint('Lỗi lưu báo cáo: $e');
      _reports.insert(0, report);
      notifyListeners();
    }
  }

  Future<void> updateStatus(String reportId, String newStatus) async {
    try {
      await _firestore
          .collection('reports')
          .doc(reportId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint('Lỗi cập nhật status: $e');
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(status: newStatus);
        notifyListeners();
      }
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      final report = _reports.firstWhere((r) => r.id == reportId);
      final userId = report.userId;

      final batch = _firestore.batch();

      batch.delete(_firestore.collection('reports').doc(reportId));

      if (userId.isNotEmpty) {
        final userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {
          'points': FieldValue.increment(-10),
          'totalReports': FieldValue.increment(-1),
        });
      }

      await batch.commit();
      debugPrint('Đã xoá báo cáo spam và trừ 10 điểm user $userId');
    } catch (e) {
      debugPrint('Lỗi xoá báo cáo: $e');
      _reports.removeWhere((r) => r.id == reportId);
      notifyListeners();
    }
  }

  Future<void> toggleUpvote(String reportId, String userId) async {
    try {
      final doc = _firestore.collection('reports').doc(reportId);
      final snapshot = await doc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      List<dynamic> upvotes = data['upvotedBy'] ?? [];

      if (upvotes.contains(userId)) {
        await doc.update({
          'upvotedBy': FieldValue.arrayRemove([userId])
        });
      } else {
        await doc.update({
          'upvotedBy': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      debugPrint('Lỗi vote: $e');
    }
  }

  Future<void> addComment(
      String reportId, String userId, String userName, String text) async {
    try {
      final newComment = {
        'userId': userId,
        'userName': userName,
        'text': text,
        'createdAt': Timestamp.now(),
      };
      await _firestore.collection('reports').doc(reportId).update({
        'comments': FieldValue.arrayUnion([newComment])
      });
    } catch (e) {
      debugPrint('Lỗi comment: $e');
    }
  }
}

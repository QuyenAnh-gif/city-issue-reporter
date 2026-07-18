import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:do_an/Models/user_model.dart';

class AuthStore extends ChangeNotifier {
  static final AuthStore _instance = AuthStore._internal();
  factory AuthStore() => _instance;
  AuthStore._internal() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    await _loadUserFromFirestore(firebaseUser);
  }

  Future<void> _loadUserFromFirestore(User firebaseUser) async {
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromFirestore(doc.data()!, firebaseUser.uid);
      } else {
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Người dùng',
          email: firebaseUser.email ?? '',
          role: UserRole.user,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        _currentUser = newUser;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi load user từ Firestore: $e');
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return 'Có lỗi xảy ra, thử lại sau';
    }
  }

  Future<String?> registerWithEmail(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      final newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email.trim(),
        role: UserRole.user,
      );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toFirestore());

      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return 'Có lỗi xảy ra, thử lại sau';
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Đã huỷ đăng nhập';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (e) {
      return 'Có lỗi xảy ra khi đăng nhập Google';
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> addPoints(int amount) async {
    if (_currentUser == null) return;
    final newPoints = _currentUser!.points + amount;
    final newTotal = _currentUser!.totalReports + 1;

    await _firestore.collection('users').doc(_currentUser!.id).update({
      'points': newPoints,
      'totalReports': newTotal,
    });

    _currentUser = _currentUser!.copyWith(
      points: newPoints,
      totalReports: newTotal,
    );
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'Email không tồn tại',
      'wrong-password' => 'Sai mật khẩu',
      'invalid-credential' => 'Email hoặc mật khẩu không đúng',
      'email-already-in-use' => 'Email đã được sử dụng',
      'weak-password' => 'Mật khẩu phải có ít nhất 6 ký tự',
      'invalid-email' => 'Email không hợp lệ',
      'too-many-requests' => 'Quá nhiều lần thử, vui lòng thử lại sau',
      'network-request-failed' => 'Lỗi kết nối mạng',
      _ => 'Có lỗi xảy ra ($code)',
    };
  }
}

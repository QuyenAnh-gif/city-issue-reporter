enum UserRole { user, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int points;
  final int totalReports;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.points = 0,
    this.totalReports = 0,
  });

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? 'Người dùng',
      email: data['email'] as String? ?? '',
      role:
          (data['role'] as String?) == 'admin' ? UserRole.admin : UserRole.user,
      points: (data['points'] as num?)?.toInt() ?? 0,
      totalReports: (data['totalReports'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'role': role == UserRole.admin ? 'admin' : 'user',
        'points': points,
        'totalReports': totalReports,
      };

  UserModel copyWith({int? points, int? totalReports}) => UserModel(
        id: id,
        name: name,
        email: email,
        role: role,
        points: points ?? this.points,
        totalReports: totalReports ?? this.totalReports,
      );
}

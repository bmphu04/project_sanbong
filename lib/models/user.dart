/// Model cho User (response từ GET /users/me)
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final int userRole; // 0 = user, 1 = admin
  final double walletBalance;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.userRole,
    required this.walletBalance,
  });

  bool get isAdmin => userRole == 1;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? '',
        userRole: (json['user_role'] as num?)?.toInt() ?? 0,
        walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      );
}

/// Cặp token trả về từ login/refresh
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  const AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
      );
}
/// Model cho Login Request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// Model cho Register Request
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? username;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.username,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (username != null) 'username': username,
      };
}

/// Model cho Auth Response
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int? ?? 3600,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Model cho User
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? avatar;
  final String? level;
  final int? points;
  final int? streakDays;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.avatar,
    this.level,
    this.points,
    this.streakDays,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
      level: json['level'] as String?,
      points: json['points'] as int?,
      streakDays: json['streakDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (username != null) 'username': username,
        if (avatar != null) 'avatar': avatar,
        if (level != null) 'level': level,
        if (points != null) 'points': points,
        if (streakDays != null) 'streakDays': streakDays,
      };
}

/// Model cho Google Sign-In Request
class GoogleSignInRequest {
  final String idToken;
  final String? accessToken;

  GoogleSignInRequest({
    required this.idToken,
    this.accessToken,
  });

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
      };
}


class UserProfile {
  final String id;
  final String fullName;
  final String email;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }
}

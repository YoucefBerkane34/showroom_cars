class User {
  int? id;
  String username;
  String password;
  String role;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "password": password,
        "role": role,
      };
}

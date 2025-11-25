class User {
  String? userId;
  String? userEmail;
  String? userName;
  String? userPhone;
  String? userPassword;
  String? userRegdate;

  User({
    this.userId,
    this.userEmail,
    this.userName,
    this.userPhone,
    this.userPassword,
    this.userRegdate,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id']?.toString(),
        userEmail: json['email'],
        userName: json['name'],
        userPhone: json['phone'],
        userPassword: json['password'],
        userRegdate: json['regdate'],
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': userEmail,
        'name': userName,
        'phone': userPhone,
        'password': userPassword,
        'regdate': userRegdate,
      };
}
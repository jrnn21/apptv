class User {
  User({
    required this.id,
    required this.username,
    required this.begin,
    required this.jwt,
    required this.days,
    required this.total,
    required this.listDevices,
  });

  String jwt;
  String id;
  String username;
  int days;
  String begin;
  int total;
  List<String>? listDevices;
}

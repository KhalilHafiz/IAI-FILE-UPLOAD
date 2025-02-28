
class Candidate {
  String? id;
  String name;
  String gender;
  String dob;
  String address;
  String email;
  String? password;


  Candidate({
    this.id,
    required this.name,
    required this.address,
    required this.gender,
    required this.dob,
    required this.email,
    this.password,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      gender: json['gender'],
      dob: json['dob'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'gender': gender,
      'dob': dob,
      'email': email,
      'password': password,
    };
  }
}

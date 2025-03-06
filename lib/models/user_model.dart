class AppUser {
  String? uid;
  String? name;
  String? email;
  String? role;
  String? profilePicture;
  String? phone;
  String? address;
  String? specialty;
  String? bio;
  List<String>? availability;

  AppUser({
    this.uid,
    this.name,
    this.email,
    this.role,
    this.profilePicture,
    this.phone,
    this.address,
    this.specialty,
    this.bio,
    this.availability,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profilePicture': profilePicture,
      'phone': phone,
      'address': address,
      'specialty': specialty,
      'bio': bio,
      'availability': availability,
    };
  }

  // Create User object from Map (when fetching from Firestore)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      profilePicture: map['profilePicture'],
      phone: map['phone'],
      address: map['address'],
      specialty: map['specialty'],
      bio: map['bio'],
      availability: List<String>.from(map['availability'] ?? []),
    );
  }
}

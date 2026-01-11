class OrganizerModel {
  final String id;
  final String name;
  final String location;
  final String about;
  final int followers;
  final int following;

  OrganizerModel({
    required this.id,
    required this.name,
    required this.location,
    required this.about,
    required this.followers,
    required this.following,
  });

  /// Create model from Firestore
  factory OrganizerModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return OrganizerModel(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      about: data['about'] ?? '',
      followers: int.tryParse(data['followers'].toString()) ?? 0,
      following: int.tryParse(data['following'].toString()) ?? 0,
    );
  }

  /// Convert model to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'about': about,
      'followers': followers,
      'following': following,
    };
  }
}

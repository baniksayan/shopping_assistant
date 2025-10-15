import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String firstName;

  @HiveField(1)
  String lastName;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String phoneNumber;

  @HiveField(4)
  String email;

  @HiveField(5)
  double? latitude;

  @HiveField(6)
  double? longitude;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String selectedCountry;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isLoggedIn;

  @HiveField(11)
  String? profileImagePath;

  @HiveField(12)
  String? pinCode;

  @HiveField(13)
  String? city;

  @HiveField(14)
  String? district;

  @HiveField(15)
  String? state;

  @HiveField(16)
  String? country;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.phoneNumber,
    required this.email,
    this.latitude,
    this.longitude,
    this.address,
    required this.selectedCountry,
    required this.createdAt,
    this.isLoggedIn = false,
    this.profileImagePath,
    this.pinCode,
    this.city,
    this.district,
    this.state,
    this.country,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  String get shortLocation {
    if (city != null && city!.isNotEmpty) {
      return city!;
    }
    if (address != null && address!.isNotEmpty) {
      final parts = address!.split(',');
      return parts.first.trim();
    }
    return 'Unknown Location';
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'selectedCountry': selectedCountry,
      'createdAt': createdAt.toIso8601String(),
      'isLoggedIn': isLoggedIn,
      'profileImagePath': profileImagePath,
      'pinCode': pinCode,
      'city': city,
      'district': district,
      'state': state,
      'country': country,
    };
  }
}

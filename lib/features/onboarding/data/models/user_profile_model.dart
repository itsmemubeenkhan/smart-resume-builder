import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 1)
class UserProfileModel extends UserProfile {
  @HiveField(0)
  @override
  final String fullName;
  @HiveField(1)
  @override
  final String email;
  @HiveField(2)
  @override
  final String phone;
  @HiveField(3)
  @override
  final String jobTitle;
  @HiveField(4)
  @override
  final String address;
  @HiveField(5)
  @override
  final String? selectedTemplateId;
  @HiveField(6, defaultValue: false)
  final bool isPremium;
  @HiveField(7)
  @override
  final String? profileImagePath;

  const UserProfileModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.jobTitle,
    required this.address,
    this.selectedTemplateId,
    this.isPremium = false,
    this.profileImagePath,
  }) : super(
          fullName: fullName,
          email: email,
          phone: phone,
          jobTitle: jobTitle,
          address: address,
          selectedTemplateId: selectedTemplateId,
          profileImagePath: profileImagePath,
        );
}

class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String jobTitle;
  final String address;
  final String? selectedTemplateId;
  final String? profileImagePath;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.jobTitle,
    required this.address,
    this.selectedTemplateId,
    this.profileImagePath,
  });
}

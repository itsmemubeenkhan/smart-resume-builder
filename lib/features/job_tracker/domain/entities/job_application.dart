import 'package:uuid/uuid.dart';

enum JobStatus {
  applied,
  interview,
  offer,
  rejected,
}

class JobApplication {
  final String id;
  final String company;
  final String position;
  final String location;
  final DateTime dateApplied;
  final JobStatus status;
  final String notes;

  JobApplication({
    required this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.dateApplied,
    required this.status,
    required this.notes,
  });

  factory JobApplication.create({
    required String company,
    required String position,
    required String location,
    required JobStatus status,
    required String notes,
  }) {
    return JobApplication(
      id: const Uuid().v4(),
      company: company,
      position: position,
      location: location,
      dateApplied: DateTime.now(),
      status: status,
      notes: notes,
    );
  }

  JobApplication copyWith({
    String? company,
    String? position,
    String? location,
    JobStatus? status,
    String? notes,
  }) {
    return JobApplication(
      id: id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      dateApplied: dateApplied,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

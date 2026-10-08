import 'package:hive/hive.dart';
import '../../domain/entities/job_application.dart';

part 'job_application_model.g.dart';

@HiveType(typeId: 0)
class JobApplicationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String company;

  @HiveField(2)
  final String position;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final DateTime dateApplied;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String notes;

  JobApplicationModel({
    required this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.dateApplied,
    required this.status,
    required this.notes,
  });

  factory JobApplicationModel.fromEntity(JobApplication job) {
    return JobApplicationModel(
      id: job.id,
      company: job.company,
      position: job.position,
      location: job.location,
      dateApplied: job.dateApplied,
      status: job.status.name,
      notes: job.notes,
    );
  }

  JobApplication toEntity() {
    return JobApplication(
      id: id,
      company: company,
      position: position,
      location: location,
      dateApplied: dateApplied,
      status: JobStatus.values.firstWhere((e) => e.name == status),
      notes: notes,
    );
  }
}

import '../entities/job_application.dart';

abstract class JobRepository {
  Future<List<JobApplication>> getJobs();
  Future<void> addJob(JobApplication job);
  Future<void> updateJob(JobApplication job);
  Future<void> deleteJob(String id);
}

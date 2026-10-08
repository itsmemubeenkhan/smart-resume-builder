import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_repository.dart';
import '../models/job_application_model.dart';

part 'job_repository_impl.g.dart';

class JobRepositoryImpl implements JobRepository {
  final Box<JobApplicationModel> _box;

  JobRepositoryImpl(this._box);

  @override
  Future<List<JobApplication>> getJobs() async {
    return _box.values.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addJob(JobApplication job) async {
    await _box.put(job.id, JobApplicationModel.fromEntity(job));
  }

  @override
  Future<void> updateJob(JobApplication job) async {
    await _box.put(job.id, JobApplicationModel.fromEntity(job));
  }

  @override
  Future<void> deleteJob(String id) async {
    await _box.delete(id);
  }
}

@riverpod
JobRepository jobRepository(JobRepositoryRef ref) {
  // We assume the box is opened in main.dart or we open it here lazily
  // Ideally, we should use a FutureProvider for the box, but for simplicity
  // we will throw if not opened, or handle it.
  // Better approach: Synchronous provider if we await in main, or FutureProvider.
  // Given main.dart awaits, we can access it directly if we store it.
  // However, `Hive.box` is synchronous if opened.
  
  return JobRepositoryImpl(Hive.box<JobApplicationModel>(AppConstants.jobBox));
}

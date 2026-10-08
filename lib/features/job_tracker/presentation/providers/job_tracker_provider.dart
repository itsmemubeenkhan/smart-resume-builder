import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/job_application.dart';
import '../../data/repositories/job_repository_impl.dart';

part 'job_tracker_provider.g.dart';

@riverpod
class JobTracker extends _$JobTracker {
  @override
  Future<List<JobApplication>> build() async {
    final repository = ref.watch(jobRepositoryProvider);
    return repository.getJobs();
  }

  Future<void> addJob(JobApplication job) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(jobRepositoryProvider);
      await repository.addJob(job);
      return repository.getJobs();
    });
  }

  Future<void> updateJob(JobApplication job) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(jobRepositoryProvider);
      await repository.updateJob(job);
      return repository.getJobs();
    });
  }

  Future<void> deleteJob(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(jobRepositoryProvider);
      await repository.deleteJob(id);
      return repository.getJobs();
    });
  }
}

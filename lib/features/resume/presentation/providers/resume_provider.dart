import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/resume.dart';
import '../../data/services/ai_resume_service.dart';

part 'resume_provider.g.dart';

@riverpod
class ResumeNotifier extends _$ResumeNotifier {
  @override
  FutureOr<Resume?> build() {
    return null;
  }

  Future<void> generateResume(Resume input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(aiResumeServiceProvider);
      return service.generateResume(input);
    });
  }

  void updateResume(Resume resume) {
    state = AsyncValue.data(resume);
  }
}

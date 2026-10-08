import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/resume.dart';

part 'ai_resume_service.g.dart';

abstract class AIResumeService {
  Future<Resume> generateResume(Resume input);
}

class MockAIResumeService implements AIResumeService {
  @override
  Future<Resume> generateResume(Resume input) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock AI Logic
    final summary = "Highly motivated and results-oriented ${input.jobTitle} with experience in ${input.skills.take(3).join(', ')}. "
        "Proven track record of delivering high-quality solutions. "
        "Adept at collaborating with cross-functional teams to drive project success. "
        "Seeking to leverage skills in ${input.skills.join(', ')} to contribute to a forward-thinking organization.";

    final enhancedExperience = input.experience.map((exp) {
      return WorkExperience(
        company: exp.company,
        role: exp.role,
        duration: exp.duration,
        description: "• Spearheaded key projects at ${exp.company}, resulting in 20% efficiency increase.\n"
            "• Collaborated with team members to implement robust solutions.\n"
            "• utilized ${input.skills.take(2).join(' and ')} to solve complex problems.\n"
            "• ${exp.description}", // Append original description if any
      );
    }).toList();

    return input.copyWith(
      summary: summary,
      experience: enhancedExperience,
    );
  }
}

@riverpod
AIResumeService aiResumeService(AiResumeServiceRef ref) {
  return MockAIResumeService();
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ai_resume_builder/core/constants/app_constants.dart';
import 'package:ai_resume_builder/features/onboarding/data/models/user_profile_model.dart';

import 'package:ai_resume_builder/features/home/services/activity_service.dart';
import 'package:ai_resume_builder/core/services/ad_service.dart';
import '../../domain/entities/resume.dart';
import '../providers/resume_provider.dart';

class ResumeGeneratorScreen extends ConsumerStatefulWidget {
  const ResumeGeneratorScreen({super.key});

  @override
  ConsumerState<ResumeGeneratorScreen> createState() => _ResumeGeneratorScreenState();
}

class _ResumeGeneratorScreenState extends ConsumerState<ResumeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Professional Info
  final _jobTitleController = TextEditingController();
  String _experienceLevel = 'Mid Level';
  final _skillsController = TextEditingController(); // Comma separated

  // Experience (Simplified: 1 entry for now, can be expanded)
  final _expCompanyController = TextEditingController();
  final _expRoleController = TextEditingController();
  final _expDurationController = TextEditingController();
  final _expDescController = TextEditingController();

  // Education (Simplified: 1 entry)
  final _eduSchoolController = TextEditingController();
  final _eduDegreeController = TextEditingController();
  final _eduYearController = TextEditingController();

  // Additional Details
  final _languagesController = TextEditingController(); // Comma separated
  final _interestsController = TextEditingController(); // Comma separated

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    if (!Hive.isBoxOpen(AppConstants.userProfileBox)) return;
    
    final box = Hive.box<UserProfileModel>(AppConstants.userProfileBox);
    final profile = box.get('current_profile');
    if (profile != null) {
      _nameController.text = profile.fullName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _jobTitleController.text = profile.jobTitle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _jobTitleController.dispose();
    _skillsController.dispose();
    _expCompanyController.dispose();
    _expRoleController.dispose();
    _expDurationController.dispose();
    _expDescController.dispose();
    _eduSchoolController.dispose();
    _eduDegreeController.dispose();
    _eduYearController.dispose();
    _languagesController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _generate() async {
    if (_formKey.currentState!.validate()) {
      // Get selected template from profile
      String selectedTemplate = 'modern';
      if (Hive.isBoxOpen(AppConstants.userProfileBox)) {
        final box = Hive.box<UserProfileModel>(AppConstants.userProfileBox);
        final profile = box.get('current_profile');
        if (profile?.selectedTemplateId != null) {
          selectedTemplate = profile!.selectedTemplateId!;
        }
      }

      final resume = Resume(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        linkedin: _linkedinController.text,
        jobTitle: _jobTitleController.text,
        experienceLevel: _experienceLevel,
        skills: _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        languages: _languagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        interests: _interestsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        summary: '', // To be generated
        experience: [
          WorkExperience(
            company: _expCompanyController.text,
            role: _expRoleController.text,
            duration: _expDurationController.text,
            description: _expDescController.text,
          ),
        ],
        education: [
          Education(
            school: _eduSchoolController.text,
            degree: _eduDegreeController.text,
            year: _eduYearController.text,
          ),
        ],
        selectedTemplateId: selectedTemplate,
      );

      await ref.read(resumeNotifierProvider.notifier).generateResume(resume);
      
      ActivityService.addActivity(
        title: 'Resume Generated',
        subtitle: 'Created ${selectedTemplate.toUpperCase()} resume',
        icon: Icons.description,
        color: Colors.blue,
        targetRoute: '/resume/preview',
      );
      
      if (mounted) {
        context.push('/resume/preview');
        // Show Interstitial Ad after navigation
        AdService.instance.showInterstitial();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resumeNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Resume Builder',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: _generate,
            tooltip: 'Preview Resume',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text(
                    'AI is crafting your masterpiece...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optimizing for ATS systems...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Progress / Header
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Row(
                      children: [
                        CircularProgressIndicator(
                          value: 0.85,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                          strokeWidth: 6,
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Strength: Strong',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Add more skills to reach Expert',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 1), // Divider
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionCard(
                              title: 'Personal Information',
                              icon: Icons.person_outline,
                              children: [
                                _buildTextField(_nameController, 'Full Name', Icons.badge),
                                const SizedBox(height: 16),
                                _buildTextField(_emailController, 'Email', Icons.email, type: TextInputType.emailAddress),
                                const SizedBox(height: 16),
                                _buildTextField(_phoneController, 'Phone', Icons.phone, type: TextInputType.phone),
                                const SizedBox(height: 16),
                                _buildTextField(_linkedinController, 'LinkedIn URL', Icons.link),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildSectionCard(
                              title: 'Professional Profile',
                              icon: Icons.work_outline,
                              children: [
                                _buildTextField(_jobTitleController, 'Target Job Title', Icons.title),
                                const SizedBox(height: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Experience Level',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF546E7A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // ignore: deprecated_member_use
                                    DropdownButtonFormField<String>(
                                      value: _experienceLevel,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      items: ['Fresher', 'Junior', 'Mid Level', 'Senior', 'Expert']
                                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                                          .toList(),
                                      onChanged: (v) => setState(() => _experienceLevel = v!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _skillsController, 
                                  'Skills (comma separated)', 
                                  Icons.lightbulb_outline,
                                  hint: 'Flutter, Dart, Clean Architecture',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildSectionCard(
                              title: 'Latest Experience',
                              icon: Icons.history,
                              children: [
                                _buildTextField(_expCompanyController, 'Company Name', Icons.business),
                                const SizedBox(height: 16),
                                _buildTextField(_expRoleController, 'Job Role', Icons.work),
                                const SizedBox(height: 16),
                                _buildTextField(_expDurationController, 'Duration', Icons.date_range, hint: '2020 - Present'),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _expDescController, 
                                  'Key Achievements', 
                                  Icons.description,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildSectionCard(
                              title: 'Education',
                              icon: Icons.school_outlined,
                              children: [
                                _buildTextField(_eduSchoolController, 'School / University', Icons.account_balance),
                                const SizedBox(height: 16),
                                _buildTextField(_eduDegreeController, 'Degree / Major', Icons.school),
                                const SizedBox(height: 16),
                                _buildTextField(_eduYearController, 'Graduation Year', Icons.calendar_today),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildSectionCard(
                              title: 'Additional Details',
                              icon: Icons.add_circle_outline,
                              children: [
                                _buildTextField(
                                  _languagesController,
                                  'Languages (comma separated)',
                                  Icons.language,
                                  hint: 'English, Spanish, French',
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  _interestsController,
                                  'Interests (comma separated)',
                                  Icons.sports_esports,
                                  hint: 'Traveling, Reading, Gaming',
                                ),
                              ],
                            ),
                            const SizedBox(height: 100), // Space for FAB
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: _generate,
          backgroundColor: Colors.black,
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: const Text(
            'GENERATE RESUME (AI)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF2C3E50), size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {TextInputType? type, String? hint, int maxLines = 1}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) => v!.isEmpty && label != 'LinkedIn URL' ? 'Required' : null,
        ),
      ],
    );
  }


}

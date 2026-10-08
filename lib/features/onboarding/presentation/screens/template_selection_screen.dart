import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ai_resume_builder/core/constants/app_constants.dart';
import 'package:ai_resume_builder/features/onboarding/data/models/user_profile_model.dart';

class TemplateSelectionScreen extends StatefulWidget {
  final bool isEditMode;

  const TemplateSelectionScreen({super.key, this.isEditMode = false});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _templates = [
    {'id': 'modern', 'name': 'Modern', 'color': Colors.cyan, 'isPremium': true},
    {'id': 'professional', 'name': 'Professional', 'color': const Color(0xFF2C3E50), 'isPremium': false},
    {'id': 'creative', 'name': 'Creative', 'color': Colors.orange, 'isPremium': true},
    {'id': 'minimalist', 'name': 'Minimalist', 'color': Colors.teal, 'isPremium': false},
    {'id': 'executive', 'name': 'Executive', 'color': Colors.indigo, 'isPremium': true},
  ];

  void _saveAndContinue() async {
    final box = Hive.box<UserProfileModel>(AppConstants.userProfileBox);
    final currentProfile = box.get('current_profile');
    
    // Check Premium Status
    final isPremium = currentProfile?.isPremium ?? false;
    final selectedTemplate = _templates[_currentPage];
    
    if (selectedTemplate['isPremium'] == true && !isPremium) {
      final result = await context.push<bool>('/subscription');
      if (result == true) {
        setState(() {}); // Refresh to update UI with new premium status
      }
      return;
    }

    if (currentProfile != null) {
      final updatedProfile = UserProfileModel(
        fullName: currentProfile.fullName,
        email: currentProfile.email,
        phone: currentProfile.phone,
        jobTitle: currentProfile.jobTitle,
        address: currentProfile.address,
        selectedTemplateId: selectedTemplate['id'],
        isPremium: currentProfile.isPremium,
      );
      await box.put('current_profile', updatedProfile);
    }

    if (mounted) {
      if (widget.isEditMode) {
        context.pop();
      } else {
        context.push('/workspace-ready');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Resume',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Template',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B67F6), // Matches the blue in the image
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explore the attractive resume templates and select one to start creating.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4A4A4A),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _templates.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 600, // Adjusted height
                          width: Curves.easeOut.transform(value) * 400,
                          child: child,
                        ),
                      );
                    },
                    child: _buildTemplateCard(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _saveAndContinue, // Skip acts same as Next here for now
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(int index) {
    final template = _templates[index];
    final bool isSelected = _currentPage == index;
    final bool isPremium = template['isPremium'] ?? false;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _ResumePreviewWidget(
              templateId: template['id'],
              color: template['color'],
            ),
          ),
        ),
        if (isPremium)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF536DFE),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ResumePreviewWidget extends StatelessWidget {
  final String templateId;
  final Color? color;

  const _ResumePreviewWidget({required this.templateId, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildLayout(),
          );
        },
      ),
    );
  }

  Widget _buildLayout() {
    switch (templateId) {
      case 'creative':
        return _buildCreativeLayout();
      case 'professional':
        return _buildProfessionalLayout();
      case 'minimalist':
        return _buildMinimalistLayout();
      case 'executive':
        return _buildExecutiveLayout();
      case 'modern':
      default:
        return _buildModernLayout();
    }
  }

  Widget _buildModernLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Contact'),
                  _buildTextLine(width: 80),
                  _buildTextLine(width: 90),
                  _buildTextLine(width: 60),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Education'),
                  _buildTextLine(width: 100, isBold: true),
                  _buildTextLine(width: 80),
                  _buildTextLine(width: 40),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Languages'),
                  _buildTextLine(width: 50),
                  _buildTextLine(width: 50),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About Me'),
                  _buildParagraph(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Work Experience'),
                  _buildTextLine(width: 120, isBold: true),
                  _buildTextLine(width: 80),
                  _buildTextLine(width: 140),
                  const SizedBox(height: 8),
                  _buildTextLine(width: 120, isBold: true),
                  _buildTextLine(width: 80),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Skills'),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildChip(),
                      _buildChip(),
                      _buildChip(),
                      _buildChip(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFF2C3E50), thickness: 2),
        const SizedBox(height: 16),
        _buildSectionTitle('Summary'),
        _buildParagraph(),
        const SizedBox(height: 16),
        _buildSectionTitle('Experience'),
        _buildTextLine(width: 140, isBold: true),
        _buildTextLine(width: 120),
        const SizedBox(height: 4),
        _buildParagraph(),
        const SizedBox(height: 16),
        _buildSectionTitle('Education'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextLine(width: 100, isBold: true),
                _buildTextLine(width: 80),
              ],
            ),
            _buildTextLine(width: 40),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Skills'),
                  _buildTextLine(width: 100),
                  _buildTextLine(width: 80),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Languages'),
                  _buildTextLine(width: 80),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreativeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFFFFF3E0),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSectionTitle('Contact'),
                _buildTextLine(width: 80),
                _buildTextLine(width: 60),
                const SizedBox(height: 16),
                _buildSectionTitle('Skills'),
                _buildTextLine(width: 70),
                _buildTextLine(width: 60),
                _buildTextLine(width: 80),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Profile'),
              _buildParagraph(),
              const SizedBox(height: 16),
              _buildSectionTitle('Experience'),
              _buildTextLine(width: 120, isBold: true),
              _buildTextLine(width: 140),
              const SizedBox(height: 8),
              _buildTextLine(width: 100, isBold: true),
              _buildTextLine(width: 120),
              const SizedBox(height: 16),
              _buildSectionTitle('Education'),
              _buildTextLine(width: 100, isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalistLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildHeader()),
        const SizedBox(height: 16),
        const Divider(color: Colors.grey),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('EXPERIENCE'),
                  const SizedBox(height: 8),
                  _buildTextLine(width: 120, isBold: true),
                  _buildTextLine(width: 80),
                  const SizedBox(height: 4),
                  _buildParagraph(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('EDUCATION'),
                  const SizedBox(height: 8),
                  _buildTextLine(width: 100, isBold: true),
                  _buildTextLine(width: 80),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('CONTACT'),
                  _buildTextLine(width: 80),
                  _buildTextLine(width: 60),
                  const SizedBox(height: 16),
                  _buildSectionTitle('SKILLS'),
                  _buildTextLine(width: 70),
                  _buildTextLine(width: 60),
                  const SizedBox(height: 16),
                  _buildSectionTitle('LANGUAGES'),
                  _buildTextLine(width: 50),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutiveLayout() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 2)),
          ),
          child: _buildHeader(),
        ),
        const SizedBox(height: 16),
        _buildExecutiveSection('Executive Summary'),
        _buildParagraph(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _buildExecutiveSection('Experience'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextLine(width: 80, isBold: true),
                      _buildTextLine(width: 40, isBold: true),
                    ],
                  ),
                  _buildTextLine(width: 100),
                  const SizedBox(height: 4),
                  _buildParagraph(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildExecutiveSection('Education'),
                  _buildTextLine(width: 80, isBold: true),
                  _buildTextLine(width: 60),
                  const SizedBox(height: 16),
                  _buildExecutiveSection('Skills'),
                  _buildTextLine(width: 60),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (templateId == 'modern') {
       return Stack(
         children: [
           Container(
             height: 80,
             decoration: const BoxDecoration(
               color: Color(0xFF00ACC1),
               borderRadius: BorderRadius.only(
                 bottomLeft: Radius.circular(60),
               ),
             ),
           ),
           Positioned(
             top: 10,
             left: 0,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'Adeline',
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                 ),
                 const Text(
                   'Parmer Kane',
                   style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                 ),
                 const SizedBox(height: 4),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                   decoration: BoxDecoration(
                     color: const Color(0xFFB2EBF2),
                     borderRadius: BorderRadius.circular(10),
                   ),
                   child: const Text(
                     'Flight Attendant',
                     style: TextStyle(fontSize: 10, color: Color(0xFF006064), fontWeight: FontWeight.bold),
                   ),
                 ),
               ],
             ),
           ),
         ],
       );
    } else if (templateId == 'professional') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('JOHN DOE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2C3E50))),
              Text('Software Engineer', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTextLine(width: 80),
              _buildTextLine(width: 60),
            ],
          )
        ],
      );
    } else if (templateId == 'creative') {
       return const Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('JOHN DOE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE65100))),
           Text('Creative Designer', style: TextStyle(color: Color(0xFFEF6C00), fontSize: 10)),
         ],
       );
    } else if (templateId == 'minimalist') {
       return const Column(
         children: [
           Text('JOHN DOE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
           SizedBox(height: 4),
           Text('SOFTWARE ENGINEER', style: TextStyle(fontSize: 10, letterSpacing: 2)),
         ],
       );
    } else if (templateId == 'executive') {
       return Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           const Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('JOHN DOE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
               const Text('Executive Director', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
             ],
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               _buildTextLine(width: 60),
               _buildTextLine(width: 40),
             ],
           ),
         ],
       );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'John Doe',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          'Software Engineer',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(height: 2, color: Colors.black12),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildExecutiveSection(String title) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildTextLine({double width = 60, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        height: 6,
        width: width,
        decoration: BoxDecoration(
          color: isBold ? Colors.black26 : Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildParagraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextLine(width: double.infinity),
        _buildTextLine(width: double.infinity),
        _buildTextLine(width: 100),
      ],
    );
  }
  
  Widget _buildChip() {
    return Container(
      width: 40,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

import 'package:ai_resume_builder/features/home/services/activity_service.dart';
import '../../domain/entities/resume.dart';
import '../providers/resume_provider.dart';

class ResumePreviewScreen extends ConsumerWidget {
  const ResumePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
               //
               if (resumeState.value != null) {
                 ActivityService.addActivity(
                   title: 'Resume Downloaded',
                   subtitle: 'Downloaded ${resumeState.value!.selectedTemplateId.toUpperCase()} template',
                   icon: Icons.download,
                   color: Colors.teal,
                   targetRoute: '/resume/preview',
                 );
                 
                 Printing.layoutPdf(
                    onLayout: (format) => _generatePdf(format, resumeState.value!),
                 );
               }
            },
          ),
        ],
      ),
      body: resumeState.when(
        data: (resume) {
          if (resume == null) return const Center(child: Text('No resume generated.'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(resume.fullName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(resume.jobTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: 8),
                      Text('${resume.email} | ${resume.phone} | ${resume.linkedin}'),
                    ],
                  ),
                ),
                const Divider(height: 32),
                const _SectionTitle(title: 'Professional Summary'),
                Text(resume.summary),
                const Divider(height: 32),
                const _SectionTitle(title: 'Skills'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resume.skills.map((skill) => Chip(label: Text(skill))).toList(),
                ),
                const Divider(height: 32),
                const _SectionTitle(title: 'Experience'),
                ...resume.experience.map((exp) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exp.company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(exp.role, style: const TextStyle(fontStyle: FontStyle.italic)),
                          Text(exp.duration),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(exp.description),
                    ],
                  ),
                )),
                const Divider(height: 32),
                const _SectionTitle(title: 'Education'),
                ...resume.education.map((edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(edu.school, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(edu.degree),
                        ],
                      ),
                      Text(edu.year),
                    ],
                  ),
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Resume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: resume.selectedTemplateId == 'modern' ? pw.EdgeInsets.zero : const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          switch (resume.selectedTemplateId) {
            case 'professional':
              return _buildProfessional(resume);
            case 'creative':
              return _buildCreative(resume);
            case 'minimalist':
              return _buildMinimalist(resume);
            case 'executive':
              return _buildExecutive(resume);
            case 'modern':
            default:
              return _buildModern(resume);
          }
        },
      ),
    );

    return pdf.save();
  }

  // 1. Blue Wave Template (Professional Design)
  pw.Widget _buildModern(Resume resume) {
    const accentColor = PdfColor.fromInt(0xFF00ACC1); // Cyan 600
    const lightAccentColor = PdfColor.fromInt(0xFFE0F7FA); // Cyan 50

    // Smooth Wave SVG Path - Top Header
    const waveSvg = '''
      <svg width="595" height="150" viewBox="0 0 595 150" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M0 0H595V100C595 100 450 140 300 100C150 60 0 100 0 100V0Z" fill="#00ACC1"/>
      </svg>
    ''';

    return pw.Stack(
      children: [
        // Header Background Wave
        pw.Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: pw.SvgImage(svg: waveSvg, fit: pw.BoxFit.fitWidth),
        ),

        pw.Column(
          children: [
            // Header Content
            pw.Container(
              height: 140, // Increased height for better spacing
              padding: const pw.EdgeInsets.symmetric(horizontal: 40), // Added horizontal padding
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        resume.fullName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        resume.jobTitle.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14, // Increased font size
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Two Column Layout
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40), // Added content padding
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Column (35%)
                  pw.Expanded(
                    flex: 35, // Increased flex for left column
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildModernSectionTitle('CONTACT', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 12),
                        _buildContactItem(resume.phone, 'P'),
                        _buildContactItem(resume.email, 'E'),
                        _buildContactItem(resume.linkedin, 'W'),
                        if (resume.address?.isNotEmpty ?? false) _buildContactItem(resume.address!, 'A'),
                        pw.SizedBox(height: 30),

                        _buildModernSectionTitle('EDUCATION', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 12),
                        ...resume.education.map((edu) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 16),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.Text(edu.degree, style: pw.TextStyle(color: PdfColors.grey800, fontSize: 10, fontStyle: pw.FontStyle.italic)),
                              pw.Text(edu.year, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                            ],
                          ),
                        )),
                        pw.SizedBox(height: 18),

                        _buildModernSectionTitle('LANGUAGES', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 12),
                        ...resume.languages.map((lang) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Text(lang, style: const pw.TextStyle(fontSize: 10)),
                        )),
                         pw.SizedBox(height: 30),

                        if (resume.interests.isNotEmpty) ...[
                          _buildModernSectionTitle('INTERESTS', color: accentColor, isUpperCase: true),
                          pw.SizedBox(height: 12),
                          ...resume.interests.map((interest) => pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 6),
                            child: pw.Text(interest, style: const pw.TextStyle(fontSize: 10)),
                          )),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 30),
                  // Right Column (65%)
                  pw.Expanded(
                    flex: 65,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildModernSectionTitle('ABOUT ME', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          resume.summary.isEmpty ? 'Passionate professional with expertise in ${resume.skills.take(3).join(", ")}.' : resume.summary,
                          style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: PdfColors.grey800),
                          textAlign: pw.TextAlign.justify,
                        ),
                        pw.SizedBox(height: 30),

                        _buildModernSectionTitle('WORK EXPERIENCE', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 12),
                        ...resume.experience.map((exp) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(exp.role, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor, fontSize: 12)),
                                  pw.Text(exp.duration, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                                ],
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                              pw.SizedBox(height: 6),
                              pw.Text(exp.description, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
                            ],
                          ),
                        )),
                        pw.SizedBox(height: 18),

                        _buildModernSectionTitle('SKILLS', color: accentColor, isUpperCase: true),
                        pw.SizedBox(height: 12),
                        pw.Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: resume.skills.map((skill) => pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: lightAccentColor,
                              border: pw.Border.all(color: accentColor, width: 0.5),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Text(skill, style: pw.TextStyle(fontSize: 10, color: accentColor, fontWeight: pw.FontWeight.bold)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildContactItem(String text, String label) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 12,
            child: pw.Text('$label.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700)),
          ),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  pw.Widget _buildModernSectionTitle(String title, {PdfColor? color, bool isUpperCase = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isUpperCase ? title.toUpperCase() : title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColors.black,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: 30,
          height: 2,
          color: color ?? PdfColors.black,
        ),
      ],
    );
  }

  // 2. Professional Template (Black & White, Traditional with Accent)
  pw.Widget _buildProfessional(Resume resume) {
    const accentColor = PdfColor.fromInt(0xFF2C3E50); // Midnight Blue

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.fullName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  resume.jobTitle,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(resume.email, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(resume.phone, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(resume.linkedin, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: accentColor, thickness: 2),
        pw.SizedBox(height: 10),

        _buildSectionTitle('Professional Summary', color: accentColor),
        pw.Text(resume.summary, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
        pw.SizedBox(height: 15),

        _buildSectionTitle('Experience', color: accentColor),
        ...resume.experience.map((exp) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text(exp.duration, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text(exp.role, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11, color: accentColor)),
                  pw.SizedBox(height: 4),
                  pw.Text(exp.description, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            )),
        pw.SizedBox(height: 15),

        _buildSectionTitle('Education', color: accentColor),
        ...resume.education.map((edu) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${edu.school} - ${edu.degree}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(edu.year, style: pw.TextStyle(fontSize: 10)),
              ],
            )),
        pw.SizedBox(height: 15),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Skills', color: accentColor),
                  pw.Text(resume.skills.join(' • '), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Languages', color: accentColor),
                  pw.Text(resume.languages.join(' • '), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
        if (resume.interests.isNotEmpty) ...[
          pw.SizedBox(height: 15),
          _buildSectionTitle('Interests', color: accentColor),
          pw.Text(resume.interests.join(' • '), style: const pw.TextStyle(fontSize: 10)),
        ],
      ],
    );
  }

  // 3. Creative Template (Side Column with Photo Placeholder)
  pw.Widget _buildCreative(Resume resume) {
    const sidebarColor = PdfColor.fromInt(0xFFFFF3E0); // Orange 50
    const accentColor = PdfColor.fromInt(0xFFE65100); // Orange 900

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Sidebar
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            color: sidebarColor,
            padding: const pw.EdgeInsets.all(20),
            height: 850, // Full height approximation
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(resume.fullName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: accentColor)),
                pw.Text(resume.jobTitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.orange800)),
                pw.SizedBox(height: 30),

                pw.Text('CONTACT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                pw.SizedBox(height: 8),
                pw.Text(resume.email, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(resume.phone, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(resume.linkedin, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 20),

                pw.Text('SKILLS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                pw.SizedBox(height: 8),
                ...resume.skills.map((s) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.all(pw.Radius.circular(4))),
                  child: pw.Text(s, style: const pw.TextStyle(fontSize: 10)),
                )),
                pw.SizedBox(height: 20),

                pw.Text('LANGUAGES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                pw.SizedBox(height: 8),
                ...resume.languages.map((l) => pw.Text(l, style: const pw.TextStyle(fontSize: 10))),
                pw.SizedBox(height: 20),

                if (resume.interests.isNotEmpty) ...[
                  pw.Text('INTERESTS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor)),
                  pw.SizedBox(height: 8),
                  ...resume.interests.map((i) => pw.Text(i, style: const pw.TextStyle(fontSize: 10))),
                ],
              ],
            ),
          ),
        ),
        // Main Content
        pw.Expanded(
          flex: 7,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PROFILE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor, fontSize: 14)),
                pw.SizedBox(height: 5),
                pw.Text(resume.summary, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
                pw.SizedBox(height: 20),

                pw.Text('EXPERIENCE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor, fontSize: 14)),
                pw.Divider(color: accentColor, thickness: 1),
                ...resume.experience.map((exp) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 12, top: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(exp.role, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text(exp.duration, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                            ],
                          ),
                          pw.Text(exp.company, style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic, color: PdfColors.orange900)),
                          pw.SizedBox(height: 4),
                          pw.Text(exp.description, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    )),
                pw.SizedBox(height: 20),

                pw.Text('EDUCATION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accentColor, fontSize: 14)),
                pw.Divider(color: accentColor, thickness: 1),
                ...resume.education.map((edu) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(edu.degree, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(edu.year, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. Minimalist Template (Clean, Whitespace)
  pw.Widget _buildMinimalist(Resume resume) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(resume.fullName, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.normal)),
        pw.Text(resume.jobTitle.toUpperCase(), style: const pw.TextStyle(fontSize: 12, letterSpacing: 2, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(resume.email, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(resume.phone, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(resume.linkedin, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 30),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left Column: Experience
            pw.Expanded(
              flex: 7,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EXPERIENCE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 15),
                  ...resume.experience.map((exp) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(exp.role, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            pw.Text(exp.company, style: const pw.TextStyle(fontSize: 11)),
                            pw.SizedBox(height: 4),
                            pw.Text(exp.description, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            // Right Column: Info
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('TIMELINE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 15),
                  ...resume.experience.map((exp) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Text(exp.duration, style: const pw.TextStyle(fontSize: 10)),
                  )),

                  pw.SizedBox(height: 20),
                  pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 15),
                  ...resume.education.map((edu) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text(edu.degree, style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(edu.year, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      ],
                    ),
                  )),

                  pw.SizedBox(height: 20),
                  pw.Text('SKILLS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                  pw.SizedBox(height: 10),
                  pw.Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: resume.skills.map((s) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                      child: pw.Text(s, style: const pw.TextStyle(fontSize: 9)),
                    )).toList(),
                  ),
                  
                  if (resume.languages.isNotEmpty) ...[
                     pw.SizedBox(height: 20),
                     pw.Text('LANGUAGES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                     pw.SizedBox(height: 10),
                     pw.Text(resume.languages.join('\n'), style: const pw.TextStyle(fontSize: 10)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. Executive Template (Elegant, Serif)
  pw.Widget _buildExecutive(Resume resume) {
    final font = pw.Font.times(); // Use Times New Roman or similar if available, defaulting to standard serif feel
    return pw.Theme(
      data: pw.ThemeData.withFont(base: font),
      child: pw.Column(
        children: [
          pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 2)),
            ),
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(resume.fullName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                    pw.Text(resume.jobTitle, style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(resume.email),
                    pw.Text(resume.phone),
                    pw.Text(resume.linkedin),
                    if (resume.address != null) pw.Text(resume.address!),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          _buildExecutiveSection('Executive Summary', resume.summary),
          
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 7,
                child: pw.Column(
                   children: [
                     _buildExecutiveSection('Professional Experience', ''),
                     ...resume.experience.map((exp) => pw.Padding(
                           padding: const pw.EdgeInsets.only(bottom: 12),
                           child: pw.Column(
                             crossAxisAlignment: pw.CrossAxisAlignment.start,
                             children: [
                               pw.Row(
                                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                 children: [
                                   pw.Text(exp.company, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                   pw.Text(exp.duration, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                 ],
                               ),
                               pw.Text(exp.role, style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                               pw.SizedBox(height: 4),
                               pw.Text(exp.description),
                             ],
                           ),
                         )),
                   ],
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  children: [
                    _buildExecutiveSection('Education', ''),
                    ...resume.education.map((edu) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                           pw.Text(edu.school, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                           pw.Text(edu.degree, style: const pw.TextStyle(fontSize: 10)),
                           pw.Text(edu.year, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    )),
                    pw.SizedBox(height: 10),
                    _buildExecutiveSection('Core Competencies', resume.skills.join(' | ')),
                    if (resume.languages.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      _buildExecutiveSection('Languages', resume.languages.join(' | ')),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, {PdfColor? color}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color ?? PdfColors.black, width: 1)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
      ),
    );
  }

  pw.Widget _buildExecutiveSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          color: PdfColors.grey200,
          padding: const pw.EdgeInsets.all(4),
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(title.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        if (content.isNotEmpty) ...[
          pw.Text(content),
          pw.SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

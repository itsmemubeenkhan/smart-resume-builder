import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_resume_builder/features/home/services/activity_service.dart';
import '../../domain/entities/job_application.dart';
import '../providers/job_tracker_provider.dart';

class AddJobScreen extends ConsumerStatefulWidget {
  final JobApplication? job;

  const AddJobScreen({super.key, this.job});

  @override
  ConsumerState<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends ConsumerState<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late JobStatus _status;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.job?.company ?? '');
    _positionController = TextEditingController(text: widget.job?.position ?? '');
    _locationController = TextEditingController(text: widget.job?.location ?? '');
    _notesController = TextEditingController(text: widget.job?.notes ?? '');
    _status = widget.job?.status ?? JobStatus.applied;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveJob() {
    if (_formKey.currentState!.validate()) {
      final newJob = JobApplication.create(
        company: _companyController.text,
        position: _positionController.text,
        location: _locationController.text,
        status: _status,
        notes: _notesController.text,
      );

      if (widget.job != null) {
        // Update
        final updatedJob = widget.job!.copyWith(
          company: _companyController.text,
          position: _positionController.text,
          location: _locationController.text,
          status: _status,
          notes: _notesController.text,
        );
        ref.read(jobTrackerProvider.notifier).updateJob(updatedJob);
        
        ActivityService.addActivity(
          title: 'Job Updated',
          subtitle: 'Updated ${_positionController.text} at ${_companyController.text}',
          icon: Icons.work_history,
          color: Colors.orange,
        );
      } else {
        // Add
        ref.read(jobTrackerProvider.notifier).addJob(newJob);
        
        ActivityService.addActivity(
          title: 'Job Applied',
          subtitle: 'Applied to ${_companyController.text}',
          icon: Icons.send,
          color: Colors.green,
          targetRoute: '/tracker',
        );
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job != null ? 'Edit Job' : 'Add Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (value) => value!.isEmpty ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) => value!.isEmpty ? 'Please enter position' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              // ignore: deprecated_member_use
              DropdownButtonFormField<JobStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: JobStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveJob,
                child: Text(widget.job != null ? 'Update Job' : 'Save Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/job_application.dart';
import '../providers/job_tracker_provider.dart';

class JobTrackerScreen extends ConsumerWidget {
  const JobTrackerScreen({super.key});

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.applied:
        return Colors.blue;
      case JobStatus.interview:
        return Colors.orange;
      case JobStatus.offer:
        return Colors.green;
      case JobStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobTrackerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tracker/add'),
        child: const Icon(Icons.add),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No job applications yet. Add one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(job.company, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.position),
                      Text(
                        DateFormat.yMMMd().format(job.dateApplied),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(job.status)),
                    ),
                    child: Text(
                      job.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(job.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                     context.push('/tracker/details', extra: job);
                  },
                  onLongPress: () {
                     showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Job'),
                          content: const Text('Are you sure you want to delete this job?'),
                          actions: [
                            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                ref.read(jobTrackerProvider.notifier).deleteJob(job.id);
                                context.pop();
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                     );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

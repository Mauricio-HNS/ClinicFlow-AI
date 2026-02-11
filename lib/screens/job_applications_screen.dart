import 'package:flutter/material.dart';
import '../models/job_application.dart';
import '../state/job_applications_state.dart';
import '../widgets/glass.dart';

class JobApplicationsScreen extends StatelessWidget {
  const JobApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidaturas')),
      body: SafeArea(
        child: ValueListenableBuilder<List<JobApplication>>(
          valueListenable: JobApplicationsState.items,
          builder: (context, items, _) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sem candidaturas ainda', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Quando alguém clicar em "Candidatar", os inscritos aparecerão aqui.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            final groups = <String, List<JobApplication>>{};
            for (final item in items) {
              groups.putIfAbsent(item.jobId, () => <JobApplication>[]).add(item);
            }
            final entries = groups.entries.toList()
              ..sort((a, b) => b.value.first.createdAt.compareTo(a.value.first.createdAt));

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: entries.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final applications = entries[index].value;
                final first = applications.first;
                return GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    title: Text(first.jobTitle, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(
                      '${first.company} • ${applications.length} inscrito(s)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    children: applications.map((application) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _CandidateRow(application: application),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final JobApplication application;

  const _CandidateRow({required this.application});

  @override
  Widget build(BuildContext context) {
    final createdAt = application.createdAt;
    final timeLabel =
        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(application.candidateName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(application.candidatePhone, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text('Inscrito em $timeLabel', style: Theme.of(context).textTheme.bodySmall),
          if (application.message != null && application.message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(application.message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

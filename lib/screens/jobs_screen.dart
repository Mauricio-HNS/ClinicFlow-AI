import 'package:flutter/material.dart';
import '../data/mock_jobs.dart';
import '../models/job.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empregos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => _goHome(context),
            tooltip: 'Home',
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Empregos perto de você', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    const _JobSearchBar(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Madrid • 5 km', style: Theme.of(context).textTheme.bodyMedium),
                        const Spacer(),
                        SizedBox(
                          height: 40,
                          child: GradientButton(
                            onPressed: () {},
                            icon: Icons.tune,
                            label: 'Filtros',
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          CategoryChip(label: 'Remoto', color: AppColors.electronics),
                          SizedBox(width: 8),
                          CategoryChip(label: 'Part-time', color: AppColors.clothing),
                          SizedBox(width: 8),
                          CategoryChip(label: 'Full-time', color: AppColors.furniture),
                          SizedBox(width: 8),
                          CategoryChip(label: '€ Salário', color: AppColors.price),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _MicroCard(
                      title: '5 vagas novas hoje',
                      subtitle: 'Empregos locais e oportunidades remotas.',
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GradientButton(
                        onPressed: () => _goHome(context),
                        icon: Icons.storefront_outlined,
                        label: 'Voltar ao marketplace',
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Vagas recomendadas', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = mockJobs[index % mockJobs.length];
                  return _JobCard(job: job);
                },
                childCount: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    onPressed: () {},
                    icon: Icons.add_business_outlined,
                    label: 'Publicar vaga',
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == '/home' || route.isFirst,
    );
  }
}

class _JobSearchBar extends StatelessWidget {
  const _JobSearchBar();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('Buscar cargo, empresa ou área', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _JobImage(job: job),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(job.company, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.highlight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(job.posted, style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.description, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              children: [
                _JobPill(text: job.location),
                const SizedBox(width: 8),
                _JobPill(text: job.type),
                if (job.remote) ...[
                  const SizedBox(width: 8),
                  _JobPill(text: 'Remoto'),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(job.salary, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
                const Spacer(),
                GradientButton(
                  onPressed: () => _openDetail(context, job),
                  label: 'Detalhes',
                  icon: Icons.info_outline_rounded,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  onPressed: () {},
                  label: 'Candidatar',
                  icon: Icons.send_outlined,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(job.company, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(job.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  _JobPill(text: job.location),
                  const SizedBox(width: 8),
                  _JobPill(text: job.type),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {},
                  icon: Icons.send_outlined,
                  label: 'Candidatar agora',
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JobImage extends StatelessWidget {
  final Job job;

  const _JobImage({required this.job});

  @override
  Widget build(BuildContext context) {
    final asset = job.imageAsset;

    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => const Icon(Icons.work_outline, color: AppColors.primary);
}

class _JobPill extends StatelessWidget {
  final String text;

  const _JobPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _MicroCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MicroCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

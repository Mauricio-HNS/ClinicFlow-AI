import 'package:flutter/material.dart';
import '../data/mock_jobs.dart';
import '../models/job.dart';
import '../theme/app_colors.dart';
import '../state/job_applications_state.dart';
import '../state/notifications_state.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';

DateTime? _publishedAtFromPostedLabel(String label, [DateTime? now]) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final normalized = label.trim().toLowerCase();

  if (normalized == 'hoje') return today;
  if (normalized == 'ontem') return today.subtract(const Duration(days: 1));

  final days = int.tryParse(normalized.split(' ').first);
  if (days != null) return today.subtract(Duration(days: days));
  return null;
}

Job _normalizeJobDates(Job job) {
  return Job(
    id: job.id,
    title: job.title,
    company: job.company,
    companyPhone: job.companyPhone,
    location: job.location,
    salary: job.salary,
    type: job.type,
    posted: job.posted,
    publishedAt: job.publishedAt ?? _publishedAtFromPostedLabel(job.posted),
    description: job.description,
    remote: job.remote,
    imageAsset: job.imageAsset,
    imageUrl: job.imageUrl,
  );
}

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final List<Job> _jobs = mockJobs.map(_normalizeJobDates).toList();
  final TextEditingController _searchController = TextEditingController();
  bool _onlyRemote = false;
  bool _onlyWithPrice = false;
  Set<String> _selectedTypes = <String>{};
  bool _onlyNewToday = false;
  String _searchQuery = '';

  List<String> get _allTypes {
    final values = _jobs.map((job) => job.type).toSet().toList()..sort();
    return values;
  }

  List<Job> get _filteredJobs {
    final search = _searchQuery.trim().toLowerCase();
    return _jobs.where((job) {
      if (_onlyRemote && !job.remote) return false;
      if (_onlyWithPrice && !_hasExplicitSalary(job)) return false;
      if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(job.type)) return false;
      if (_onlyNewToday && !_isNewToday(job)) return false;
      if (search.isNotEmpty) {
        final haystack = <String>[
          job.title,
          job.company,
          job.location,
          job.type,
          job.description,
          job.salary,
        ].join(' ').toLowerCase();
        if (!haystack.contains(search)) return false;
      }
      return true;
    }).toList();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_onlyRemote) count += 1;
    if (_onlyWithPrice) count += 1;
    if (_onlyNewToday) count += 1;
    count += _selectedTypes.length;
    return count;
  }

  int get _newTodayCount => _jobs.where(_isNewToday).length;

  bool _isNewToday(Job job) => job.relativePosted().toLowerCase() == 'hoje';

  bool _isValidSinglePhone(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    if (normalized.contains(',') || normalized.contains(';') || normalized.contains('/') || normalized.contains('|')) {
      return false;
    }
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  bool _hasExplicitSalary(Job job) {
    final salary = job.salary.trim().toLowerCase();
    if (salary.isEmpty) return false;
    if (salary == 'a combinar') return false;
    return salary.contains('€');
  }

  void _showSalaryFilterInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded),
              SizedBox(width: 8),
              Text('Filtro € Salário'),
            ],
          ),
          content: const Text(
            'Esse filtro mostra apenas vagas que informam salário explícito no anúncio (ex.: €12/h ou €1.400–€1.700). Vagas sem salário definido não serão mostradas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFiltersSheet(BuildContext context) async {
    var tempRemote = _onlyRemote;
    final tempTypes = <String>{..._selectedTypes};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtros de vagas', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tempRemote ? const Color(0x3322C55E) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: tempRemote
                            ? const Color(0xAA22C55E)
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                      boxShadow: tempRemote
                          ? const [
                              BoxShadow(
                                color: Color(0x5522C55E),
                                blurRadius: 18,
                                spreadRadius: 0.4,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Somente vagas remotas',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tempRemote ? const Color(0xFF0F7A36) : null,
                            ),
                      ),
                      value: tempRemote,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF22C55E),
                      onChanged: (value) => setModalState(() => tempRemote = value),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tipo de vaga', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allTypes.map((type) {
                      final selected = tempTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: const Color(0x3322C55E),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xAA22C55E)
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                        shadowColor: const Color(0x5522C55E),
                        selectedShadowColor: const Color(0x5522C55E),
                        elevation: selected ? 3 : 0,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected ? const Color(0xFF0F7A36) : null,
                            ),
                        onSelected: (value) {
                          setModalState(() {
                            if (value) {
                              tempTypes.add(type);
                            } else {
                              tempTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempRemote = false;
                            tempTypes.clear();
                          });
                        },
                        child: const Text('Limpar'),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 42,
                        child: GradientButton(
                          onPressed: () {
                            setState(() {
                              _onlyRemote = tempRemote;
                              _selectedTypes = tempTypes;
                            });
                            Navigator.pop(context);
                          },
                          icon: Icons.check_rounded,
                          label: 'Aplicar filtros',
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _onlyRemote = false;
      _onlyWithPrice = false;
      _onlyNewToday = false;
      _selectedTypes.clear();
    });
  }

  void _goHome(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == '/home' || route.isFirst,
    );
  }

  InputDecoration _publishInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.88)),
      filled: true,
      fillColor: AppColors.surface.withValues(alpha: 0.42),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.75)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.68), width: 1.3),
      ),
    );
  }

  void _openPublishJobSheet(BuildContext context) {
    var title = '';
    var company = '';
    var companyPhone = '';
    var location = '';
    var salary = '';
    var salaryNegotiable = false;
    var description = '';
    String? typeValue;
    bool? isRemote;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.canvas,
                    AppColors.surface,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    24 + MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(22),
                        tint: AppColors.surface,
                        opacity: 0.2,
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.glow.withValues(alpha: 0.34),
                                    blurRadius: 14,
                                    spreadRadius: 0.2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.work_outline_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Publicar vaga', style: Theme.of(sheetContext).textTheme.titleLarge),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Preencha os dados para criar um card premium na lista.',
                                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        decoration: _publishInputDecoration(
                          label: 'Título da vaga',
                          hint: 'Ex: Assistente de loja',
                          icon: Icons.badge_outlined,
                        ),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: _publishInputDecoration(
                          label: 'Empresa',
                          hint: 'Ex: Mercado Lavapiés',
                          icon: Icons.apartment_rounded,
                        ),
                        onChanged: (value) => company = value,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: _publishInputDecoration(
                          label: 'Celular da empresa',
                          hint: 'Ex: +34 600 123 456',
                          icon: Icons.phone_outlined,
                        ),
                        onChanged: (value) => companyPhone = value,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: _publishInputDecoration(
                          label: 'Local',
                          hint: 'Ex: Madrid Centro',
                          icon: Icons.place_outlined,
                        ),
                        onChanged: (value) => location = value,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: ValueKey<bool>(salaryNegotiable),
                        initialValue: salaryNegotiable ? 'A combinar' : salary,
                        readOnly: salaryNegotiable,
                        decoration: _publishInputDecoration(
                          label: 'Salário',
                          hint: 'Ex: €1.400–€1.700 ou €12/h',
                          icon: Icons.euro_rounded,
                        ),
                        onChanged: (value) {
                          if (!salaryNegotiable) salary = value;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChoiceChip(
                          label: const Text('A combinar'),
                          selected: salaryNegotiable,
                          onSelected: (value) {
                            setSheetState(() {
                              salaryNegotiable = value;
                              salary = value ? 'A combinar' : '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: typeValue,
                        hint: const Text('Selecione o tipo'),
                        items: <String>{..._allTypes, 'Full-time', 'Part-time', 'Freelance'}
                            .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setSheetState(() => typeValue = value);
                        },
                        decoration: _publishInputDecoration(
                          label: 'Tipo de vaga',
                          hint: 'Selecione o tipo',
                          icon: Icons.category_outlined,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isRemote == true
                              ? AppColors.primary.withValues(alpha: 0.09)
                              : AppColors.surface.withValues(alpha: 0.32),
                          border: Border.all(
                            color: isRemote == true
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                          boxShadow: isRemote == true
                              ? [
                                  BoxShadow(
                                    color: AppColors.glow.withValues(alpha: 0.32),
                                    blurRadius: 16,
                                    spreadRadius: 0.2,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Modalidade (obrigatório)',
                            style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isRemote == true ? AppColors.primaryEnd : AppColors.textPrimary,
                                ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Presencial'),
                                  selected: isRemote == false,
                                  onSelected: (_) => setSheetState(() => isRemote = false),
                                ),
                                ChoiceChip(
                                  label: const Text('Remota'),
                                  selected: isRemote == true,
                                  onSelected: (_) => setSheetState(() => isRemote = true),
                                ),
                              ],
                            ),
                          ),
                          value: isRemote == true,
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        minLines: 3,
                        maxLines: 5,
                        decoration: _publishInputDecoration(
                          label: 'Descrição',
                          hint: 'Resumo das atividades e requisitos',
                          icon: Icons.notes_rounded,
                        ),
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          onPressed: () {
                            final jobTitle = title.trim();
                            final jobCompany = company.trim();
                            final jobCompanyPhone = companyPhone.trim();
                            final jobLocation = location.trim();
                            final jobSalary = salary.trim();
                            final jobDescription = description.trim();
                            if (jobTitle.isEmpty ||
                                jobCompany.isEmpty ||
                                jobCompanyPhone.isEmpty ||
                                jobLocation.isEmpty ||
                                jobSalary.isEmpty ||
                                jobDescription.isEmpty ||
                                typeValue == null ||
                                isRemote == null) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Todos os campos são obrigatórios.')),
                              );
                              return;
                            }

                            if (!_isValidSinglePhone(jobCompanyPhone)) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Informe apenas 1 celular válido da empresa.')),
                              );
                              return;
                            }

                            final newJob = Job(
                              id: 'j${DateTime.now().microsecondsSinceEpoch}',
                              title: jobTitle,
                              company: jobCompany,
                              companyPhone: jobCompanyPhone,
                              location: jobLocation,
                              salary: jobSalary,
                              type: typeValue!,
                              posted: 'Hoje',
                              publishedAt: DateTime.now(),
                              description: jobDescription,
                              remote: isRemote!,
                              imageAsset: 'assets/demo/empregos.jpg',
                            );

                            setState(() {
                              _jobs.insert(0, newJob);
                            });

                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text('Vaga "$jobTitle" publicada com sucesso.'),
                                ),
                              );
                          },
                          icon: Icons.send_outlined,
                          label: 'Publicar vaga',
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _filteredJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empregos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups_rounded),
            onPressed: () => Navigator.pushNamed(context, '/job-applications'),
            tooltip: 'Candidaturas',
          ),
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
                    _JobSearchBar(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Madrid • 5 km',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          child: GradientButton(
                            onPressed: () => _openFiltersSheet(context),
                            icon: Icons.tune,
                            label: _activeFilterCount > 0 ? 'Filtros ($_activeFilterCount)' : 'Filtros',
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
                        children: [
                          _JobShortcutChip(
                            label: 'Remoto',
                            color: AppColors.electronics,
                            selected: _onlyRemote,
                            onTap: () => setState(() => _onlyRemote = !_onlyRemote),
                          ),
                          const SizedBox(width: 8),
                          _JobShortcutChip(
                            label: 'Part-time',
                            color: AppColors.clothing,
                            selected: _selectedTypes.contains('Part-time'),
                            onTap: () {
                              setState(() {
                                if (_selectedTypes.contains('Part-time')) {
                                  _selectedTypes.remove('Part-time');
                                } else {
                                  _selectedTypes.add('Part-time');
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _JobShortcutChip(
                            label: 'Full-time',
                            color: AppColors.furniture,
                            selected: _selectedTypes.contains('Full-time'),
                            onTap: () {
                              setState(() {
                                if (_selectedTypes.contains('Full-time')) {
                                  _selectedTypes.remove('Full-time');
                                } else {
                                  _selectedTypes.add('Full-time');
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _JobShortcutChip(
                            label: '€ Salário',
                            color: AppColors.price,
                            selected: _onlyWithPrice,
                            onTap: () => setState(() => _onlyWithPrice = !_onlyWithPrice),
                          ),
                        ],
                      ),
                    ),
                    if (_activeFilterCount > 0) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_onlyRemote)
                            InputChip(
                              label: const Text('Remoto'),
                              onDeleted: () => setState(() => _onlyRemote = false),
                            ),
                          if (_onlyWithPrice)
                            InputChip(
                              label: const Text('Com salário'),
                              onDeleted: () => setState(() => _onlyWithPrice = false),
                            ),
                          if (_onlyNewToday)
                            InputChip(
                              label: const Text('Novas hoje'),
                              onDeleted: () => setState(() => _onlyNewToday = false),
                            ),
                          ..._selectedTypes.map(
                            (type) => InputChip(
                              label: Text(type),
                              onDeleted: () => setState(() => _selectedTypes.remove(type)),
                            ),
                          ),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Limpar tudo'),
                          ),
                        ],
                      ),
                      if (_onlyWithPrice) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _showSalaryFilterInfo(context),
                            icon: const Icon(Icons.info_outline_rounded),
                            label: const Text('O que significa € Salário?'),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    _MicroCard(
                      title: '$_newTodayCount vagas novas hoje',
                      subtitle: _onlyNewToday
                          ? 'Filtro ativo: mostrando apenas vagas novas.'
                          : 'Toque para mostrar apenas vagas novas na lista.',
                      active: _onlyNewToday,
                      onTap: () => setState(() => _onlyNewToday = !_onlyNewToday),
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
                  final job = filteredJobs[index];
                  return _JobCard(job: job);
                },
                childCount: filteredJobs.length,
              ),
            ),
            if (filteredJobs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nenhuma vaga encontrada', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Tente reduzir os filtros para ver mais resultados.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Remover filtros'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    onPressed: () => _openPublishJobSheet(context),
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
}

class _JobSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _JobSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: BorderRadius.circular(18),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Buscar cargo, empresa ou área',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Limpar busca',
                ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _JobShortcutChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _JobShortcutChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(color.withValues(alpha: 0.12), AppColors.neumorphicBase)
              : AppColors.neumorphicBase,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.92),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neumorphicLightShadow,
              blurRadius: 11,
              offset: const Offset(-5, -5),
            ),
            BoxShadow(
              color: AppColors.neumorphicDarkShadow,
              blurRadius: 14,
              spreadRadius: 0.6,
              offset: const Offset(6, 6),
            ),
            if (selected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 14,
                spreadRadius: 0.2,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  bool _isValidSinglePhone(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    if (normalized.contains(',') || normalized.contains(';') || normalized.contains('/') || normalized.contains('|')) {
      return false;
    }
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

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
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.86),
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.highlight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  job.relativePosted(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              job.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.84),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _JobPill(text: job.location),
                _JobPill(text: job.type),
                if (job.remote) const _JobPill(text: 'Remoto'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    job.salary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
                GradientButton(
                  onPressed: () => _openDetail(context, job),
                  label: 'Detalhes',
                  icon: Icons.info_outline_rounded,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                GradientButton(
                  onPressed: () => _applyToJob(context, job),
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

  void _openDetail(BuildContext parentContext, Job job) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                job.company,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.companyPhone,
                      style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.86),
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _JobPill(text: job.location),
                  _JobPill(text: job.type),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {
                    _applyToJob(parentContext, job);
                  },
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

  void _applyToJob(BuildContext context, Job job) {
    var candidateName = '';
    var candidatePhone = '';
    var candidateMessage = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Candidatar-se', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('${job.title} • ${job.company}', style: Theme.of(sheetContext).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Seu nome',
                  hintText: 'Ex: Ana Silva',
                ),
                onChanged: (value) => candidateName = value,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Seu celular',
                  hintText: 'Ex: +34 600 123 456',
                ),
                onChanged: (value) => candidatePhone = value,
              ),
              const SizedBox(height: 10),
              TextField(
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensagem (opcional)',
                  hintText: 'Fale brevemente da sua experiência',
                ),
                onChanged: (value) => candidateMessage = value,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: () {
                    final name = candidateName.trim();
                    final phone = candidatePhone.trim();
                    final message = candidateMessage.trim();

                    if (name.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Nome e celular são obrigatórios.')),
                      );
                      return;
                    }
                    if (!_isValidSinglePhone(phone)) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(content: Text('Informe um celular válido (apenas 1 número).')),
                      );
                      return;
                    }

                    JobApplicationsState.addApplication(
                      job: job,
                      candidateName: name,
                      candidatePhone: phone,
                      message: message,
                    );

                    NotificationsState.addJobApplication(
                      jobTitle: job.title,
                      candidateName: name,
                    );

                    Navigator.pop(sheetContext);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Candidatura enviada para ${job.title}.'),
                        ),
                      );
                  },
                  icon: Icons.send_outlined,
                  label: 'Enviar candidatura',
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
  final bool active;
  final VoidCallback onTap;

  const _MicroCard({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? const Color(0xAA22C55E) : Colors.white.withValues(alpha: 0.35),
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color(0x5522C55E),
                  blurRadius: 18,
                  spreadRadius: 0.2,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: active ? const Color(0xFF16A34A) : AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: active ? const Color(0xFF0F7A36) : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

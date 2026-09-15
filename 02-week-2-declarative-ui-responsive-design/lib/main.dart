import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double kWideBreakpoint = 700;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: _isDark,
        onDarkChanged: (value) => setState(() => _isDark = value),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  static const _information = <AcademicInformation>[
    AcademicInformation(
      title: 'Assignments',
      value: '8',
      description: '3 due this week',
      icon: Icons.assignment_outlined,
    ),
    AcademicInformation(
      title: 'Attendance',
      value: '92%',
      description: 'Above class target',
      icon: Icons.fact_check_outlined,
    ),
    AcademicInformation(
      title: 'Portfolio',
      value: 'Ready',
      description: 'Last updated today',
      icon: Icons.work_outline,
    ),
    AcademicInformation(
      title: 'Current week',
      value: '02',
      description: 'Declarative UI',
      icon: Icons.calendar_today_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academic Overview'),
            Text('Semester 5', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Semantics(
            label: 'Dark mode',
            toggled: isDark,
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 4),
                CupertinoSwitch(
                  key: const Key('theme-switch'),
                  value: isDark,
                  activeTrackColor: colorScheme.primary,
                  onChanged: onDarkChanged,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
          final horizontalPadding = columns == 2 ? 32.0 : 16.0;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  12,
                ),
                sliver: const SliverToBoxAdapter(child: ProfileHeader()),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  32,
                ),
                sliver: SliverGrid(
                  key: Key('academic-grid-$columns'),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 142,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _information[index];
                    return InfoCard(
                      key: Key('info-card-$index'),
                      title: item.title,
                      value: item.value,
                      description: item.description,
                      icon: item.icon,
                    );
                  }, childCount: _information.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Student profile, Raditya Riefki, NIM 244107020204, class TI-3E',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.tertiaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Text(
                'RR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Raditya Riefki', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '244107020204  |  TI-3E',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Mobile Development',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$title: $value. $description',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AcademicInformation {
  const AcademicInformation({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
}

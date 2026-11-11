import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.scrollController});

  final ScrollController scrollController;

  static const _settings = [
    (icon: Icons.notifications_rounded, label: 'Notifications'),
    (icon: Icons.lock_rounded, label: 'Privacy'),
    (icon: Icons.dark_mode_rounded, label: 'Appearance'),
    (icon: Icons.language_rounded, label: 'Language'),
    (icon: Icons.storage_rounded, label: 'Storage'),
    (icon: Icons.help_rounded, label: 'Help'),
    (icon: Icons.info_rounded, label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 32,
        16,
        bottomInset + 16,
      ),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              'JD',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Jordan Doe',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        Text(
          'Product designer',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            _Stat(value: '128', label: 'Posts'),
            _Stat(value: '4.2k', label: 'Followers'),
            _Stat(value: '312', label: 'Following'),
          ],
        ),
        const SizedBox(height: 24),
        Card.filled(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final item in _settings)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

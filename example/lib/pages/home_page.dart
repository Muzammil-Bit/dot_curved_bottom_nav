import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.scrollController,
    required this.onOpenStyle,
  });

  final ScrollController scrollController;
  final VoidCallback onOpenStyle;

  static const _features = [
    (
      icon: Icons.swipe_vertical_rounded,
      title: 'Hides on scroll',
      body: 'Scroll down and the bar slides away. Scroll up to bring it back.',
    ),
    (
      icon: Icons.animation_rounded,
      title: 'Animated indicator',
      body: 'The dot glides between items and the curve follows it.',
    ),
    (
      icon: Icons.palette_rounded,
      title: 'Fully themeable',
      body: 'Colors, sizes, radius, margin, timing and curve are all yours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Dot curved bottom nav')),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
          sliver: SliverList.list(
            children: [
              Text(
                'A bottom navigation bar that curves around a dot indicator.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpenStyle,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Customize the bar'),
              ),
              const SizedBox(height: 24),
              for (final feature in _features)
                Card.filled(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      feature.icon,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(feature.title),
                    subtitle: Text(feature.body),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

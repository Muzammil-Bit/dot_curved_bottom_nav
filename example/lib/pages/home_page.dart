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
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 12),
              Text('Latest stories', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
          sliver: SliverList.builder(
            itemCount: 12,
            itemBuilder: (context, index) => _StoryCard(index: index),
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.index});

  final int index;

  static const _titles = [
    'Designing calm interfaces',
    'Motion that explains itself',
    'Why small details matter',
    'Building for one hand',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hue = (index * 47) % 360;
    final color = HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.6).toColor();

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            color: color.withValues(alpha: 0.25),
            child: Icon(Icons.auto_stories_rounded, color: color, size: 32),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[index % _titles.length],
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${3 + index % 6} min read',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../nav_style.dart';

/// Live controls for every option of the bar. Changes show up in the bar at
/// the bottom of the screen right away.
class StylePage extends StatelessWidget {
  const StylePage({
    super.key,
    required this.scrollController,
    required this.style,
    required this.onChanged,
  });

  final ScrollController scrollController;
  final NavStyle style;
  final ValueChanged<NavStyle> onChanged;

  static const _backgrounds = [
    Color(0xff15171C),
    Color(0xff1E2A4A),
    Color(0xff3A1F5D),
    Color(0xff0F3D3E),
    Color(0xffFFFFFF),
    Color(0xffF1E6D8),
  ];

  static const _indicators = [
    Color(0xff4F8BFF),
    Color(0xffFF6B6B),
    Color(0xffFFC145),
    Color(0xff3DDC97),
    Color(0xffB388FF),
    Color(0xffFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Style'),
          actions: [
            TextButton(
              onPressed: () => onChanged(const NavStyle()),
              child: const Text('Reset'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
          sliver: SliverList.list(
            children: [
              _Section(
                title: 'Colors',
                children: [
                  _SwatchRow(
                    label: 'Background',
                    colors: _backgrounds,
                    selected: style.backgroundColor,
                    onSelected: (c) =>
                        onChanged(style.copyWith(backgroundColor: c)),
                  ),
                  _SwatchRow(
                    label: 'Indicator',
                    colors: _indicators,
                    selected: style.indicatorColor,
                    onSelected: (c) =>
                        onChanged(style.copyWith(indicatorColor: c)),
                  ),
                ],
              ),
              _Section(
                title: 'Shape',
                children: [
                  _SliderTile(
                    label: 'Height',
                    value: style.height,
                    min: 50,
                    max: 75,
                    onChanged: (v) => onChanged(style.copyWith(height: v)),
                  ),
                  _SliderTile(
                    label: 'Indicator size',
                    value: style.indicatorSize,
                    min: 3,
                    max: 9,
                    onChanged: (v) =>
                        onChanged(style.copyWith(indicatorSize: v)),
                  ),
                  _SliderTile(
                    label: 'Corner radius',
                    value: style.borderRadius,
                    min: 0,
                    max: 30,
                    onChanged: (v) =>
                        onChanged(style.copyWith(borderRadius: v)),
                  ),
                  _SliderTile(
                    label: 'Side margin',
                    value: style.horizontalMargin,
                    min: 0,
                    max: 40,
                    onChanged: (v) =>
                        onChanged(style.copyWith(horizontalMargin: v)),
                  ),
                ],
              ),
              _Section(
                title: 'Motion',
                children: [
                  _SliderTile(
                    label: 'Duration',
                    value: style.durationMs.toDouble(),
                    min: 100,
                    max: 1200,
                    divisions: 11,
                    unit: 'ms',
                    onChanged: (v) =>
                        onChanged(style.copyWith(durationMs: v.round())),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final curve in NavCurve.values)
                        ChoiceChip(
                          label: Text(curve.label),
                          selected: style.curve == curve,
                          onSelected: (_) =>
                              onChanged(style.copyWith(curve: curve)),
                        ),
                    ],
                  ),
                ],
              ),
              _Section(
                title: 'Behavior',
                children: [
                  Text('Items', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      for (var n = 2; n <= 5; n++)
                        ButtonSegment(value: n, label: Text('$n')),
                    ],
                    selected: {style.itemCount},
                    onSelectionChanged: (s) =>
                        onChanged(style.copyWith(itemCount: s.first)),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hide on scroll'),
                    subtitle:
                        const Text('Slide the bar away while scrolling down'),
                    value: style.hideOnScroll,
                    onChanged: (v) =>
                        onChanged(style.copyWith(hideOnScroll: v)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A titled card that groups related controls.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.unit = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Text(
              '${value.round()}$unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          padding: const EdgeInsets.symmetric(vertical: 16),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SwatchRow extends StatelessWidget {
  const _SwatchRow({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in colors)
                Semantics(
                  button: true,
                  selected: color == selected,
                  child: GestureDetector(
                    onTap: () => onSelected(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color == selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: color == selected ? 3 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

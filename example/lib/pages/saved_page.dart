import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Saved')),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 18,
            itemBuilder: (context, index) {
              final hue = (index * 37 + 200) % 360;
              final color =
                  HSLColor.fromAHSL(1, hue.toDouble(), 0.6, 0.55).toColor();
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.55)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Collection ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

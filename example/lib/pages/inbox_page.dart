import 'package:flutter/material.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key, required this.scrollController});

  final ScrollController scrollController;

  static const _names = [
    'Ava Martin',
    'Noah Reyes',
    'Mia Chen',
    'Liam Patel',
    'Zara Okafor',
    'Ethan Brooks',
  ];

  static const _messages = [
    'Loved the new navigation, the dot is so smooth.',
    'Can we try the bounce curve on the release build?',
    'Sent you the updated icons.',
    'Lunch tomorrow?',
    'The bar hides perfectly when I scroll the feed.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Inbox')),
        SliverPadding(
          padding: EdgeInsets.only(bottom: bottomInset + 16),
          sliver: SliverList.separated(
            itemCount: 30,
            separatorBuilder: (_, __) => const Divider(indent: 72, height: 1),
            itemBuilder: (context, index) {
              final name = _names[index % _names.length];
              final unread = index < 3;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(name[0]),
                ),
                title: Text(
                  name,
                  style: unread
                      ? const TextStyle(fontWeight: FontWeight.w700)
                      : null,
                ),
                subtitle: Text(
                  _messages[index % _messages.length],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: unread
                    ? Badge(backgroundColor: theme.colorScheme.primary)
                    : Text('${index + 1}h', style: theme.textTheme.bodySmall),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:chatify/models/group.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  const GroupTile({
    super.key,
    required this.group,
    this.onTap,
    this.onDetailsTap,
  });

  final Group group;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          group.name,
          style: AppStyles.styleSemiBold18(context),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (group.description.isNotEmpty)
                Text(
                  group.description,
                  style: AppStyles.styleRegular14(context),
                ),
              const SizedBox(height: 6),
              Text(
                'Created by ${group.createdByName ?? 'Unknown'} · ${group.memberIds.length} members',
                style: AppStyles.styleRegular12(context),
              ),
            ],
          ),
        ),
        trailing: onDetailsTap != null
            ? IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: onDetailsTap,
              )
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

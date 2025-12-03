import 'package:chatify/models/app_user.dart';
import 'package:chatify/models/group.dart';
import 'package:chatify/services/group/group_service.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:flutter/material.dart';

Future<void> showGroupDetailsSheet({
  required BuildContext context,
  required GroupService groupService,
  required Group group,
}) async {
  final membersFuture = groupService.fetchGroupMembers(group.memberIds);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: AppStyles.styleSemiBold20(context)),
              const SizedBox(height: 8),
              if (group.description.isNotEmpty)
                Text(group.description,
                    style: AppStyles.styleRegular16(context)),
              const SizedBox(height: 12),
              Text(
                'Created by ${group.createdByName ?? 'Unknown creator'}',
                style: AppStyles.styleRegular14(context),
              ),
              const SizedBox(height: 16),
              Text('Members', style: AppStyles.styleSemiBold16(context)),
              const SizedBox(height: 8),
              FutureBuilder<List<AppUser>>(
                future: membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final members = snapshot.data ?? const <AppUser>[];
                  if (members.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No members yet.',
                        style: AppStyles.styleRegular14(context),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final initials = member.displayName.isNotEmpty
                          ? member.displayName[0].toUpperCase()
                          : '?';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(initials),
                        ),
                        title: Text(
                          member.displayName,
                          style: AppStyles.styleMedium16(context),
                        ),
                        subtitle: Text(
                          member.email,
                          style: AppStyles.styleRegular12(context),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: members.length,
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

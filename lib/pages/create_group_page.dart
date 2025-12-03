import 'package:chatify/services/auth/auth_service.dart';
import 'package:chatify/services/chat/chat_services.dart';
import 'package:chatify/services/group/group_service.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chatServices = ChatServices();
  final _groupService = GroupService();
  final _authService = AuthService();
  final Set<String> _selectedMemberIds = <String>{};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one member for the group.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _groupService.createGroup(
        name: _nameController.text,
        description: _descriptionController.text,
        memberIds: _selectedMemberIds.toList(growable: false),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    final content = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a new group',
            style: AppStyles.styleSemiBold24(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Group name is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Tell members what this group is about',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add members',
            style: AppStyles.styleSemiBold18(context),
          ),
          const SizedBox(height: 8),
          _buildUsersList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _createGroup,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create group'),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? MediaQuery.sizeOf(context).width * 0.2 : 20,
            vertical: 24,
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final currentUserId = _authService.getCurrentUser()?.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Unable to load users',
            style: AppStyles.styleRegular14(context),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? <Map<String, dynamic>>[];
        final filteredUsers = users
            .where((user) => user['uid'] != currentUserId)
            .toList(growable: false);

        if (filteredUsers.isEmpty) {
          return Text(
            'No other users available yet.',
            style: AppStyles.styleRegular14(context),
          );
        }

        return ListView.separated(
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: filteredUsers.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final userId = user['uid'] as String?;
            final userName = (user['name'] as String?)?.trim();
            final userEmail = (user['email'] as String?) ?? '';

            if (userId == null) {
              return const SizedBox.shrink();
            }

            final isSelected = _selectedMemberIds.contains(userId);
            return CheckboxListTile(
              value: isSelected,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    _selectedMemberIds.add(userId);
                  } else {
                    _selectedMemberIds.remove(userId);
                  }
                });
              },
              title: Text(
                userName?.isNotEmpty == true ? userName! : userEmail,
                style: AppStyles.styleMedium16(context),
              ),
              subtitle:
                  Text(userEmail, style: AppStyles.styleRegular12(context)),
            );
          },
        );
      },
    );
  }
}

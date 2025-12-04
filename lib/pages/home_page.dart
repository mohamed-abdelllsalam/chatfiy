import 'package:chatify/components/group_details_sheet.dart';
import 'package:chatify/components/group_tile.dart';
import 'package:chatify/components/my_drawer.dart';
import 'package:chatify/components/user_tile.dart';
import 'package:chatify/models/group.dart';
import 'package:chatify/pages/chat_page.dart';
import 'package:chatify/pages/create_group_page.dart';
import 'package:chatify/pages/group_chat_page.dart';
import 'package:chatify/services/auth/auth_service.dart';
import 'package:chatify/services/chat/chat_services.dart';
import 'package:chatify/services/group/group_service.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        title: Text(
          'Home',
          style: AppStyles.styleSemiBold20(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      drawer: const MyDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(),
          _buildGroupList(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final created = await navigator.push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const CreateGroupPage(),
                  ),
                );
                if (!mounted) return;
                if (created == true) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Group created successfully.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.group_add),
              label: const Text('New group'),
            )
          : null,
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users',
              style: AppStyles.styleRegular16(context),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? const <Map<String, dynamic>>[];

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users available',
              style: AppStyles.styleRegular16(context),
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(users[index], context);
          },
        );
      },
    );
  }

  Widget _buildGroupList() {
    return StreamBuilder<List<Group>>(
      stream: _groupService.streamGroupsForCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading groups',
              style: AppStyles.styleRegular16(context),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data ?? const <Group>[];
        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Create a group to start a shared conversation with multiple friends.',
                style: AppStyles.styleRegular16(context),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return GroupTile(
              group: group,
              onTap: () => _openGroupChat(group),
              onDetailsTap: () => _showGroupDetails(group),
            );
          },
        );
      },
    );
  }

  Future<void> _showGroupDetails(Group group) {
    return showGroupDetailsSheet(
      context: context,
      groupService: _groupService,
      group: group,
    );
  }

  void _openGroupChat(Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupChatPage(group: group),
      ),
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUserEmail = _authService.getCurrentUser()?.email;

    if (userData['email'] == currentUserEmail) {
      return const SizedBox.shrink();
    }

    return UserTile(
      text: userData['name'] ?? userData['email'],
      textStyle: AppStyles.styleMedium16(context),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData['email'],
              receiverID: userData['uid'],
            ),
          ),
        );
      },
    );
  }
}

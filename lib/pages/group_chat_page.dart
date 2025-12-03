import 'dart:async';

import 'package:chatify/components/chat_buble.dart';
import 'package:chatify/components/group_details_sheet.dart';
import 'package:chatify/models/group.dart';
import 'package:chatify/models/group_message.dart';
import 'package:chatify/services/auth/auth_service.dart';
import 'package:chatify/services/group/group_service.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:flutter/material.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key, required this.group});

  final Group group;

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();

  StreamSubscription<Group?>? _groupSubscription;
  late Group _group;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _group = widget.group;

    _groupSubscription =
        _groupService.streamGroupById(widget.group.id).listen((updated) {
      if (updated != null && mounted) {
        setState(() {
          _group = updated;
        });
      }
    });

    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _groupSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await _groupService.sendGroupMessage(
        groupId: _group.id,
        message: text,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _group.name,
          style: AppStyles.styleSemiBold18(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showGroupDetailsSheet(
              context: context,
              groupService: _groupService,
              group: _group,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserId = _authService.getCurrentUser()?.uid;

    return StreamBuilder<List<GroupMessage>>(
      stream: _groupService.streamGroupMessages(_group.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: AppStyles.styleRegular14(context),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? const <GroupMessage>[];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });

        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Start the conversation with this group.',
              style: AppStyles.styleRegular14(context),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.senderId == currentUserId;
            final displayName = message.senderName?.isNotEmpty == true
                ? message.senderName!
                : message.senderEmail;

            return Align(
              alignment:
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ChatBuble(
                message: message.message,
                isCurrentUser: isCurrentUser,
                senderName: isCurrentUser ? null : displayName,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSending ? null : _sendMessage,
              child: _isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

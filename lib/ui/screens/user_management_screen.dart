import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  String _currentUserEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final authState = context.read<AuthBloc>().state;
    _currentUserEmail =
        authState is AuthAuthenticated ? authState.user.email : '';
    final users = await context.read<AuthRepository>().getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleRole(UserModel user) async {
    if (user.email == _currentUserEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя изменить собственную роль')),
      );
      return;
    }

    final newRole =
        user.role == UserRole.admin ? UserRole.user : UserRole.admin;
    await context.read<AuthRepository>().updateUserRole(user.email, newRole);
    await _loadUsers();
  }

  Future<void> _deleteUser(UserModel user) async {
    if (user.email == _currentUserEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя удалить собственный аккаунт')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: Text(
            'Аккаунт «${user.name}» (${user.email}) будет удалён безвозвратно. '
            'Арендованные им товары станут свободными.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<AuthRepository>().deleteUser(user.email);
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text('Нет зарегистрированных пользователей'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) => _UserTile(
                    user: _users[index],
                    isSelf: _users[index].email == _currentUserEmail,
                    onToggleRole: () => _toggleRole(_users[index]),
                    onDelete: () => _deleteUser(_users[index]),
                  ),
                ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onToggleRole;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onToggleRole,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == UserRole.admin;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isAdmin
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
        child: Icon(
          isAdmin ? Icons.shield_rounded : Icons.person,
          color: isAdmin ? Colors.white : Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(user.email),
      trailing: isSelf
          ? Chip(
              label: const Text('Вы'),
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onPrimaryContainer),
            )
          : PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'role') onToggleRole();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(
                        isAdmin
                            ? Icons.remove_moderator_outlined
                            : Icons.add_moderator_outlined,
                        size: 20,
                        color: isAdmin
                            ? Colors.red.shade600
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Text(isAdmin ? 'Убрать права' : 'Дать права'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 20, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      const Text('Удалить аккаунт'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

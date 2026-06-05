import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../screens/user_management_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              _buildAvatar(context, user),
              const SizedBox(height: 20),
              _buildUserInfo(context, user),
              const SizedBox(height: 32),
              if (user.role == UserRole.admin) ...[
                _buildAdminSection(context),
                const SizedBox(height: 16),
              ],
              _buildLogoutButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, UserModel user) {
    final isAdmin = user.role == UserRole.admin;
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.person, size: 52, color: Colors.white),
        ),
        if (isAdmin)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, UserModel user) {
    return Column(
      children: [
        Text(
          user.name,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: user.role == UserRole.admin
                ? Colors.amber.shade50
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: user.role == UserRole.admin
                  ? Colors.amber.shade800
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Администрирование',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          ),
          icon: const Icon(Icons.group_outlined),
          label: const Text('Управление пользователями'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            context.read<AuthBloc>().add(const LogoutRequested()),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Выйти из аккаунта'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade300),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

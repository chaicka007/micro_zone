import 'package:flutter/material.dart';

class UnauthenticatedTab extends StatelessWidget {
  final VoidCallback onGoToAuth;

  const UnauthenticatedTab({super.key, required this.onGoToAuth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              'Вы не авторизованы',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Войдите в аккаунт, чтобы\nполучить доступ к этому разделу',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 28),
            TextButton(
              onPressed: onGoToAuth,
              child: const Text('Перейти к авторизации'),
            ),
          ],
        ),
      ),
    );
  }
}

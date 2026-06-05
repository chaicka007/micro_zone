import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите имя';
    if (value.trim().length < 2) return 'Имя слишком короткое';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Некорректный формат email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 5) return 'Минимум 5 символов';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Подтвердите пароль';
    if (value != _passwordController.text) return 'Пароли не совпадают';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: _handleAuthState,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 28),
                _buildForm(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is RegisterSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация прошла успешно! Теперь войдите.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (state is RegisterFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Создать аккаунт',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Заполните форму для регистрации',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Имя',
            hint: 'Иван Иванов',
            prefixIcon: const Icon(Icons.person_outline),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'example@mail.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: 'Пароль',
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Подтверждение пароля',
            obscureText: _obscureConfirm,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: _validateConfirmPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ElevatedButton(
          onPressed: _submitRegister,
          child: const Text('Зарегистрироваться'),
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Уже есть аккаунт? ',
            style: TextStyle(color: Colors.grey.shade600)),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Войти'),
        ),
      ],
    );
  }
}

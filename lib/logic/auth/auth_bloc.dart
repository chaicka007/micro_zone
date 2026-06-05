import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthUnauthenticated()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final user = await _authRepository.login(
      email: event.email,
      password: event.password,
    );
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthFailure('Неверный email или пароль'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final newUser = UserModel(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    final success = await _authRepository.register(newUser);
    if (success) {
      emit(const RegisterSuccess());
    } else {
      emit(const RegisterFailure('Пользователь с таким email уже существует'));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }
}

import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases authUseCases;

  AuthBloc({required this.authUseCases}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);

    // Check auth status on initialization
    add(CheckAuthStatusEvent());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      if (authUseCases.isUserSignedIn()) {
        final user = await authUseCases.getCurrentUserDetails();
        final email = user?.email ?? '';
        emit(Authenticated(email: email, user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = await authUseCases.login(
          email: event.email, password: event.password);
      final user = await authUseCases.getCurrentUserDetails();
      emit(Authenticated(email: email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = await authUseCases.register(
          phoneNumber: event.phoneNumber,
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName);
      final user = await authUseCases.getCurrentUserDetails();
      emit(Authenticated(email: email, user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authUseCases.logout();
    emit(Unauthenticated());
  }
}

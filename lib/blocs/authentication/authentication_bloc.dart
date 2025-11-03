import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/authentication_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc({required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AuthenticationInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<LogInRequested>(_onLogInRequested);
    on<LogOutRequested>(_onLogOutRequested);
  }

  void _onSignUpRequested(
      SignUpRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationAuthenticated());
    } catch (e) {
      emit(AuthenticationFailure(message: e.toString()));
      emit(AuthenticationUnauthenticated());
    }
  }

  void _onLogInRequested(
      LogInRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _authenticationRepository.logIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticationAuthenticated());
    } catch (e) {
      emit(AuthenticationFailure(message: e.toString()));
      emit(AuthenticationUnauthenticated());
    }
  }

  void _onLogOutRequested(
      LogOutRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    await _authenticationRepository.logOut();
    emit(AuthenticationUnauthenticated());
  }
}
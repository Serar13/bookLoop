import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequested extends AuthenticationEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, phone];
}

class LogInRequested extends AuthenticationEvent {
  final String email;
  final String password;

  const LogInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogOutRequested extends AuthenticationEvent {}
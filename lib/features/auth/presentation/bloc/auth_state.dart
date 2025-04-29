import 'package:equatable/equatable.dart';
import 'package:smartmedia_campaign_manager/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String email;
  final User? user;

  Authenticated({required this.email, this.user});

  @override
  List<Object?> get props => [email, user];
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class Unauthenticated extends AuthState {}

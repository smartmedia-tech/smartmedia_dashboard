part of 'clients_bloc.dart';

abstract class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object> get props => [];
}

class ClientsInitial extends ClientsState {}

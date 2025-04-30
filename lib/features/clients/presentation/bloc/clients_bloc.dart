import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc() : super(ClientsInitial()) {
    on<ClientsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

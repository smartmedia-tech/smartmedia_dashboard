import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stores_event.dart';
part 'stores_state.dart';

class StoresBloc extends Bloc<StoresEvent, StoresState> {
  StoresBloc() : super(StoresInitial()) {
    on<StoresEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

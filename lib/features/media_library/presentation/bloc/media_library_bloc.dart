import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'media_library_event.dart';
part 'media_library_state.dart';

class MediaLibraryBloc extends Bloc<MediaLibraryEvent, MediaLibraryState> {
  MediaLibraryBloc() : super(MediaLibraryInitial()) {
    on<MediaLibraryEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

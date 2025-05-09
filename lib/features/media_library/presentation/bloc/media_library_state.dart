part of 'media_library_bloc.dart';

abstract class MediaLibraryState extends Equatable {
  const MediaLibraryState();

  @override
  List<Object> get props => [];
}

class MediaLibraryInitial extends MediaLibraryState {}

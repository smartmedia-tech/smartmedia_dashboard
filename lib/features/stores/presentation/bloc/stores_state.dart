part of 'stores_bloc.dart';

abstract class StoresState extends Equatable {
  const StoresState();  

  @override
  List<Object> get props => [];
}
class StoresInitial extends StoresState {}

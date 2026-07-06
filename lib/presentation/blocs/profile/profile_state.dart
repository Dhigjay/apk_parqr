import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String address;
  final String phone;
  final String email;
  
  const ProfileLoaded({
    required this.name, 
    required this.address,
    this.phone = '',
    this.email = '',
  });

  @override
  List<Object?> get props => [name, address, phone, email];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

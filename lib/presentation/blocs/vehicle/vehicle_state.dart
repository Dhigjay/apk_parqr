import 'package:equatable/equatable.dart';
import 'package:parqr/domain/entities/vehicle_entity.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleEntity> vehicles;
  
  const VehicleLoaded({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

class VehicleAddedSuccess extends VehicleState {}

// Alias for consistency with complete_profile_page usage
class VehicleAdded extends VehicleAddedSuccess {}

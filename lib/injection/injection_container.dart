import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data Sources Remote
import 'package:parqr/data/datasources/remote/auth_remote_ds.dart';
import 'package:parqr/data/datasources/remote/user_remote_ds.dart';
import 'package:parqr/data/datasources/remote/vehicle_remote_ds.dart';
import 'package:parqr/data/datasources/remote/admin_remote_ds.dart';
import 'package:parqr/data/datasources/remote/payment_remote_ds.dart';

// Repositories Implementation
import 'package:parqr/data/repositories/auth_repo_impl.dart';
import 'package:parqr/data/repositories/user_repo_impl.dart';
import 'package:parqr/data/repositories/vehicle_repo_impl.dart';
import 'package:parqr/data/repositories/operator_repo_impl.dart';
import 'package:parqr/data/repositories/admin_repo_impl.dart';
import 'package:parqr/data/repositories/parking_lot_repo_impl.dart';
import 'package:parqr/data/repositories/parking_session_repo_impl.dart';
import 'package:parqr/data/repositories/payment_repo_impl.dart';

// Repositories Interfaces
import 'package:parqr/domain/repositories/i_auth_repository.dart';
import 'package:parqr/domain/repositories/i_user_repository.dart';
import 'package:parqr/domain/repositories/i_vehicle_repository.dart';
import 'package:parqr/domain/repositories/i_operator_repository.dart';
import 'package:parqr/domain/repositories/i_admin_repository.dart';
import 'package:parqr/domain/repositories/i_parking_lot_repository.dart';
import 'package:parqr/domain/repositories/i_parking_session_repository.dart';
import 'package:parqr/domain/repositories/payment_repository.dart';

// Blocs & Cubits
import 'package:parqr/presentation/blocs/auth/auth_bloc.dart';
import 'package:parqr/presentation/blocs/profile/profile_cubit.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_cubit.dart';
import 'package:parqr/presentation/blocs/parking_session/active_session_cubit.dart';
import 'package:parqr/presentation/blocs/payment/payment_cubit.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_cubit.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_cubit.dart';

final sl = GetIt.instance; // Deklarasi 'sl' cukup satu kali saja di sini

Future<void> initInjection() async {
  // --- External ---
  final supabaseClient = Supabase.instance.client;
  sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // --- Data Sources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSource(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<IPaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IVehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IOperatorRepository>(
    () => OperatorRepoImpl(sl()),
  );
  sl.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IParkingLotRepository>(
    () => ParkingLotRepoImpl(sl()),
  );
  sl.registerLazySingleton<IParkingSessionRepository>(
    () => ParkingSessionRepoImpl(sl()),
  );
  sl.registerLazySingleton<IPaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Blocs / Cubits ---
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(),
  );
  sl.registerFactory<VehicleCubit>(
    () => VehicleCubit(),
  );
  sl.registerFactory<ActiveSessionCubit>(
    () => ActiveSessionCubit(),
  );
  sl.registerFactory<PaymentCubit>(
    () => PaymentCubit(),
  );
  sl.registerFactory<OperatorDashboardCubit>(
    () => OperatorDashboardCubit(),
  );
  sl.registerFactory<AdminApprovalCubit>(
    () => AdminApprovalCubit(adminRepository: sl()),
  );
}
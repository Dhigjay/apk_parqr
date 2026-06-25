import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports
import '../data/datasources/remote/auth_remote_ds.dart';
import '../data/datasources/remote/user_remote_ds.dart';
import '../data/datasources/remote/vehicle_remote_ds.dart';

import '../data/repositories/auth_repo_impl.dart';
import '../data/repositories/user_repo_impl.dart';
import '../data/repositories/vehicle_repo_impl.dart';

import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_user_repository.dart';
import '../domain/repositories/i_vehicle_repository.dart';
import '../domain/repositories/i_operator_repository.dart';
import '../domain/repositories/i_admin_repository.dart';

import '../data/repositories/operator_repo_impl.dart';
import '../data/repositories/admin_repo_impl.dart';
import '../data/datasources/remote/admin_remote_ds.dart';

import '../presentation/blocs/auth/auth_bloc.dart';

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

  // --- Blocs ---
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
}
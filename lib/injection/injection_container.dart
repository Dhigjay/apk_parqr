import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Imports
import '../data/datasources/remote/auth_remote_ds.dart';
import '../data/repositories/auth_repo_impl.dart';
import '../domain/repositories/i_auth_repository.dart';
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

  // --- Repositories ---
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Blocs ---
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
}
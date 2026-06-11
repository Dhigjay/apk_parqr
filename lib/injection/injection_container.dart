import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initInjection() async {
  // External
  final supabaseClient = Supabase.instance.client;
  sl.registerLazySingleton<SupabaseClient>(() => supabaseClient);

  // Feature - Auth (Nanti kita daftarkan RemoteDataSource, Repo, dan Bloc di sini)
}

// Jangan lupa import file AuthBloc-nya di bagian atas file ini
  // import '../presentation/blocs/auth/auth_bloc.dart';

  // --- Blocs ---
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );
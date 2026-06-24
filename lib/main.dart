import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'injection/injection_container.dart';
import 'domain/repositories/i_auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables via --dart-define-from-file
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final hasSupabaseConfig =
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  if (hasSupabaseConfig) {
    // 1. Inisialisasi Supabase
    await Supabase.initialize(
      url: 'https://rtchxgkayaquwzuicuzy.supabase.co',
      publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0Y2h4Z2theWFxdXd6dWljdXp5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMDg4MzMsImV4cCI6MjA5NjU4NDgzM30.mSCi-u3KD55EQJgbiA1yu9cvbcAi_Sq6OeU1vfXsy_g',
    );

    // 2. Inisialisasi Dependency Injection
    await initInjection();
  } else if (kDebugMode) {
    debugPrint(
      'ParQr berjalan dalam development UI mode: Supabase belum dikonfigurasi.',
    );
  } else {
    throw Exception(
      'Gagal memuat API Key Supabase. Pastikan flag --dart-define-from-file=.env sudah terpasang.',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final hasSupabaseConfig = const String.fromEnvironment('SUPABASE_URL').isNotEmpty && 
                                      const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty;
            if (hasSupabaseConfig) {
              return sl<AuthBloc>()..add(AuthCheckStatusRequested());
            }
            // Fallback for development without Supabase
            return AuthBloc(authRepository: _DummyAuthRepository());
          },
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

class _DummyAuthRepository implements IAuthRepository {
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> register(String email, String password, String name, String phone) async {}
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> logout() async {}
  @override
  bool get isLoggedIn => false;
  @override
  String? get currentRole => null;
}

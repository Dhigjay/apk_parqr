import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/onboarding/add_vehicle_page.dart';
import '../../presentation/pages/onboarding/complete_profile_page.dart';
import '../../presentation/pages/user/booking/booking_page.dart';
import '../../presentation/pages/user/booking/qr_entry_page.dart';
import '../../presentation/pages/user/home/home_page.dart';
import '../../presentation/pages/user/parking_detail/parking_detail_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.completeProfile,
        builder: (context, state) => const CompleteProfilePage(),
      ),
      GoRoute(
        path: RouteNames.addVehicle,
        builder: (context, state) => const AddVehiclePage(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.parkingDetail,
        builder: (context, state) => const ParkingDetailPage(),
      ),
      GoRoute(
        path: RouteNames.booking,
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: RouteNames.qrEntry,
        builder: (context, state) => const QrEntryPage(),
      ),
      // Rute lain (operator, payment, admin, dll) akan didaftarkan seiring implementasi modul.
    ],
  );
}

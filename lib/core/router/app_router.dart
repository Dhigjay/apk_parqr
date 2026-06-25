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
import '../../presentation/pages/user/active_parking/active_parking_page.dart';
import '../../presentation/pages/user/payment/payment_page.dart';
import '../../presentation/pages/user/payment/qris_payment_page.dart';
import '../../presentation/pages/user/payment/exit_qr_page.dart';
import '../../presentation/pages/user/history/history_page.dart';
import '../../presentation/pages/user/history/history_detail_page.dart';
import '../../presentation/widgets/status_badge.dart';

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
      GoRoute(
        path: RouteNames.activeParking,
        builder: (context, state) => const ActiveParkingPage(),
      ),
      GoRoute(
        path: RouteNames.payment,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final sessionId = extra?['sessionId'] as String? ?? 'demo-session-001';
          final startTimeStr = extra?['startTime'] as String? ?? DateTime.now().toIso8601String();
          final startTime = DateTime.tryParse(startTimeStr) ?? DateTime.now();
          final tariffPerHour = extra?['tariffPerHour'] as double? ?? 5000.0;
          return PaymentPage(
            sessionId: sessionId,
            startTime: startTime,
            tariffPerHour: tariffPerHour,
          );
        },
      ),
      GoRoute(
        path: '${RouteNames.payment}/qris',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final sessionId = extra?['sessionId'] as String? ?? 'demo-session-001';
          final totalTariff = extra?['totalTariff'] as double? ?? 5000.0;
          final totalDuration = extra?['totalDuration'] as int? ?? 3600;
          return QrisPaymentPage(
            sessionId: sessionId,
            totalTariff: totalTariff,
            totalDuration: totalDuration,
          );
        },
      ),
      GoRoute(
        path: RouteNames.exitQr,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final exitQrPayload = extra?['exitQrPayload'] as String? ?? 'EXIT-QR-123';
          final tariff = extra?['tariff'] as double? ?? 5000.0;
          final durationInSeconds = extra?['durationInSeconds'] as int? ?? 3600;
          final method = extra?['method'] as String? ?? 'Cash';
          return ExitQrPage(
            exitQrPayload: exitQrPayload,
            tariff: tariff,
            durationInSeconds: durationInSeconds,
            method: method,
          );
        },
      ),
      GoRoute(
        path: RouteNames.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: RouteNames.historyDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final id = extra?['id'] as String? ?? '';
          final name = extra?['name'] as String? ?? '';
          final address = extra?['address'] as String? ?? '';
          final date = extra?['date'] as String? ?? '';
          final duration = extra?['duration'] as String? ?? '';
          final vehicle = extra?['vehicle'] as String? ?? '';
          final fare = extra?['fare'] as String? ?? '';
          final statusLabel = extra?['statusLabel'] as String? ?? '';
          final statusType = extra?['statusType'] as StatusBadgeType? ?? StatusBadgeType.neutral;
          final isOngoing = extra?['isOngoing'] as bool? ?? false;
          return HistoryDetailPage(
            id: id,
            name: name,
            address: address,
            date: date,
            duration: duration,
            vehicle: vehicle,
            fare: fare,
            statusLabel: statusLabel,
            statusType: statusType,
            isOngoing: isOngoing,
          );
        },
      ),
    ],
  );
}

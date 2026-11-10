import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/debug_fcm_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/main_shell.dart';
import 'pages/profile_page.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  registerBackgroundHandler();
  await initLocalNotifications();
  await requestNotificationPermission();

  runApp(const ProviderScope(child: CampusNotifyApp()));
}

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen(authStateProvider, (_, __) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final goingLogin = state.matchedLocation == AppRoutes.login;

      if (authAsync.isLoading) return null;

      final loggedIn = authAsync.value ?? false;

      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.announcement,
        builder: (_, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/debug-fcm',
        builder: (_, __) => const DebugFcmPage(),
      ),
    ],
  );

  ref.onDispose(() => refresh.dispose());
  return router;
});
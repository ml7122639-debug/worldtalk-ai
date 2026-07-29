import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/translator_screen.dart';
import 'screens/nova_chat_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(...); // Uncomment after Firebase setup

  runApp(const ProviderScope(child: WorldTalkApp()));
}

class WorldTalkApp extends ConsumerWidget {
  const WorldTalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'WorldTalk AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: AppNavigator.navigatorKey,
      initialRoute: '/splash',
      onGenerateRoute: AppNavigator.onGenerateRoute,
    );
  }
}

/// Centralized route names for the app
class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const translator = '/translator';
  static const novaChat = '/nova';
  static const history = '/history';
  static const settings = '/settings';

  const AppRoutes._();
}

/// Simple navigator without go_router (lighter for MVP)
class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _pageRoute(const SplashScreen(), settings);
      case AppRoutes.home:
        return _pageRoute(const HomeScreen(), settings);
      case AppRoutes.translator:
        final args = settings.arguments as Map<String, String>?;
        return _pageRoute(
          TranslatorScreen(
            initialSourceLang: args?['sourceLang'],
            initialTargetLang: args?['targetLang'],
          ),
          settings,
        );
      case AppRoutes.novaChat:
        return _pageRoute(const NovaChatScreen(), settings);
      case AppRoutes.history:
        return _pageRoute(const HistoryScreen(), settings);
      case AppRoutes.settings:
        return _pageRoute(const SettingsScreen(), settings);
      default:
        return _pageRoute(const HomeScreen(), settings);
    }
  }

  static PageRouteBuilder _pageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static void push(BuildContext context, String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  static void pushReplacement(BuildContext context, String route,
      {Object? arguments}) {
    Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}

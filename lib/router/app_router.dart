import 'package:book_loop/router/app_routes.dart';
import 'package:book_loop/router/propose_trade_screen.dart';
import 'package:book_loop/screens/home_screen.dart';
import 'package:book_loop/screens/main_navigation.dart';
import 'package:book_loop/screens/onBoarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../screens/create_profile_screen.dart';
import '../screens/login.dart';
import '../repositories/authentication_repository.dart';
import '../screens/main_top_bar.dart';
import '../screens/register.dart';
import '../screens/splash_screen.dart';
import 'package:book_loop/screens/add_books_screen.dart';
import '../screens/exchange_screen.dart';
import '../screens/events_screen.dart';
import 'package:book_loop/screens/book_details_screen.dart';
import '../screens/profile_screen.dart';
import 'package:book_loop/screens/chat_list_screen.dart';

const String loginPath = "/login";
const String singinPath = "/singin";
const String homePath = "/home";
const String aboutPath = "/about";
const String userProfilePath = "/userProfile";
const String forgotPasswordPagePath = "/forgotPasswordPage";
const String waitingVerificationPath = "/waitingVerification";
const String waitingVerificationEditPath = "/waitingVerificationEdit";
const String editProfilePath = "/editProfile";
const String splashPath = "/splash";
const String onBordingPath = "/onBording";
const String createProfilePath = "/createProfile";
const String addBooksPath = "/addBooks";
const String welcomePath = "/welcome";
const String adminPath = "/admin";
const String adminConsolePath = "/adminConsole";

final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _topShellNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'topShell');

class AppRouter {
  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splashPath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: AppRoutes.splashRoute,
        path: splashPath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        name: AppRoutes.onBordingRoute,
        path: onBordingPath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 600), // Animation duration
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation, // Gradually increase the opacity
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.singinRoute,
        path: singinPath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository: context.read<AuthenticationRepository>(),
            ),
            child: RegisterScreen(),
          ),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.loginRoute,
        path: loginPath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.createProfileRoute,
        path: createProfilePath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateProfileScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: AppRoutes.addBooksRoute,
        path: addBooksPath,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddBooksScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: 'proposeTrade',
        path: '/proposeTrade',
        pageBuilder: (context, state) {
          final book = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProposeTradeScreen(requestedBook: book),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        name: 'bookDetails',
        path: '/bookDetails',
        pageBuilder: (context, state) {
          final book = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BookDetailsScreen(book: book),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.homeRoute,
            path: homePath,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            name: 'profile',
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            name: 'exchange',
            path: '/exchange',
            pageBuilder: (context, state) => const NoTransitionPage(child: ExchangeScreen()),
          ),
          GoRoute(
            name: 'chatList',
            path: '/chatList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ChatListScreen()),
          ),
          GoRoute(
            name: 'events',
            path: '/events',
            pageBuilder: (context, state) => const NoTransitionPage(child: EventsScreen()),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _topShellNavigatorKey,
        builder: (context, state, child) => TopNavigation(child: child),
        routes: [
          GoRoute(
            name: 'topHome',
            path: '/topHome',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            name: 'topEvents',
            path: '/topEvents',
            pageBuilder: (context, state) => const NoTransitionPage(child: EventsScreen()),
          ),
          GoRoute(
            name: 'topExchange',
            path: '/topExchange',
            pageBuilder: (context, state) => const NoTransitionPage(child: ExchangeScreen()),
          ),
        ],
      ),
    ],
  );
}

import 'package:book_loop/router/app_routes.dart';
import 'package:book_loop/screens/home_screen.dart';
import 'package:book_loop/screens/onBoarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/authentication/authentication_bloc.dart';
import '../screens/create_profile_screen.dart';
import '../screens/login.dart';
import '../repositories/authentication_repository.dart';
import '../screens/register.dart';
import '../screens/splash_screen.dart';
import 'package:book_loop/screens/add_books_screen.dart';

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
        name: AppRoutes.homeRoute,
        path: homePath,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HomeScreen(),
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
    ],
  );
}

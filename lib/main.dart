import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/blocs/authentication/authentication_bloc.dart';
import 'package:book_loop/services/onboarding_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://biwlythywcyjhjwtuzgf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpd2x5dGh5d2N5amhqd3R1emdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNDQxNDQsImV4cCI6MjA3NzgyMDE0NH0.6e9_FK1_VfKYW_JRYKjWBnuoJdRRvsk1pDzbinFaXGQ',
  );

  // Initialize AuthenticationRepository
  final authenticationRepository = AuthenticationRepository();

  runApp(MyApp(authenticationRepository: authenticationRepository));
}

class MyApp extends StatefulWidget {
  final AuthenticationRepository authenticationRepository;

  const MyApp({super.key, required this.authenticationRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleUri(initialUri);
      }

      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      });
    } catch (e) {
      debugPrint("DeepLink error: $e");
    }
  }

  void _handleUri(Uri uri) {
    debugPrint("Received deep link: $uri");

    if (uri.host == "reset") {
      final token = uri.queryParameters["token"];
      final email = uri.queryParameters["email"];
      if (token != null && email != null) {
        AppRouter.navigatorKey.currentContext?.go(
          "/resetPassword",
          extra: {
            "token": token,
            "email": email,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: widget.authenticationRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository: widget.authenticationRepository,
            ),
          ),
        ],
        child: FutureBuilder<bool>(
          future: OnboardingService.isCompleted(),
          builder: (context, snapshot) {
            final initialOnboarding = snapshot.data ?? false;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: "BookLoop",
              routerConfig: AppRouter(initialOnboarding: initialOnboarding).router,
            );
          },
        ),
      ),
    );
  }
}
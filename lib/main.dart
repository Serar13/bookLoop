import 'package:book_loop/router/app_router.dart';
import 'package:book_loop/repositories/authentication_repository.dart';
import 'package:book_loop/blocs/authentication/authentication_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class MyApp extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;

  const MyApp({super.key, required this.authenticationRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: authenticationRepository, // Provide AuthenticationRepository
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository: authenticationRepository,
            ),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "BookLoop",
          // router configuration
          routerConfig: AppRouter().router,
        ),
      ),
    );
  }
}
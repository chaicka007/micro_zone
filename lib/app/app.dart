import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/product_repository.dart';
import '../logic/auth/auth_bloc.dart';
import '../logic/products/product_bloc.dart';
import '../ui/screens/main_screen.dart';
import 'app_theme.dart';

class MicroZoneApp extends StatelessWidget {
  const MicroZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ProductRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthBloc(
              authRepository: ctx.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => ProductBloc(
              productRepository: ctx.read<ProductRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'MicroZone',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainScreen(),
        ),
      ),
    );
  }
}

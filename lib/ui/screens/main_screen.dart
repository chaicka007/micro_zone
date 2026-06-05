import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import 'add_product_screen.dart';
import '../tabs/auth_tab.dart';
import '../tabs/catalog_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/search_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          setState(() => _currentIndex = 2);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAuth = authState is AuthAuthenticated;
          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  // Каталог — доступен всем
                  const CatalogTab(),
                  // Поиск — доступен всем
                  const SearchTab(),
                  // Профиль — форма входа для гостей
                  isAuth ? const ProfileTab() : const AuthTab(),
                ],
              ),
            ),
            floatingActionButton: isAuth && _currentIndex == 0
                ? FloatingActionButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddProductScreen()),
                    ),
                    child: const Icon(Icons.add_rounded),
                  )
                : null,
            bottomNavigationBar: NavigationBar(
              height: 60,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) =>
                  setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag),
                  label: 'Каталог',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_sharp),
                  selectedIcon: Icon(Icons.search_rounded),
                  label: 'Поиск',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Профиль',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

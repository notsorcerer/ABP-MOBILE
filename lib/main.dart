import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cart_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/product_repository.dart';
import 'services/api_service.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const LiquidPediaApp());
}

class LiquidPediaApp extends StatelessWidget {
  const LiquidPediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(CartRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(OrderRepository(apiService)),
        ),
      ],
      child: MaterialApp(
        title: 'LiquidPedia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

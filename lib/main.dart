import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/cart_bloc.dart';
import 'blocs/product_bloc.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Shopping Cart App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFE91E63),
          scaffoldBackgroundColor: const Color(0xFFFCE4EC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFCE4EC),
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        home: const CatalogScreen(),
      ),
    );
  }
}
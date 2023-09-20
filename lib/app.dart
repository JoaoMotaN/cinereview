import 'package:cinereview/app/pages/account/account_page.dart';
import 'package:cinereview/app/pages/category/category_page.dart';
import 'package:cinereview/app/pages/favorites/favorites_page.dart';
import 'package:cinereview/app/pages/home/home_page.dart';
import 'package:cinereview/app/pages/home/playlist_page.dart';
import 'package:cinereview/app/pages/login/login_page.dart';
import 'package:cinereview/app/pages/movieDetails/movie_details.dart';
import 'package:cinereview/app/pages/register/resgister_page.dart';
import 'package:cinereview/app/pages/reviews/reviews_page.dart';
import 'package:cinereview/app/pages/search/search_page.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:cinereview/app/auth/auth_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Define o ícone da barra de status como escuro
    ));

    return MaterialApp(
      title: 'Cinereview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: ProjectColors.pink,
          contentTextStyle: ProjectText.bold,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/playlist': (context) => const PlaylistPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/reviews': (context) => const ReviewsPage(),
        '/account': (context) => const AccountPage(),
        '/category': (context) => const CategoryPage(),
        '/movie/info': (context) => const MovieDetails(),
        '/search': (context) => const SearchPage()
      },
    );
  }
}

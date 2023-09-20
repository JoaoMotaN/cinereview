import 'dart:async';
import 'package:cinereview/app/components/nav_bar.dart';
import 'package:cinereview/app/data/http/http_client.dart';
import 'package:cinereview/app/data/models/info_model.dart';
import 'package:cinereview/app/data/repositories/movies_repository.dart';
import 'package:cinereview/app/data/repositories/users_repository.dart';
import 'package:cinereview/app/pages/home/category_section.dart';
import 'package:cinereview/app/pages/home/header_section.dart';
import 'package:cinereview/app/pages/home/stores/movies_store.dart';
import 'package:cinereview/app/pages/home/movie_galery.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MoviesStore store = MoviesStore(
    repository: MoviesRepository(
      client: HttpClient(),
    ),
    usersRepository: UsersRepository(
      auth: AuthService(),
    ),
  );

  late UsersInfo info;

  void getInfo() async {
    info =
        (await UsersRepository(auth: context.read<AuthService>()).readInfo())!;
    store.loadHomepage(info.favGenre);
  }

  Future<void> getPersonalPlaylist() async {
    await UsersRepository(
      auth: context.read<AuthService>(),
    ).getPersonalPlaylist();
    store.getPersonalPlaylist();
  }

  void logout() async {
    await context.read<AuthService>().logout();
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
          [
            store.isLoading,
            store.error,
            store.trendMovies,
            store.moviesByGender
          ],
        ),
        builder: (context, child) {
          if (store.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: ProjectColors.orange,
              ),
            );
          }

          if (store.error.value.isNotEmpty) {
            return Center(
              child: Text(
                store.error.value,
                style: ProjectText.bold,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (store.trendMovies.value.isEmpty) {
            return const Center(
              child: Text(
                '',
                style: ProjectText.bold,
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 64, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderSection(),
                    Container(height: 32),
                    MovieGalery(
                      title: 'Populares',
                      movies: store.trendMovies.value,
                    ),
                    Container(height: 16),
                    const CategorySection(),
                    Container(height: 16),
                    Container(height: 48),
                    MovieGalery(
                      movies: store.moviesByGender.value,
                      title: 'Com base no seu perfil',
                    ),
                    Container(height: 24)
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: NavBar(context, 0),
    );
  }
}

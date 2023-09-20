import 'package:cinereview/app/components/bigger_movie_card.dart';
import 'package:cinereview/app/components/nav_bar.dart';
import 'package:cinereview/app/data/http/http_client.dart';
import 'package:cinereview/app/data/repositories/movies_repository.dart';
import 'package:cinereview/app/data/repositories/users_repository.dart';
import 'package:cinereview/app/pages/favorites/stores/favorites_movie_store.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoritesMoviesStore store;
  int reload = 0;

  @override
  void initState() {
    super.initState();

    store = FavoritesMoviesStore(
      repository: MoviesRepository(
        client: HttpClient(),
      ),
      user: UsersRepository(
        auth: Provider.of<AuthService>(context, listen: false),
      ),
    );

    store.getFavoritesMovies();
  }

  navigateBack() {
    Navigator.pushNamed(context, '/home');
  }

  void reloadPage() {
    setState(() {
      reload++;
    });
  }

  @override
  Widget build(BuildContext context) {
    store.getFavoritesMovies();
    return Scaffold(
      backgroundColor: ProjectColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
          [store.isLoading, store.favoriteMovies, store.error],
        ),
        builder: (context, child) {
          if (store.isLoading.value) {
            return const Scaffold(
              backgroundColor: ProjectColors.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: ProjectColors.orange,
                ),
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

          if (store.favoriteMovies.value.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item na lista.',
                style: ProjectText.bold,
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 64, left: 24, right: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: navigateBack,
                        icon: const Icon(
                          PhosphorIcons.arrow_left,
                          size: 32,
                        ),
                      ),
                      Container(width: 12),
                      const Text('Favoritos', style: ProjectText.tittle),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      itemCount: store.favoriteMovies.value.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 20,
                        crossAxisCount: 2,
                        childAspectRatio: 160 / 320,
                      ),
                      itemBuilder: (context, index) {
                        return BiggerMovieCard(
                          reloadFunction: reloadPage,
                          showFavButton: true,
                          movie: store.favoriteMovies.value[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: NavBar(context, 2),
    );
  }
}

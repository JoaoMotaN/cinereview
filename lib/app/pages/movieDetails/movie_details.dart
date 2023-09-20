import 'package:cinereview/app/components/review_card.dart';
import 'package:cinereview/app/components/review_dialog.dart';
import 'package:cinereview/app/data/genres_list.dart';
import 'package:cinereview/app/data/models/movie_model.dart';
import 'package:cinereview/app/data/models/review_model.dart';
import 'package:cinereview/app/data/repositories/reviews_repository.dart';
import 'package:cinereview/app/data/repositories/users_repository.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatefulWidget {
  const MovieDetails({super.key});

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  static const posterHost = 'https://image.tmdb.org/t/p/w500';
  late MovieModel movie;
  late dynamic urlArguments;
  late ReviewsRepository reviewsRepository;
  List<ReviewModel> reviews = [];
  bool isFavorite = false;
  bool getOnce = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    urlArguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, MovieModel>;
    reviewsRepository = Provider.of<ReviewsRepository>(context);
    getPageinfo();
    getReviews();
  }

  void getReviews() async {
    List<ReviewModel> data = await reviewsRepository.getMovieReviews(movie.id);

    setState(() {
      reviews = data;
    });
  }

  String formatNumber(int num) {
    final formater = NumberFormat('#,##0', 'pt_BR');
    return formater.format(num);
  }

  String getGendersName(List<int> ids) {
    if (ids.isEmpty) {
      return '';
    }

    if (ids.length == 1) {
      dynamic find = GenresList.menuItens.firstWhere(
        (genre) => genre.id == ids[0],
      );
      return find.name;
    }

    String genderNames = '';

    for (int i = 0; i <= 1; i++) {
      dynamic find = GenresList.menuItens.firstWhere(
        (genre) => genre.id == ids[i],
      );

      if (find.runtimeType == Genre) {
        if (genderNames != '') {
          genderNames += find.name;
        } else {
          genderNames += '${find.name}, ';
        }
      }
    }

    return genderNames;
  }

  void goFoward() {
    Navigator.pop(context);
  }

  Future<void> saveFavorite() async {
    await UsersRepository(
      auth: context.read<AuthService>(),
    ).toggleFavorites(movie.id.toString());
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> addPersonalPlaylist() async {
    await UsersRepository(
      auth: context.read<AuthService>(),
    ).addPersonalPlaylist(
      movie.id,
      movie.title,
      movie.posterPath,
    );
  }

  Future<void> getIsFavorite() async {
    final response = await UsersRepository(
      auth: context.read<AuthService>(),
    ).isFavorite(movie.id.toString());
    setState(() {
      isFavorite = response;
      isLoading = false;
    });
  }

  Future<void> getPageinfo() async {
    movie = urlArguments['movie'];
    if (!getOnce) {
      getOnce = true;
      await getIsFavorite();
    }
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(movie: movie),
    ).then((value) => getReviews());
  }

  @override
  Widget build(BuildContext context) {
    String formatedVotes = formatNumber(movie.voteCount);

    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return true;
      },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                backgroundColor: ProjectColors.background,
                color: ProjectColors.orange,
              ),
            )
          : Scaffold(
              backgroundColor: ProjectColors.background,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 64, right: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon:
                                const Icon(PhosphorIcons.arrow_left, size: 32),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Adicionar a sua playlist',
                                icon: const Icon(
                                  Icons.add_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await addPersonalPlaylist();
                                },
                              ),
                              IconButton(
                                tooltip: 'Favoritar filme',
                                icon: isFavorite
                                    ? const Icon(
                                        PhosphorIcons.heart_fill,
                                        size: 32,
                                        color: ProjectColors.pink,
                                      )
                                    : const Icon(
                                        PhosphorIcons.heart,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                onPressed: saveFavorite,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 6,
                                blurRadius: 10,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(posterHost + movie.posterPath),
                          ),
                        ),
                      ),
                      Container(height: 16),
                      Text(
                        movie.title,
                        style: ProjectText.tittle,
                        textAlign: TextAlign.center,
                      ),
                      Container(height: 24),
                      Text(
                        getGendersName(movie.genreIds),
                        style: ProjectText.bold20,
                      ),
                      Container(height: 16),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.star_fill,
                                size: 32,
                                color: Colors.amber[600],
                              ),
                              Container(width: 8),
                              Text(
                                movie.voteEverage.toString().substring(0, 3),
                                style: ProjectText.tittle,
                              ),
                            ],
                          ),
                          Text(
                            '$formatedVotes votos',
                            style: ProjectText.disabled,
                          )
                        ],
                      ),
                      Container(height: 24),
                      const Row(
                        children: [
                          Text('Sinopse', style: ProjectText.tittle),
                        ],
                      ),
                      Container(height: 16),
                      Text(movie.overview, style: ProjectText.regular),
                      Container(height: 16),
                      const Row(
                        children: [
                          Text('Reviews', style: ProjectText.tittle),
                        ],
                      ),
                      Container(height: 16),
                      Visibility(
                        visible: reviews.isEmpty,
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Nenhum review foi adicionado',
                                  style: ProjectText.bold20,
                                ),
                              ],
                            ),
                            Container(height: 80),
                          ],
                        ),
                      ),
                      reviews.isNotEmpty
                          ? ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                return ReviewCard(review: reviews[index]);
                              },
                            )
                          : Container(),
                      Container(height: 96)
                    ],
                  ),
                ),
              ),
              floatingActionButton: SizedBox(
                width: 70,
                height: 70,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      _showReviewDialog(context);
                    },
                    backgroundColor: ProjectColors.pink,
                    child: const Icon(
                      PhosphorIcons.pencil,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

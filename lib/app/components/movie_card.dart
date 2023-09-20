import 'package:cinereview/app/data/models/movie_model.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';

class MovieCard extends StatefulWidget {
  final MovieModel movie;
  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  static const posterHost = 'https://image.tmdb.org/t/p/w500';

  String getFormattedTittle() {
    if (widget.movie.title.length > 30) {
      return '${widget.movie.title.substring(0, 30)}...';
    }

    return widget.movie.title;
  }

  void navigateToMovie() {
    Navigator.pushNamed(
      context,
      '/movie/info',
      arguments: {'movie': widget.movie},
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 10,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Colors.black.withAlpha(30),
            onTap: navigateToMovie,
            child: SizedBox(
              width: 120,
              height: 180,
              child: Image.network(
                posterHost + widget.movie.posterPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          height: 8,
        ),
        SizedBox(
          width: 110,
          child: Text(
            getFormattedTittle(),
            style: ProjectText.movieCard,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

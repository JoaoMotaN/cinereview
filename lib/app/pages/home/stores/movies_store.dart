import 'package:cinereview/app/data/http/exceptions.dart';
import 'package:cinereview/app/data/models/movie_model.dart';
import 'package:cinereview/app/data/repositories/movies_repository.dart';
import 'package:cinereview/app/data/repositories/users_repository.dart';
import 'package:flutter/foundation.dart';

class MoviesStore {
  final IMoviesRepository repository;
  final UsersRepository usersRepository;

  // Variável reativa para o loading
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  // Variável reativa para o state
  final ValueNotifier<List<MovieModel>> trendMovies =
      ValueNotifier<List<MovieModel>>([]);

  final ValueNotifier<List<Map<String, String>>> myPlaylist =
      ValueNotifier<List<Map<String, String>>>([]);

  final ValueNotifier<List<MovieModel>> moviesByGender =
      ValueNotifier<List<MovieModel>>([]);

  // Variável reativa para o erro
  final ValueNotifier<String> error = ValueNotifier<String>('');

  MoviesStore({required this.repository, required this.usersRepository});

  Future getTrendMovies() async {
    try {
      final result = await repository.getTrendMovies();
      trendMovies.value = result;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future getPersonalPlaylist() async {
    try {
      isLoading.value = true;
      final playlist = await usersRepository.getPersonalPlaylist();
      myPlaylist.value = playlist;
      isLoading.value = false;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future updateItemPersonalPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    try {
      await usersRepository.updatePersonalPlaylist(
        index,
        movieId,
        movieName,
        posterPath,
      );
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteItemPersonalPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    try {
      await usersRepository.deleteItemPlaylist(
          index, movieId, movieName, posterPath);
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future getMoviesByGender(String genderId) async {
    try {
      final result = await repository.getMoviesByGender(genderId);
      moviesByGender.value = result;
    } on NotFoundException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }

    await getTrendMovies();
  }

  loadHomepage(String genderId) async {
    isLoading.value = true;
    await getMoviesByGender(genderId);
    await getTrendMovies();
    isLoading.value = false;
  }
}

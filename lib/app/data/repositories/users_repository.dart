import 'package:cinereview/app/data/database/db_firestore.dart';
import 'package:cinereview/app/data/models/info_model.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersRepository extends ChangeNotifier {
  late FirebaseFirestore db;
  late AuthService auth;
  UsersInfo userInfo = UsersInfo(name: '', favGenre: '');

  UsersRepository({required this.auth}) {
    _startRepository();
  }

  _startRepository() async {
    await _startFirestore();
    await readInfo();
  }

  _startFirestore() {
    db = DBFirestore.get();
  }

  Future<UsersInfo?> readInfo() async {
    if (auth.user != null) {
      final snapshot = await db
          .collection('users/${auth.user!.uid}/info')
          .doc(auth.user!.uid)
          .get();
      UsersInfo info = UsersInfo(
        name: snapshot.data()!.values.toList()[1],
        favGenre: snapshot.data()!.values.toList()[0],
      );
      userInfo = info;
      return info;
    } else {
      return null;
    }
  }

  Future<void> excluirUsuario() async {
    try {
      var user = auth.user;
      if (user != null) {
        var userUid = user.uid;
        await user.delete().then((value) async {
          await db.collection("users").doc(userUid).delete();
        });
      } else {
        debugPrint("Você precisa estar autenticado para excluir um usuário.");
      }
    } catch (e) {
      debugPrint("Erro ao excluir o usuário: $e");
    }
  }

  Future<void> saveInfo(UsersInfo newInfo) async {
    await db
        .collection('users/${auth.user!.uid}/info')
        .doc(auth.user!.uid)
        .set({'name': newInfo.name, 'favGenre': newInfo.favGenre});
    notifyListeners();
  }

  Future<void> updateInfo(UsersInfo newInfo) async {
    await db
        .collection('users/${auth.user!.uid}/info')
        .doc(auth.user!.uid)
        .update({'name': newInfo.name, 'favGenre': newInfo.favGenre});
    notifyListeners();
  }

  Future<List<Map<String, String>>> getPersonalPlaylist() async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/personalPlaylist/${auth.user!.uid}');

    try {
      final DocumentSnapshot snapshot = await document.get();
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('playlist')) {
        final List<Map<String, String>> playlist =
            (data['playlist'] as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map<Map<String, String>>((item) {
          return {
            'movieId': item['movieId'].toString(),
            'movieName': item['movieName'].toString(),
            'posterPath': item['posterPath'].toString(),
          };
        }).toList();

        return playlist;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  Future<void> addPersonalPlaylist(
      int movieId, String movieName, String posterPath) async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/personalPlaylist/${auth.user!.uid}');
    try {
      final DocumentSnapshot snapshot = await document.get();
      final data = snapshot.data();
      List<dynamic> playlist = [];

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('playlist')) {
          playlist = List.from(data['playlist']);
        }
      }

      final index = playlist.indexWhere((item) => item['movieId'] == movieId);

      if (index == -1) {
        playlist.add({
          'movieId': movieId,
          'movieName': movieName,
          'posterPath': posterPath,
        });
      } else {
        playlist.removeAt(index);
      }

      await document.set({'playlist': playlist});
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> updatePersonalPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/personalPlaylist/${auth.user!.uid}');
    try {
      final DocumentSnapshot snapshot = await document.get();
      final data = snapshot.data();
      List<dynamic> playlist = [];

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('playlist')) {
          playlist = List.from(data['playlist']);
        }
      }

      if (index != -1) {
        playlist[index] = ({
          'movieId': movieId,
          'movieName': movieName,
          'posterPath': posterPath,
        });
      }

      await document.update({'playlist': playlist});
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> deleteItemPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/personalPlaylist/${auth.user!.uid}');
    try {
      final DocumentSnapshot snapshot = await document.get();
      final data = snapshot.data();
      List<dynamic> playlist = [];

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('playlist')) {
          playlist = List.from(data['playlist']);
        }
      }

      if (index != -1) {
        playlist.removeAt(index);
      }

      await document.update({'playlist': playlist});
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<bool> isFavorite(String movieId) async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/favorites/${auth.user!.uid}');

    final DocumentSnapshot snapshot = await document.get();
    final data = snapshot.data();
    List<dynamic> favorites = [];

    if (data != null && data is Map<String, dynamic>) {
      favorites = data['favorites'];
    }

    final isFavorited =
        favorites.firstWhere((movie) => movie == movieId, orElse: () => false);

    if (isFavorited == false) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> toggleFavorites(String movieId) async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/favorites/${auth.user!.uid}');

    try {
      final DocumentSnapshot snapshot = await document.get();
      final data = snapshot.data();
      List<dynamic> favorites = [];

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('favorites')) {
          favorites = List.from(data['favorites']);
        }
      }

      if (!favorites.contains(movieId)) {
        favorites.add(movieId);
      } else {
        favorites.remove(movieId);
      }

      await document.set({'favorites': favorites}, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<List<dynamic>> getFavorites() async {
    final DocumentReference document =
        db.doc('users/${auth.user!.uid}/favorites/${auth.user!.uid}');

    final DocumentSnapshot snapshot = await document.get();
    final data = snapshot.data();
    List<dynamic> favorites = [];

    if (data != null && data is Map<String, dynamic>) {
      favorites = data['favorites'];
    }

    return favorites;
  }
}

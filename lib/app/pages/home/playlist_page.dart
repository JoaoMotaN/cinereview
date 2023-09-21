import 'package:cinereview/app/components/block_button.dart';
import 'package:cinereview/app/components/nav_bar.dart';
import 'package:cinereview/app/data/http/http_client.dart';
import 'package:cinereview/app/data/repositories/movies_repository.dart';
import 'package:cinereview/app/data/repositories/users_repository.dart';
import 'package:cinereview/app/pages/home/stores/movies_store.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  static const posterHost = 'https://image.tmdb.org/t/p/w500';
  late MoviesStore store;
  int reload = 0;
  final movieNameEC = TextEditingController();

  @override
  void initState() {
    super.initState();

    store = MoviesStore(
      repository: MoviesRepository(
        client: HttpClient(),
      ),
      usersRepository: UsersRepository(
        auth: Provider.of<AuthService>(context, listen: false),
      ),
    );
    store.getPersonalPlaylist();
  }

  navigateBack() {
    Navigator.pushNamed(context, '/home');
  }

  void reloadPage() {
    setState(() {
      reload++;
    });
  }

  Future<void> updatePersonalPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    await UsersRepository(
      auth: context.read<AuthService>(),
    ).updatePersonalPlaylist(index, movieId, movieName, posterPath);
  }

  Future<void> deleteItemPlaylist(
    int index,
    String movieId,
    String movieName,
    String posterPath,
  ) async {
    await UsersRepository(
      auth: context.read<AuthService>(),
    ).deleteItemPlaylist(
      index,
      movieId,
      movieName,
      posterPath,
    );
  }

  void showSnackBar(String message, bool erro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: erro ? ProjectColors.pink : Colors.green[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
          [
            store.isLoading,
            store.myPlaylist,
            store.error,
          ],
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

          if (store.myPlaylist.value.isEmpty) {
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
                      const Text('Minha Playlist', style: ProjectText.tittle),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: store.myPlaylist.value.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.network(
                            posterHost +
                                store.myPlaylist.value[index]["posterPath"]!,
                          ),
                          title: Text(
                            store.myPlaylist.value[index]["movieName"] ?? "",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Atualizar título do filme',
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              maxLength: 500,
                                              maxLines: 3,
                                              controller: movieNameEC
                                                ..text = store.myPlaylist
                                                    .value[index]["movieName"]!,
                                              cursorColor: ProjectColors.orange,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white
                                                    .withOpacity(0.01),
                                                labelText: 'Título do filme',
                                                labelStyle: const TextStyle(
                                                    color: ProjectColors
                                                        .lightGray),
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.never,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: const BorderSide(
                                                    color: ProjectColors.orange,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 16.0,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16.0,
                                            ),
                                            BlockButton(
                                              label: 'Editar título',
                                              onPressed: () async {
                                                await updatePersonalPlaylist(
                                                  index,
                                                  store.myPlaylist.value[index]
                                                      ["movieId"]!,
                                                  movieNameEC.text.trim(),
                                                  store.myPlaylist.value[index]
                                                      ["posterPath"]!,
                                                );
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                }
                                                showSnackBar(
                                                    'Filme atualizado com sucesso!',
                                                    false);
                                                await store
                                                    .getPersonalPlaylist();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.orange.shade100,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  store.isLoading.value = true;
                                  await deleteItemPlaylist(
                                    index,
                                    store.myPlaylist.value[index]["movieId"]!,
                                    store.myPlaylist.value[index]["movieName"]!,
                                    store.myPlaylist.value[index]
                                        ["posterPath"]!,
                                  );
                                  store.isLoading.value = false;
                                  await Future.delayed(Duration.zero);
                                  setState(() {});
                                  showSnackBar('Filme removido!', true);
                                  await store.getPersonalPlaylist();
                                },
                                icon: Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ],
                          ),
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
      bottomNavigationBar: NavBar(context, 1),
    );
  }
}

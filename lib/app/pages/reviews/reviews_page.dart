import 'package:cinereview/app/components/block_button.dart';
import 'package:cinereview/app/components/custom_outlined_button.dart';
import 'package:cinereview/app/components/nav_bar.dart';
import 'package:cinereview/app/components/review_card.dart';
import 'package:cinereview/app/data/repositories/reviews_repository.dart';
import 'package:cinereview/app/pages/reviews/store/reviews_store.dart';
import 'package:cinereview/app/services/auth_service.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:cinereview/app/styles/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late ReviewsStore store;

  @override
  @override
  void initState() {
    super.initState();

    store = ReviewsStore(
      ReviewsRepository(
        auth: Provider.of<AuthService>(context, listen: false),
      ),
    );

    store.getReviews();
  }

  final reviewEC = TextEditingController();
  double sliderValue = 0.0;

  navigateBack() {
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProjectColors.background,
      body: AnimatedBuilder(
          animation: Listenable.merge(
            [store.isLoading, store.userReviews, store.error],
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

            if (store.userReviews.value.isEmpty) {
              return const Center(
                child: Text(
                  'Você ainda não adicionou reviews',
                  style: ProjectText.bold,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 64, left: 24, right: 24),
                child: SingleChildScrollView(
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
                          const Text('Meus reviews', style: ProjectText.tittle),
                        ],
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 20),
                        shrinkWrap: true,
                        itemCount: store.userReviews.value.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Stack(
                                children: [
                                  ReviewCard(
                                    review: store.userReviews.value[index],
                                    showMovieTitle: true,
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    top: -15.0,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                return StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Editar Review'),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              PhosphorIcons
                                                                  .star_fill,
                                                              color: Colors
                                                                  .amber[600],
                                                            ),
                                                            Container(width: 8),
                                                            Text(
                                                              sliderValue
                                                                  .toStringAsFixed(
                                                                      1),
                                                              style: ProjectText
                                                                  .tittle,
                                                            ),
                                                          ],
                                                        ),
                                                        Slider(
                                                          activeColor:
                                                              ProjectColors
                                                                  .orange,
                                                          value: sliderValue,
                                                          min: 0,
                                                          max: 10,
                                                          divisions: 100,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              sliderValue =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                        TextField(
                                                          maxLength: 500,
                                                          maxLines: 3,
                                                          controller: reviewEC
                                                            ..text = store
                                                                .userReviews
                                                                .value[index]
                                                                .review,
                                                          cursorColor:
                                                              ProjectColors
                                                                  .orange,
                                                          decoration:
                                                              InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors
                                                                .white
                                                                .withOpacity(
                                                                    0.01),
                                                            labelText:
                                                                'Digite o seu review...',
                                                            labelStyle: const TextStyle(
                                                                color: ProjectColors
                                                                    .lightGray),
                                                            floatingLabelBehavior:
                                                                FloatingLabelBehavior
                                                                    .never,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color:
                                                                    ProjectColors
                                                                        .orange,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 20.0,
                                                              horizontal: 16.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(height: 16),
                                                        BlockButton(
                                                          label:
                                                              'Editar Review',
                                                          onPressed: () async {
                                                            await store
                                                                .editReview(
                                                              store
                                                                  .userReviews
                                                                  .value[index]
                                                                  .reviewerId,
                                                              store
                                                                  .userReviews
                                                                  .value[index]
                                                                  .movieId,
                                                              store
                                                                  .userReviews
                                                                  .value[index]
                                                                  .movieTitle,
                                                              store
                                                                  .userReviews
                                                                  .value[index]
                                                                  .reviewerName,
                                                              sliderValue,
                                                              reviewEC.text
                                                                  .trim(),
                                                              index,
                                                            );
                                                            if (mounted) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                            await store
                                                                .getReviews();
                                                          },
                                                        ),
                                                        Container(height: 16),
                                                        CustomOutlinedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          label: 'Cancelar',
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                });
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.deepOrange.shade100,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            await store.deleteReview(
                                              store.userReviews.value[index]
                                                  .reviewerId,
                                              index,
                                            );
                                            await store.getReviews();
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(height: 16)
                            ],
                          );
                        },
                      ),
                      Container(height: 32)
                    ],
                  ),
                ),
              );
            }
          }),
      bottomNavigationBar: NavBar(context, 3),
    );
  }
}

import 'package:cinereview/app/components/gradient_icons.dart';
import 'package:cinereview/app/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class NavBar extends StatelessWidget {
  final BuildContext _context;
  final int selectedIndex;

  const NavBar(this._context, this.selectedIndex, {super.key});

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        {
          Navigator.pushNamed(_context, '/home');
        }
      case 1:
        {
          Navigator.pushNamed(_context, '/playlist');
        }
      case 2:
        {
          Navigator.pushNamed(_context, '/favorites');
        }
      case 3:
        {
          Navigator.pushNamed(_context, '/reviews');
        }
      case 4:
        {
          Navigator.pushNamed(_context, '/account');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.02),
        indicatorColor: Colors.transparent,
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => handleNavigation(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(
              PhosphorIcons.house,
              color: Colors.white,
            ),
            label: 'Home',
            selectedIcon: GradientIcon(
                PhosphorIcons.house_fill, 24, ProjectColors.primaryGradient),
          ),
          NavigationDestination(
            icon: Icon(
              PhosphorIcons.playlist,
              color: Colors.white,
            ),
            label: 'Playlist',
            selectedIcon: GradientIcon(
                PhosphorIcons.house_fill, 24, ProjectColors.primaryGradient),
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.heart),
            label: 'Favoritos',
            selectedIcon: GradientIcon(
              PhosphorIcons.heart_fill,
              24,
              ProjectColors.primaryGradient,
            ),
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.article),
            label: 'Reviews',
            selectedIcon: GradientIcon(
              PhosphorIcons.article_fill,
              24,
              ProjectColors.primaryGradient,
            ),
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user),
            label: 'Conta',
            selectedIcon: GradientIcon(
              PhosphorIcons.user_fill,
              24,
              ProjectColors.primaryGradient,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flexpath/gradient_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'global_menu.dart';
import 'sidebar_menu.dart';
import 'main.dart'; // Import main.dart to access FlexPathApp.logout

/// A global scaffold widget that provides a consistent layout for various screens
/// including a sidebar menu and a global floating action button menu.
class GlobalScaffold extends StatelessWidget {
  final Widget child;
  final String route;

  const GlobalScaffold({
    super.key,
    required this.child,
    required this.route,
  });

  /// Navigates to a specified screen.
  /// This method is passed down to the SidebarMenu and GlobalMenu.
  void _navigateToScreen(BuildContext context, String targetRoute, {Object? arguments}) {
    // Check if the current route is already the target route to prevent stacking identical screens
    if (ModalRoute.of(context)?.settings.name != targetRoute) {
      Navigator.pushReplacementNamed(context, targetRoute, arguments: arguments);
    } else {
      // If already on the same route, do nothing to avoid redundant navigation
      // print('Already on route: $targetRoute'); // Removed print
    }
  }

  /// Handles user logout.
  /// This method is passed down to the SidebarMenu and GlobalMenu.
  Future<void> _logout(BuildContext context) async {
    await FlexPathApp.logout(context); // Call the static logout method from main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Stack(
          children: [
            /// The main content of the screen
            child,
            /// Global menu floating action button
            GlobalMenu(
              navigateToScreen: (route, {arguments}) => _navigateToScreen(context, route, arguments: arguments),
              logout: () => _logout(context),
              heroTag: 'globalScaffoldGlobalMenuFab',
            ),
            // Menu button to open the sidebar
            Positioned(
              top: 10,
              left: 10,
              child: FadeInLeft(
                duration: const Duration(milliseconds: 800),
                child: Builder(
                  builder: (context) => IconButton(
                    icon: FaIcon(FontAwesomeIcons.bars, color: Theme.of(context).primaryColor, size: 30),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Open Menu',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: SidebarMenu(
        navigateToScreen: (route) => _navigateToScreen(context, route),
        logout: () => _logout(context),
      ),
    );
  }
}
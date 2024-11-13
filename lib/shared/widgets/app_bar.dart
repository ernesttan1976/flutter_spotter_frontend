// lib/shared/widgets/app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/features/auth/providers/auth_provider.dart';
import 'package:spotter/config/routes.dart';

class SpotterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  
  const SpotterAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) async {
            if (value == 'logout') {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Optional: Create a Drawer widget to go with the AppBar
class SpotterDrawer extends StatelessWidget {
  const SpotterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'SPOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Drone Reporting System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_a_photo),
            title: const Text('Add Report'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, Routes.addReport);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('View Reports'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, Routes.viewReports);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
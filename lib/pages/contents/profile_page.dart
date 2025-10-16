import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/controller/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ProfileController>(
        context,
        listen: false,
      ).loadUserProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        controller.userImageUrl != null &&
                            controller.userImageUrl!.isNotEmpty
                        ? NetworkImage(controller.userImageUrl!)
                        : null,
                    child:
                        (controller.userImageUrl == null ||
                            controller.userImageUrl!.isEmpty)
                        ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.fullName ?? 'Tanpa Nama',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.email ?? '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 30,
                    ),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.blue),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => controller.editProfile(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.deepPurple,
                          ),
                          title: const Text('Settings'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => controller.openSettings(context),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: const Text('Logout'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _showLogOutConfirmation(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  void _showLogOutConfirmation(BuildContext context) {
    final controller = Provider.of<ProfileController>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi logout"),
        content: Text(
          "Apakah Anda yakin ingin logout?",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text("Logout"),
            onPressed: () async {
              Navigator.pop(context);
              await controller.logout(context);
            },
          ),
        ],
      ),
    );
  }
}

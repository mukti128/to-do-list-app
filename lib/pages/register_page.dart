import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/controller/auth_controller.dart';
import 'package:to_do_list/pages/login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    String? validatePassword(String value) {
      if (value.isEmpty) return "Password harus diisi";
      if (value.length < 8) return "Password minimal 8 karakter";
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return "Password harus mengandung huruf besar";
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return "Password harus mengandung huruf kecil";
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return "Password harus mengandung angka";
      }
      return null;
    }

    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Registrasi")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: "Nama Lengkap"),
                      validator: (value) =>
                          value!.isEmpty ? "Nama lengkap harus diisi" : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email harus diisi";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Format email tidak valid";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      validator: (value) => validatePassword(value ?? ""),
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                          labelText: "Konfirmasi Password"),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Konfirmasi password harus diisi";
                        }
                        if (value != passwordController.text) {
                          return "Password dan konfirmasi tidak sama";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Tombol Daftar
                    controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              bool success = await controller.register(
                                fullName: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Registrasi berhasil! Silakan login.",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      controller.errorMessage ??
                                          "Terjadi kesalahan",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text("Daftar"),
                          ),

                    /// Link ke Login Page
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Sudah punya akun? Login"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

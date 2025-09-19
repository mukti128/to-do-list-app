import 'package:flutter/material.dart';
import 'package:to_do_list/controller/auth_service.dart';
import 'package:to_do_list/page/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  String? _validatePassword(String value) {
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    String? error = await _authService.register(
      fullName: _nameController.text.trim(),
      email: _emailcontroller.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi berhasil! Silakan login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator: (value) => value!.isEmpty ? "Nama lengkap harus diisi" : null,
              ),
              TextFormField(
                controller: _emailcontroller,
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => _validatePassword(value ?? ""),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: "Konfirmasi Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Konfirmasi password harus diisi";
                  }
                  if (value != _passwordController.text) {
                    return "Password dan konfirmasi tidak sama";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _register,
                    child: const Text("Daftar"),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
